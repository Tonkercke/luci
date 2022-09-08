include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-xray
PKG_VERSION:=1.16.1
PKG_RELEASE:=1

PKG_LICENSE:=MPLv2
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=yichya <mail@yichya.dev>
PKG_BUILD_PARALLEL:=1

LUCI_TITLE:=LuCI Support for Xray
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+luci-base +xray-core +dnsmasq +ca-bundle +PACKAGE_firewall4:kmod-nft-tproxy +PACKAGE_firewall:ipset +PACKAGE_firewall:iptables +PACKAGE_firewall:iptables-mod-tproxy

define Package/$(PKG_NAME)/config
menu "luci-app-xray Configuration"
	depends on PACKAGE_$(PKG_NAME)

config PACKAGE_XRAY_INCLUDE_CLOUDFLARE_ORIGIN_ROOT_CA
	bool "Include Cloudflare Origin Root CA"
	default n

config PACKAGE_XRAY_INFINITE_RETRY_ON_STARTUP
	bool "Retry infinitely on Xray startup (may solve some startup problems)"
	default n

config PACKAGE_XRAY_RLIMIT_NOFILE_LARGE
	bool "Increase Max Open Files Limit (recommended)"
	default y

choice
	prompt "Limit memory use by setting rlimit_data (experimental)"
	default PACKAGE_XRAY_RLIMIT_DATA_UNLIMITED
	config PACKAGE_XRAY_RLIMIT_DATA_UNLIMITED
		bool "Not limited"
	config PACKAGE_XRAY_RLIMIT_DATA_SMALL
		bool "Small limit (about 50MB)"
	config PACKAGE_XRAY_RLIMIT_DATA_LARGE
		bool "Large limit (about 210MB)"
endchoice

endmenu
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [[ ! -f $${IPKG_INSTROOT}/usr/share/xray/xray.init.replaced ]]; then
	if [[ ! -f $${IPKG_INSTROOT}/etc/init.d/xray ]]; then
	    echo "echo This file does nothing" > $${IPKG_INSTROOT}/etc/init.d/xray
	fi
	mv $${IPKG_INSTROOT}/etc/init.d/xray $${IPKG_INSTROOT}/usr/share/xray/xray.init.replaced
	mkdir -p $${IPKG_INSTROOT}/etc/config
	mv $${IPKG_INSTROOT}/tmp/xray.conf $${IPKG_INSTROOT}/etc/config/xray
fi
rm -f $${IPKG_INSTROOT}/tmp/xray.conf
mkdir -p $${IPKG_INSTROOT}/etc/init.d
mv $${IPKG_INSTROOT}/tmp/xray.init $${IPKG_INSTROOT}/etc/init.d/xray
if [[ -z "$${IPKG_INSTROOT}" ]]; then
	if [[ -f /etc/uci-defaults/xray ]]; then
		( . /etc/uci-defaults/xray ) && rm -f /etc/uci-defaults/xray
	fi
	rm -rf /tmp/luci-indexcache* /tmp/luci-modulecache
fi
exit 0
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/xray
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
