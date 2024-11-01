#!/bin/bash

# Function to display usage message
usage() {
    echo "Usage: $0 <originalFile> <patchFile>"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Assign arguments to variables
originalFile=$1
patchFile=$2

# Run the patch command
patch -R "$originalFile" < "$patchFile"
