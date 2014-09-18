# avs_image_mgr

## Introduction

The Auto-Versioning Systems Image Manager is a set of scripts which
wrap around xCAT and FSVS to facilitate disciplined management of
netboot images for computational systems.

The interface for avs_image_mgr, and the primary use case, were
presented in detail at the 2013 meeting of the Cray User Group.  Details on `avs_image_mgr` use in a production environment are available in the [conference paper](http://cug.org/proceedings/cug2013_proceedings/includes/files/pap184.pdf) and accompanying [slides](http://cug.org/proceedings/cug2013_proceedings/includes/files/pap184-file2.pdf).

## Quick Start

This section details how to set up image_mgr to create a basic xCAT
boot image using avs_image_mgr.

1. Install and configure the following prerequisites:

    * A functioning [xCAT](http://xcat.sf.net/) environment.  

    * The `tsflags` and `priorities` yum plugins

    * The [FSVS](http://fsvs.tigris.org/) tool for image versioning.

    * A node designated for image building.  It is strongly recommended
      that you dedicate an xCAT service node for image builds.  However,
      the xCAT management node can also be used.  Currently, only
      EL6-based image building nodes are supported.

1.  Check out image_mgr on your image building node.

    This node can be the xCAT MN, or a sufficiently privileged service
    node.  For production deployments, a dedicated image building node is
    recommended:

        git clone http://github.com/lpezzaglia/avs_image_mgr

    By default, the image will be built and versioned within the
    checkout area, so ensure that sufficient space is available.

1. Choose a production name, test name, architecture, and OS for the image.  `avs_image_mgr` has been most heavily tested with SL6.

        IMAGE_NAME=example.prod
        TEST_IMAGE_NAME=example.test
        ARCH=x86_64
        OS=SL6.3

1. Add this image to the xCAT configuration

        for _I in $IMAGE_NAME $TEST_IMAGE_NAME; do 
            chdef -t osimage ${OS}-${ARCH}-netboot-${_I} \
            provmethod=netboot \
            pkglist=/install/custom/netboot/${OS}/${_I}.pkglist \
            imagetype=linux \
            rootimgdir=/install/netboot/${OS}/${ARCH}/${_I}
        done

1. Build the image:

        ./image_mgr.sh create -p $IMAGE_NAME -o $ARCH -o $OS -u [your username] -m "Initial build"

    Note that committing the first image build to SVN will take some
    time.  Subsequent builds with fewer overall changes will commit more
    rapidly.

    Upon completion, an image build report will be generated:

          Image rebuild completed at Tue Aug 19 10:26:14 PDT 2014

          Initial build


        -------------------------------------------------------------------------
                 PROCEDURE NAME      TIME  +/- RPMS  +/- SIZE      RPMS      SIZE
        prepare_image_directory        0s         0        0M         0        0M
                 generate_image      591s        94      426M        94      426M
                     build_prep       98s         0        0M        94      426M
                setup_yum_repos       98s         0        0M        94      426M
                        cleanup      103s         0     -143M        94      283M
                          TOTAL      890s        94      283M        94      283M

        Image example.prod created  

1. Once the image is built to your satisfaction, tag it:

        ./image_mgr.sh tag -p $IMAGE_NAME -o $ARCH -o $OS

1. Display all available tags:

        ./image_mgr.sh list-tags -p $IMAGE_NAME -o $ARCH -o $OS

1. Pack a tag as the test image using the masquerading (`-x`) feature

        ./image_mgr.sh pack -p $IMAGE_NAME -o $ARCH -o $OS -t [tag name] -x $TEST_IMAGE_NAME

1. Ask xCAT to boot a node with the new test image image:

        nodeset [node] netboot=$TEST_IMAGE_NAME
        rpower [node] reset
        rcons [node]

1. Once testing is complete, pack the tag as the production image

        ./image_mgr.sh pack -p $IMAGE_NAME -o $ARCH -o $OS -t [tag name]

1. Boot a node with the new production image:

        nodeset [node] netboot=$IMAGE_NAME
        ...


### Customizing the base image:

Customizing the base image is generally performed in two steps: 

1. Adding new shell functions to any file in:
    * `site-specific/include/image.common.d/`
    * `site-specific/include/image.common.${OS,OS_FAMILY}.d/`
    * `image-specific/include/image.${IMAGE_NAME}.d/`


1. Modifying the do_create() function defined in `image-specific/include/image.${IMAGE_NAME}.d/` to call the new functions.  
