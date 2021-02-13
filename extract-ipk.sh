#!/bin/bash
# SPDX-License-Identifier: MIT
# github.com/falk-werner/extract-ipk

if [ "" == "$1" ] || [ "-h" == "$1" ] || [ "--help" == "$1" ]; then
	cat << EOF
extract-ipk, Copyright (c) 2021 by Falk Werner <github.com/falk-werner>
Create IPK files from already installed packages

Usage:
	$0 <package>
EOF
	exit 1
fi

########################
# Function definitions #
########################

# switch back to initial dir
# and remove working directory
function cleanup {
	cd ${CUR_DIR}
	rm -rf ${WORK_DIR}
}


#################################
# Check if package is installed #
#################################

PACKAGE="$1"
FOUND=$(opkg list-installed "${PACKAGE}" | wc -l)
if [ "1" != "${FOUND}" ]; then
	echo "error: unknown package"
	exit 1
fi


#############################
# Setup working environment #
#############################
 
CUR_DIR=$(pwd)
WORK_DIR=$(mktemp -d -t extract-ipk-XXXXXX)

cd ${WORK_DIR}

#########################
# create  debian-binary #
#########################

echo "2.0" > debian-binary


#########################
# Create control.tar.gz #
#########################

OPKG_INFO_DIR="/var/lib/opkg/info"
CONTROL_FILE_PREFIX="${OPKG_INFO_DIR}/${PACKAGE}."
CONTROL_FILE_PREFIX_LENGTH="${#CONTROL_FILE_PREFIX}"

CONTROL_FILES=$(ls ${CONTROL_FILE_PREFIX}*)
if [ "0" != "$?" ]; then
	echo "error: failed to find package in OPKG info dir: ${OPKG_INFO_DIR}"
	exit 1
fi

mkdir control
for file in ${CONTROL_FILES}; do
	SUFFIX="${file:$CONTROL_FILE_PREFIX_LENGTH}"
	# ignore .list file (contains installed files),
	# but include all other files (control, preinst, postinst, prerm, postrm, ...)
	if [ "list" != "$SUFFIX" ]; then
		cp -p "$file" "control/${SUFFIX}"
	fi
done

cd control
tar -czf ../control.tar.gz .
cd .. 


######################
# Create data.tar.gz #
######################

mkdir data
DATA_FILES=$(opkg files ${PACKAGE} | tail -n +2)
for file in $DATA_FILES; do
	# we ignore directories
	# tar will create parent diretories
	# empty directories will be lost
	if [ ! -d "${file}" ]; then
		cp -p --parents -d "${file}" data
	fi
done

cd data
tar -czf ../data.tar.gz .
cd ..


###############
# Package IPK #
###############

ar -cr "${CUR_DIR}/${PACKAGE}.ipk" debian-binary control.tar.gz data.tar.gz


###########
# Cleanup #
###########

cleanup

