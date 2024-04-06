import subprocess
import options as op

def service_startstop(service, action):

    bash_path = 'bash/shared/service_startstop.sh'
    check = subprocess.run(['bash', bash_path, action, service])
    number = check.returncode

    return number



def service_remove(service):

    bash_path = 'bash/shared/service_remove.sh'
    check = subprocess.run(['bash', bash_path, service])
    number = check.returncode

    return number



def service_install(service):
        
        bash_path = 'bash/shared/service_install.sh'
        check = subprocess.run(['bash', bash_path, service])
        number = check.returncode

        return number



def dhcp_create_global_config(author, ddns):

    part = "global"
    bash_path = 'bash/dhcp/dhcp_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opauthor, author, op.opddns, ddns])
    number = check.returncode

    return number



def dhcp_create_subnet(subnetname, subnetadd, subnetmask, startadd, lastadd, dnsserver, routers, broadcast, dlt, mlt, networkadapter, ntp, domainname):
    
    part = "subnet"
    
    bash_path = 'bash/dhcp/dhcp_create_part.sh'

    if ntp == "" and domainname == "" :
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opsubnetname, subnetname, op.opip, subnetadd, op.opsubnetmask, subnetmask, op.opfirstaddress, startadd, op.oplastaddress, lastadd, op.opdns, dnsserver, op.oprouters, routers, op.opbroadcast, broadcast, op.opdlt, dlt, op.opmlt, mlt, op.opnetworkadapter, networkadapter])
    elif ntp != "" and domainname != "" :
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opsubnetname, subnetname, op.opip, subnetadd, op.opsubnetmask, subnetmask, op.opfirstaddress, startadd, op.oplastaddress, lastadd, op.opdns, dnsserver, op.oprouters, routers, op.opbroadcast, broadcast, op.opdlt, dlt, op.opmlt, mlt, op.opnetworkadapter, networkadapter, op.opntp, ntp, op.opdomainname, domainname])
    elif ntp != "":
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opsubnetname, subnetname, op.opip, subnetadd, op.opsubnetmask, subnetmask, op.opfirstaddress, startadd, op.oplastaddress, lastadd, op.opdns, dnsserver, op.oprouters, routers, op.opbroadcast, broadcast, op.opdlt, dlt, op.opmlt, mlt, op.opnetworkadapter, networkadapter, op.opntp, ntp])
    elif domainname != "":
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opsubnetname, subnetname, op.opip, subnetadd, op.opsubnetmask, subnetmask, op.opfirstaddress, startadd, op.oplastaddress, lastadd, op.opdns, dnsserver, op.oprouters, routers, op.opbroadcast, broadcast, op.opdlt, dlt, op.opmlt, mlt, op.opnetworkadapter, networkadapter, op.opdomainname, domainname])
    
    number = check.returncode

    return number



def dhcp_create_network_adapter(networkadapter):

    part = "network-adapter"
    
    bash_path = 'bash/dhcp/dhcp_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opnetworkadapter, networkadapter])
    
    number = check.returncode

    return number




def dhcp_check_subnet(subnetname):
    part = "subnet"

    try:
        config = subprocess.check_output(["./bash/dhcp/dhcp_check_part.sh", op.oppart, part, op.opinput, subnetname], universal_newlines=True)
        configarray = config.split()

        return configarray

    except:
        script_path = "bash/dhcp/dhcp_check_part.sh"
        check = subprocess.run(['bash', script_path, op.oppart, part, op.opinput, subnetname])
        number = check.returncode

        return number



def list_all_network_adapter():

        networkadapters = subprocess.check_output(["./bash/shared/list_network_adapters.sh"], universal_newlines=True)
        adapterarray = networkadapters.split()

        return adapterarray



def dhcp_list_all_subnet():
    part = "subnet"

    try:
        config = subprocess.check_output(["./bash/dhcp/dhcp_check_part.sh", op.oppart, part], universal_newlines=True)
        configarray = config.split()

        return configarray

    except:
        bash_path = "bash/dhcp/dhcp_check_part.sh"
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number



def dhcp_delete_network_adapter(networkadapter):

    part = "network-adapter"

    bash_path = 'bash/dhcp/dhcp_delete_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opnetworkadapter, networkadapter])
    number = check.returncode

    return number




def dhcp_delete_subnet(subnetname):
    part = "subnet"
    bash_path = "bash/dhcp/dhcp_delete_part.sh"
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opsubnetname, subnetname])
    number = check.returncode

    return number




def dhcp_check_static_host(name):
    part = "static-host"
    try:
        config = subprocess.check_output(["./bash/dhcp/dhcp_check_part.sh", op.oppart, part, op.opinput, name], universal_newlines=True)
        configarray = config.split()
        
        return configarray

    except:
        bash_path = "bash/dhcp/dhcp_check_part.sh.sh"
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, name])
        number = check.returncode

        return number

def dhcp_delete_static_host(name):
    part = "static-host"

    bash_path = "bash/dhcp/dhcp_delete_part.sh"
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.ophostname, name])
    number = check.returncode

    return number



