#! /bin/bash
files=`ls *.svg`
echo $files
for i in $files; do inkscape --file=$i -D -e ${i//.svg/.png} ;done