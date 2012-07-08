#!/bin/bash
usage="usage: status.sh <search> <sp>"
if [ $# -lt 1 ]; then
    echo $usage
    exit 1
fi
search=$1
sp=$2

echo "*mzXML *in *out *tmp *best"
for f in $(ls -d ${sp}*/); do echo $f $(ls $f/mzXML/*mzXML | wc -l) $(ls $f/$search/*in 2>/dev/null | wc -l) $(ls $f/$search/*out 2> /dev/null | wc -l) $(ls $f/$search/*tmp 2> /dev/null | wc -l) $(ls $f/$search/*best 2> /dev/null | wc -l); done