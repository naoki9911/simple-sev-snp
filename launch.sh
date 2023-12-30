#!/bin/bash

set -eu

SEV_SNP_MEASURE_PATH="./sev-snp-measure"
SEV_SNP_MEASURE="$SEV_SNP_MEASURE_PATH/sev-snp-measure.py"
SEV_SNP_CREATE_IDBLOCK="$SEV_SNP_MEASURE_PATH/snp-create-id-block.py"
QEMU="$HOME/AMDSEV/usr/local/bin/qemu-system-x86_64"
OVMF="$HOME/AMDSEV/usr/local/share/qemu/OVMF.fd"
KERNEL="$HOME/AMDSEV/linux/guest/arch/x86/boot/bzImage"

CPU_MODEL="EPYC-Milan-v2"
VCPU_NUM="1"

INITRD="./alpine-initrd.img"
APPEND="console=ttyS0 earlyprintk=ttyS0"

ID_KEY="./sev-id.key"
AUTHOR_KEY="./sev-author.key"

MEASURE_HASH=$($SEV_SNP_MEASURE --mode snp --vcpus=$VCPU_NUM --vcpu-type=$CPU_MODEL --ovmf=$OVMF --kernel=$KERNEL --initrd=$INITRD --append="$APPEND" --output-format base64 --vmm-type QEMU)
BLOCKS=$($SEV_SNP_CREATE_IDBLOCK --measure $MEASURE_HASH --idkey $ID_KEY --authorkey $AUTHOR_KEY)
BLOCKS=$(echo $BLOCKS | awk '{print $1}')

set -x

$QEMU -enable-kvm \
-cpu $CPU_MODEL \
-drive if=pflash,file=$OVMF,format=raw,readonly=on \
-kernel $KERNEL -initrd $INITRD -append "$APPEND" \
-m 2G -machine q35,confidential-guest-support=sev0,kvm-type=protected,memory-backend=ram1,vmport=off \
-nic user -no-reboot -nodefaults -nographic \
-object memory-backend-memfd-private,id=ram1,share=true,size=2G \
-object sev-snp-guest,auth-key-enabled=on,cbitpos=51,discard=none,host-data=,$BLOCKS,id=sev0,kernel-hashes=on,reduced-phys-bits=1 \
-serial mon:stdio -smp $VCPU_NUM -trace kvm_sev_*

