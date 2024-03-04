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