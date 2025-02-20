#!/bin/sh

set -e

# remove the .sh extension for all files that have it
rename 's/\.sh$//' *.sh
