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
    
    name = configarray[1]
    directory = configarray[2]
    dirperm = configarray[3]


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
            access = configarray[linecounter]
            counter = counter + 1
        elif counter == 1:
            permission = configarray[linecounter]
            counter = counter + 1
        elif counter == 2:
            sync = configarray[linecounter]
            counter = counter + 1
        elif counter == 3:
            squash = configarray[linecounter]
            counter = counter + 1
        elif counter == 4:
            subtree = configarray[linecounter]
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


def samba_list_all_users():
    part="list-all-users"
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



def samba_check_selected_nobody_share(button):
    part="nobody-share"
    try:
        config = subprocess.check_output(["./bash/samba/samba_check_part.sh", op.oppart, part, op.opinput, button], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/samba/samba_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, button])
        number = check.returncode

        return number



def samba_check_all_single_user_share():
    part="single-user-share"
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



def samba_add_singl_user_share(sharename, sharepath, dirperm, owneru, ownerg, comment, validusers, readonly, writable, guestok, browsable, public, createmask, dirmask, forceuser, forcegroup, dotfiles):
    part="single-user-share"
    if createmask == "":
        createmask = "not_configured"
    if dirmask == "":
        dirmask = "not_configured"
    if dirperm == "":
        dirperm = "not_configured"
    if comment == "":
        comment = "not_configured"
    bash_path = 'bash/samba/samba_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opsharename, sharename, op.oppath, sharepath, op.opdirperm, dirperm, op.opowneruser, owneru, op.opownergroup, ownerg, op.opcomment, comment, op.opvalidusers, validusers, op.opreadonly, readonly, op.opwritable, writable, op.opguestok, guestok, op.opbrowsable, browsable, op.oppublic, public, op.opcreatemask, createmask, op.opdirmask, dirmask, op.opforceuser, forceuser, op.opforcegroup, forcegroup, op.opdotfiles, dotfiles])
    number = check.returncode

    return number



def samba_delete_single_user_share(button, dirdel):
    part="single-user-share"
    bash_path = 'bash/samba/samba_delete_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, button, op.opdirdel, dirdel])
    number = check.returncode

    return number



def samba_check_selected_single_user_share(button):
    part="single-user-share"
    try:
        config = subprocess.check_output(["./bash/samba/samba_check_part.sh", op.oppart, part, op.opinput, button], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/samba/samba_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, button])
        number = check.returncode

        return number


def samba_list_all_samba_group():
    part="samba-groups"
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



def samba_create_user_group(userlist):
    part="create-user-list"
    bash_path = 'bash/samba/samba_create_part.sh'
    number = 0
    if len(userlist) < 3:
        groupname = userlist[1]
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opgroupname, groupname])
    else:
        userlist.pop(0)
        groupname = userlist[0]
        userlist.pop(0)
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opgroupname, groupname, op.opuser, userlist[0]])
        userlist.pop(0)
        number = check.returncode

        if number != 0:
            return number
    
        for i in userlist:
            part="append-user-list"
            check = subprocess.run(['bash', bash_path, op.oppart, part, op.opgroupname, groupname, op.opuser, i])
            number = check.returncode

    return number

def samba_delete_user_group(button, forcedel="no"):
    part="delete-user-list"
    
    bash_path = 'bash/samba/samba_delete_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, button, op.opforcedelete, forcedel])
    number = check.returncode

    return number



def samba_list_users_in_group(button):
    part="samba-groups"
    try:
        config = subprocess.check_output(["./bash/samba/samba_check_part.sh", op.oppart, part, op.opinput, button], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/samba/samba_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, button])
        number = check.returncode

        return number



def samba_check_all_group_share():
    part="group-share"
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


