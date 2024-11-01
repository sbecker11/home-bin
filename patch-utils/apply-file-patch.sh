#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "Usage: apply-file-patch <originalFile> <patchFile>"
    exit 1
fi

patch ${originalFile} < ${patchFile}
