################################################################################
#
# eka2l1
#
################################################################################

EKA2L1_VERSION = 0.0.8.1
EKA2L1_SITE = https://github.com/EKA2L1/EKA2L1.git
EKA2L1_SITE_METHOD=git
EKA2L1_GIT_SUBMODULES=YES
EKA2L1_LICENSE = GPL-3.0
EKA2L1_SUPPORTS_IN_SOURCE_BUILD = NO
EKA2L1_DEPENDENCIES = qt5base qt5tools qt5multimedia

EKA2L1_CONF_OPTS = -DBUILD_SHARED_LIBS=OFF -DEKA2L1_BUILD_TESTS=OFF

# grab the .git folder to ensure git variables apply during the build
define EKA2L1_FIXGIT
        cp -r $(BR2_DL_DIR)/eka2l1/git/.git $(@D)
endef
EKA2L1_PRE_CONFIGURE_HOOKS += EKA2L1_FIXGIT

define EKA2L1_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/bin
	$(INSTALL) -D $(@D)/buildroot-build/bin/eka2l1_qt \
		$(TARGET_DIR)/usr/bin/
endef

$(eval $(cmake-package))
