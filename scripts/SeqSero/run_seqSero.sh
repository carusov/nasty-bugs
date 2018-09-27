#!/bin/bash

### Author: Mark Klick
### Date: 8/17/2018
### Purpose: This script takes fastq files as input, exectues the seqsero.py script, then parses the output
### which contains the computationally found serotype.

# Define default parameters
#INDIR=$PWD

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -s|--sample_id)
            SNAME="$2"
            shift;;
        -h|--help)
            printf "\nUSAGE: run_seqsero.sh -i [input dir] -s [sample] \n"
            exit;;
        *)
            printf "\nERROR: Invalid script usage.\n"
            run_seqSero.sh -h
            exit 1;;
    esac
    shift
done

# Make sure input directory exists
if [ ! -d "$SNAME" ]
then
    mkdir -p "$SNAME"
    INDIR=$(readlink -f "$SNAME")
else
    INDIR=$(readlink -f "$SNAME")
fi

# download the sample
download_sample_basespace.sh -n $SNAME -t $INDIR

cd "$INDIR"
# activate seqSero mini conda environment
source activate seqsero

# run seqSero.py
for f in $(ls "$INDIR"/*_R1*.fastq.gz); do

    b=$(basename $f)
    pre=${b%_R1*}
    suf=${b#*_R1}

    SeqSero.py -m 2 -i "$INDIR"/$pre"_R1"$suf "$INDIR"/$pre"_R2"$suf
done

# deactivate conda environment
source deactivate

echo "finito"
