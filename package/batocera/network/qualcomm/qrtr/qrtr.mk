################################################################################
#
# qrtr
#
################################################################################

QRTR_VERSION = v1.2
QRTR_SITE = $(call github,linux-msm,qrtr,$(QRTR_VERSION))
QRTR_LICENSE = BSD-3-Clause license
QRTR_LICENSE_FILE = LICENSE
QRTR_DEPENDENCIES = linux-headers
HOST_QRTR_DEPENDENCIES = linux-headers toolchain
QRTR_INSTALL_STAGING = YES

$(eval $(meson-package))
$(eval $(host-meson-package))
