#!/bin/bash

ARGS=$(getopt -n "$0" -o a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t: --long authoritative:,ddns-style:,subnet-name:,ip-address:,subnet-mask:,first-address:,last-address:,dns-server:,routers:,broadcast:,dlt:,mlt:,network-adapter:,ntp-server:,domain-name:,part:,host-name:,mac-address: -- "$@")

if [ $? -ne 0 ]; then
    exit 10
fi

eval set -- "$ARGS"

#part parameter ellenorzese
part=""
author=""
ddns=""
hostname=""
mac=""
ip=""
subnetmask=""
author=""
ddns=""
subnetname=""
firstaddress=""
lastaddress=""
dns=""
routers=""
broadcast=""
dlt=""
mlt=""
networkadapter=""
ntp=""
domainname=""

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
    --authoritative | -a)
        if [[ -n "$2" && "$2" != -* ]]; then
            author="$2"
            shift 2
        else
            exit 10
        fi
        ;;
    
    --ddns-style | -b)
        if [[ -n "$2" && "$2" != -* ]]; then
            ddns="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --host-name | -s)
        if [[ -n "$2" && "$2" != -* ]]; then
            hostname="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --ip-address | -d)
        if [[ -n "$2" && "$2" != -* ]]; then
            ip="$2"
            shift 2
        else
            exit 10
        fi
        ;;
                
    --mac-address | -t)
        if [[ -n "$2" && "$2" != -* ]]; then
            mac="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --subnet-name | -c)
        if [[ -n "$2" && "$2" != -* ]]; then
            subnetname="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --subnet-mask | -e)
        if [[ -n "$2" && "$2" != -* ]]; then
            subnetmask="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --first-address | -f)
        if [[ -n "$2" && "$2" != -* ]]; then
            firstaddress="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --last-address | -g)
        if [[ -n "$2" && "$2" != -* ]]; then
            lastaddress="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --dns-server | -h)
        if [[ -n "$2" && "$2" != -* ]]; then
            dns="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --routers | -i)
        if [[ -n "$2" && "$2" != -* ]]; then
            routers="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --broadcast | -j)
        if [[ -n "$2" && "$2" != -* ]]; then
            broadcast="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --dlt | -k)
        if [[ -n "$2" && "$2" != -* ]]; then
            dlt="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --mlt | -l)
        if [[ -n "$2" && "$2" != -* ]]; then
            mlt="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --network-adapter | -m)
        if [[ -n "$2" && "$2" != -* ]]; then
            networkadapter="$2"
            shift 2
        else
            exit 10
        fi
        ;;

    --ntp-server | -n)
        if [[ -n "$2" && "$2" != -* ]]; then
            ntp="$2"
            shift 2
        else
            exit 10
        fi
        ;;
    --domain-name | -o)
        if [[ -n "$2" && "$2" != -* ]]; then
            domainname="$2"
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

