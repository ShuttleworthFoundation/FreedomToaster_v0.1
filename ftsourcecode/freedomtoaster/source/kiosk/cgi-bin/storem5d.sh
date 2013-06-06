#!/bin/bash
# This script takes a single parameter
# (the directory containing all the iso images for this distro.)
# and writes all the md5sums of the images to tha same directory
DIR=`echo $1 | tr [:upper:] [:lower:]`
echo "Doing:"
for i in `ls -1 /distros/$DIR/*.iso`
do
	echo -e "\t$i"
	md5sum $i > $i.md5
done
