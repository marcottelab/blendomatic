#!/bin/bash
# Chiefly for inspect runs since they're slow and need to be parallelized through Launcher
usage="usage: launch.sh <jobname> <numhours> <qtype{long|normal}>"
args=("$@")
if [ ${#args[@]} -lt 3 ]; then
    echo $usage
    exit 1
fi
name=${args[0]}
hours=${args[1]}
qtype=${args[2]}
submit_script='tacc/scripts/submit/launcher.sge'
cp tacc/launcher_head.sge $submit_script
echo '#$ -N '$name >> $submit_script
echo '#$ -l h_rt='${hours}':00:00' >> $submit_script
echo '#$ -q '${qtype} >> $submit_script #long
cat tacc/launcher_body.sge >> $submit_script

qsub < $submit_script
#cat $submit_script