def samba_add_group_share(sharename, sharepath, dirperm, owneru, ownerg, comment, validtype, groupname, readonly, writable, guestok, browsable, public, createmask, dirmask, forceuser, forcegroup, dotfiles):
    part="group-share"
    if createmask == "":
        createmask = "not_configured"
    if dirmask == "":
        dirmask = "not_configured"
    if dirperm == "":
        dirperm = "not_configured"
    if comment == "":
        comment = "not_configured"
    bash_path = 'bash/samba/samba_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opsharename, sharename, op.oppath, sharepath, op.opdirperm, dirperm, op.opowneruser, owneru, op.opownergroup, ownerg, op.opcomment, comment, op.opvalidtype, validtype, op.opgroupname, groupname, op.opreadonly, readonly, op.opwritable, writable, op.opguestok, guestok, op.opbrowsable, browsable, op.oppublic, public, op.opcreatemask, createmask, op.opdirmask, dirmask, op.opforceuser, forceuser, op.opforcegroup, forcegroup, op.opdotfiles, dotfiles])
    number = check.returncode

    return number



def samba_delete_group_share(button, dirdel):
    part="group-share"
    bash_path = 'bash/samba/samba_delete_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, button, op.opdirdel, dirdel])
    number = check.returncode

    return number



def samba_check_selected_group_share(button):
    part="group-share"
    try:
        config = subprocess.check_output(["./bash/samba/samba_check_part.sh", op.oppart, part, op.opinput, button], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/samba/samba_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, button])
        number = check.returncode

        return number



