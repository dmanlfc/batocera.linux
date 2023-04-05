###########################################################
#
# zesarux
#
###########################################################
# Version: Commits on Apr 6, 2023
ZESARUX_VERSION = f320730d59e4fe234d288489da0c94f68f736528
ZESARUX_SITE = $(call github,chernandezba,zesarux,$(ZESARUX_VERSION))
ZESARUX_SOURCE = ZEsarUX-$(ZESARUX_VERSION).tar.gz
ZESARUX_LICENSE = GPLv3
ZESARUX_LICENSE_FILES = /src/LICENSE
ZESARUX_SUBDIR = src

ZESARUX_DEPENDENCIES = aalib ncurses

ZESARUX_CONF_OPTS += --c-compiler $(TARGET_CC)
ZESARUX_CONF_OPTS += --enable-memptr
ZESARUX_CONF_OPTS += --enable-visualmem
ZESARUX_CONF_OPTS += --enable-cpustats
ZESARUX_CONF_OPTS += --disable-caca

ifeq ($(BR2_PACKAGE_XORG7),y)
    ZESARUX_DEPENDENCIES += xlib_libX11 xlib_libXext xlib_libXxf86vm
else
    ZESARUX_CONF_OPTS += --disable-xwindows
    ZESARUX_CONF_OPTS += --disable-xext
    ZESARUX_CONF_OPTS += --disable-xvidmode
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
    ZESARUX_DEPENDENCIES += openssl
    ZESARUX_CONF_OPTS += --enable-ssl
endif

ifeq ($(BR2_PACKAGE_SDL2),y)
    ZESARUX_DEPENDENCIES += sdl2
    ZESARUX_CONF_OPTS += --enable-sdl2
else
    ZESARUX_CONF_OPTS += --disable-sdl
endif

ifeq ($(BR2_PACKAGE_ALSA_LIB),y)
    ZESARUX_DEPENDENCIES += alsa-lib
else
    ZESARUX_CONF_OPTS += --disable-alsa
endif

ifeq ($(BR2_PACKAGE_PULSEAUDIO),y)
    ZESARUX_DEPENDENCIES += pulseaudio
else
    ZESARUX_CONF_OPTS += --disable-pulse
endif

define ZESARUX_CONFIGURE_CMDS
    (cd $(@D)/src; rm -f config.cache; \
        $(TARGET_CONFIGURE_OPTS) \
        $(TARGET_CONFIGURE_ARGS) \
        CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include \
            -I$(STAGING_DIR)/usr/include/X11" \
        LDFLAGS="-L$(STAGING_DIR)/usr/lib -lncurses -ltinfo" \
        ./configure \
        --prefix=/usr \
        $(ZESARUX_CONF_OPTS) \
    )
endef

define ZESARUX_BUILD_CMDS
    $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/src
endef

# removed docs speech_filters
define ZESARUX_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr
    mkdir -p $(TARGET_DIR)/usr/bin
    mkdir -p $(TARGET_DIR)/usr/share/zesarux/
    (cd $(@D)/src && COMMONFILES="*.odt mantransfev3.bin *.rom zxuno.flash tbblue.mmc \
        my_soft zesarux.mp3 zesarux.xcf editionnamegame.tap* bin_sprite_to_c.sh \
        keyboard_*.bmp z88_shortcuts.bmp" \
        && cp -f -a $$COMMONFILES $(TARGET_DIR)/usr/share/zesarux/)
    cp $(@D)/src/zesarux $(TARGET_DIR)/usr/bin/
endef

define ZESARUX_EVMPAY
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp -f $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/zesarux/*.keys $(TARGET_DIR)/usr/share/evmapy
endef

ZESARUX_POST_INSTALL_TARGET_HOOKS += ZESARUX_EVMPAY

$(eval $(autotools-package))
