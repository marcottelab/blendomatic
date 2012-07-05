#! /bin/bash
# usage: tide_search.sh blendo_path proj_path db_file
args=("$@")
blendo_path=${args[0]}
proj_path=${args[1]}
db_file=${args[2]}

exec_path=$blendo_path/src.MS/local/bin
PROT=${db_file/.fasta/_miss2.protidx}
PEP=${PROT/.protidx/.pepix}

# Index the DB file
IDX="$exec_path/tide-index"
$IDX --max_missed_cleavages=2 --enzyme=trypsin --mods_spec=C+57.02146 --fasta=$db_file --proteins=$PROT --peptides=$PEP

# Create spectrumrecords
mkdir $proj_path/tide
curr_dir=$(pwd)
cd $proj_path/tide
$exec_path/tide-msconvert --spectrumrecords $proj_path/mzXML/*.mzXML
#cd $curr_dir

# Perform search
SEARCH="$exec_path/tide-search"
SUFFIX=".tideres"
for SR in $(ls $proj_path/tide/*.spectrumrecords)
do
 $SEARCH --peptides=$PEP --proteins=$PROT --spectra=$SR --results=protobuf 
 # They claim you can direct output, but it doesn't work.
# Always goes into results.tideres
 OUT=$(basename $SR)
 OUT=$proj_path/tide/${OUT/.spectrumrecords/}$SUFFIX
 mv results.tideres $OUT
done

# Convert .results output to .pep.xml
RESULTS="$exec_path/tide-results"
AUX="${PROT/_miss2.protidx/.fasta.auxlocs}"
SUFFIX=".results"
#SUFFIX=".results.pepxml"
for SR in $(ls $proj_path/tide/*.spectrumrecords)
do
 RES=${SR/.spectrumrecords/.tideres}
 OUT=$(basename $SR)
 OUT=$proj_path/tide/${OUT/.spectrumrecords/}$SUFFIX
 $RESULTS --proteins=$PROT --spectra=$SR --results_file=$RES --out_filename=$OUT --out_format=pep.xml --aux_locations=$AUX --show_all_proteins=True
 #They attach another extension, which messes up following steps
# mv $OUT.pep.xml $OUT
done

# Create hit_list for msblender input from .pep.xml
#cd $proj_path/tide
cd $proj_path/tide
echo $(pwd)
source $blendo_path/MSblender/pre/tide_pepxml-to-hit_list.sh
cd $curr_dir