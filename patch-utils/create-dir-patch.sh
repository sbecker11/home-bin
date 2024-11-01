#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: create-dir-patch <originalDir> <updatedDir> <patchDirFile>"
    exit 1
fi

originalDir=$1
updatedDir=$2
patchDirFile=$3

diff -rUN ${originalDir} ${updatedDir} > ${patchDirFile}
