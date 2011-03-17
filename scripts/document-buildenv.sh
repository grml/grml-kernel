#!/bin/sh
# Purpose: capture information regarding the build environment
# Usage:   cd grml-kernel/2.6.38 ; ../scripts/document-buildenv.sh

echo "Build infrastructure documentation - $(date)" > README.buildenv

dpkg --list cpp\* gcc\* g++\* libstdc\* libgcc\* binutils\* libc6\* >> README.buildenv

echo "" >> README.buildenv
echo "# gcc version:" >> README.buildenv
gcc --version >> README.buildenv

echo "# apt-cache policy:" >> README.buildenv
apt-cache policy >> README.buildenv

echo "" >> README.buildenv
echo "# kernel version:" >> README.buildenv
echo "$(uname -a)" >> README.buildenv

dpkg --list $(grep -v '^#' ../scripts/source_packages) > README.modules.$(dpkg --print-architecture)

## END OF FILE #################################################################
