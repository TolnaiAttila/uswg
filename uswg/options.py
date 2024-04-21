#create part options
oppart="--part" #subnet, global, backup, static-host, network-adapter

#create subet options
opsubnetname="--subnet-name" #string enabled separators: ., -
opip="--ip-address" #ip address
opsubnetmask="--subnet-mask" #netmask format 255.255.255.0
opfirstaddress="--first-address" #ip address
oplastaddress="--last-address" #ip address
opdns="--dns-server" #ip address or string separated by ,
oprouters="--routers" #ip address
opbroadcast="--broadcast" #ip address
opdlt="--dlt" #number
opmlt="--mlt" #number
opnetworkadapter="--network-adapter"
opntp="--ntp-server" #ip address
opdomainname="--domain-name" #string

#create global config options
opauthor="--authoritative" #yes, no
opddns="--ddns-style" #standard, interim, none

#create statis-host options
ophostname="--host-name"
opmac="--mac-address"
#opip="--ip-address" #subnet

#delete subnet option
#opsubnetname="--subnet-name" #string enabled separators: ., -

#delete static-host
#ophostname="--host-name"

#check
opinput="--input"

opport="--port"

opaction="--action"
opname="--name"
opdirectory="--directory"
opaccess="--access"
oppermission="--permission"
opsync="--sync"
opsubtree="--subtree-check"
opsquash="--root-squash"
opdirperm="--directory-permission"
opdirdel="--directory-delete"
opworkgroup="--workgroup"
opnetbios="--netbios-name"
opmtg="--map-to-guest"
opuag="--usershare-allow-guests"
opsecurity="--security"
oppublic="--public"
opuser="--username"
oppasswd1="--password1"
oppasswd2="--password2"
opsharename="--share-name"
oppath="--path"
opowneruser="--owner-user"
opownergroup="--owner-group"
opcomment="--comment"
opreadonly="--read-only"
opwritable="--writable"
opguestok="--guest-ok"
opguestonly="--guest-only"
opbrowsable="--browsable"
opcreatemask="--create-mask"
opdirmask="--directory-mask"
opforceuser="--force-user"
opforcegroup="--force-group"
opdotfiles="--hide-dot-files"
opvalidusers="--valid-users"
opgroupname="--group-name"
opforcedelete="--force-delete"
opvalidtype="--valid-type"

opipv4="--listen-ipv4"
opipv6="--listen-ipv6"
oplocalen="--local-enable"
opmessageen="--message-enable"
opwriteen="--write-enable"
opforcedotfiles="--force-dot-files"
ophideids="--hide-ids"
opmaxpip="--max-p-ip"
opmaxclients="--max-clients"
opanonen="--anon-enable"
opanonupen="--anon-upload-enable"
opanonmkdiren="--anon-mkdir-enable"
opanonotherwriteen="--anon-other-write-enable"
opanonworldro="--anon-world-readonly"
opmessage="--message-text"
opchroot="--chroot"