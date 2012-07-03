#! /bin/bash
# usage: inspect_run.sh blendo_path proj_path db_file
args=("$@")
blendo_path=${args[0]}
proj_path=${args[1]}
db_file=${args[2]}

curr_dir=$(pwd)
cd $proj_path
python $blendo_path/src.MS/inspect/current/PrepDB.py FASTA $db_file
python $blendo_path/MS-toolbox/bin/prepare-inspect.py
$proj_path/scripts/run-inspect.sh

# Create hit_list for msblender input from .pep.xml
cd $proj_path/inspect
$blendo_path/MSblender/pre/inspect_out-to-hit_list.sh
cd $curr_dir