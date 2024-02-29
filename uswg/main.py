from flask import Flask, request, make_response, jsonify, render_template, redirect, url_for
import jwt
import datetime
from functools import wraps
from dotenv import load_dotenv
import os
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
import options as op
import errortext as err
import functions as f
import subprocess

load_dotenv()
app = Flask(__name__)





app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite://///home/ati/Desktop/uswg/uswg.db'


db = SQLAlchemy(app)
app.app_context().push()

class Users(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    public_id = db.Column(db.String(50), unique=True, nullable=False)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)


def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        token = None
        
        if 'x-access-token' in request.cookies:
            token = request.cookies.get('x-access-token')

        if not token:
            return jsonify({'message' : 'Token is missing'}), 401

        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user = Users.query.filter_by(public_id=data['public_id']).first()
            
        except:
            return jsonify({'message' : 'Token is invalid'}), 401

        return f(current_user, *args, **kwargs)

    return decorated


@app.route('/login')
def login():
    auth = request.authorization

    if not auth or not auth.username or not auth.password:
        return make_response('Could not verify!', 401, {'WWW-Authenticate' : 'Basic realm="Login Required!"'})

    user = Users.query.filter_by(username=auth.username).first()

    if not user:
        return make_response('Could not verify!', 401, {'WWW-Authenticate' : 'Basic realm="Login Required!"'})



    if check_password_hash(user.password, auth.password):
        token = jwt.encode({'public_id' : user.public_id, 'exp' : datetime.datetime.now() + datetime.timedelta(minutes=45)}, app.config['SECRET_KEY'], "HS256")
        response = make_response('Hello World')
        response.set_cookie('x-access-token', token)
        return response


    return make_response('Could not verify!', 401, {'WWW-Authenticate' : 'Basic realm="Login Required!"'})



@app.route("/dhcp")
@token_required
def dhcp(current_user):
    
    status = f.dhcp_status()
    adapterarray = f.list_all_network_adapter()
    
    configarray = f.dhcp_list_all_subnet()
    staticarray = f.dhcp_list_all_static_host()
    globalconfarray = f.dhcp_check_global_config()
    if isinstance(configarray, int) or isinstance(staticarray, int) or isinstance(globalconfarray, int):
        return render_template('dhcp/dhcp.html', status=status, adapterarray=adapterarray)

    lastbackupdate = f.dhcp_check_backup()
    return render_template('dhcp/dhcp.html', status=status, configarray=configarray, staticarray=staticarray, globalconfarray=globalconfarray, lastbackupdate=lastbackupdate, adapterarray=adapterarray)



@app.route("/service/add", methods=['POST'])
@token_required
def service_add(current_user):
    text = ""
    id = request.form.get('form_id')
    if id == "subnet":
        subnetname = str(request.form.get('subnet-name'))
        dnsserver = str(request.form.get('dns-server-name'))
        broadcast = str(request.form.get('broadcast-address'))
        routers = str(request.form.get('routers'))
        subnetmask = str(request.form.get('subnet-mask'))
        dlt = str(request.form.get('default-lease-time'))
        mlt = str(request.form.get('max-lease-time'))
        subnetadd = str(request.form.get('subnet-address'))
        startadd = str(request.form.get('start-address'))
        lastadd = str(request.form.get('last-address'))
        networkadapter = str(request.form.get('network-adapter'))
        ntp = str(request.form.get('ntp-server'))
        domainname = str(request.form.get('domain-name'))

        number = f.dhcp_create_subnet(subnetname, subnetadd, subnetmask, startadd, lastadd, dnsserver, routers, broadcast, dlt, mlt, networkadapter, ntp, domainname)

        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.dhcp_create_network_adapter(networkadapter)

        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.dhcp_merge_config()
        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)


        return redirect(url_for('dhcp'))



    if id == "static-host":
        name = str(request.form.get('static-host-name'))
        ip = str(request.form.get('static-host-address'))
        mac = str(request.form.get('static-host-mac'))

        number = f.dhcp_create_static_host(name, mac, ip)

        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.dhcp_merge_config()
        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for('dhcp'))

    if id == "backup":
        if 'create-backup-button' in request.form:
            number = f.dhcp_create_backup()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            return redirect(url_for('dhcp'))

        if 'restore-backup-button' in request.form:
            number = f.dhcp_restore_backup()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            return redirect(url_for('dhcp'))
        

    return render_template('shared/error.html', text=text)

