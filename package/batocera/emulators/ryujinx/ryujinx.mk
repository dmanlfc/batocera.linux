################################################################################
#
# ryujinx
#
################################################################################

RYUJINX_VERSION = 1.1.4
RYUJINX_SOURCE = ryujinx-$(RYUJINX_VERSION)-linux_x64.tar.gz
RYUJINX_SITE = https://github.com/Ryujinx/release-channel-master/releases/download/$(RYUJINX_VERSION)
RYUJINX_DEPENDENCIES = sdl2 openal hicolor-icon-theme adwaita-icon-theme

define RYUJINX_INSTALL_TARGET_CMDS
        mkdir -p $(TARGET_DIR)/usr/ryujinx
        cp -pr ${@D}/* $(TARGET_DIR)/usr/ryujinx/
        #$(INSTALL) -D -m 0755 ${@D}/Ryujinx $(TARGET_DIR)/usr/ryujinx/Ryujinx

        #evmap config
        mkdir -p $(TARGET_DIR)/usr/share/evmapy
        cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/ryujinx/switch.ryujinx.keys $(TARGET_DIR)/usr/share/evmapy
endef

$(eval $(generic-package))
