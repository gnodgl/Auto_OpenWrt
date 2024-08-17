#!/bin/bash
# 默认中文
uci set luci.main.lang=zh_cn

# 设置时区
# uci -q batch <<-EOF
# 	set system.@system[0].timezone='CST-8'
# 	set system.@system[0].zonename='Asia/Shanghai'
#
# 	delete system.ntp.server
# 	add_list system.ntp.server='ntp1.aliyun.com'
# 	add_list system.ntp.server='ntp.tencent.com'
# 	add_list system.ntp.server='ntp.ntsc.ac.cn'
# 	add_list system.ntp.server='time.ustc.edu.cn'
# EOF
# root默认密码root
sed -i 's|^root:[^:]*:|root:$1$zIMgxsz9$tIl71DXbq00Tkjwk0jGVf.:|' /etc/shadow
# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/argon'
# Set default lan ip to 10.10.10.1
uci set network.lan.ipaddr=10.10.10.1
# Set default lan to eth1
uci set network.lan.device='eth1'
# Set default wan to eth0
uci set network.wan.device='eth0'
uci set network.wan6.device='eth0'
#commit all uci
uci commit

exit 0
