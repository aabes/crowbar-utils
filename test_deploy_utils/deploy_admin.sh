#!/bin/bash

# Script originally written for cygwin - now on ubuntu
# Intended to be run from the Host system running Virtual Box
# VM name is the VBox name of your admin server, already configured for running the
# Crowbar Admin server (with networking, disk, etc)

# $1 = admin VM name (glob)
# $2 = full path to ISO

set -x
VM_NAME=${1}
ISO_PATH=${2}

echo VM_NAME=${VM_NAME}
echo ISO_PATH=${ISO_PATH}

# test OS
if [[ $( uname -a ) == *"CYGWIN"* ]]
then
        CYGWIN=1
else
        echo "This is not running on CYGWIN.  I invite you to hack this so it works in your OS"
#        exit
fi

# path to VBoxManage
VBOX_M='/usr/bin/VBoxManage'
[[ $CYGWIN == '1' ]] && VBOX_M='/drives/c/Program Files/Oracle/VirtualBox/VBoxManage.exe'

# Get the list of VMs that match  $1
VM=$("$VBOX_M" list vms | grep $VM_NAME  )

# test to make sure we only have one VM to reset
if [[ $( echo "${VM}" | wc -l ) > 1 ]]
then
        echo more than one match, must only be one
        exit
fi

echo "Virtual machine to reset: ${VM}"

# get the UID of the VM
VM=$("$VBOX_M" list vms | grep $1 | cut -d"{" -f2 | cut -d"}" -f1  )

# TODO
# find the empty DVD drive in the VM: "usually 1,0"

# change ISO path style from cygwin to Windows (if necessary)
[[ $CYGWIN == '1' ]] && ISO_PATH=$(cygpath -w ${ISO_PATH})
echo "Path to ISO: ${ISO_PATH}"

# attach that medium, assuming that the vm already let go of the previous one
"$VBOX_M" storageattach "${VM}" --storagectl "IDE Controller" --medium "${ISO_PATH}" --port 1 --device 0 --type dvddrive

# restart th VM, with vengance
"$VBOX_M" controlvm "${VM}" reset || "$VBOX_M" startvm "${VM}" 



exit 0

