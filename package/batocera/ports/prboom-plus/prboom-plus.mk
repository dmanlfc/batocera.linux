################################################################################
#
# prboom-plus
#
################################################################################

PRBOOM_PLUS_VERSION = v2.6.2
PRBOOM_PLUS_SITE = https://github.com/coelckers/prboom-plus.git
PRBOOM_PLUS_SITE_METHOD=git
PRBOOM_PLUS_GIT_SUBMODULES=YES
PRBOOM_PLUS_LICENSE = GPLv3
PRBOOM_PLUS_DEPENDENCIES = sdl2 fluidsynth libglu libmad libvorbis pcre sdl2_image sdl2_mixer sdl2_net
PRBOOM_PLUS_SUBDIR = prboom2
PRBOOM_PLUS_SUPPORTS_IN_SOURCE_BUILD = NO

PRBOOM_PLUS_CONF_OPTS = -DCMAKE_CROSSCOMPILING=FALSE -DCMAKE_BUILD_TYPE=Release

define PRBOOM_PLUS_INSTALL_TARGET_CMDS
        mkdir -p $(TARGET_DIR)/usr/bin
        mkdir -p $(TARGET_DIR)/usr/share/prboom-plus
        $(INSTALL) -D -m 0755 $(@D)/prboom2/buildroot-build/prboom-plus $(TARGET_DIR)/usr/bin/prboom-plus
        cp -a $(@D)/prboom2/buildroot-build/prboom-plus.wad $(TARGET_DIR)/usr/share/prboom-plus/

        # evmap config
        mkdir -p $(TARGET_DIR)/usr/share/evmapy
        cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/ports/prboom-plus/prboom-plus.keys $(TARGET_DIR)/usr/share/evmapy
endef

$(eval $(cmake-package))
