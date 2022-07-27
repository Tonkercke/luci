# Copyright 2018-2020 Alex D (https://gitlab.com/Nooblord/)
# Copyright 2022 ZeroChaos (https://github.com/zerolabnet/)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-torbp
PKG_VERSION:=1.0
PKG_RELEASE:=1

LUCI_DEPENDS:=+tor +tor-geoip +obfs4proxy
LUCI_TITLE:=Tor bridges proxy
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/config/torbp
endef

include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call BuildPackage,luci-app-torbp))