def ftp_check_global_config():
    part="global"
    try:
        config = subprocess.check_output(["./bash/ftp/ftp_check_part.sh", op.oppart, part], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/ftp/ftp_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def ftp_check_message():
    part="message"
    try:
        config = subprocess.check_output(["./bash/ftp/ftp_check_part.sh", op.oppart, part], universal_newlines=True)
        return config

    except:
        bash_path = '/bash/ftp/ftp_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def ftp_modify_global_config(ipv4, ipv6, localen, messageen, writeen, dotfiles, hideids, maxpip, maxclients, anonimen, anonimupen, anonimmkdiren, anonimotherwriteen, anonimworldreadonly):
    part="global"
    bash_path = 'bash/ftp/ftp_modify_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opipv4, ipv4, op.opipv6, ipv6, op.oplocalen, localen, op.opmessageen, messageen, op.opwriteen, writeen, op.opforcedotfiles, dotfiles, op.ophideids, hideids, op.opmaxpip, maxpip, op.opmaxclients, maxclients, op.opanonen, anonimen, op.opanonupen, anonimupen, op.opanonmkdiren, anonimmkdiren, op.opanonotherwriteen, anonimotherwriteen, op.opanonworldro, anonimworldreadonly])
    number = check.returncode

    return number


def ftp_modify_message(messagetext):
    part="message"
    if messagetext == "" :
        messagetext = "empty"

    bash_path = 'bash/ftp/ftp_modify_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opmessage, messagetext])
    number = check.returncode

    return number


def ftp_merge_config():
    bash_path = 'bash/ftp/ftp_merge_config.sh'
    check = subprocess.run(['bash', bash_path])
    number = check.returncode

    return number


def ftp_list_allowed_users():
    part="list-allowed-ftp-users"
    try:
        config = subprocess.check_output(["./bash/ftp/ftp_users.sh", op.oppart, part], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/ftp/ftp_users.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def ftp_list_denied_users():
    part="list-denied-ftp-users"
    try:
        config = subprocess.check_output(["./bash/ftp/ftp_users.sh", op.oppart, part], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/ftp/ftp_users.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number

    
def ftp_list_chroot_users():
    part="list-chroot-ftp-users"
    try:
        config = subprocess.check_output(["./bash/ftp/ftp_users.sh", op.oppart, part], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/ftp/ftp_users.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def ftp_allow_user(uname):
    part = "allow-ftp-share"
    bash_path = 'bash/ftp/ftp_users.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opuser, uname])
    number = check.returncode

    return number



def ftp_deny_user(uname, dirdel):
    part = "deny-ftp-share"
    bash_path = 'bash/ftp/ftp_users.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opuser, uname, op.opdirdel, dirdel])
    number = check.returncode

    return number


def ftp_modify_chroot(uname, chroot):
    part = "chroot-modify"
    bash_path = 'bash/ftp/ftp_users.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opuser, uname, op.opchroot, chroot])
    number = check.returncode

    return number


def ftp_list_passwdless_users():
    part="list-passwdless-users"
    try:
        config = subprocess.check_output(["./bash/ftp/ftp_users.sh", op.oppart, part], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/ftp/ftp_users.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number



def ftp_modify_user_passwd(uname, passwd1, passwd2):
    part = "add-passwd"
    bash_path = 'bash/ftp/ftp_users.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opuser, uname, op.oppasswd1, passwd1, op.oppasswd2, passwd2])
    number = check.returncode

    return number


def ftp_add_system_user(uname):
    part = "add-system-user"
    bash_path = 'bash/ftp/ftp_users.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opuser, uname])
    number = check.returncode

    return number



def adapter_status():
    part = "status"
    bash_path = 'bash/adapter/adapter_check_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part])
    number = check.returncode

    return number



def adapter_install(service, ip, gateway, dns, adapter, nginx):
    bash_path = 'bash/shared/service_install.sh'
    check = subprocess.run(['bash', bash_path, service, ip, gateway, dns, adapter, nginx])
    number = check.returncode

    return number


def adapter_create_adapter_config(adapter, ip, gateway, dns, status):
    if ip == "" :
        ip = "empty"
    if gateway == "" :
        gateway = "empty"
    if dns == "" :
        dns = "empty"

    part = "adapter-configuration"
    bash_path = 'bash/adapter/adapter_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.opnetworkadapter, adapter, op.opip, ip, op.opgateway, gateway, op.opdns, dns, op.opstatus, status])
    number = check.returncode

    return number



def adapter_merge_config():
    bash_path = 'bash/adapter/adapter_merge_config.sh'
    check = subprocess.run(['bash', bash_path])
    number = check.returncode

    return number


def adapter_disable():
    part="network-adapter"
    method="disable"
    bash_path = 'bash/shared/service_remove.sh'
    check = subprocess.run(['bash', bash_path, part, method])
    number = check.returncode

    return number



def adapter_disable_and_restore():
    part="network-adapter"
    method="restore"
    bash_path = 'bash/shared/service_remove.sh'
    check = subprocess.run(['bash', bash_path, part, method])
    number = check.returncode

    return number



def adapter_failed_install_restore():
    part="network-adapter"
    method="failed-install-restore"
    bash_path = 'bash/shared/service_remove.sh'
    check = subprocess.run(['bash', bash_path, part, method])
    number = check.returncode

    return number



def adapter_check_all_adapter():
    part="list-all-adapters"
    try:
        config = subprocess.check_output(["./bash/adapter/adapter_check_part.sh", op.oppart, part], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/adapter/adapter_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number



def adapter_check_one_adapter(button):
    part="check-adapter"
    try:
        config = subprocess.check_output(["./bash/adapter/adapter_check_part.sh", op.oppart, part, op.opinput, button], universal_newlines=True)
        array = config.split("\n")
        if array[-1] == "":
            array.pop(-1)
        return array

    except:
        bash_path = '/bash/adapter/adapter_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part, op.opinput, button])
        number = check.returncode

        return number



def adapter_netplan_apply(service):
    bash_path = 'bash/adapter/adapter_netplan_apply.sh'
    check = subprocess.run(['bash', bash_path, service])
    number = check.returncode

    return number



def adapter_hostname():
    part="hostname"
    try:
        config = subprocess.check_output(["./bash/adapter/adapter_check_part.sh", op.oppart, part], universal_newlines=True)
        return config

    except:
        bash_path = '/bash/adapter/adapter_check_part.sh'
        check = subprocess.run(['bash', bash_path, op.oppart, part])
        number = check.returncode

        return number


def adapter_modify_hostname(hostname):
    part = "hostname"
    bash_path = 'bash/adapter/adapter_create_part.sh'
    check = subprocess.run(['bash', bash_path, op.oppart, part, op.ophostname2, hostname])
    number = check.returncode

    return number