#!/bin/bash
usage="usage: quicklaunch.sh <foldermatch>"
if [ $# -lt 1 ]; then
    echo $usage
    exit 1
fi
match=$1

for f in $(ls -d ${match}*/)
do 
    f=${f%?} 
    name=i${f:0:1}${f: -6}
    plist=tacc/scripts/submit/paramlist.$name
    rm $plist
    echo "~/git/blendomatic/scripts/main.sh $f mzXML/$f ${f:0:2}.fasta 0.01 inspect 1" >> $plist
    for i in $(seq 31)
    do 
        echo "sleep 300; $f/scripts/run-inspect.sh" >> $plist
    done
    ./tacc/launch.sh $name 24 long '8way 32'
done
