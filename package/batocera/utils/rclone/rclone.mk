################################################################################
#
# rclone
#
################################################################################

RCLONE_VERSION = v1.56.2
RCLONE_SITE = $(call github,rclone,rclone,$(RCLONE_VERSION))
RCLONE_LICENSE = MIT
SYNCTHING_LICENSE_FILES = COPYING

RCLONE_TARGET_ENV = \
	PATH=$(BR_PATH) \
	GOROOT="$(HOST_GO_ROOT)" \
	GOPATH="$(HOST_GO_GOPATH)" \
	GOCACHE="$(HOST_GO_TARGET_CACHE)"

define RCLONE_BUILD_CMDS
	cd $(@D) && $(RCLONE_TARGET_ENV) go build
endef

define RCLONE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/rclone $(TARGET_DIR)/usr/bin/rclone
endef

$(eval $(golang-package))