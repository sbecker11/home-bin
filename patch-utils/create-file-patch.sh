#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "Usage: create-file-patch <originalFile> <updatedFile> <patchFile>"
    exit 1
fi

originalFile=$1
updatedFile=$2
patchFile=$3
diff -u ${originalFile} ${updatedFile} > ${patchFile}
