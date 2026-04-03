################################################################################
#
# uboot-odroid-go-ultra
#
################################################################################

UBOOT_ODROID_GO_ULTRA_VERSION = 2025.10
UBOOT_ODROID_GO_ULTRA_SITE = https://ftp.denx.de/pub/u-boot
UBOOT_ODROID_GO_ULTRA_SOURCE = u-boot-$(UBOOT_ODROID_GO_ULTRA_VERSION).tar.bz2
UBOOT_ODROID_GO_ULTRA_LICENSE = GPL-2.0+
UBOOT_ODROID_GO_ULTRA_LICENSE_FILES = Licenses/README
UBOOT_ODROID_GO_ULTRA_INSTALL_IMAGES = YES

# Amlogic FIP signing repo.
UBOOT_ODROID_GO_ULTRA_FIP_COMMIT = 42d372123631066fb77fbcbb612dc3eb41a3f6f9
UBOOT_ODROID_GO_ULTRA_FIP_URL = \
	https://github.com/LibreELEC/amlogic-boot-fip/archive/$(UBOOT_ODROID_GO_ULTRA_FIP_COMMIT)
UBOOT_ODROID_GO_ULTRA_EXTRA_DOWNLOADS = \
	$(UBOOT_ODROID_GO_ULTRA_FIP_URL)/amlogic-boot-fip-$(UBOOT_ODROID_GO_ULTRA_FIP_COMMIT).tar.gz

UBOOT_ODROID_GO_ULTRA_DEPENDENCIES = host-pkgconf host-openssl host-bison host-flex
UBOOT_ODROID_GO_ULTRA_DEPENDENCIES += host-python-setuptools host-dtc host-swig
UBOOT_ODROID_GO_ULTRA_DEPENDENCIES += host-gnutls host-python-pyelftools

define UBOOT_ODROID_GO_ULTRA_EXTRACT_FIP
	mkdir -p $(@D)/fip
	$(TAR) -xf $(UBOOT_ODROID_GO_ULTRA_DL_DIR)/amlogic-boot-fip-$(UBOOT_ODROID_GO_ULTRA_FIP_COMMIT).tar.gz \
		-C $(@D)/fip --strip-components=1
endef
UBOOT_ODROID_GO_ULTRA_POST_EXTRACT_HOOKS += UBOOT_ODROID_GO_ULTRA_EXTRACT_FIP

UBOOT_ODROID_GO_ULTRA_MAKE_OPTS = \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	HOSTCFLAGS="$(HOST_CFLAGS)" \
	HOSTLDFLAGS="$(HOST_LDFLAGS)"

define UBOOT_ODROID_GO_ULTRA_CONFIGURE_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(UBOOT_ODROID_GO_ULTRA_MAKE_OPTS) \
		odroid-go-ultra_defconfig
endef

define UBOOT_ODROID_GO_ULTRA_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(UBOOT_ODROID_GO_ULTRA_MAKE_OPTS)
	mkdir -p $(@D)/fip-output
	cd $(@D)/fip && $(@D)/fip/build-fip.sh odroid-go-ultra $(@D)/u-boot.bin $(@D)/fip-output
	# Extract the first 440 bytes (the MBR boot code)
	dd if=$(@D)/fip-output/u-boot.bin.sd.bin of=$(@D)/fip-output/u-boot-header.bin bs=1 count=440
	# Extract everything from byte 512 onwards (the main payload)
	dd if=$(@D)/fip-output/u-boot.bin.sd.bin of=$(@D)/fip-output/u-boot-main.bin bs=512 skip=1
endef

define UBOOT_ODROID_GO_ULTRA_INSTALL_IMAGES_CMDS
	mkdir -p $(BINARIES_DIR)/uboot-odroid-go-ultra
	$(INSTALL) -D -m 0644 $(@D)/fip-output/u-boot-header.bin \
		$(BINARIES_DIR)/uboot-odroid-go-ultra/u-boot-header.bin
	$(INSTALL) -D -m 0644 $(@D)/fip-output/u-boot-main.bin \
		$(BINARIES_DIR)/uboot-odroid-go-ultra/u-boot-main.bin
endef

$(eval $(generic-package))
