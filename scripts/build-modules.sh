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

## END OF FILE #################################################################
