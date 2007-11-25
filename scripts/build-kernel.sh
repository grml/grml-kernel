#!/bin/sh
# Filename:      build-kernel.sh
# Purpose:       very hackish build script to build a Debian package of a kernel
# Authors:       grml-team (grml.org), (c) Michael Prokop <mika@grml.org>
# Bug-Reports:   see http://grml.org/bugs/
# License:       This file is licensed under the GPL v2 or any later version.
# Latest change: Son Nov 25 19:34:51 CET 2007 [mika]
################################################################################

if [ -z "$REVISION" ] ;
   REVISION="grml.01"
fi

# TODO: patch the kernel accordingly; currently I'm doing something like
# for p in ~/grml/hg/grml-kernel/2.6.23/[0-9]* ;     patch -p1 < $p || echo $p >> /tmp/error
# for p in ~/grml/hg/grml-kernel/2.6.23/x86/[0-9]* ; patch -p1 < $p || echo $p >> /tmp/error

# make sure we have a clean tree:
make-kpkg clean

make-kpkg --revision "$REVISION" --us --uc --rootcmd fakeroot \
kernel-image kernel-headers kernel-doc kernel-source

## END OF FILE #################################################################
