#!/bin/bash
# GitHub 只克隆指定目录到本地
function merge_package() {
    # 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    if [[ $# -lt 3 ]]; then
        echo "Syntax error: [$#] [$*]" >&2
        return 1
    fi
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" target_dir="$3" && shift 3
    rootdir="$PWD"
    localdir="$target_dir"
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    # 使用循环逐个移动文件夹
    for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
    done
    cd "$rootdir"
}

### 系统信息定制 ###
# 默认ip为10.10.10.1
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate

# 修改默认主题为Argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# TTYD 自动登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 修改系统信息
cp -f $GITHUB_WORKSPACE/banner package/base-files/files/etc/banner

# 定制golang版本 1.23.0 Alist3.36.0 go >=1.22.4
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

### 第三方应用安装 ###
# diskman
git clone https://github.com/lisaac/luci-app-diskman package/luci-app-diskman

# netdata
rm -rf feeds/luci/applications/luci-app-netdata
git clone --depth=1 https://github.com/gnodgl/luci-app-netdata package/luci-app-netdata

# OpenClash
merge_package master https://github.com/vernesong/OpenClash package luci-app-openclash

# HomeProxy
git clone https://github.com/muink/openwrt-chinadns-ng package/chinadns-ng
git clone https://github.com/muink/luci-app-homeproxy package/luci-app-homeproxy
#git clone https://github.com/immortalwrt/homeproxy package/homeproxy

# MosDNS
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/luci/applications/luci-app-mosdns
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Argon主题
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# 在线用户
git clone --depth=1 https://github.com/gnodgl/luci-app-onliner package/luci-app-onliner

### 菜单调整 ###
# nlbwmon带宽监控调整菜单位置到网络
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's/services/network/g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js

# Frpc菜单名修改
sed -i 's,frp 客户端,Frp 客户端,g' feeds/luci/applications/luci-app-frpc/po/zh_Hans/frpc.po

# UPnP菜单名修改
sed -i 's,UPnP IGD 和 PCP\/NAT-PMP 服务,通用即插即用（UPnP）,g' feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po
sed -i 's,UPnP IGD & PCP\/NAT-PMP,UPnP,g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json

# Samba4菜单调整至服务
sed -i 's/nas/services/g' feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json

# ttyd菜单调整至系统
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json


### 主题定制 ###
# Argon主题定制
sed -i 's/bing/none/g' package/luci-app-argon-config/root/etc/config/argon
sed -i 's,Argon 主题设置,Argon 设置,g' package/luci-app-argon-config/po/zh_Hans/argon-config.po
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp -f $GITHUB_WORKSPACE/images/favicon.ico package/luci-theme-argon/htdocs/luci-static/argon/favicon.ico


./scripts/feeds update -a
./scripts/feeds install -a
