#!/bin/bash
usage="usage: run_template_command.sh <command> <jobname> <numhours> 
<numTasks>"
args=("$@")
if [ ${#args[@]} -lt 5 ]; then
    echo $usage
    exit 1
fi
command=${args[0]}
name=${args[1]}
hours=${args[2]}
tasks=${args[3]/_/ }
submit_script='tacc/scripts/submit/template_submit.sh'
cp tacc/scripts/template.sh $submit_script
echo '#$ -J '$name >> $submit_script
echo '#$ -t '$hours':00:00' >> $submit_script
# First number says jobs per node; 8 means one proc per job
# Second number says number of cores; mult of 8 on longhorn
# Eg: 8way 8 means one node, 8 jobs.  4way 32 means 4 nodes, 4 jobs/node.
echo '#$ -n '$tasks >> $submit_script
echo $command >> $submit_script
qsub $submit_script
#cat $submit_script
