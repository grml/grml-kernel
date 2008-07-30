#!/bin/sh
# Filename:      config-checker.sh
# Purpose:       check some important settings in a kernel configuration file
# Authors:       grml-team (grml.org), (c) Michael Prokop <mika@grml.org>
# Bug-Reports:   see http://grml.org/bugs/
# License:       This file is licensed under the GPL v2 or any later version.
# Latest change: Wed Jul 30 17:55:37 CEST 2008 [mika]
################################################################################

if [ -z "$1" ] ; then
   echo "Usage: $0 <kernel-configuration-file>">&2
   exit 1
else
   CONFIG=$1
fi

for value in \
    "CONFIG_SERIAL_8250_NR_UARTS=16" \
    "CONFIG_SERIAL_8250_RUNTIME_UARTS=8" \
    "CONFIG_DEBUG_MUTEXES is not set" \
    "CONFIG_BLK_DEV_IO_TRACE=y" \
    "CONFIG_TASKSTATS=y" \
    "CONFIG_BLK_DEV_LOOP=m" \
    ; do
    grep -q "$value" $CONFIG || echo "$CONFIG not correct, use \"$value\" instead"
done

# Documentation of some different settings between 32bit and 64bit grml-kernel
# ============================================================================
# CONFIG_RWSEM_GENERIC_SPINLOCK / CONFIG_RWSEM_XCHGADD_ALGORITHM => architecture specific
# CONFIG_GENERIC_TIME_VSYSCALL => not available on x86
# CONFIG_HAVE_CPUMASK_OF_CPU_MAP => architecture specific
# CONFIG_ZONE_DMA32 => amd64 only (32bit DMA)
# CONFIG_AUDIT_ARCH => symbol only
# CONFIG_KTIME_SCALAR => symbol only
# CONFIG_GROUP_SCHED / CONFIG_USER_SCHED => buggy feature, not relevant for grml
# CONFIG_UTS_NS / CONFIG_IPC_NS / CONFIG_USER_NS /CONFIG_PID_NS => not interesting without virtualization features
# CONFIG_GENERIC_CPU => amd64 only
# CONFIG_AGP_AMD64 => amd64 only
# CONFIG_SECURITY_DEFAULT_MMAP_MIN_ADDR => x86 vs. amd64, 0 on x86 and 65536 for amd64
