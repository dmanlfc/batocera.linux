################################################################################
#
# perfect-dark
#
################################################################################
# Versions: Commits on Oct 31, 2023
PERFECT_DARK_VERSION = 4914aa335b8db10fef08c54df9bc9b343129b362
PERFECT_DARK_SITE = https://github.com/fgsfdsfgs/perfect_dark.git
PERFECT_DARK_SITE_METHOD = git
PERFECT_DARK_GIT_SUBMODULES=YES
PERFECT_DARK_LICENSE = MIT License
PERFECT_DARK_LICENSE_FILE = LICENSE

PERFECT_DARK_DEPENDENCIES = sdl2 zlib

#PERFECT_DARK_SOURCE = pd-i686-linux.zip
#PERFECT_DARK_SITE = \
    https://nightly.link/fgsfdsfgs/perfect_dark/workflows/c-cpp/port

#define PERFECT_DARK_EXTRACT_CMDS
#	@unzip -q -o $(DL_DIR)/$(PERFECT_DARK_DL_SUBDIR)/$(PERFECT_DARK_SOURCE) -d $(@D)
#endef

# doesn't support 64-bit architectures, yet
PERFECT_DARK_BUILD_ARGS += TARGET_PLATFORM=i686-linux
PERFECT_DARK_BUILD_ARGS += VERSION_HASH=$(PERFECT_DARK_VERSION)

PERFECT_DARK_LDFLAGS += -lSDL2

# FUTURE USE when it supports 64-bit builds
# use -j2 otherwise build fails finding includes
define PERFECT_DARK_BUILD_CMDS
    $(TARGET_CONFIGURE_OPTS) $(MAKE) $(PERFECT_DARK_BUILD_ARGS) \
        LDFLAGS="$(PERFECT_DARK_LDFLAGS)" -C $(@D) -f Makefile.port -j2
endef

define PERFECT_DARK_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/bin/pdark
	$(INSTALL) -D -m 0755 $(@D)/pd $(TARGET_DIR)/usr/bin/pdark/pd
endef

define PERFECT_DARK_EVMAPY
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/ports/perfect-dark/pdark.keys \
	    $(TARGET_DIR)/usr/share/evmapy
endef

PERFECT_DARK_POST_INSTALL_TARGET_HOOKS += PERFECT_DARK_EVMAPY

$(eval $(generic-package))
