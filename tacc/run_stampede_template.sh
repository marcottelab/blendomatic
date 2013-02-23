#!/bin/bash
usage="usage: run_template_command.sh <command> <jobname> <numhours> 
<numTasks>"
args=("$@")
if [ ${#args[@]} -lt 4 ]; then
    echo $usage
    exit 1
fi
command=${args[0]}
name=${args[1]}
hours=${args[2]}
tasks=${args[3]}
submit_script='tacc/scripts/submit/template_submit.sh'
cp tacc/scripts/stampede_template.sh $submit_script
echo '#SBATCH -J '$name >> $submit_script
echo '#SBATCH -t '$hours':00:00' >> $submit_script
echo '#SBATCH -n '$tasks >> $submit_script
echo $command >> $submit_script
sbatch $submit_script
#cat $submit_script
