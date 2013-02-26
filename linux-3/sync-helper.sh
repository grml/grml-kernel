# very stupid script which makes updating grml-kernel.git
# from Debian's svn://svn.debian.org/kernel/dists/trunk
# a *bit* easier

if ! test -f README.Grml ; then
  echo "Please invoke this script inside the grml-kernel/linux-3/debian directory." >&2
  exit 1
fi

for file in \
  config/alpha/ \
  config/armel/ \
  config/armhf/ \
  config/hppa/ \
  config/i386/config.486 \
  config/i386/config.686-pae \
  config/i386/rt/ \
  config/ia64/ \
  config/kernelarch-mips/ \
  config/m68k/ \
  config/mips/ \
  config/mipsel/ \
  config/powerpc/ \
  config/powerpcspe/ \
  config/ppc64/ \
  config/s390/ \
  config/s390x/ \
  config/sh4/ \
  config/sparc/ \
  config/sparc64/ \
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
  po/
do
  rm -rf $file
done
