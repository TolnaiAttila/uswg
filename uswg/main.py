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
            #jsonify({'message' : 'Token is missing'}),
            return render_template('shared/relogin.html'), 401

        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user = Users.query.filter_by(public_id=data['public_id']).first()
            
        except:
            return render_template('shared/relogin.html'), 401
            #return jsonify({'message' : 'Token is invalid'}), 401

        return f(current_user, *args, **kwargs)

    return decorated


@app.route('/login')
def login():
    err_text = request.args.get('text')
    return render_template('shared/login.html', err_text = err_text)

@app.route('/login/check', methods=['POST'])
def login_check():
    #auth = request.authorization
    passwd = None
    uname = None
    passwd = str(request.form.get('passwd'))
    uname = str(request.form.get('username'))

    if passwd == None or uname == None:
        text = "Sikertelen bejelentkezés"
        return redirect(url_for('login', text=text))

    #if not auth or not auth.username or not auth.password:
     #   return make_response('Sikertelen bejelentkezés!', 401, {'WWW-Authenticate' : 'Basic realm="Login Required!"'})

    user = Users.query.filter_by(username=uname).first()

    if not user:
        text = "Sikertelen bejelentkezés"
        return redirect(url_for('login', text=text))
        #return make_response('Sikertelen bejelentkezés!', 401, {'WWW-Authenticate' : 'Basic realm="Login Required!"'})



    if check_password_hash(user.password, passwd):
        exp_time = datetime.datetime.now() + datetime.timedelta(minutes=60)
        exp_timestamp = int(exp_time.timestamp())
        token = jwt.encode({'public_id' : user.public_id, 'exp' : exp_timestamp}, app.config['SECRET_KEY'], "HS256")
        template = render_template('shared/index.html')
        response = make_response(template)
        response.set_cookie('x-access-token', token)
        return response

    text = "Sikertelen bejelentkezés"
    return redirect(url_for('login', text=text))

    #return make_response('Could not verify!', 401, {'WWW-Authenticate' : 'Basic realm="Login Required!"'})

@app.route("/dhcp")
@token_required
def dhcp(current_user):
    service = "isc-dhcp-server"
    status = f.status(service)
    adapterarray = f.list_all_network_adapter()
    
    configarray = f.dhcp_list_all_subnet()
    staticarray = f.dhcp_list_all_static_host()
    globalconfarray = f.dhcp_check_global_config()
    if isinstance(configarray, int) or isinstance(staticarray, int) or isinstance(globalconfarray, int):
        return render_template('dhcp/dhcp.html', status=status, adapterarray=adapterarray)

    lastbackupdate = f.dhcp_check_backup()
    return render_template('dhcp/dhcp.html', status=status, configarray=configarray, staticarray=staticarray, globalconfarray=globalconfarray, lastbackupdate=lastbackupdate, adapterarray=adapterarray)


@app.route("/dns")
@token_required
def dns(current_user):
    service = "named"
    status = f.status(service)

    listenon = f.dns_check_listenon()

    if isinstance(listenon, int):
        number = listenon
        text = err.error(number)
        return render_template('shared/error.html', text=text)
    


    return render_template('dns/dns.html', status=status, listenon=listenon)



@app.route("/nfs")
@token_required
def nfs(current_user):
    service = "nfs-server"
    status =f.status(service)
    
    configarray = f.nfs_check_configuration()
    spanarray = f.nfs_check_rowspan()
    sharearray = f.nfs_list_all_name() 
    if isinstance(configarray, int) or isinstance(spanarray, int) or isinstance(sharearray, int):
        return render_template('nfs/nfs.html', status=status)
    
    return render_template('nfs/nfs.html', status=status, configarray=configarray, spanarray=spanarray, sharearray=sharearray)





