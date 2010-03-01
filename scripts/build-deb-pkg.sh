#!/bin/sh

if ! [ -r Makefile ] ; then
  echo "Not inside a kernel source directory. Exiting." >&2
  exit 1
fi

if [ -z "$1" ] ; then
   echo "Usage: $0 <versionnumber>" >&2
   echo "Example: grml.00" >&2
   exit 1
fi

# information during runtime:
grml_version="$1"
date=$(date +%Y%m%d)
arch=$(dpkg --print-architecture)

# information from Makefile:
version=$(awk '/^VERSION = / {print $3}' Makefile)
patchlevel=$(awk '/^PATCHLEVEL = / {print $3}' Makefile)
sublevel=$(awk '/^SUBLEVEL = / {print $3}' Makefile)
extraversion=$(awk '/^EXTRAVERSION = / {print $3}' Makefile)
kversion="${version}.${patchlevel}.${sublevel}${extraversion}"

# export important variables:
if [ "$(dpkg --print-architecture)" = "amd64" ] ; then
  export EXTRAVERSION='-grml64'
else
  export EXTRAVERSION='-grml'
fi

export DEBEMAIL='kernel@grml.org'
export DEBFULLNAME='Grml Kernel Team'
export DEBIAN_REVISION="${grml_version}~${kversion}.${date}"

echo "Trying to build linux-image-${version}.${patchlevel}.${sublevel}${EXTRAVERSION}_${DEBIAN_REVISION}_${arch}.deb"
fakeroot -u make deb-pkg EXTRAVERSION="${EXTRAVERSION}" KDEB_PKGVERSION="${DEBIAN_REVISION}"

## END OF FILE #################################################################
