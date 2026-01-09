include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-geph5
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=YourName
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for Geph5
  DEPENDS:=+luci-base +wget-ssl +ca-certificates
  # 注意：这里假设你已经有了 geph5 的二进制包，或者你可以手动添加依赖
endef

define Package/$(PKG_NAME)/description
  LuCI interface for Geph5 Client.
endef

define Build/Compile
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