@app.route("/service/modify", methods=['POST'])
@token_required
def service_modify(current_user):
    text = ""
    id = request.form.get('form_id')
    if id == "subnet-check":
        if 'modify-subnet-button' in request.form:
            subnetname = str(request.form.get('modify-subnet-button'))
            
            configarray = f.dhcp_check_subnet(subnetname)

            if isinstance(configarray, list):
                
                adapterarray = f.list_all_network_adapter()
                return render_template('dhcp/subnet_modify.html', configarray=configarray, adapterarray=adapterarray)
            
            else:
                number = configarray
                text = err.error(number)
                return render_template('shared/error.html', text=text)
                

        if 'delete-subnet-button' in request.form:
            subnetname = str(request.form.get('delete-subnet-button'))
            
            configarray = f.dhcp_check_subnet(subnetname)
            if isinstance(configarray, int):
                number = configarray
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            oldadapter = configarray[12]
          
            configarray = f.dhcp_list_all_subnet()
            if isinstance(configarray, int):
                number = configarray
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            counter = 0
            for i in range(10, len(configarray), 13):
                if oldadapter == configarray[i]:
                    counter = counter + 1
            
            if counter == 1 :
                    
                number = f.dhcp_delete_network_adapter(oldadapter)
                    
                if number != 0:
                    text = err.error(number)
                    return render_template('shared/error.html', text=text)
                
            configarray = f.dhcp_check_subnet(subnetname)

            number = f.dhcp_delete_subnet(configarray[0])
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            number = f.dhcp_merge_config()
            if number != 0 :
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            return redirect(url_for('dhcp'))


    if id == "subnet-modify":
        subnetname = str(request.form.get('subnet-name'))
        dnsserver = str(request.form.get('dns-server-name'))
        broadcast = str(request.form.get('broadcast-address'))
        routers = str(request.form.get('routers'))
        subnetmask = str(request.form.get('subnet-mask'))
        dlt = str(request.form.get('default-lease-time'))
        mlt = str(request.form.get('max-lease-time'))
        subnetadd = str(request.form.get('subnet-address'))
        startadd = str(request.form.get('start-address'))
        lastadd = str(request.form.get('last-address'))
        networkadapter = str(request.form.get('network-adapter'))
        ntp = str(request.form.get('ntp-server'))
        domainname = str(request.form.get('domain-name'))

        buttonname = str("modify_subnet_" + subnetname + "_Button")
        

        configarray = f.dhcp_check_subnet(buttonname)
        if isinstance(configarray, int):
            number = configarray
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        oldadapter = configarray[12]

        
        if networkadapter != str(oldadapter) :

            configarray = f.dhcp_list_all_subnet()

            if isinstance(configarray, int):
                number = configarray
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            counter = 0
            for i in range(10, len(configarray), 13):
                if oldadapter == configarray[i]:
                    counter = counter + 1
            
            if counter == 1 :
                
                number = f.dhcp_delete_network_adapter(oldadapter)

                if number != 0:
                    text = err.error(number)
                    return render_template('shared/error.html', text=text)
            
        number = f.dhcp_delete_subnet(subnetname)
        
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)


            
        number = f.dhcp_create_subnet(subnetname, subnetadd, subnetmask, startadd, lastadd, dnsserver, routers, broadcast, dlt, mlt, networkadapter, ntp, domainname)
        
        if number == 0 :
    
            number = f.dhcp_create_network_adapter(networkadapter)

            if number != 0 :
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            else:
                number = f.dhcp_merge_config()
                if number != 0 :
                    text = err.error(number)
                    return render_template('shared/error.html', text=text)

                return redirect(url_for('dhcp'))
        else:
            text = err.error(number)
            return render_template('shared/error.html', text=text)


    if id == "dhcp-global-modify":
        author = str(request.form.get('authoritative'))
        ddns = str(request.form.get('ddns-update-style'))

        number = f.dhcp_create_global_config(author, ddns)
        if number != 0 :
                text = err.error(number)
                return render_template('shared/error.html', text=text)
        
        number = f.dhcp_merge_config()
        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for('dhcp'))

    if id == "static-host-check":
        if 'modify-static-host-button' in request.form:
            
            name = str(request.form.get('modify-static-host-button'))
            
            configarray = f.dhcp_check_static_host(name)
            if isinstance(configarray, int):
                number = configarray
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            return render_template('dhcp/static_host_modify.html', configarray=configarray)
        
        
        if 'delete-static-host-button' in request.form:
            name = str(request.form.get('delete-static-host-button'))

            configarray = f.dhcp_check_static_host(name)
            if isinstance(configarray, int):
                number = configarray
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            number = f.dhcp_delete_static_host(configarray[0])
            if number != 0 :
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            number = f.dhcp_merge_config()
            if number != 0 :
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            return redirect(url_for('dhcp'))


    if id == "static-host-modify":
        name = str(request.form.get('static-host-name'))
        ip = str(request.form.get('static-host-address'))
        mac = str(request.form.get('static-host-mac'))

        number = f.dhcp_delete_static_host(name)
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        
        number = f.dhcp_create_static_host(name, mac, ip)
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.dhcp_merge_config()
        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)


        return redirect(url_for('dhcp'))

    return render_template('shared/error.html', text=text)

