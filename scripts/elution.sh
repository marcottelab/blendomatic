#! /bin/bash
usage="Usage: elution.sh <sourcedir> <msb_dir> <shortname> <match> <fdr_num>"
# run from where you want target directory made
args=("$@")
if [ ${#args[@]} -lt 5 ]; then
    echo $usage
    exit 1
fi

abspath(){ python -c "import os.path; print os.path.abspath('$1')" ; }
sourcedir=$(abspath ${args[0]})
msb=${args[1]}
shortname=${args[2]}
match=${args[3]}
fdr_num=${args[4]}
fdr_string="0"${fdr_num#*.}
fdr_string_out=${fdr_string}"0"
searches=( Tide Inspect MSGFDB )
extensions=( xcorr_hit_list_best MQscore_hit_list_best logSpecProb_hit_list_best )

if [ -d $shortname ]; then
    echo "exiting: directory exists. does not handle merging with existing output."
    exit 1
fi

mkdir $shortname
cd $shortname
echo "sourcedir:"$sourcedir", combining into $shortname.(search).combined_best"
nsearches=${#searches[@]}
for (( i=0;i<$nsearches;i++ ))
do
    search=${searches[$i]}
    ext=${extensions[$i]}
    echo "match"${match}*.$ext
    comb_file=$shortname.$search.combined_best
    bestfiles=$(ls $sourcedir/${match}*.$ext)
    for bestfile in $bestfiles
    do
        if [ $search != Tide ]; then
            cat $bestfile >> $shortname.$search.combined_best
        else
            # Tide is missing spectrum ids--handle separately
            filebase=$(basename "$bestfile")
            filebase="${filebase%%.*}"
            sed "s/^000/${filebase}/g" $bestfile >> $comb_file
        fi
    done
    if [ ${#bestfiles} -gt 0 ]; then
        # -e enables special characters, needed for tab and maybe newline too
        echo -e "${search}\t${comb_file}" >> $shortname.conf
        echo 'search '$search': '$(echo $bestfiles | wc -w)' files' >> $shortname.bestcount
    fi
done

echo "Blendomatic: creating msblender_in"
$msb/pre/make-msblender_in.py $shortname.conf 
echo "Blendomatic: running MSblender"
$msb/src/msblender $shortname.msblender_in 
$msb/post/make-spcount.py $shortname.msblender_in.msblender_out $shortname.prot_list $fdr_num
$msb/post/filter-msblender.py $shortname.msblender_in.msblender_out $fdr_string > $shortname.filter
python $msb/post/msblender_out-to-pep_count.py $shortname.msblender_in.msblender_out $fdr_num
echo "Blendomatic: DONE.  Results summary:"
cat $shortname.bestcount
tail -n 1 $shortname.filter
echo "Total union proteins: "$(wc -l $shortname.spcount*)

# protein count with unique peptides only, and compute pairwise scores
sp=${shortname%%"_"*}
pep2prots=$(ls ../../$sp.pepDict) # returns blank and so skipped if not found
python ~/git/complex/protein_counts.py $shortname.pep_count_FDR${fdr_string} True $pep2prots
protcounts=$shortname.prot_count_uniqpeps2_FDR${fdr_string}
python ~/git/complex/score.py $protcounts poisson 1000
python ~/git/complex/scripts/compactify.py $protcounts.corr_poisson f2
~/git/complex/scripts/wcc.sh $protcounts 1
python ~/git/complex/scripts/compactify.py $protcounts.T.wcc_width1 f2