@app.route("/samba")
@token_required
def samba(current_user):
    service = "smbd"
    status = f.status(service)
    globalconfig = f.samba_check_global_config()
    nobodyconfig = f.samba_check_all_nobody_share()
    singleconfig = f.samba_check_all_single_user_share()
    groupconfig = f.samba_check_all_group_share()


    numbers = [0, 0, 0, 0]
    
    if isinstance(globalconfig, int):
        numbers[0] = 1
    if isinstance(nobodyconfig, int):
        numbers[1] = 1
    if isinstance(singleconfig, int):
        numbers[2] = 1
    if isinstance(groupconfig, int):
        numbers[3] = 1
    

    number = ""
    for i in numbers:
        number = (number + str(i))
   

    if number == "0000":
        return render_template('samba/samba.html', status=status, globalconfig=globalconfig, nobodyconfig=nobodyconfig, singleconfig=singleconfig, groupconfig=groupconfig)
    elif number == "0001":
        return render_template('samba/samba.html', status=status, globalconfig=globalconfig, nobodyconfig=nobodyconfig, singleconfig=singleconfig)
    elif number == "0010":
        return render_template('samba/samba.html', status=status, globalconfig=globalconfig, nobodyconfig=nobodyconfig, groupconfig=groupconfig)
    elif number == "0011":
        return render_template('samba/samba.html', status=status, globalconfig=globalconfig, nobodyconfig=nobodyconfig)
    elif number == "0100":
        return render_template('samba/samba.html', status=status, globalconfig=globalconfig, singleconfig=singleconfig, groupconfig=groupconfig)
    elif number == "0101":
        return render_template('samba/samba.html', status=status, globalconfig=globalconfig, singleconfig=singleconfig)
    elif number == "0110":
        return render_template('samba/samba.html', status=status, globalconfig=globalconfig, groupconfig=groupconfig)
    elif number == "0111":
        return render_template('samba/samba.html', status=status, globalconfig=globalconfig)
    elif number == "1000":
        return render_template('samba/samba.html', status=status, nobodyconfig=nobodyconfig, singleconfig=singleconfig, groupconfig=groupconfig)
    elif number == "1001":
        return render_template('samba/samba.html', status=status, nobodyconfig=nobodyconfig, singleconfig=singleconfig)
    elif number == "1010":
        return render_template('samba/samba.html', status=status, nobodyconfig=nobodyconfig, groupconfig=groupconfig)
    elif number == "1011":
        return render_template('samba/samba.html', status=status, nobodyconfig=nobodyconfig)
    elif number == "1100":
        return render_template('samba/samba.html', status=status, singleconfig=singleconfig, groupconfig=groupconfig)
    elif number == "1101":
        return render_template('samba/samba.html', status=status, singleconfig=singleconfig)
    elif number == "1110":
        return render_template('samba/samba.html', status=status, groupconfig=groupconfig)
    else:
        return render_template('samba/samba.html', status=status)




@app.route("/ftp")
@token_required
def ftp(current_user):
    service = "vsftpd"
    status = f.status(service)
    globalconfig = f.ftp_check_global_config()
    if isinstance(globalconfig, int):
        return render_template('ftp/ftp.html', status=status)
    
    allowedusers = f.ftp_list_allowed_users()
    if isinstance(allowedusers, int):
        return render_template('ftp/ftp.html', status=status)

    denyiedusers = f.ftp_list_denied_users()
    if isinstance(denyiedusers, int):
        return render_template('ftp/ftp.html', status=status)



    chrootusers = f.ftp_list_chroot_users()
    if isinstance(chrootusers, int):
        return render_template('ftp/ftp.html', status=status)

    return render_template('ftp/ftp.html', status=status, globalconfig=globalconfig, allowedusers=allowedusers, denyiedusers=denyiedusers, chrootusers=chrootusers)



@app.route("/ftp/users", methods=['POST'])
@token_required
def ftp_users(current_user):
    passwdlessusers = f.ftp_list_passwdless_users()
    if isinstance(passwdlessusers, int):
        number = passwdlessusers
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)

    return render_template('ftp/ftp_users.html', passwdlessusers=passwdlessusers)


@app.route("/samba/groups", methods=['GET', 'POST'])
@token_required
def samba_groups(current_user):
    
    grouparray = f.samba_list_all_samba_group()
    if isinstance(grouparray, int):
        number = grouparray
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)

    usersarray = f.samba_list_samba_users()
    if isinstance(usersarray, int):
        number = usersarray
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)

    return render_template('samba/samba_groups.html', grouparray=grouparray, usersarray=usersarray, code=307)


@app.route("/samba/users", methods=['POST'])
@token_required
def samba_users(current_user):
    #if id == "samba-users-check":
    sysusers = f.samba_list_leftover_system_users()
    sambausers = f.samba_list_samba_users()

    if isinstance(sysusers, int):
        number = sysusers
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
    if isinstance(sambausers, int):
        number = sambausers
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)


    return render_template('samba/users_modify.html', sysusers=sysusers, sambausers=sambausers)



@app.route("/adapter")
@token_required
def adapter(current_user):
    adapterarray = f.list_all_network_adapter()
    allowed = f.adapter_status()
    adaptersconf = f.adapter_check_all_adapter()
    hostname = f.adapter_hostname()
    
    if isinstance(adaptersconf, int):
        return render_template('adapter/adapter.html', allowed=allowed, adapterarray=adapterarray, hostname=hostname)
    return render_template('adapter/adapter.html', allowed=allowed, adapterarray=adapterarray, adaptersconf=adaptersconf, hostname=hostname)



