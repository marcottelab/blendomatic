#!/bin/bash
usage="usage: run_template_command.sh <command> <jobname> <numhours> 
<qtype{long|normal}> <procs {4/8way_8/16/32}>"
args=("$@")
if [ ${#args[@]} -lt 5 ]; then
    echo $usage
    exit 1
fi
command=${args[0]}
name=${args[1]}
hours=${args[2]}
qtype=${args[3]}
procs=${args[4]/_/ }
submit_script='tacc/scripts/submit/template_submit.sh'
module load python
module load java
cp tacc/scripts/template.sh $submit_script
echo '#$ -N '$name >> $submit_script
echo '#$ -l h_rt='${hours}':00:00' >> $submit_script
echo '#$ -q '${qtype} >> $submit_script #long
# First number says jobs per node; 8 means one proc per job
# Second number says number of cores; mult of 8 on longhorn
# Eg: 8way 8 means one node, 8 jobs.  4way 32 means 4 nodes, 4 jobs/node.
echo '#$ -pe '${procs} >> $submit_script
echo $command >> $submit_script
qsub $submit_script
#cat $submit_script
