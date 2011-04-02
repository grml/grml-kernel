#!/bin/sh
# Filename:      build-kernel.sh
# Purpose:       very hackish build script to build a Debian package of a kernel
# Authors:       grml-team (grml.org), (c) Michael Prokop <mika@grml.org>
# Bug-Reports:   see http://grml.org/bugs/
# License:       This file is licensed under the GPL v2 or any later version.
################################################################################

if [ -z "$KVERS" ] ; then
  echo "Usage example: KVERS=2.6.38-grml.00 $0" >&2
  exit 1
fi

# make sure we have a clean tree:
make-kpkg clean

make-kpkg --revision "$KVERS" --us --uc --initrd --rootcmd fakeroot \
  kernel-image kernel-headers kernel-doc kernel-source

## END OF FILE #################################################################
