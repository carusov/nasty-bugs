#!/bin/bash

### Author: Vincent Caruso
### Date: 4/26/18
### Last modified: 4/26/18
### Purpose: This script selects a single FASTQ file from a directory of FASTQ
### files and assembles a genome de novo using the SPAdes assembler. The script
### takes as input a working directory from which to select a FASTQ file, and
## it selects the largest FASTQ file for assembly.

# Define default parameters
WDIR=$PWD

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-w|--working)
	    WDIR="$2"
	    shift;;
	-o|--output)
	    OUTDIR="$2"
	    shift;;
	-h|--help)
	    printf "\nUSAGE: assemble_isolate.sh [options]\n"
	    printf "\nOptions: \t[default]"
	    printf "\n-w --working \t[current directory] \t\tdirectory of FASTQ files"
	    printf "\n-o --output \t[current/spades_output] \tdirectory for SPAdes output"
	    printf "\n"
	    exit;;
	*)

	;;

    esac
    shift
done


WDIR=$(readlink -f "$WDIR")


# Set output directory
if [[ -z "$OUTDIR" ]];
then
    OUTDIR="$WDIR"/assembly
else
    OUTDIR=$(readlink -f "$OUTDIR")
fi
    

# Print configuration message
printf "\nWORKING DIRECTORY: %s" "$WDIR"
printf "\nOUTPUT DIRECTORY: %s\n" "$OUTDIR"


# Find largest FASTQ file
fastq=($(ls -S "$WDIR"/*.fastq*))
fastq=${fastq[0]}


# Print selected isolate name
name=${fastq##*/}
#name=${name%%_*}
printf "\nI'm going to assemble file %s.\n\n" "$name"


# Assemble selected FASTQ file
spades.py --12 "$fastq" -o "$OUTDIR" --careful
