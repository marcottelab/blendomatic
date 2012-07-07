#!/bin/bash
usage="usage: run_template_command.sh <command> <jobname> <numhours> <qtype{long|normal}>"
args=("$@")
if [ ${#args[@]} -lt 4 ]; then
    echo $usage
    exit 1
fi
command=${args[0]}
name=${args[1]}
hours=${args[2]}
qtype=${args[3]}
submit_script='scripts/submit/template_submit.sh'
cp scripts/template.sh $submit_script
echo '#$ -N '$name >> $submit_script
echo '#$ -l h_rt='${hours}':00:00' >> $submit_script
echo '#$ -q '${qtype} >> $submit_script #long
echo $command >> $submit_script
qsub $submit_script
#cat $submit_script
