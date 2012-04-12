#! /bin/bash
usage="Usage: main.sh <proj_name> <mzXML_path> <db_source> <fdr>"
# run from where you want target directory made

abspath(){ python -c "import os.path; print os.path.abspath('$1')" ; }

base_path="/project/marcotte/MSblendomatic"
blendo_path="$base_path/blendomatic"
src_path="$base_path/src.MS"
scripts_path="$blendo_path/scripts"
#### debug mode ####
#scripts_path=$(abspath "../../scripts")
#set -x
searches=( tide msgfdb inspect ) #inspect )
########
base_work_dir=$(pwd)

args=("$@")
if [ ${#args[@]} -lt 4 ]; then
    echo $usage
    exit 1
fi
proj_name=${args[0]}
mzXML_path=$(abspath ${args[1]})
db_source=$(abspath ${args[2]})
fdr=${args[3]}

# helpers

# make new project directory with appropriate mstb.conf changes
proj_path=$base_work_dir/$proj_name
if [ -d $proj_name ]; then
    echo "exiting: directory ${proj_name} already exists."
    exit 1
fi
mkdir $proj_path
cp -r $blendo_path/project_template/* $proj_path

# move mzXML and fasta DB sequence files into place
if [ -d $mzXML_path ]; then
    echo "using all .mzXML files from $mzXML_path"
    ln -s $mzXML_path/*.mzXML $proj_path/mzXML/
elif [ -f $mzXML_path ]; then
    echo "using mzXML file: $mzXML_path"
    ln -s $mzXML_path $proj_path/mzXML/
else
    echo "exiting: mzXML file(s) not found: $mzXML_path"
    exit 1
fi
if [ -f $db_source ]; then
    echo "using DB file: $db_source"
    ln -s $db_source $proj_path/DB/
else
    echo "exiting: DB file not found: $db_source"
    exit 1
fi

# create proper DB combined file with decoys
echo "MSblendomatic: setting up combined target/decoy db"
db_file_temp=$proj_path/DB/$(basename $db_source)
python $base_path/MS-toolbox/bin/fasta-reverse.py $db_file_temp
db_file=${db_file_temp%.*}_combined.fasta
mv $db_file_temp.target $db_file
cat $db_file_temp.reverse >> $db_file

# set up mstb correctly
# use @ as separator to avoid path name ('/') regex issues
sed -i s@project_name_replace@${proj_name}@g $proj_path/mstb.conf
sed -i s@project_path_replace@${proj_path}@g $proj_path/mstb.conf
db_basename=$(basename $db_file)
db_basename=${db_basename%.*}
sed -i s@DB_combined@${db_basename}@g $proj_path/mstb.conf

# run searches
for search in "${searches[@]}"
do
    if [ $search = 'tide' ]; then
        echo "MSblendomatic: running tide"
        source $scripts_path/tide_run.sh $base_path $proj_path $db_file
    elif [ $search = 'msgfdb' ]; then
        echo "MSblendomatic: running MSGFDB"
        source $scripts_path/msgfdb_run.sh $base_path $proj_path $db_file
    elif [ $search = 'inspect' ]; then
        echo "MSblendomatic: running Inspect"
        source $scripts_path/inspect_run.sh $base_path $proj_path $db_file
    fi
done

# move search output _best files into place
mkdir $proj_path/bestfiles
for bestfile in $(ls $proj_path/*/*_best)
do
    ln -s $(abspath $bestfile) $proj_path/bestfiles/
done

# run msblender to get spcount file output
echo "MSblendomatic: preparing to run MSblender"
curr_dir=$(pwd)
cd $proj_path
source $scripts_path/elution.sh $proj_path/bestfiles $base_path/MSblender $proj_name "" $fdr
cd $curr_dir