@app.route("/ssh")
@token_required
def ssh(current_user):
    service = "ssh"
    status = f.status(service)
    startup = f.ssh_startup_status()
    iplist = f.ssh_list_ip_address()
    selectedport = f.ssh_selected_port()
    selectedip = f.ssh_selected_ip_address()

    return render_template('ssh/ssh.html', status=status, startup=startup, iplist=iplist, selectedport=selectedport, selectedip=selectedip)


@app.route("/ufw")
@token_required
def ufw(current_user):
    return render_template('ufw/ufw.html')



@app.route("/help")
@token_required
def help(current_user):
    return render_template('help/help.html')


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
        
    if id == "listen-on":

        ip = str(request.form.get("listen-on-ip"))
        port = str(request.form.get("listen-on-port"))

        number = f.dns_create_listenon(ip, port)

        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('dns'))

    if id == "nfs-share":
        name = str(request.form.get('share-name'))
        directory= str(request.form.get('share-dir'))
        dirperm = str(request.form.get('dirperm'))
        access = str(request.form.get('access'))
        permission = str(request.form.get('permission'))
        sync = str(request.form.get('sync'))
        squash = str(request.form.get('squash'))
        subtree = str(request.form.get('subtree'))

        number = f.nfs_create_share(name, directory, dirperm, access, permission, sync, subtree, squash)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.nfs_merge()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('nfs'))



    if id == "nfs-access":
        name = str(request.form.get('share-name'))
        access = str(request.form.get('access'))
        permission = str(request.form.get('permission'))
        sync = str(request.form.get('sync'))
        squash = str(request.form.get('squash'))
        subtree = str(request.form.get('subtree'))

        number = f.nfs_add_access(name, access, permission, sync, subtree, squash)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.nfs_merge()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('nfs'))


    if id == "add-samba-user":
        user = str(request.form.get('username'))
        passwd1 = str(request.form.get('password1'))
        passwd2 = str(request.form.get('password2'))
        
        number = f.samba_add_samba_user(user, passwd1, passwd2)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for('samba_users'), code=307)



    if id == "add-system-user":
        user = str(request.form.get('system-user'))

        number = f.samba_add_system_user(user)
        
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('samba_users'), code=307)


    if id == "samba-nobody-share-redirect":
        userarray = f.samba_list_all_users()
        if isinstance(userarray, int):
            number = userarray
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        grouparray = f.samba_list_all_system_groups()
        if isinstance(grouparray, int):
            number = grouparray
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        return render_template('samba/add_nobody_share.html', userarray=userarray, grouparray=grouparray)


    if id == "samba-add-nobody-share":
        sharename = str(request.form.get('share-name'))
        sharepath = str(request.form.get('share-path'))
        dirperm = str(request.form.get('dir-perm'))
        owneru = str(request.form.get('owner-user'))
        ownerg = str(request.form.get('owner-group'))
        comment = str(request.form.get('comment'))
        readonly = str(request.form.get('read-only'))
        writable = str(request.form.get('writable'))
        guestok = str(request.form.get('guest-ok'))
        guestonly = str(request.form.get('guest-only'))
        browsable = str(request.form.get('browsable'))
        public = str(request.form.get('public'))
        createmask = str(request.form.get('create-mask'))
        dirmask = str(request.form.get('directory-mask'))
        forceuser = str(request.form.get('force-user'))
        forcegroup = str(request.form.get('force-group'))
        dotfiles = str(request.form.get('hide-dot-files'))

        number = f.samba_add_nobody_share(sharename, sharepath, dirperm, owneru, ownerg, comment, readonly, writable, guestok, guestonly, browsable, public, createmask, dirmask, forceuser, forcegroup, dotfiles)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.samba_merge_config()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for("samba"))



    if id == "samba-single-user-share-redirect":
        userarray = f.samba_list_all_users()
        if isinstance(userarray, int):
            number = userarray
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        grouparray = f.samba_list_all_system_groups()
        if isinstance(grouparray, int):
            number = grouparray
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        sambausersarray = f.samba_list_samba_users()
        if isinstance(sambausersarray, int):
            number = sambausersarray
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        return render_template('samba/add_single_user_share.html', sambausersarray=sambausersarray, userarray=userarray, grouparray=grouparray)


    if id == "samba-add-single-user-share":
        sharename = str(request.form.get('share-name'))
        sharepath = str(request.form.get('share-path'))
        dirperm = str(request.form.get('dir-perm'))
        owneru = str(request.form.get('owner-user'))
        ownerg = str(request.form.get('owner-group'))
        comment = str(request.form.get('comment'))
        validusers = str(request.form.get('valid-users'))
        readonly = str(request.form.get('read-only'))
        writable = str(request.form.get('writable'))
        guestok = str(request.form.get('guest-ok'))
        browsable = str(request.form.get('browsable'))
        public = str(request.form.get('public'))
        createmask = str(request.form.get('create-mask'))
        dirmask = str(request.form.get('directory-mask'))
        forceuser = str(request.form.get('force-user'))
        forcegroup = str(request.form.get('force-group'))
        dotfiles = str(request.form.get('hide-dot-files'))

        number = f.samba_add_singl_user_share(sharename, sharepath, dirperm, owneru, ownerg, comment, validusers, readonly, writable, guestok, browsable, public, createmask, dirmask, forceuser, forcegroup, dotfiles)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.samba_merge_config()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for("samba"))



    if id == "samba-add-group":
        
        userlist = [value for _, value in request.form.items()]
        number = f.samba_create_user_group(userlist)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.samba_merge_config()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)        
        
        return redirect(url_for('samba_groups'), code=307)


    if id == "samba-group-share-redirect":

        userarray = f.samba_list_all_users()
        if isinstance(userarray, int):
            number = userarray
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        grouparray = f.samba_list_all_system_groups()
        if isinstance(grouparray, int):
            number = grouparray
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        sambagroupsarray = f.samba_list_all_samba_group()
        if isinstance(sambagroupsarray, int):
            number = sambagroupsarray
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)

        return render_template('samba/add_group_share.html', sambagroupsarray=sambagroupsarray, userarray=userarray, grouparray=grouparray)




    if id == "samba-add-group-share":
        sharename = str(request.form.get('share-name'))
        sharepath = str(request.form.get('share-path'))
        dirperm = str(request.form.get('dir-perm'))
        owneru = str(request.form.get('owner-user'))
        ownerg = str(request.form.get('owner-group'))
        comment = str(request.form.get('comment'))
        validtype = str(request.form.get('valid-type'))
        groupname = str(request.form.get('group-name'))
        readonly = str(request.form.get('read-only'))
        writable = str(request.form.get('writable'))
        guestok = str(request.form.get('guest-ok'))
        browsable = str(request.form.get('browsable'))
        public = str(request.form.get('public'))
        createmask = str(request.form.get('create-mask'))
        dirmask = str(request.form.get('directory-mask'))
        forceuser = str(request.form.get('force-user'))
        forcegroup = str(request.form.get('force-group'))
        dotfiles = str(request.form.get('hide-dot-files'))

        number = f.samba_add_group_share(sharename, sharepath, dirperm, owneru, ownerg, comment, validtype, groupname, readonly, writable, guestok, browsable, public, createmask, dirmask, forceuser, forcegroup, dotfiles)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.samba_merge_config()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for("samba"))

    if id == "ftp-add-passwd-user":
        uname = str(request.form.get('username'))
        passwd1 = str(request.form.get('password1'))
        passwd2 = str(request.form.get('password2'))

        number = f.ftp_modify_user_passwd(uname, passwd1, passwd2)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for("ftp_users"), code=307)


    if id == "add-ftp-system-user":
        uname = str(request.form.get('system-user'))
        number = f.ftp_add_system_user(uname)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for("ftp_users"), code=307)

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


    if id == "listen-on-delete":
        button = str(request.form.get('delete-listen-on-button'))
        number = f.dns_delete_listenon(button)
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('dns'))


    if id == "nfs-share-check":
        if 'modify-nfs-share-button' in request.form:
            sharename = str(request.form.get('modify-nfs-share-button'))
            
            configarray = f.nfs_check_configuration_modify(sharename)
            if isinstance(configarray, list):
                return render_template('nfs/share_modify.html', configarray=configarray)
            
            else:
                number = configarray
                text = err.error(number)
                return render_template('shared/error.html', text=text)

        if 'delete-nfs-share-button' in request.form:
            buttoninput = str(request.form.get('delete-nfs-share-button'))
            number = f.nfs_delete_part(buttoninput)
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            number = f.nfs_merge()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            return redirect(url_for('nfs'))

        if 'delete-nfs-all-share-button' in request.form:
            part = "all"
            sharename = str(request.form.get('delete-nfs-all-share-button'))
            dirdel = str(request.form.get('dir-delete'))
            number = f.nfs_delete_all(sharename, dirdel)

            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            number = f.nfs_merge()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
                
            return redirect(url_for('nfs'))


    if id =="nfs-share-modify":
        dirdel = "no"
        
        configarray = [value for _, value in request.form.items()]
        
        
        number = f.nfs_delete_all(configarray[1], dirdel)
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.nfs_share_modify(configarray)

        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.nfs_merge()
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('nfs'))

    if id == "samba-global":
        workgroup = str(request.form.get('workgroup'))
        netbios = str(request.form.get('netbios-name'))
        mtg = str(request.form.get('map-to-guest'))
        uag = str(request.form.get('usershare-allow-guests'))
        security = str(request.form.get('security'))
        public = str(request.form.get('public'))

        number = f.samba_create_global_config(workgroup, netbios, mtg, uag, security, public)
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.samba_merge_config()
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('samba'))

    

    if id == "remove-samba-user" :
        user = str(request.form.get('remove-user-samba-button'))
        
        number = f.samba_remove_samba_user(user)

        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for('samba_users'), code=307)

    

    if id == "samba-nobody-share-check":

        if "modify-samba-share-button" in request.form:
            button = str(request.form.get('modify-samba-share-button'))
            configarray = f.samba_check_selected_nobody_share(button)
            
            if isinstance(configarray, int):
                number = configarray
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            userarray = f.samba_list_all_users()
            if isinstance(userarray, int):
                number = userarray
                text=err.error(number)
                return render_template('shared/error.html', text=text)
        
            grouparray = f.samba_list_all_system_groups()
            if isinstance(grouparray, int):
                number = grouparray
                text=err.error(number)
                return render_template('shared/error.html', text=text)

            return render_template('samba/modify_nobody_share.html', configarray=configarray, userarray=userarray, grouparray=grouparray)
            

        if "delete-samba-share-button" in request.form:
            button = str(request.form.get('delete-samba-share-button'))
            dirdel = str(request.form.get('dir-delete'))
            number = f.samba_delete_nobody_share(button, dirdel)
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            number = f.samba_merge_config()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            return redirect(url_for("samba"))


    if id == "samba-modify-nobody-share":
        sharename = str(request.form.get('share-name'))
        sharepath = str(request.form.get('share-path'))
        dirperm = str(request.form.get('dir-perm'))
        owneru = str(request.form.get('owner-user'))
        ownerg = str(request.form.get('owner-group'))
        comment = str(request.form.get('comment'))
        readonly = str(request.form.get('read-only'))
        writable = str(request.form.get('writable'))
        guestok = str(request.form.get('guest-ok'))
        guestonly = str(request.form.get('guest-only'))
        browsable = str(request.form.get('browsable'))
        public = str(request.form.get('public'))
        createmask = str(request.form.get('create-mask'))
        dirmask = str(request.form.get('directory-mask'))
        forceuser = str(request.form.get('force-user'))
        forcegroup = str(request.form.get('force-group'))
        dotfiles = str(request.form.get('hide-dot-files'))

        dirdel="no"
        
        number = f.samba_delete_nobody_share(sharename, dirdel)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.samba_add_nobody_share(sharename, sharepath, dirperm, owneru, ownerg, comment, readonly, writable, guestok, guestonly, browsable, public, createmask, dirmask, forceuser, forcegroup, dotfiles)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.samba_merge_config()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for("samba"))


    if id == "samba-single-user-share-check":
        if "delete-samba-share-button" in request.form:
            button = str(request.form.get('delete-samba-share-button'))
            dirdel = str(request.form.get('dir-delete'))

            number = f.samba_delete_single_user_share(button, dirdel)
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            number = f.samba_merge_config()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            return redirect(url_for("samba"))
        
        if "modify-samba-share-button" in request.form:
            button = str(request.form.get('modify-samba-share-button'))
            configarray = f.samba_check_selected_single_user_share(button)
            
            if isinstance(configarray, int):
                number = configarray
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            userarray = f.samba_list_all_users()
            if isinstance(userarray, int):
                number = userarray
                text=err.error(number)
                return render_template('shared/error.html', text=text)
        
            grouparray = f.samba_list_all_system_groups()
            if isinstance(grouparray, int):
                number = grouparray
                text=err.error(number)
                return render_template('shared/error.html', text=text)

            sambausersarray = f.samba_list_samba_users()
            if isinstance(sambausersarray, int):
                number = sambausersarray
                text=err.error(number)
                return render_template('shared/error.html', text=text)

            return render_template('samba/modify_single_user_share.html', sambausersarray=sambausersarray, configarray=configarray, userarray=userarray, grouparray=grouparray)

        

    if id == "samba-modify-single-user-share":
        sharename = str(request.form.get('share-name'))
        sharepath = str(request.form.get('share-path'))
        dirperm = str(request.form.get('dir-perm'))
        owneru = str(request.form.get('owner-user'))
        ownerg = str(request.form.get('owner-group'))
        comment = str(request.form.get('comment'))
        readonly = str(request.form.get('read-only'))
        writable = str(request.form.get('writable'))
        guestok = str(request.form.get('guest-ok'))
        validusers = str(request.form.get('valid-users'))
        browsable = str(request.form.get('browsable'))
        public = str(request.form.get('public'))
        createmask = str(request.form.get('create-mask'))
        dirmask = str(request.form.get('directory-mask'))
        forceuser = str(request.form.get('force-user'))
        forcegroup = str(request.form.get('force-group'))
        dotfiles = str(request.form.get('hide-dot-files'))

        dirdel="no"
        
        number = f.samba_delete_single_user_share(sharename, dirdel)

        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.samba_add_singl_user_share(sharename, sharepath, dirperm, owneru, ownerg, comment, validusers, readonly, writable, guestok, browsable, public, createmask, dirmask, forceuser, forcegroup, dotfiles)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.samba_merge_config()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for("samba"))


    if id == "samba-check-group":
        if "delete-samba-group-button" in request.form:

            button = str(request.form.get('delete-samba-group-button'))
            
            number = f.samba_delete_user_group(button)
            if number != 0:
                text=err.error(number)
                return render_template('shared/error.html', text=text)
            
            return redirect(url_for('samba_groups'), code=307)

        if "modify-samba-group-button" in request.form:
            button = str(request.form.get('modify-samba-group-button'))
            sambausers = f.samba_list_samba_users()
            groupnamearray = button.split("_")
            groupname = groupnamearray[3]
            if isinstance(sambausers, int):
                number = sambausers
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            groupusers = f.samba_list_users_in_group(button)
            if isinstance(groupusers, int):
                number = groupusers
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            return render_template("samba/modify_group.html", groupname=groupname, sambausers=sambausers, groupusers=groupusers)

    if id == "samba-modify-group":
        userlist = [value for _, value in request.form.items()]
        
        groupname = userlist[1]

        forcedel = "yes"
        number = f.samba_delete_user_group(groupname, forcedel)
        if number != 0:
                text=err.error(number)
                return render_template('shared/error.html', text=text)


        number = f.samba_create_user_group(userlist)
        if number != 0:
                text=err.error(number)
                return render_template('shared/error.html', text=text)


        number = f.samba_merge_config()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)


        return redirect(url_for('samba_groups'), code=307)
        

    if id == "samba-group-share-check":
        if "delete-samba-share-button" in request.form:
            button = str(request.form.get('delete-samba-share-button'))
            dirdel = str(request.form.get('dir-delete'))

            number = f.samba_delete_group_share(button, dirdel)
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            
            number = f.samba_merge_config()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
            return redirect(url_for("samba"))
        
        if "modify-samba-share-button" in request.form:
            button = str(request.form.get('modify-samba-share-button'))
            configarray = f.samba_check_selected_group_share(button)
            if isinstance(configarray, int):
                number = configarray
                text = err.error(number)
                return render_template('shared/error.html', text=text)

            userarray = f.samba_list_all_users()
            if isinstance(userarray, int):
                number = userarray
                text=err.error(number)
                return render_template('shared/error.html', text=text)
        
            grouparray = f.samba_list_all_system_groups()
            if isinstance(grouparray, int):
                number = grouparray
                text=err.error(number)
                return render_template('shared/error.html', text=text)

            sambagroupsarray = f.samba_list_all_samba_group()
            if isinstance(sambagroupsarray, int):
                number = sambagroupsarray
                if number != 0:
                    text = err.error(number)
                    return render_template('shared/error.html', text=text)
            
            return render_template('samba/modify_group_share.html', sambagroupsarray=sambagroupsarray, configarray=configarray, userarray=userarray, grouparray=grouparray)


    if id == "samba-modify-group-share":
        sharename = str(request.form.get('share-name'))
        sharepath = str(request.form.get('share-path'))
        dirperm = str(request.form.get('dir-perm'))
        owneru = str(request.form.get('owner-user'))
        ownerg = str(request.form.get('owner-group'))
        comment = str(request.form.get('comment'))
        readonly = str(request.form.get('read-only'))
        writable = str(request.form.get('writable'))
        guestok = str(request.form.get('guest-ok'))
        groupname = str(request.form.get('group-name'))
        validtype = str(request.form.get('valid-type'))
        browsable = str(request.form.get('browsable'))
        public = str(request.form.get('public'))
        createmask = str(request.form.get('create-mask'))
        dirmask = str(request.form.get('directory-mask'))
        forceuser = str(request.form.get('force-user'))
        forcegroup = str(request.form.get('force-group'))
        dotfiles = str(request.form.get('hide-dot-files'))

        dirdel="no"
        
        number = f.samba_delete_group_share(sharename, dirdel)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.samba_add_group_share(sharename, sharepath, dirperm, owneru, ownerg, comment, validtype, groupname, readonly, writable, guestok, browsable, public, createmask, dirmask, forceuser, forcegroup, dotfiles)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.samba_merge_config()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for("samba"))


    if id == "ftp-global-modify-redirect":
        globalconfig = f.ftp_check_global_config()
        
        if isinstance(globalconfig, int):
            number = globalconfig
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        message = f.ftp_check_message()
        if isinstance(message, int):
            number = message
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        return render_template('ftp/modify_global_config.html', message=message, globalconfig=globalconfig)


    if id == "ftp-global-modify":
        ipv4 = str(request.form.get('ipv4'))
        ipv6 = str(request.form.get('ipv6'))
        localen = str(request.form.get('local-enable'))
        messageen = str(request.form.get('dir-message'))
        writeen = str(request.form.get('write-enable'))
        dotfiles = str(request.form.get('force-dot-files'))
        hideids = str(request.form.get('hide-ids'))
        maxpip = str(request.form.get('max-p-ip'))
        maxclients = str(request.form.get('max-clients'))
        anonimen = str(request.form.get('anonim-enable'))
        anonimupen = str(request.form.get('anonim-upload-enable'))
        anonimmkdiren = str(request.form.get('anonim-mkdir-enable'))
        anonimotherwriteen = str(request.form.get('anonim-other-write-enable'))
        anonimworldreadonly = str(request.form.get('anonim-world-readonly'))
        messagetext = str(request.form.get('message'))

        number = f.ftp_modify_global_config(ipv4, ipv6, localen, messageen, writeen, dotfiles, hideids, maxpip, maxclients, anonimen, anonimupen, anonimmkdiren, anonimotherwriteen, anonimworldreadonly)
        if number != 0:  
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.ftp_modify_message(messagetext)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.ftp_merge_config()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for('ftp'))


    if id == "ftp-allow-user":
        uname = str(request.form.get('allow-user-ftp-button'))
        number = f.ftp_allow_user(uname)
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.ftp_merge_config()
        if number != 0:
            text=err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for('ftp'))


    if id == "ftp-deny-user":
        if 'deny-user-ftp-button' in request.form:
            uname = str(request.form.get('deny-user-ftp-button'))
            dirdel = str(request.form.get('dir-delete'))

            number = f.ftp_deny_user(uname, dirdel)
            if number != 0:
                text=err.error(number)
                return render_template('shared/error.html', text=text)

            number = f.ftp_merge_config()
            if number != 0:
                text=err.error(number)
                return render_template('shared/error.html', text=text)

            return redirect(url_for('ftp'))

        if 'modify-user-ftp-button' in request.form:
            uname = str(request.form.get('modify-user-ftp-button'))
            radioname = ("chroot_"+uname)
            chroot = str(request.form.get(radioname))
            
            number = f.ftp_modify_chroot(uname, chroot)
            if number != 0:
                text=err.error(number)
                return render_template('shared/error.html', text=text)
            
            number = f.ftp_merge_config()
            if number != 0:
                text=err.error(number)
                return render_template('shared/error.html', text=text)

            return redirect(url_for('ftp'))


    if id == "adapter-modify-redirect":
        button = str(request.form.get('modify-adapter-button'))

        adapter = f.adapter_check_one_adapter(button)
        if isinstance(adapter, int):
            number = adapter
            text=err.error(number)
            return render_template('shared/error.html', text=text)
        
        return render_template('adapter/adapter_modify.html', adapter=adapter)
    
    if id == "adapter-modify":
        adapter = str(request.form.get('adapter-name'))
        ip = str(request.form.get('ip'))
        gateway = str(request.form.get('gateway'))
        dns = str(request.form.get('nameserver'))
        status = str(request.form.get('status'))

        
        number = f.adapter_create_adapter_config(adapter, ip, gateway, dns, status)
        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        number = f.adapter_merge_config()
        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for('adapter'))


    if id == "hostname":
        hostname = str(request.form.get('hostname'))
        number = f.adapter_modify_hostname(hostname)
        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('adapter'))
    
    
    if id == "ssh-startup":
        status = str(request.form.get('ssh-startup'))
        number = f.ssh_startup_modify(status)

        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)

        return redirect(url_for('ssh'))
    

    if id == "ssh-access":
        ip = str(request.form.get('ip-address'))
        port = str(request.form.get('port'))

        number = f.ssh_access_modify(ip, port)
        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        number = f.ssh_merge_config()
        if number != 0 :
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('ssh'))
        
    
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


    if id == "dns":
        service = "bind9"
        number = f.service_install(service)

        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('dns'))


    if id == "nfs":
        service = "nfs-kernel-server"
        number = f.service_install(service)

        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('nfs'))


    if id == "samba":
        service = "samba"
        number = f.service_install(service)
        
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('samba'))

    
    if id == "ftp":
        service = "vsftpd"
        number = f.service_install(service)
        
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('ftp'))


    if id == "adapter":
        service = "network-adapter"
        ip = str(request.form.get('ip-address'))
        gateway = str(request.form.get('gateway'))
        dns = str(request.form.get('nameserver'))
        adapter = str(request.form.get('network-adapter'))
        nginx = str(request.form.get('server-config'))

        number = f.adapter_install(service, ip, gateway, dns, adapter, nginx)
        if number != 0:
            number = f.adapter_failed_install_restore()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)

        status = "up"
        number = f.adapter_create_adapter_config(adapter, ip, gateway, dns, status)
        if number != 0:
            number = f.adapter_failed_install_restore()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)

        number = f.adapter_merge_config()
        if number != 0:
            number = f.adapter_failed_install_restore()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)

        return redirect(url_for('adapter'))


    if id == "ssh":
        service = "openssh-server"
        number = f.service_install(service)
        
        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('ssh'))


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


    if id == "dns":
        service = "bind9"
        number = f.service_remove(service)

        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('dns'))


    if id == "nfs":
        service = "nfs-kernel-server"
        number = f.service_remove(service)

        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('nfs'))

    if id == "samba":
        service = "samba"
        number = f.service_remove(service)

        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('samba'))

    if id == "ftp":
        service = "vsftpd"
        number = f.service_remove(service)

        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('ftp'))

    
    if id == "adapter":
        if 'disable-button' in request.form:
            number = f.adapter_disable()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
        
            return redirect(url_for('adapter'))
        
        if 'disable-and-restore-button' in request.form:
            number = f.adapter_disable_and_restore()
            if number != 0:
                text = err.error(number)
                return render_template('shared/error.html', text=text)
        
            return redirect(url_for('adapter'))

    
    if id == "ssh":
        service = "openssh-server"
        number = f.service_remove(service)

        if number != 0:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
        return redirect(url_for('ssh'))

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

    
    if id == "dns":
        action = str(request.form.get('startstop'))
        service = "bind9"
        number = f.service_startstop(service, action)

        if number == 0:
            return redirect(url_for('dns'))
        else:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        

    if id == "nfs":
        action = str(request.form.get('startstop'))
        service = "nfs-kernel-server"
        number = f.service_startstop(service, action)

        if number == 0:
            return redirect(url_for('nfs'))
        else:
            text = err.error(number)
            return render_template('shared/error.html', text=text)


    if id == "samba":
        action = str(request.form.get('startstop'))
        service = "smbd"
        number = f.service_startstop(service, action)

        if number == 0:
            return redirect(url_for('samba'))
        else:
            text = err.error(number)
            return render_template('shared/error.html', text=text)

    if id == "ftp":
        action = str(request.form.get('startstop'))
        service = "vsftpd"
        number = f.service_startstop(service, action)

        if number == 0:
            return redirect(url_for('ftp'))
        else:
            text = err.error(number)
            return render_template('shared/error.html', text=text)


    if id == "adapter":
        if 'netplan-apply-button' in request.form:
            service = "netplan"
            number = f.adapter_netplan_apply(service)

            if number == 0:
                return redirect(url_for('adapter'))
            else:
                text = err.error(number)
                return render_template('shared/error.html', text=text)

        if 'systemd-networkd-button' in request.form:
            action = "restart"
            service = "systemd-networkd"
            number = f.service_startstop(service, action)

            if number == 0:
                return redirect(url_for('adapter'))
            else:
                text = err.error(number)
                return render_template('shared/error.html', text=text)



    if id == "ssh":
        action = str(request.form.get('startstop'))
        service = "ssh"
        number = f.service_startstop(service, action)

        if number == 0:
            return redirect(url_for('ssh'))
        else:
            text = err.error(number)
            return render_template('shared/error.html', text=text)
        
    return render_template('shared/error.html', text=text)

if __name__ == "__main__":
    app.run()


