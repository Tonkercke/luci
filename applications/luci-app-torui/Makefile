include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-torui
PKG_VERSION:=1.01
PKG_RELEASE:=0

LUCI_TITLE:=Luci Tor UI
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+tor +wget-ssl

define Package/$(PKG_NAME)/conffiles
/etc/config/torui
endef

define Package/$(PKG_NAME)/postinst
	#!/bin/sh
	if [ -z "$${IPKG_INSTROOT}" ]; then
		rm -f /tmp/luci-indexcache* 2>/dev/null
	fi
	exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
