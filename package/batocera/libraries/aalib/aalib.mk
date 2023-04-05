###########################################################
#
# aalib
#
###########################################################

AALIB_VERSION = 1.4rc5
AALIB_SOURCE = aalib-$(AALIB_VERSION).tar.gz
AALIB_SITE = https://downloads.sourceforge.net/sourceforge/aa-project
AALIB_LICENSE = LGPL-2.1-or-later
AALIB_LICENSE_FILES = COPYING

AALIB_INSTALL_STAGING = YES

AALIB_DEPENDENCIES = gpm

ifeq ($(BR2_PACKAGE_XLIB_LIBX11),y)
    AALIB_DEPENDENCIES += xlib_libX11
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXT),y)
    AALIB_DEPENDENCIES += xlib_libXt
endif

define AALIB_CONFIGURE_CMDS
    cd $(@D) && \
    $(TARGET_CONFIGURE_OPTS) \
    $(TARGET_CONFIGURE_ARGS) \
    CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include" \
    LDFLAGS="-L$(STAGING_DIR)/usr/lib -lncurses -ltinfo" \
    ./configure \
        --prefix=/usr \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info
endef

define AALIB_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 755 $(@D)/src/.libs/libaa.so.1.0.4 $(TARGET_DIR)/usr/lib/libaa.so.1.0.4
    ln -sf /usr/lib/libaa.so.1.0.4 $(TARGET_DIR)/usr/lib/libaa.so.1
    ln -sf /usr/lib/libaa.so.1.0.4 $(TARGET_DIR)/usr/lib/libaa.so
endef

$(eval $(autotools-package))
