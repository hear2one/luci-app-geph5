include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-geph5
PKG_VERSION:=2.0.0
PKG_RELEASE:=4

PKG_LICENSE:=MIT
PKG_MAINTAINER:=hear2one

LUCI_TITLE:=LuCI support for Geph5 Client
LUCI_DESCRIPTION:=Modern LuCI interface and procd service integration for Geph5 Client.
LUCI_DEPENDS:=+luci-base +ca-bundle +ca-certificates
LUCI_MAINTAINER:=hear2one
LUCI_URL:=https://github.com/hear2one/luci-app-geph5
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/config/geph5
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}$${PKG_INSTROOT}" ]; then
	chmod 0755 /etc/init.d/geph5 /usr/libexec/geph5-action /etc/uci-defaults/99-luci-app-geph5 2>/dev/null || true
	if [ -x /etc/uci-defaults/99-luci-app-geph5 ]; then
		/etc/uci-defaults/99-luci-app-geph5 && rm -f /etc/uci-defaults/99-luci-app-geph5
	fi
	rm -f /tmp/luci-indexcache.*
	rm -rf /tmp/luci-modulecache/
	/etc/init.d/rpcd reload 2>/dev/null || true
fi
exit 0
endef

define Build/Prepare/$(PKG_NAME)
	$(FIND) $(PKG_BUILD_DIR)/root $(PKG_BUILD_DIR)/htdocs -type d -exec chmod 0755 {} +
	$(FIND) $(PKG_BUILD_DIR)/root $(PKG_BUILD_DIR)/htdocs -type f -exec chmod 0644 {} +
	chmod 0755 \
		$(PKG_BUILD_DIR)/root/etc/init.d/geph5 \
		$(PKG_BUILD_DIR)/root/etc/uci-defaults/99-luci-app-geph5 \
		$(PKG_BUILD_DIR)/root/usr/libexec/geph5-action
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
