#!/bin/sh
#v0.6

#打印颜色信息
#1粗体、高亮
#22非粗体
#4字体下划线
#24无下划线
#5闪烁
#25无闪烁
#7前景背景反转
#27关闭反转
#m结束转义序列
#黑 红 绿 黄 蓝 洋红 青 白 0 1 2 3 4 5 6 7
red='\e[91m'
green='\e[32m'
yellow='\e[33m'
blue='\e[34m'
purple='\e[35m'
none='\e[0m'
echo_red() {
echo -e "${red}$*${none}";
}
echo_green() {
echo -e "${green}$*${none}";
}
echo_yellow() {
echo -e "${yellow}$*${none}";
}
#判断路由器频段
#result $wireless_num路由器无线驱动数量
#return 2：2.4G单频
#@ 5：5G单频
#@ 25：双频或混频
#@ 1：返回错误值，没有无线驱动或无线驱动有3个以上
test_roter_freq() {
wireless_num=$(uci get wireless.globals.wirelessNum)
case $wireless_num in
1)
if [ -n "$(uci show wireless | grep "freqValue='2'")" ];then
return 2
elif [ -n "$(uci show wireless | grep "freqValue='5'")" ];then
return 5
elif [ -n "$(uci show wireless | grep "freqValue='25'")" ];then
return 25
fi
;;
2)
return 25
;;
*)
return 1
;;
esac
}
#获取伪装mac地址和名字
#result $host_name
#@ $wifi_macaddr
#return 0：两个变量都有值且mac地址合法
#@ 1：有任意变量为空
#@ 2：staMac地址文档为空或不存在
#@ 3：获取随机行号连续5次不合法
get_mac_name() {
[ ! -e "$sta_mac_textPath" ] && return 2
local lineNum="$(wc -l < "$sta_mac_textPath")"
[ "$lineNum" -eq 1 ] && return 2
local count=1
while :;
do
#随机取得一个行号
a="$(head -n 2 /dev/urandom | md5sum | cut -c 1-3)"
a=$(printf %d "0x$a")
b="$(head -n 2 /dev/urandom | md5sum | cut -c 4-6)"
b=$(printf %d "0x$b")
randomLineNum=$(( ((a + b) % lineNum) + 1 ))
if [ "$randomLineNum" -gt "0" ] && [ "$randomLineNum" -le "$lineNum" ];then
break
elif [ $count -ge 5 ];then
return 3
fi
count=$(( count + 1 ))
done
#获取前后两段MAC，组合起来
local aheadMac="$(sed -n "$randomLineNum p" "$sta_mac_textPath" | cut -d "@" -f 2)"
local backMac="$(head -n 2 /dev/urandom | md5sum | cut -c 1-6 | awk '{printf "%s%s%s%s%s", substr($1,1,2), ":", substr($1,3,2), ":", substr($1,5,2)}' | awk '{print toupper($0)}')"
host_name=$(sed -n "$randomLineNum p" "$sta_mac_textPath" | cut -d "@" -f 1)
wifi_macaddr="$aheadMac:$backMac"
if [[ -z "$host_name" || -z "$wifi_macaddr" ]];then
return 1
elif [ -n "$(echo "$wifi_macaddr" | grep -E "[0-9|a-f|A-F]{2}:[0-9|a-f|A-F]{2}:[0-9|a-f|A-F]{2}:[0-9|a-f|A-F]{2}:[0-9|a-f|A-F]{2}:[0-9|a-f|A-F]{2}")" ];then
return 0
fi
}
#获得添加的所有sta网络的规则
#result $all_wireless_num
#return: 0:成功定义变量且变量有值
#@ 1：错误，$sys_release获取失败
#@ 2：错误，$all_wireless_num值为空
get_all_wireless_num() {
#没有到获取openwrt系统版本号，返回1
[ -z "$sys_release" ] && return 1
#获取无线规则，18版和19、21版本规则不一样，需要根据系统版本来区分提取。
if [ "$sys_release" == "18" ];then
all_wireless_num=$(uci show wireless | grep "wireless.@wifi-iface\[[0-9]\{1,2\}\].mode" | grep 'sta' | awk -F[.=] '{print $2}')
else
all_wireless_num=$(uci show wireless | grep 'wireless.wifinet[0-9]*.mode' | grep 'sta' | awk -F[.=] '{print $2}')
fi
[ -z "$all_wireless_num" ] && return 2
return 0
}
#打印wifi信息
#格式化输出wifi信息
#@args 1:wifi总行数
print_wifi() {
for i in $(seq 1 "$1");do
mesg=$(sed -n "${i}p" /tmp/wifiOK | sed "s/\^\&/ /g")
num=$(echo "$mesg" | awk -F"\t" '{printf("%s",$1)}')
signal=$(echo "$mesg" | awk -F"\t" '{printf("%s",$2)}')
essid=$(echo "$mesg" | awk -F"\t" '{printf("%s",$3)}' | sed "s/@##@/ /g")
address=$(echo "$mesg" | awk -F"\t" '{printf("%s",$4)}')
channel=$(echo "$mesg" | awk -F"\t" '{printf("%s",$5)}')
z_char=$(echo "$essid" | sed "s/[0-9a-zA-z[:punct:]\ ]//g" | grep -v "^$" | wc -c)
z_char=$(( z_char / 3 ))
if [ $z_char -gt 1 ];then
printf "%-5s%s\t%-$(( 26 + z_char ))s\t%s\t%s\t\n" "$num" "$signal" "$essid" "$address" "$channel"
else
printf "%-5s%s\t%-26s\t%s\t%s\t\n" "$num" "$signal" "$essid" "$address" "$channel"
fi
done
}


#scp路径，方便调用脚本
scp_path='/etc/config/scp'
#获取openwrt系统版本号
sys_release=$(awk -F"[.']" '/DISTRIB_RELEASE/{print $2}' /etc/openwrt_release)
#客户端mac地址路径
sta_mac_textPath="$scp_path/mac.txt"
