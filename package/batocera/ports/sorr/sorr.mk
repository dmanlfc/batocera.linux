################################################################################
#
# sorr
#
################################################################################
# Version: Commits on Dec 10, 2023
SORR_VERSION = bf92f7604fcecf8d6a7ac305d9b46bce18ea5669
SORR_SITE = https://github.com/SplinterGU/BennuGD2.git
SORR_SITE_METHOD = git
SORR_GIT_SUBMODULES = YES
SORR_LICENSE = MIT
SORR_LICENSE_FILE = LICENSE.md

SORR_DEPENDENCIES += sdl2

SORR_SUPPORTS_IN_SOURCE_BUILD = NO

SORR_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release
SORR_CONF_OPTS += -DBUILD_SHARED_LIBS=OFF

define SORR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/buildroot-build/sorr \
	    $(TARGET_DIR)/usr/bin/sorr
endef

define SORR_EVMAPY
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/ports/sorr/sorr.keys \
	    $(TARGET_DIR)/usr/share/evmapy
endef

SORR_POST_INSTALL_TARGET_HOOKS += SORR_EVMAPY

$(eval $(cmake-package))