#part parameter alapjan vegrehajtas
case "$part" in
    backup)
        path="/etc/.uswg_configs/dhcp/dhcp_config/"
        oldpath="/etc/.uswg_configs/dhcp/old_dhcp_config/"
        dhpath="/etc/dhcp/dhcpd.conf"
        adapterpath="/etc/default/isc-dhcp-server"


        if [ -z `ls -A $oldpath | tr -d ' ' | tr -d '\n'` ]; then
            sudo cp $path* $oldpath
            sudo cp $dhpath $oldpath
            sudo cp $adapterpath $oldpath
        else
            sudo rm $oldpath*
            sudo cp $path* $oldpath
            sudo cp $dhpath $oldpath
            sudo cp $adapterpath $oldpath
        fi
        exit 0
        ;;

    global)
        
        path="/etc/.uswg_configs/dhcp/dhcp_config/dhcp_base_global.conf"

        ./bash/shared/exist_file.sh $path
        exitcode=$?
        

        if [ $exitcode -eq 0 ]; then
            sudo -S rm $path
        fi
        case "$author" in
            yes)
                echo "authoritative;" | sudo tee -a $path > /dev/null
                ;;
            no)
                echo "not authoritative;" | sudo tee -a $path > /dev/null
                ;;
            *)
                exit 5
                ;;
        esac

        case "$ddns" in
            standard)
                sudo echo "ddns-update-style standard;" | sudo tee -a $path > /dev/null
                ;;

            interim)
                sudo echo "ddns-update-style interim;" | sudo tee -a $path > /dev/null
                ;;

            none)
                sudo echo "ddns-update-style none;" | sudo tee -a $path > /dev/null
                ;;
            *)
                exit 5
                ;;
        esac
        
        ;;

    static-host)

        if [ -z "$hostname" ] || [ -z "$ip" ] || [ -z "$mac" ]; then
            #invalid ertek, ures bemenet
            exit 5
        fi

        path="/etc/.uswg_configs/dhcp/dhcp_config/dhcp_static_$hostname.conf"

        ./bash/shared/exist_file.sh $path

        if [ $? -eq 0 ]; then
            exit 4
        else
            sudo touch $path
            sudo echo "#static_host $hostname" | sudo tee -a $path > /dev/null
            sudo echo "host $hostname {" | sudo tee -a $path > /dev/null
            sudo echo "hardware ethernet $mac;" | sudo tee -a $path > /dev/null
            sudo echo "fixed-address $ip;" | sudo tee -a $path > /dev/null
            sudo echo "}" | sudo tee -a $path > /dev/null
        fi

        ;;

    subnet)

        if [ -z "$ip" ] || [ -z "$subnetmask" ] || [ -z "$subnetname" ] || [ -z "$firstaddress" ] || [ -z "$lastaddress" ] || [ -z "$dns" ] || [ -z "$routers" ] || [ -z "$broadcast" ] || [ -z "$dlt" ] || [ -z "$mlt" ] || [ -z "$networkadapter" ]; then
            #invalid ertek, ures bemenet
            exit 5
        else
            path="/etc/.uswg_configs/dhcp/dhcp_config/dhcp_subnet_$subnetname.conf"
            
            ./bash/shared/exist_file.sh $path

            if [ $? -eq 0 ]; then
                
                exit 4

            else

                sudo touch $path

                sudo echo "#subnet_name $subnetname assigned network-adapter $networkadapter" | sudo tee -a $path > /dev/null
                sudo echo "subnet $ip netmask $subnetmask{" | sudo tee -a $path > /dev/null
                sudo echo "range $firstaddress $lastaddress;" | sudo tee -a $path > /dev/null
                sudo echo "option domain-name-servers $dns;" | sudo tee -a $path > /dev/null
                sudo echo "option subnet-mask $subnetmask;" | sudo tee -a $path > /dev/null
                sudo echo "option routers $routers;" | sudo tee -a $path > /dev/null
                sudo echo "option broadcast-address $broadcast;" | sudo tee -a $path > /dev/null

                if [ ! -z "$ntp" ]; then
                    sudo echo "option ntp-servers $ntp;" | sudo tee -a $path > /dev/null
                fi

                if [ ! -z "$domainname" ]; then
                    sudo echo "option domain-name \"$domainname\";" | sudo tee -a $path > /dev/null
                fi
                sudo echo "default-lease-time $dlt;" | sudo tee -a $path > /dev/null
                sudo echo "max-lease-time $mlt;" | sudo tee -a $path > /dev/null
                sudo echo "}" | sudo tee -a $path > /dev/null

            fi
        fi
        
        ;;
    
    network-adapter)

        path="/etc/default/isc-dhcp-server"

        ./bash/shared/exist_file.sh $path

        exitcode=$?

        if [ $exitcode -ne 0 ]; then
            exit 1
        fi

        line=`cat $path | grep "^INTERFACESv4=\".*$networkadapter.*\"$"`

        if [ -z "$line" ]; then
            
            basecontent="INTERFACESv4=\""
            existadapters=`grep -n "^INTERFACESv4=\".*\"$" $path | cut -d'"' -f2`
            endcharacter="\""

            linenumber=`grep -n "^INTERFACESv4=\".*\"$" $path | cut -d':' -f1`


            if [[ -n "$linenumber" ]]; then
                if [ -z "$existadapters" ]; then
                    newcontent=$basecontent$existadapters$networkadapter$endcharacter
                    sudo -S sed -i "${linenumber}s/.*/${newcontent}/" "$path"
                else
                    newcontent=$basecontent$existadapters" "$networkadapter$endcharacter
                    sudo -S sed -i "${linenumber}s/.*/${newcontent}/" "$path"
                fi
            else
                #nem talalhato a szoveg
                exit 11
            fi
        fi

        

        ;;

    *)
        exit 5
        ;;
esac

#./bash/dhcp/dhcp_merge_config.sh