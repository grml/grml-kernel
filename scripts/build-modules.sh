#!/bin/sh
# Filename:      build-modules.sh
# Purpose:       hackish style to build external kernel modules for grml kernel
# Authors:       grml-team (grml.org), (c) Michael Prokop <mika@grml.org>
# Bug-Reports:   see http://grml.org/bugs/
# License:       This file is licensed under the GPL v2 or any later version.
# Latest change: Son Nov 25 19:31:12 CET 2007 [mika]
################################################################################

if [ "$(id -u)" != 0 ] ;then
   echo "Sorry, need root permission. Exiting"
   exit 1
fi

echo "--------------------------------------------------------------------------"
echo "Notice: set \$MA_OPTIONS for specifying build options to m-a."
echo "        set \$KERNELDIRS for specifying location of kernel headers"
echo "        set \$KERNELVERSION for specifying kernel version"
echo "        set \$BUILD_PACKAGES for specifying packages to be build"
echo "        set \$SOURCE_PACKAGES for specifying source packages"

if [ -z "$KERNELVERSION" ] ; then
   KERNELVERSION="$(uname -r)"
   echo "No \$KERNELVERSION given, assuming $KERNELVERSION"
fi

if [ -z "$KERNELDIRS" ] ; then
   KERNELDIRS=/usr/src/linux-headers-"$KERNELVERSION"
   echo "No \$KERNELDIRS given, assuming $KERNELDIRS"
fi

if ! [ -r "$KERNELDIRS/Makefile" ] ; then
   echo "Fatal: could not find kernel headers"
   exit 10
fi

if [ -z "$BUILD_PACKAGES" ] ; then
   BUILD_PACKAGES=packages
fi

if [ -z "$SOURCE_PACKAGES" ] ; then
   SOURCE_PACKAGES=source_packages
fi

if ! [ -r "$BUILD_PACKAGES" ] ; then
   echo 'Fatal: could not read $BUILD_PACKAGES'>&2
   exit 20
fi

if ! [ -r "$SOURCE_PACKAGES" ] ; then
   echo 'Fatal: could not read $SOURCE_PACKAGES'>&2
   exit 30
fi

echo "Checking for present source packages as defined in ${SOURCE_PACKAGES}..."
for package in $(cat "$SOURCE_PACKAGES") ; do
    dpkg --list $package 1>/dev/null 2>&1 || echo "Warning: no source package for $package present"
done

for package in $(cat "$BUILD_PACKAGES") ; do
    KERNELDIRS=$KERNELDIRS m-a $MA_OPTIONS -k $KERNELVERSION build $package || FAILED="$FAILED $package"
done

echo "--------------------------------------------------------------------------"
echo "The following packages failed to build:"
echo "$FAILED"
echo "--------------------------------------------------------------------------"

echo "--------------------------------------------------------------------------"
echo "Information:"
echo "Source packages for grml-kerneladdons and truecrypt are not available yet."
echo "So do not forget to build them manually. :)"
echo "--------------------------------------------------------------------------"

## Instructions for grml-kerneladdons:
# download tar.gz of grml-kerneladdons via:
# http://deb.grml.org/pool/main/g/grml-kerneladdons-2.6.23/
# make sure /usr/src/linux is the according symlink to /usr/src/linux-headers-2.6.23-grml
# touch /usr/src/linux-headers-2.6.23-grml/include/linux/config.h (fix acerhk)
# and finally build it using 'dpkg-buildpackage -rfakeroot'

## Instructions for truecrypt:
# dget http://deb.grml.org/pool/main/t/truecrypt-2.6.23-grml/truecrypt-2.6.23-grml_4.3a-3.dsc
# unp truecrypt-2.6.23-grml_4.3a.orig.tar.gz
# unp truecrypt-2.6.23-grml_4.3a-3.diff.gz
# mv truecrypt-4.3a-source-code truecrypt-2.6.23-grml-4.3a
# cd truecrypt-2.6.23-grml-4.3a
# patch -p1 < ../truecrypt-2.6.23-grml_4.3a-3.diff
# chmod 755 debian/rules
# and finally build it using 'dpkg-buildpackage -rfakeroot'

## END OF FILE #################################################################
