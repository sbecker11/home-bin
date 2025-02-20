#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: apply-dir-patch <patchDirFile>"
    exit 1
fi

patchDirFile=$1
patch -p0 < ${patchDirFile}
