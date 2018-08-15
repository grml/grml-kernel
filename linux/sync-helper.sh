# very stupid script which makes updating grml-kernel.git
# from Debian's svn://svn.debian.org/kernel/dists/trunk
# a *bit* easier

if ! test -f README.Grml ; then
  echo "Please invoke this script inside the grml-kernel/linux/debian directory." >&2
  exit 1
fi

for file in \
  abi \
  config/alpha/ \
  config/arm64/ \
  config/arm64ilp32/ \
  config/armel/ \
  config/armhf/ \
  config/hppa/ \
  config/i386/rt/ \
  config/ia64/ \
  config/kernelarch-arm/ \
  config/kernelarch-mips/ \
  config/kernelarch-powerpc/ \
  config/kernelarch-s390/ \
  config/kernelarch-sparc/ \
  config/m68k/ \
  config/mips/ \
  config/mips64/ \
  config/mips64el/ \
  config/mips64r6/ \
  config/mips64r6el/ \
  config/mipsel/ \
  config/mipsn32/ \
  config/mipsn32el/ \
  config/mipsn32r6/ \
  config/mipsn32r6el/ \
  config/mipsr6/ \
  config/mipsr6el/ \
  config/or1k/ \
  config/powerpc/ \
  config/powerpcspe/ \
  config/ppc64/ \
  config/ppc64el/ \
  config/riscv64/ \
  config/s390/ \
  config/s390x/ \
  config/sh3/ \
  config/sh4/ \
  config/sparc/ \
  config/sparc64/ \
  config/tilegx/ \
  config/x32/ \
  installer/ \
  patches/bugfix/all/firmware-remove-redundant-log-messages-from-drivers.patch \
  patches/bugfix/all/firmware_class-log-every-success-and-failure.patch \
  patches/debian/dfsg/ \
  patches/debian/iwlwifi-do-not-request-unreleased-firmware.patch \
  patches/features/all/drivers-media-dvb-usb-af9005-request_firmware.patch \
  patches/features/all/hidepid/ \
  patches/features/all/rt/ \
  patches/features/all/sound-pci-cs46xx-request_firmware.patch \
  patches/features/all/wacom/ \
  patches/series-orig \
  patches/series-rt \
  po/ \
  rules.d/arch/powerpc \
  templates/po
do
  rm -rf $file
done
