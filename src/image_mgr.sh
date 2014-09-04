#!/usr/bin/env bash



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
IMAGE_MGR_SCRIPT_DIR="$(readlink -f "$(dirname "$0")")"
CWD_ORIG="$(pwd)"
cd "$IMAGE_MGR_SCRIPT_DIR"

. include/image_mgr.pre

trap 'generic_fail ${BASH_SOURCE[0]} $LINENO $?' 1 2 3 15 ERR



# Set default values for many variables.  Some of these
# can be overridden by files included from the site-specific/ and
# image-specific/ areas
ADDITIONAL_PACKAGES_LIST_PROVIDER="default"
ADDONROOT=""
ARCH=""
ATTEMPT_RESUME=""

# Whether or not to build add-ons with images
# By setting $BASE_ONLY, only the base
# image will be built.
BASE_ONLY=""

COMMIT_MESSAGE=""
DATE=`date '+%Y%m%d'`
DATESTAMP="$(date +%Y-%m-%d-%H-%M-%S)"
DIFF_OLD_REVISION=""
DIFF_NEW_REVISION=""
DIFF_SCRATCH_DIR=""
FSVS="_env_fsvs"

# The path to the FSVS repository where images will be stored
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


# The path to a directory containing image support files.
# By convention, most image building functions will
# expect support files in ${IMAGE_MGR_BASE}/files or
# ${IMAGE_MGR_BASE}/src
IMAGE_MGR_BASE="$IMAGE_MGR_SCRIPT_DIR"

# The path to the $IMAGEFILES area, which most image building
# functions will expect to contain suppport files
IMAGEFILES="${IMAGE_MGR_BASE}/files/"


IMAGE_OUTPUT_NAME=""
IMG_BASE_DIR=""
IMGROOT=""
KEEP_LOCALE=""
KERNEL="$(uname -r)"
KERNEL_NOARCH="$(echo $KERNEL | sed -e 's/.x86_64//')"
KERNEL_SUFFIX=""

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

# The default size of the / tmpfs filesystem.
# This must be large enough to accommodate the size of the image.
ROOTSIZE="1024"

STAMP=""
SVNHOST=""
SVNPROTO="file://"

# The default path to the image repository area
SVN_REPO_DIR="${IMAGE_MGR_BASE}/image_repo/"

SYSTEMNAME="Generic"
TAG_NAME=""
TAG_PATH=""
TAG_REVISION=""
USER_NAME=""
XCAT_NETBOOT_DIR=""
YUM=""

# Default extra arguments to pass to yum
YUM_EXTRA_ARGS="-d 1"


# The OS image will be built in BASE.
# Placing this area on tmpfs may speed up image builds for compatible images
BASE="${IMAGE_MGR_BASE}/builddir/"


cd "$IMAGE_MGR_SCRIPT_DIR"
IMAGE_MGR="$(pwd)/$(basename "$0")"

# Ensure we are running in an unshared mount namespace
env | grep '^__UNSHARED=1' >/dev/null 2>&1 || \
    exec env __UNSHARED=1 unshare -m -- ${IMAGE_MGR} "$@"


# Import all functions
image_mgr_prep "$@"


# Begin the image build
image_mgr_main "$@"


trap - 1 2 3 15 ERR


