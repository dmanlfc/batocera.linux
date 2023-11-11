################################################################################
#
# dolphin-triforce
#
################################################################################
# Version: 15 Mar, 2023
DOLPHIN_TRIFORCE_VERSION = 6b7664dd230de299bae22150be77f4766cddde83
DOLPHIN_TRIFORCE_SITE = https://crediar.dev/crediar/dolphin
DOLPHIN_TRIFORCE_SITE_METHOD = git
DOLPHIN_TRIFORCE_LICENSE = GPLv2+
DOLPHIN_TRIFORCE_GIT_SUBMODULES = YES
DOLPHIN_TRIFORCE_SUPPORTS_IN_SOURCE_BUILD = NO

DOLPHIN_TRIFORCE_DEPENDENCIES += bluez5_utils hidapi host-xz ffmpeg libcurl
DOLPHIN_TRIFORCE_DEPENDENCIES += libevdev libpng libusb lzo xz sdl2 zlib

DOLPHIN_TRIFORCE_CONF_OPTS  = -DCMAKE_BUILD_TYPE=Release
DOLPHIN_TRIFORCE_CONF_OPTS += -DBUILD_SHARED_LIBS=OFF
DOLPHIN_TRIFORCE_CONF_OPTS += -DDISTRIBUTOR='batocera.linux'
DOLPHIN_TRIFORCE_CONF_OPTS += -DUSE_DISCORD_PRESENCE=OFF
DOLPHIN_TRIFORCE_CONF_OPTS += -DUSE_MGBA=OFF
DOLPHIN_TRIFORCE_CONF_OPTS += -DUSE_UPNP=OFF
DOLPHIN_TRIFORCE_CONF_OPTS += -DENABLE_TESTS=OFF
DOLPHIN_TRIFORCE_CONF_OPTS += -DENABLE_AUTOUPDATE=OFF
DOLPHIN_TRIFORCE_CONF_OPTS += -DENABLE_ANALYTICS=OFF
DOLPHIN_TRIFORCE_CONF_OPTS += -DENABLE_SDL=ON
DOLPHIN_TRIFORCE_CONF_OPTS += -DENABLE_CLI_TOOL=OFF

ifeq ($(BR2_PACKAGE_XSERVER_XORG_SERVER),y)
    DOLPHIN_TRIFORCE_DEPENDENCIES += xserver_xorg-server
    DOLPHIN_TRIFORCE_CONF_OPTS += -DENABLE_X11=ON
else
    DOLPHIN_TRIFORCE_CONF_OPTS += -DENABLE_X11=OFF
endif

ifeq ($(BR2_PACKAGE_VULKAN_HEADERS)$(BR2_PACKAGE_VULKAN_LOADER),yy)
    DOLPHIN_TRIFORCE_CONF_OPTS += -DENABLE_VULKAN=ON
else
    DOLPHIN_TRIFORCE_CONF_OPTS += -DENABLE_VULKAN=OFF
endif

# add triforce legacy app image
define DOLPHIN_TRIFORCE_APPIMAGE
    mkdir -p $(TARGET_DIR)/usr/bin
    $(INSTALL) -D -m 0555 \
        "$(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/dolphin-triforce/dolphin-triforce.AppImage" \
        "${TARGET_DIR}/usr/bin/dolphin-triforce-legacy"
endef

define DOLPHIN_TRIFORCE_INI
    mkdir -p $(TARGET_DIR)/usr/share/triforce
    # copy extra ini files
    cp -prn $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/dolphin-triforce/*.ini \
		$(TARGET_DIR)/usr/share/triforce
endef

define DOLPHIN_TRIFORCE_EVMAPY
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp -prn $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/dolphin-triforce/*.keys \
		$(TARGET_DIR)/usr/share/evmapy
endef

define DOLPHIN_TRIFORCE_RM_NOGUI
	rm $(TARGET_DIR)/usr/bin/dolphin-triforce-nogui
endef

DOLPHIN_TRIFORCE_POST_INSTALL_TARGET_HOOKS += DOLPHIN_TRIFORCE_APPIMAGE
DOLPHIN_TRIFORCE_POST_INSTALL_TARGET_HOOKS += DOLPHIN_TRIFORCE_INI
DOLPHIN_TRIFORCE_POST_INSTALL_TARGET_HOOKS += DOLPHIN_TRIFORCE_EVMAPY

# remove no-gui binary to save space for x86 builds that use QT
ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_X86_64_ANY),y)
    DOLPHIN_TRIFORCE_POST_INSTALL_TARGET_HOOKS += DOLPHIN_TRIFORCE_RM_NOGUI
endif

$(eval $(cmake-package))
