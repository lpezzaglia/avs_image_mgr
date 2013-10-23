#!/usr/bin/env bash
# $Id: image_mgr.sh 60 2013-09-12 20:05:29Z larry $



# Auto-Versioning Systems Image Manager, Copyright (c) 2013, The
# Regents of the University of California, through Lawrence Berkeley
# National Laboratory (subject to receipt of any required approvals
# from the U.S. Dept. of Energy).  All rights reserved.
# 
# If you have questions about your rights to use or distribute this
# software, please contact Berkeley Lab's Technology Transfer
# Department at TTD@lbl.gov.
# 
# NOTICE.  This software is owned by the U.S. Department of Energy.
# As such, the U.S. Government has been granted for itself and others
# acting on its behalf a paid-up, nonexclusive, irrevocable, worldwide
# license in the Software to reproduce, prepare derivative works, and
# perform publicly and display publicly.  Beginning five (5) years
# after the date permission to assert copyright is obtained from the
# U.S. Department of Energy, and subject to any subsequent five (5)
# year renewals, the U.S. Government is granted for itself and others
# acting on its behalf a paid-up, nonexclusive, irrevocable, worldwide
# license in the Software to reproduce, prepare derivative works,
# distribute copies to the public, perform publicly and display
# publicly, and to permit others to do so.



# Netboot image generator
# This utility wraps FSVS and xCAT {gen,pack}image

# This file contains default settings.
# You should not need to edit this file.  Edit files in
# include/image-specific/<image-name>.d/ to override these settings.

set -E
set -e
set -u
set -o posix




# The path to the image_mgr.sh script
SCRIPT_DIR=$(dirname $0)
cd $SCRIPT_DIR
IMAGE_MGR=$(pwd)/$(basename $0)
. include/image_mgr.pre



trap generic_fail 1 2 3 15 ERR



ADDONROOT=""
ARCH=""
ATTEMPT_RESUME=""
COMMIT_MESSAGE=""
DATE=`date '+%Y%m%d'`
DATESTAMP="$(date +%Y-%m-%d-%H-%M-%S)"
DIFF_OLD_REVISION=""
DIFF_NEW_REVISION=""
DIFF_SCRATCH_DIR=""
FSVS_REPOSITORY=""
GENIMAGE_PROVIDER="default"
GPFS_CONFIG_SERVERS=""

# Whether or not to install documentation.  Setting $INSTALL_DOCS to
# "no" will activate the %_excludedocs RPM macro on RPM-based systems.
# Any other value will result in distribution-default behavior.
INSTALL_DOCS="no"

# A colon-separated list of which locales to install.  If set to the
# empty string, distribution-default behavior will result.  If set to
# some other value, the value will be set as the %install_langs RPM
# macro on RPM-based systems.
INSTALL_LOCALES="C"

IMAGE_OUTPUT_NAME=""
IMG_BASE_DIR=""
IMGROOT=""
KEEP_LOCALE=""
KERNEL_NOARCH=""

# Sign kernel modules.  This is currently only supported on EL6.
# On EL6, this will sign any out-of-tree kernel modules with the
# GPG secret key named by ${KERNEL_MODULE_SIGNING_KEY}.  The secret
# key must be present in the default GPG secret keyring, and the
# kernel sources must be installed.
#
# If set to the empty string, no attempt to sign modules will be made.
# Note that on EL6, kernel module signature enforcement can be enabled
# by passing enforcemodulesig=1 on the kernel command line.  If
# module signature enforcement is disabled, then unsigned modules can
# be loaded, but modules signed with the wrong signature will still be
# rejected.
#
# The signature can be removed from a signed kernel module with:
# objcopy -R .note.module.sig foo.ko
KERNEL_MODULE_SIGNING_KEY=""

# Activate "masquerading" capability.  This allows you to pack any
# image tag as any xCAT image.  This can be used to perform testing on
# a new version of an image without altering the production packed
# image.  Note that you will still need to update the xCAT synclist
# files for the masqueraded image name.
#
# If $MASQUERADE_IMAGE is set to the empty string, no masquerading
# will be done.  Otherwise, the image will be packed as
# $MASQUERADE_IMAGE instead of the true image name.
#
# This functionality is normally activated through the "-x"
# command-line option
MASQUERADE_IMAGE=""

MODE=""
OS=""
OS_FAMILY=""
OS_MAJOR_VERSION=""
OS_RELEASE=""
PACK_ON_COMPLETION=""
PROFILE=""
STAMP=""
TAG_NAME=""
TAG_PATH=""
TAG_REVISION=""
USER_NAME=""
XCAT_NETBOOT_DIR=""
YUM=""








# Import all functions
image_mgr_prep "$@"


# Begin the image build
image_mgr_main "$@"


trap - 1 2 3 15 ERR


