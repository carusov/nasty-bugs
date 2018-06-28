#!/bin/bash

### Author: Vincent Caruso
### Date: 11/16/2017
### This script performs quality filtering on a set of Illumina paired-end FASTQ
### read files. It first trims read ends (5' and 3') until a base with a
### minimum quality score is encountered, and discards reads that fall below
### a minimum length. The trimmed reads are then further cleaned by discarding
### any whose average quality is below a minimum score. Optionally, reads whose
### pair was discarded are also dicarded.

# Define default parameters
INDIR=$PWD
MINQ=30
AVGQ=10
MINL=62
CPU=4
GZIP=0

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-i|--in_dir)
	    INDIR="$2"
	    shift;;
	-q|--min_qual)
	    MINQ="$2"
	    shift;;
	-t|--trim)
	    TRIM="$2"
	    shift;;
	-a|--avg_qual)
	    AVGQ="$2"
	    shift;;
	-l|--length)
	    MINL="$2"
	    shift;;
	-n|--numcpus)
	    CPU="$2"
	    shift;;
	    ;;
	-h|--help)
	    printf "\nUSAGE: trim_and_clean.sh [-q/-t minimum quality/minimum bases to trim]\n"
	    printf "\nOptions: \t[default]"
	    printf "\n-i --in_dir \t[current directory] \tdirectory of FASTQ files"
	    printf "\n-q --min_qual \t[30] \t\t\tminimum quality for trimming"
	    printf "\n-t --trim \t[20] \t\t\tbases to trim"
	    printf "\n-a --avg_qual \t[10] \t\t\tminimum average quality for cleaning"
	    printf "\n-l --length \t[62] \t\t\tminimum length for cleaning"
	    printf "\n-n --numcpus \t[4] \t\t\tnumber of cpus to use"
	    printf "\n--gzip \t[FALSE] \t\t\tcompress cleaned sample files\n\n"
	    exit;;
	*)
    	    printf "\nERROR: Invalid script usage. Here is the proper usage for this script:\n"
	    trim_and_clean.sh -h
	    exit 1;;
    esac
    shift
done

# Check for valid input parameters
#if [ -z $MINQ ] && [ -z $TRIM ]
#then
#    printf "\nERROR: You must specify either a minimum quality (-q) or"
#    printf "\nnumber of bases to trim (-t).\n"
#    exit 1
#fi

# Make sure input directory exists
if [ ! -d "$INDIR" ]
then
    printf "\nERROR: The specified input directory does not exist.\n"
    exit 1
else
    INDIR=$(readlink -f "$INDIR")
fi

# Create directories for interleaved and cleaned reads
if [ ! -d "$INDIR"/interleaved ]; then
    mkdir "$INDIR"/interleaved
fi

if [ ! -d "$INDIR"/clean ]; then
    mkdir "$INDIR"/clean
fi

# Assemble, trim and clean
for f in $(ls "$INDIR"/*_R1*.fastq.gz); do

    b=$(basename $f)
    pre=${b%_R1*}
    suf=${b#*_R1}

    # Check to see if sample has already been cleaned
    if [ -f "$INDIR"/clean/$pre".cleaned.fastq.gz" ];
    then
	printf "Sample %s has already been cleaned\n" $pre

    else
	# Assemble paired-end read files
	run_assembly_shuffleReads.pl "$INDIR"/$pre"_R1"$suf "$INDIR"/$pre"_R2"$suf \
				     > "$INDIR"/interleaved/$pre".fastq"
	printf "\nSample %s assembled\n\n" $pre

	# Trim and clean assembled read files
	# If user specifies trim length, use that for trimming instead of quality
	if [ ! -z $TRIM ]
	then
    	    run_assembly_trimClean.pl -i "$INDIR"/interleaved/$pre".fastq" \
				      -o "$INDIR"/clean/$pre".cleaned.fastq.gz" \
				      --bases_to_trim $TRIM \
				      --min_avg_quality $AVGQ \
				      --min_length $MINL \
				      --nosingletons \
				      --numcpus $CPU
	else
	    run_assembly_trimClean.pl -i "$INDIR"/interleaved/$pre".fastq" \
				      -o "$INDIR"/clean/$pre".cleaned.fastq.gz" \
				      --min_quality $MINQ \
				      --min_avg_quality $AVGQ \
				      --min_length $MINL \
				      --nosingletons \
				      --numcpus $CPU
	fi

	printf "\nSample %s trimmed and cleaned\n" $pre
    fi
done
#> & "$INDIR"/clean/cleaning.log &