def dhcp_create_static_host(name, mac, ip):
    part = "static-host"

    script_path = "bash/dhcp/dhcp_create_part.sh"
    check = subprocess.run(['bash', script_path, op.oppart, part, op.ophostname, name, op.opmac, mac, op.opip, ip])
    number = check.returncode

    return number



def dhcp_create_backup():
    part = "backup"

    bash_path = 'bash/dhcp/dhcp_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part])
    number = check.returncode

    return number



def dhcp_restore_backup():
    bash_path = 'bash/dhcp/dhcp_restore_backup.sh'
    check = subprocess.run(['bash', bash_path])
    number = check.returncode

    return number



def status(service):
    bash_path = 'bash/shared/status.sh'
    check = subprocess.run(['bash', bash_path, service])
    number = check.returncode

    return number



def dhcp_list_all_static_host():
    part = "static-host"
    try:
        config = subprocess.check_output(["./bash/dhcp/dhcp_check_part.sh", op.oppart, part], universal_newlines=True)
        configarray = config.split()

        return configarray

    except:
        bash_path = 'bash/dhcp/dhcp_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number



def dhcp_check_global_config():
    part = "global"
    try:
        config = subprocess.check_output(["./bash/dhcp/dhcp_check_part.sh", op.oppart, part], universal_newlines=True)
        configarray = config.split('\n')

        return configarray

    except:
        bash_path = 'bash/dhcp/dhcp_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number



def dhcp_check_backup():
    part = "backup"
    
    try:
        lastbackupdate = subprocess.check_output(["./bash/dhcp/dhcp_check_part.sh", op.oppart, part], universal_newlines=True)

        return lastbackupdate

    except:
        bash_path = 'bash/dhcp/dhcp_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number



def dhcp_merge_config():
    bash_path = 'bash/dhcp/dhcp_merge_config.sh'
    check = subprocess.run(['bash', bash_path])
    number = check.returncode

    return number



def dns_create_listenon(ip, port):
    part = "listen-on"
    bash_path = 'bash/dns/dns_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opip, ip, op.opport, port])
    number = check.returncode

    return number



def dns_check_listenon():
    part = "listen-on"
    
    try:
        listenon = subprocess.check_output(["./bash/dns/dns_check_part.sh", op.oppart, part], universal_newlines=True)
        array = listenon.split()
        return array

    except:
        bash_path = '/bash/dns/dns_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def dns_delete_listenon(buttonvalue):
    part = "listen-on"
    bash_path = 'bash/dns/dns_delete_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, buttonvalue])
    number = check.returncode

    return number


def nfs_check_configuration():
    part = "configuration"
    try:
        config = subprocess.check_output(["./bash/nfs/nfs_check_part.sh", op.oppart, part], universal_newlines=True)
        array = config.split()
        return array

    except:
        bash_path = '/bash/nfs/nfs_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number

def nfs_check_rowspan():
    part = "rowspan"
    try:
        config = subprocess.check_output(["./bash/nfs/nfs_check_part.sh", op.oppart, part], universal_newlines=True)
        array = config.split()
        return array

    except:
        bash_path = '/bash/nfs/nfs_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def nfs_check_configuration_modify(sharename):
    part = "configuration"
    try:
        config = subprocess.check_output(["./bash/nfs/nfs_check_part.sh", op.oppart, part, op.opinput, sharename], universal_newlines=True)
        array = config.split()
        return array

    except:
        bash_path = '/bash/nfs/nfs_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, sharename])
        number = check.returncode

        return number


def nfs_create_share(name, directory, dirperm, access, permission, sync, subtree, squash):
    action = "create"
    
    bash_path = 'bash/nfs/nfs_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.opaction, action, op.opname, name, op.opdirectory, directory, op.opdirperm, dirperm, op.opaccess, access, op.oppermission, permission, op.opsync, sync, op.opsubtree, subtree, op.opsquash, squash])
    number = check.returncode

    return number


def nfs_add_access(name, access, permission, sync, subtree, squash):
    action = "append"
    
    bash_path = 'bash/nfs/nfs_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.opaction, action, op.opname, name, op.opaccess, access, op.oppermission, permission, op.opsync, sync, op.opsubtree, subtree, op.opsquash, squash])
    number = check.returncode

    return number


def nfs_share_modify(configarray):
    
    name = configarray[1][1]
    directory = configarray[2][1]
    dirperm = configarray[3][1]


    configarray.pop(0)
    configarray.pop(0)
    configarray.pop(0)
    configarray.pop(0)
    
    access = ""
    permission = ""
    sync = ""
    squash = ""
    subtree = ""
    
    counter = 0
    linecounter = 0
    created = False
    for i in configarray:
        if counter == 0:
            access = configarray[linecounter][1]
            counter = counter + 1
        elif counter == 1:
            permission = configarray[linecounter][1]
            counter = counter + 1
        elif counter == 2:
            sync = configarray[linecounter][1]
            counter = counter + 1
        elif counter == 3:
            squash = configarray[linecounter][1]
            counter = counter + 1
        elif counter == 4:
            subtree = configarray[linecounter][1]
            counter = 0

            if created == False:
                created = True
                number = nfs_create_share(name, directory, dirperm, access, permission, sync, subtree, squash)
                if number != 0:
                    return number
            else:
                number = nfs_add_access(name, access, permission, sync, subtree, squash)
                if number != 0:
                    return number
        linecounter = linecounter + 1
    return 0


    