@app.route("/service/install", methods=['POST'])
@token_required
def service_install(current_user):
    text = ""
    id = request.form.get('form_id')
    if id == "dhcp":
        subnetname = str(request.form.get('subnet-name'))
        author = str(request.form.get('authoritative'))
        ddns = str(request.form.get('ddns-update-style'))
        dnsserver = str(request.form.get('dns-server-name'))
        broadcast = str(request.form.get('broadcast-address'))
        routers = str(request.form.get('routers'))
        subnetmask = str(request.form.get('subnet-mask'))
        dlt = str(request.form.get('default-lease-time'))
        mlt = str(request.form.get('max-lease-time'))
        subnetadd = str(request.form.get('subnet-address'))
        startadd = str(request.form.get('start-address'))
        lastadd = str(request.form.get('last-address'))
        networkadapter = str(request.form.get('network-adapter'))
        ntp = str(request.form.get('ntp-server'))
        domainname = str(request.form.get('domain-name'))
        
        service = "isc-dhcp-server"
        number = f.service_install(service)
        
        if number == 0 :
   
            number = f.dhcp_create_global_config(author, ddns)
            if number != 0:
                f.service_remove(service)
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            number = f.dhcp_create_subnet(subnetname, subnetadd, subnetmask, startadd, lastadd, dnsserver, routers, broadcast, dlt, mlt, networkadapter, ntp, domainname)
            
            if number != 0:
                f.service_remove(service)
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            number = f.dhcp_create_network_adapter(networkadapter)

            if number != 0 :
                f.service_remove(service)
                text = err.error(number)
                return render_template('shared/error.html', text=text)


            service = "isc-dhcp-server"
            action = "restart"
            f.service_startstop(service, action)

        else:
            text = "Sikertelen telepítés!"
            return render_template('shared/error.html', text=text)
        
        number = f.dhcp_merge_config()
        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)


        return redirect(url_for('dhcp'))

    return render_template('shared/error.html', text=text)

@app.route("/service/remove", methods=['POST'])
@token_required
def service_remove(current_user):
    id = request.form.get('form_id')
    if id == "dhcp":
        service = "isc-dhcp-server"
        number = f.service_remove(service)
        
        
        if number == 0:
            return redirect(url_for('dhcp'))
        else:
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for('dhcp'))

    return render_template('shared/error.html')


@app.route("/service/status", methods=['POST'])
@token_required
def service_status(current_user):
    id = request.form.get('form_id')
    text=""
    if id == "dhcp":
        action = str(request.form.get('startstop'))
        service = "isc-dhcp-server"
        number = f.service_startstop(service, action)

        if number == 0:
            return redirect(url_for('dhcp'))
        else:
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        
        

    return render_template('shared/error.html', text=text)

if __name__ == "__main__":
    app.run()


