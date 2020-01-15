#!/bin/bash
# Adds the required files to the provided disk.dsk
# usage: add_to_disk PATH_TO_APPLECOMMANDER.jar PATH_TO_BINARY.a2 PATH_TO_DISK

set -e

if (( $# != 3 )); then
    echo "Bad number of arguments"
    echo "usage: add_to_disk.sh PATH_TO_APPLECOMMANDER.jar PATH_TO_BINARY.a2 PATH_TO_DISK"
    exit
fi

echo " . removing previous instance of ESCAPE form the disk"
java -jar ${1} -d ${3} ESCAPE

echo " .. adding ESCAPE to the disk"
java -jar ${1} -cc65 ${3} ESCAPE BIN < ${2}

echo "DONE."
