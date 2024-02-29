#!/bin/bash

ARGS=$(getopt -n "$0" -o p:b: --long part:,input: -- "$@")

if [ $? -ne 0 ]; then
    exit 10
fi

eval set -- "$ARGS"

part=""
input=""

while true; do
    case "$1" in
        --part | -p)
            if [[ -n "$2" && "$2" != -* ]]; then
                part="$2"
                shift 2
            else
                exit 10
            fi
            ;;
        
        --input | -b)
            if [[ -n "$2" && "$2" != -* ]]; then
                input="$2"
                shift 2
            else
                exit 10
            fi
            ;;
        
        --)
            shift
            break
            ;;

        *)
            exit 10
            ;;
    esac
done

if [ -z "$part" ]; then
    exit 5
fi

case "$part" in
    backup)

        path="/etc/dhcp/.old_uswg_dhcp_config/dhcpd.conf"

        ./bash/shared/exist_file.sh $path

        if [ $? -eq 0 ]; then
            date=`stat /etc/dhcp/.old_uswg_dhcp_config/ | grep "^Modify:.\+$" | cut -d' ' -f2- | cut -d'.' -f1`
            echo -n $date
            exit 0
        else
            exit 1
        fi

        ;;

    subnet)
        if [ -z "$input" ]; then
            
            path="/etc/dhcp/.uswg_dhcp_config/"

            for i in `ls $path | grep "^dhcp_subnet_.\+\.conf$"`; do
                subnetname=`cat $path$i | grep "^#subnet_name[[:space:]].\+[[:space:]]assigned[[:space:]]network-adapter[[:space:]].\+$" | cut -d' ' -f2`
                networkadapter=`cat $path$i | grep "^#subnet_name[[:space:]].\+[[:space:]]assigned[[:space:]]network-adapter[[:space:]].\+$" | cut -d' ' -f5`
                subnetadd=`cat $path$i| grep "^subnet[[:space:]].\+[[:space:]]netmask[[:space:]].\+{$" | cut -d' ' -f2`
                first=`cat $path$i| grep "^range[[:space:]].\+[[:space:]].\+;$" | cut -d' ' -f2`
                last=`cat $path$i| grep "^range[[:space:]].\+[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';'`
                dnsserver=`cat $path$i| grep "^option[[:space:]]domain-name-servers[[:space:]].\+;$" | cut -d' ' -f3- | tr -d ';'`
                subnetmask=`cat $path$i| grep "^option[[:space:]]subnet-mask[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';'`
                routers=`cat $path$i| grep "^option[[:space:]]routers[[:space:]].\+;$" | cut -d' ' -f3- | tr -d ';'`
                broadcast=`cat $path$i| grep "^option[[:space:]]broadcast-address[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';'`
                ntp=`cat $path$i | grep "^option[[:space:]]ntp-servers[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';'`
                domainname=`cat $path$i | grep "^option[[:space:]]domain-name[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';' | tr -d '\"'`
                dlt=`cat $path$i| grep "^default-lease-time[[:space:]].\+;$" | cut -d' ' -f2 | tr -d ';'`
                mlt=`cat $path$i| grep "^max-lease-time[[:space:]].\+;$" | cut -d' ' -f2 | tr -d ';'`
                    
                    if [ -z "$ntp" ]; then
                        ntp="---"
                    fi

                    if [ -z "$domainname" ]; then
                        domainname="---"
                    fi

                echo $subnetname
                echo $subnetadd
                echo $subnetmask
                echo $first
                echo $last
                echo $dnsserver
                echo $broadcast
                echo $routers
                echo $ntp
                echo $domainname
                echo $networkadapter
                echo $dlt
                echo $mlt
                
            done
            exit 0
        else
            if [ -z `echo $input | grep "^\(\(modify\)\|\(delete\)\)_subnet_.\+_Button$"` ]; then
                exit 5
            else
                subnetname=`echo $input | cut -d'_' -f3`
                path="/etc/dhcp/.uswg_dhcp_config/dhcp_subnet_${subnetname}.conf"
                
                ./bash/shared/exist_file.sh $path
    
                if [ $? -eq 0 ]; then
                    subnetname=`cat $path$i | grep "^#subnet_name[[:space:]].\+[[:space:]]assigned[[:space:]]network-adapter[[:space:]].\+$" | cut -d' ' -f2`
                    networkadapter=`cat $path$i | grep "^#subnet_name[[:space:]].\+[[:space:]]assigned[[:space:]]network-adapter[[:space:]].\+$" | cut -d' ' -f5`
                    subnetadd=`cat $path$i| grep "^subnet[[:space:]].\+[[:space:]]netmask[[:space:]].\+{$" | cut -d' ' -f2`
                    first=`cat $path$i| grep "^range[[:space:]].\+[[:space:]].\+;$" | cut -d' ' -f2`
                    last=`cat $path$i| grep "^range[[:space:]].\+[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';'`
                    dnsserver=`cat $path$i| grep "^option[[:space:]]domain-name-servers[[:space:]].\+;$" | cut -d' ' -f3- | tr -d ';'`
                    subnetmask=`cat $path$i| grep "^option[[:space:]]subnet-mask[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';'`
                    routers=`cat $path$i| grep "^option[[:space:]]routers[[:space:]].\+;$" | cut -d' ' -f3- | tr -d ';'`
                    broadcast=`cat $path$i| grep "^option[[:space:]]broadcast-address[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';'`
                    ntp=`cat $path$i | grep "^option[[:space:]]ntp-servers[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';'`
                    domainname=`cat $path$i | grep "^option[[:space:]]domain-name[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';' | tr -d '\"'`
                    dlt=`cat $path$i| grep "^default-lease-time[[:space:]].\+;$" | cut -d' ' -f2 | tr -d ';'`
                    mlt=`cat $path$i| grep "^max-lease-time[[:space:]].\+;$" | cut -d' ' -f2 | tr -d ';'`
                    
                    if [ -z "$ntp" ]; then
                        ntp="---"
                    fi

                    if [ -z "$domainname" ]; then
                        domainname="---"
                    fi

                    returnarray=($subnetname $subnetadd $subnetmask $first $last $dnsserver $broadcast $routers $ntp $domainname $dlt $mlt $networkadapter)

                    for i in "${returnarray[@]}"; do
                        echo $i
                    done
                    exit 0
                else
                    exit 1
                fi
            fi
        fi
        ;;

    static-host)
        if [ -z "$input" ]; then
            path="/etc/dhcp/.uswg_dhcp_config/"

            for i in `ls $path | grep "^dhcp_static_.\+\.conf$"`; do
                name=`cat $path$i | grep "^host[[:space:]].\+[[:space:]]{$" | cut -d' ' -f2`
                mac=`cat $path$i | grep "^hardware[[:space:]]ethernet[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';'`
                ip=`cat $path$i | grep "^fixed-address[[:space:]].\+;$" | cut -d' ' -f2 | tr -d ';'`
                echo $name
                echo $mac
                echo $ip
            done
            exit 0

        else

            if [ -z `echo $input | grep "^\(\(modify\)\|\(delete\)\)_static_host_.\+_Button$"` ]; then
                
                exit 5
            else
                name=`echo $input | cut -d'_' -f4`
                path="/etc/dhcp/.uswg_dhcp_config/dhcp_static_${name}.conf"

                ./bash/shared/exist_file.sh $path
                
                if [ $? -eq 0 ]; then
        
                    name=`cat $path | grep "^host[[:space:]].\+[[:space:]]{$" | cut -d' ' -f2`
                    mac=`cat $path | grep "^hardware[[:space:]]ethernet[[:space:]].\+;$" | cut -d' ' -f3 | tr -d ';'`
                    ip=`cat $path | grep "^fixed-address[[:space:]].\+;$" | cut -d' ' -f2 | tr -d ';'`

                    returnarray=($name $mac $ip)

                    for i in "${returnarray[@]}"; do
                        echo $i
                    done
                    exit 0
                else
                    exit 1
                fi

            fi
        fi
        ;;

    global)

        path="/etc/dhcp/.uswg_dhcp_config/dhcp_base_global.conf"

        ./bash/shared/exist_file.sh $path
        
        if [ $? -eq 0 ]; then
            cat $path | grep authoritative | tr -d ';'
            cat $path | grep ddns-update-style | cut -d' ' -f2 | tr -d ';'
            exit 0
        else
            exit 1
        fi
        ;;

    *)
        exit 5
        ;;

esac