################################################################################
#
# syncthing
#
################################################################################

SYNCTHING_VERSION = v1.18.3
SYNCTHING_SITE = $(call github,syncthing,syncthing,$(SYNCTHING_VERSION))
SYNCTHING_LICENSE = MPLv2
SYNCTHING_LICENSE_FILES = LICENSE

SYNCTHING_TARGET_ENV = \
	PATH=$(BR_PATH) \
	GOROOT="$(HOST_GO_ROOT)" \
	GOPATH="$(HOST_GO_GOPATH)" \
	GOCACHE="$(HOST_GO_TARGET_CACHE)"
	
define SYNCTHING_BUILD_CMDS
	cd $(@D) && $(SYNCTHING_TARGET_ENV) go run build.go install
endef

$(eval $(golang-package))
