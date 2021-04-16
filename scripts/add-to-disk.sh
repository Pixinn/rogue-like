#!/bin/bash
# Adds the required files to the provided disk.dsk
# usage: add_to_disk PATH_TO_APPLECOMMANDER.jar PATH_TO_BINARY.a2 PATH_TO_DISK

set -e

if (( $# != 3 )); then
    echo "Bad number of arguments"
    echo "usage: add_to_disk.sh PATH_TO_APPLECOMMANDER.jar PATH_TO_BINARY.a2 PATH_TO_DISK"
    exit
fi

# ###
# NOTE:
# The loader must have the same basename as the game loaded
# ###
echo " . removing previous instance of ESCAPE from the disk"
java -jar ${1} -d ${3} ESCAPE
java -jar ${1} -d ${3} ESCAPE.SYSTEM

echo " .. adding ESCAPE and its loader to the disk"
java -jar ${1} -cc65 ${3} ESCAPE BIN < ${2}
java -jar ${1} -p ${3} ESCAPE.SYSTEM SYS < ${CC65_HOME}/target/apple2/util/loader.system

echo "DONE."
