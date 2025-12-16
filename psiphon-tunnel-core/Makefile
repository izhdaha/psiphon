include $(TOPDIR)/rules.mk

PKG_NAME:=psiphon-tunnel-core
PKG_VERSION:=2.0.34
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Psiphon-Labs/psiphon-tunnel-core/archive/refs/tags
PKG_HASH:=b8c9e4dc56c0201081d0bef88473e57d13479bd165b258fdfa6fb26df2c49d66
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=OpenWrt Community <openwrt-devel@lists.openwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/Psiphon-Labs/psiphon-tunnel-core
GO_PKG_BUILD_PKG:=github.com/Psiphon-Labs/psiphon-tunnel-core/ConsoleClient

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/psiphon
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Psiphon Tunnel Core Client
  URL:=https://github.com/Psiphon-Labs/psiphon-tunnel-core
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/psiphon/description
  Psiphon is a circumvention system that uses a combination of secure communication
  and obfuscation technologies (VPN, SSH, and HTTP Proxy).
  
  This package provides the standalone 'ConsoleClient' binary installed as 'psiphon'.
endef

define Package/psiphon/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/psiphon.conf $(1)/etc/config/psiphon

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/psiphon.config $(1)/etc/psiphon.config

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/psiphon.init $(1)/etc/init.d/psiphon

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/ConsoleClient $(1)/usr/bin/psiphon
endef

$(eval $(call BuildPackage,psiphon))
