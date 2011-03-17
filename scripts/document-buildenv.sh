#!/bin/sh
# Purpose: capture information regarding the build environment
# Usage:   cd grml-kernel/2.6.38 ; ../scripts/document-buildenv.sh

buildenv="README.buildenv.$(dpkg --print-architecture)"
modules="README.modules.$(dpkg --print-architecture)"

echo "Build infrastructure documentation - $(date)" > "${buildenv}"

dpkg --list cpp\* gcc\* g++\* libstdc\* libgcc\* binutils\* libc6\* >> "${buildenv}"

echo "" >> "${buildenv}"
echo "# gcc version:" >> "${buildenv}"
gcc --version >> "${buildenv}"

echo "# apt-cache policy:" >> "${buildenv}"
apt-cache policy >> "${buildenv}"

echo "" >> "${buildenv}"
echo "# kernel version:" >> "${buildenv}"
echo "$(uname -a)" >> "${buildenv}"

dpkg --list $(grep -v '^#' ../scripts/source_packages) > $modules

## END OF FILE #################################################################
