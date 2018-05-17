# Author: Vincent Caruso
# Date written: January 29, 2018
# Date last modified: January 29, 2018
# Purpose: This script runs the SeqSero Salmonella serotyping analysis on a set
# of samples in the specified working directory. It takes as input parameters a
# working directory path and a prefix for the sample names. The script assumes
# a separate directory for each sample under the working directory. There may
# be multiple replicates per sample. There must be a pair of .fastq read files
# (forward and reverse) for each replicate, and read files for all replicates
# must be placed directly under the sample directory (not in subdirectories).
# Alternatively, all replicates could be placed in a single "sample" directory
# if desired.

# Set default parameters
PREFIX="VS"
WDIR=$PWD

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-w|--working)
	    WDIR="$2"
	    shift;;
	-p|--prefix)
	    PREFIX="$2"
	    shift;;
	-h|--help|*)
	    printf "\nUSAGE: run_seqsero_analysis.sh [options]\n"
	    printf "\nOptions: \t[ default ]"
	    printf "\n-w --working \t[ current directory ] \tworking directory"
	    printf "\n-p --prefix \t[ VS ] \t\t\tsample name prefix\n\n"
	    exit;;
	*)
	;;
    esac
    shift
done

printf "\nWorking directory: %s" $(dirname "$WDIR")
printf "\nSample name prefix: %s\n\n" "$PREFIX"

if [ ! -d "$WDIR" ];then
    echo "ERROR: Es tut mir leid, that working directory doesn't exist!"
    exit
fi

pushd "$WDIR"

source activate seqsero

for sample in $(ls -d "$PREFIX"*)
do
    if [ -d "$sample" ]
    then
	cd "$sample"
	for iso in $(ls *R1*.fastq*)
	do
	    bn=${iso%_R1*}  # remove direction suffix
	    name=${bn%%_*}  # remove any other suffix
	    suffix=${iso#*R1}  # get the suffix

	    SeqSero.py -m 2 -i $bn"_R1"$suffix $bn"_R2"$suffix
	    cp SeqSero_result_*/Seqsero_result.txt ./$name"_seqsero_result.txt"
	    rm -r SeqSero_result_*
	    printf "\nDone with isolate %s\n\n" $name
	done
	cd ..
    fi
    printf "\nDone with sample %s\n\n" "$sample"
done

source deactivate
popd
