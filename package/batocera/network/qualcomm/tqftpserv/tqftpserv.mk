################################################################################
#
# tqftpserv
#
################################################################################

TQFTPSERV_VERSION = v1.1.1
TQFTPSERV_SITE = $(call github,linux-msm,tqftpserv,$(TQFTPSERV_VERSION))
TQFTPSERV_LICENSE = BSD-3-Clause license
TQFTPSERV_LICENSE_FILE = LICENSE
TQFTPSERV_DEPENDENCIES = host-qrtr qrtr zstd

$(eval $(meson-package))