def nfs_delete_all(buttoninput, dirdel):
    part = "all"
    bash_path = 'bash/nfs/nfs_delete_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, buttoninput, op.opdirdel, dirdel])
    number = check.returncode

    return number

def nfs_delete_part(buttoninput):
    part = "part"
    buttoninput = '"' + buttoninput + '"'
    bash_path = 'bash/nfs/nfs_delete_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, buttoninput])
    number = check.returncode

    return number

def nfs_merge():
    bash_path = 'bash/nfs/nfs_merge_config.sh'
    check = subprocess.run(['bash', bash_path])
    number = check.returncode

    return number

def nfs_list_all_name():
    part = "only-name"
    try:
        config = subprocess.check_output(["./bash/nfs/nfs_check_part.sh", op.oppart, part], universal_newlines=True)
        array = config.split()
        return array

    except:
        bash_path = '/bash/nfs/nfs_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def samba_check_global_config():
    part = "global"
    try:
        config = subprocess.check_output(["./bash/samba/samba_check_part.sh", op.oppart, part], universal_newlines=True)
        array = config.split("\n")
        return array

    except:
        bash_path = '/bash/samba/samba_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def samba_create_global_config(workgroup, bname, mtg, uag, security, public):
    part="global"
    bash_path = 'bash/samba/samba_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opworkgroup, workgroup, op.opnetbios, bname, op.opmtg, mtg, op.opuag, uag, op.opsecurity, security, op.oppublic, public])
    number = check.returncode

    return number


def samba_merge_config():
    bash_path = 'bash/samba/samba_merge_config.sh'
    check = subprocess.run(['bash', bash_path])
    number = check.returncode

    return number


def samba_list_leftover_system_users():
    part = "list-leftover-system-users"
    try:
        config = subprocess.check_output(["./bash/samba/samba_users.sh", op.oppart, part], universal_newlines=True)
        array = config.split()
        return array

    except:
        bash_path = '/bash/samba/samba_users.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def samba_list_samba_users():
    part = "list-samba-users"
    try:
        config = subprocess.check_output(["./bash/samba/samba_users.sh", op.oppart, part], universal_newlines=True)
        array = config.split()
        return array

    except:
        bash_path = '/bash/samba/samba_users.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def samba_add_samba_user(user, passwd1, passwd2):
    part = "add-samba-user"
    bash_path = 'bash/samba/samba_users.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opuser, user, op.oppasswd1, passwd1, op.oppasswd2, passwd2])
    number = check.returncode

    return number


def samba_remove_samba_user(user):
    part = "remove-samba-user"
    bash_path = 'bash/samba/samba_users.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opuser, user])
    number = check.returncode

    return number


def samba_add_system_user(user):
    part = "add-system-user"
    bash_path = 'bash/samba/samba_users.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opuser, user])
    number = check.returncode

    return number


def samba_check_all_nobody_share():
    part="nobody-share"
    try:
        config = subprocess.check_output(["./bash/samba/samba_check_part.sh", op.oppart, part], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/samba/samba_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def samba_list_all_system_users():
    part="list-all-system-users"
    try:
        config = subprocess.check_output(["./bash/samba/samba_users.sh", op.oppart, part], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/samba/samba_users.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number



def samba_list_all_system_groups():
    part="list-all-system-groups"
    try:
        config = subprocess.check_output(["./bash/samba/samba_users.sh", op.oppart, part], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/samba/samba_users.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number



def samba_add_nobody_share(sharename, sharepath, dirperm, owneru, ownerg, comment, readonly, writable, guestok, guestonly, browsable, public, createmask, dirmask, forceuser, forcegroup, dotfiles):
    part="nobody-share"
    if createmask == "":
        createmask = "not_configured"
    if dirmask == "":
        dirmask = "not_configured"
    if dirperm == "":
        dirperm = "not_configured"
    if comment == "":
        comment = "not_configured"
    
    bash_path = 'bash/samba/samba_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opsharename, sharename, op.oppath, sharepath, op.opdirperm, dirperm, op.opowneruser, owneru, op.opownergroup, ownerg, op.opcomment, comment, op.opreadonly, readonly, op.opwritable, writable, op.opguestok, guestok, op.opguestonly, guestonly, op.opbrowsable, browsable, op.oppublic, public, op.opcreatemask, createmask, op.opdirmask, dirmask, op.opforceuser, forceuser, op.opforcegroup, forcegroup, op.opdotfiles, dotfiles])
    number = check.returncode

    return number


def samba_delete_nobody_share(button, dirdel):
    part="nobody-share"
    bash_path = 'bash/samba/samba_delete_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, button, op.opdirdel, dirdel])
    number = check.returncode

    return number