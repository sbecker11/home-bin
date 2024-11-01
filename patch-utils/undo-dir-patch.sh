#!/bin/bash

usage() {
    echo "Usage: undo-dir-patch <originalDir> <patchDirFile>"
    exit 1
}

if [ "$#" -ne 2 ]; then
    usage
fi

originalDir=$1
patchDirFile=$2

patch -R -p0 ${originalDir} > ${patchDirFile}
