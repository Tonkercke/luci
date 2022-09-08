include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-torui
PKG_VERSION:=1.01
PKG_RELEASE:=0

LUCI_TITLE:=Luci Tor UI
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+tor +tor-geoip +tor-gencert +tor-resolve

define Package/$(PKG_NAME)/conffiles
/etc/config/torui
endef

define Package/luci-app-torui/postinst
	#!/bin/sh
	if [ -z "$${IPKG_INSTROOT}" ]; then
		rm -f /tmp/luci-indexcache* 2>/dev/null
	fi
	exit 0
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
