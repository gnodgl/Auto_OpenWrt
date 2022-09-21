#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 默认ip为10.10.10.1
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate


#删除原默认主题
#rm -rf package/emortal/luci-theme-argon

rm -rf package/lean/luci-theme-argon
rm -rf package/lean/luci-theme-bootstrap
rm -rf package/lean/luci-theme-material
rm -rf package/lean/luci-theme-netgear

#移除不用软件包
rm -rf feeds/luci/applications/luci-app-dockerman
rm -rf feeds/luci/applications/luci-app-wrtbwmon
rm -rf feeds/packages/net/smartdns

# 添加adguardhome
git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome
# 添加openclash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/luci-app-openclash
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-openclash/tools/po2lmo
make && sudo make install
popd

# 添加smartdns
svn co https://github.com/kenzok8/openwrt-packages/trunk/smartdns package/smartdns
svn co https://github.com/immortalwrt/luci/branches/openwrt-18.06/applications/luci-app-smartdns package/luci-app-smartdns
#添加argon-config 使用 最新argon
git clone https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
# 添加主题edge 
git clone -b 18.06 https://github.com/kiddin9/luci-theme-edge package/luci-theme-edge
# 添加主题neobird
git clone https://github.com/thinktip/luci-theme-neobird.git  package/luci-theme-neobird
# 修改 argon 为默认主题,可根据你喜欢的修改成其他的（不选择那些会自动改变为默认主题的主题才有效果）
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile


./scripts/feeds update -a
./scripts/feeds install -a
