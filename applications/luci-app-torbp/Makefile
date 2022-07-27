include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-torbp
PKG_VERSION:=1.0
PKG_RELEASE:=1

LUCI_DEPENDS:=+tor +tor-geoip +obfs4proxy
LUCI_TITLE:=Luci Tor bridges proxy
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/config/torbp
endef

include ../../luci.mk

