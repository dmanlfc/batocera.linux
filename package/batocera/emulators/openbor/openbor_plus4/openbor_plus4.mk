################################################################################
#
# openbor_plus4
#
################################################################################
 
OPENBOR_PLUS4_VERSION = v1.526
OPENBOR_PLUS4_SITE = $(call github,whitedragon0000,OpenBOR_PLUS,$(OPENBOR_PLUS4_VERSION))
OPENBOR_PLUS4_LICENSE = BSD
OPENBOR_PLUS4_LICENSE_FILE = LICENSE

OPENBOR_PLUS4_DEPENDENCIES = libvpx sdl2 libpng libogg libvorbis host-yasm sdl2_gfx
OPENBOR_PLUS4_EXTRAOPTS=""

ifeq ($(BR2_x86_64),y)
    OPENBOR_PLUS4_EXTRAOPTS=BUILD_LINUX_LE_x86_64=1
endif

ifeq ($(BR2_arm)$(BR2_aarch64),y)
    OPENBOR_PLUS4_EXTRAOPTS=BUILD_LINUX_LE_arm=1
endif

define OPENBOR_PLUS4_BUILD_CMDS
    cd $(@D)/engine && chmod +x $(@D)/engine/version.sh && $(@D)/engine/version.sh
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" \
	    -C $(@D)/engine -f Makefile $(OPENBOR_PLUS4_EXTRAOPTS) VERBOSE=1
endef

define OPENBOR_PLUS4_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/engine/OpenBOR $(TARGET_DIR)/usr/bin/OpenBOR_Plus4
endef

$(eval $(generic-package))
