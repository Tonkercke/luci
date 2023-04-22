#!/bin/bash
#v1.2

#更改wifi身份信息并验证是否更改成功
#args 19|21:wifinet[0-9]*
#@ 18:@wifi-iface[0]
#return 成功0 失败1
change_wifi_info() {
get_mac_name
wifi_num=$1
wifi_name=$(uci get wireless."$wifi_num".ssid)
pci_name=$(uci get wireless."$wifi_num".network)
old_hostName=$(uci get network."$pci_name".hostname)
old_macaddr=$(uci get wireless."$wifi_num".macaddr)
[ -z "$wifi_name" ] && echo "找不到wifi" && exit 1
echo -e "\n\n更改的网络: $wifi_name\n"
for i in $(seq 5);do
get_mac_name
#修改伪装的主机名称
uci set network."$pci_name".hostname="$host_name"
uci set wireless."$wifi_num".macaddr="$wifi_macaddr"
if [[ "$(uci get network."$pci_name".hostname)" != "$old_hostName" && "$(uci get wireless."$wifi_num".macaddr)" != "$old_macaddr" ]];then
echo -e "主机名称更改成功.\n更改前主机名: $old_hostName\n更改后主机名: $host_name"
echo -e "\nMAC地址更改成功 .\n更改前MAC地址: $old_macaddr\n更改后MAC地址: $wifi_macaddr"
break
fi
if [ "$i" == 5 ];then
echo "$wifi_name更改信息没有成功"
return 1
fi
sleep 1
done
return 0
}

#main
. '/etc/config/scp/tools_func.sh'
#获取用户输入的wifi名称
user_input="$1"
#判断是luci点击触发，进行二次取值
if [ "$user_input" == ":" ];then
user_input="$(echo "$*" | awk -F': ' '{printf("%s\n", $2)}')"
luci_mode=1
else
user_input=$*
luci_mode=0
fi
#输入all修改所有wifi的信息
if [[ "${user_input}" == "all" ]];then
#获得添加的所有网络的规则
get_all_wireless_num
for i in $all_wireless_num;do
change_wifi_info "$i"
if [ "$?" == "1" ];then
exit 1
fi
done
uci commit wireless
uci commit network
#luci点击触发
elif [ "$luci_mode" == "1" ];then
get_mac_name
change_wifi_info "$user_input"
if [ "$?" == "1" ];then
exit 1
fi
uci commit network
uci commit wireless
elif [ -z "$user_input" ];then
echo "输入为空"
exit 1
else
#获取要修改mac的目标wifi
get_all_wireless_num
wifi_all_name=
for i in $all_wireless_num;do
wifi_all_name="$wifi_all_name####$(uci get wireless."$i".ssid)"
done
for i in $(echo "$*" | sed "s/ /\n/g");do
change_target_num=$(echo "$wifi_all_name" | sed "s/####/\n/g" | grep "$i" | awk '{printf("%s|###|",$0)}')
wifi_num=
for j in $(echo "$change_target_num" | sed "s/|###|/\n/g");do
wifi_num="$wifi_num $(uci show wireless | grep "$j" | grep -E "wireless.wifinet[0-9]*[\.]ssid" | cut -d "." -f 2)"
done
for j in $wifi_num;do
change_wifi_info "$j"
if [ "$?" == "1" ];then
exit 1
fi
done
done
uci commit network
uci commit wireless
fi
