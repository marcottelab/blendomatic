#! /bin/bash
# usage: msgfdb_search.sh blendo_path proj_path db_file
args=("$@")
blendo_path=${args[0]}
proj_path=${args[1]}
db_file=${args[2]}

java -Xmx5000M -cp $blendo_path/src.MS/MSGFDB/current/MSGFDB.jar msdbsearch.BuildSA -d $db_file -tda 0

curr_dir=$(pwd)
cd $proj_path
python $blendo_path/MS-toolbox/bin/prepare-MSGFDB.py
$proj_path/scripts/run-MSGFDB.sh

# Create hit_list for msblender input from .pep.xml
cd $proj_path/MSGFDB
$blendo_path/MSblender/pre/MSGFDB_out-to-hit_list.sh
cd $curr_dir