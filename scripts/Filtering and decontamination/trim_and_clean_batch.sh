#!/bin/bash

### Author: Vincent Caruso
### Date: 5/25/18
### This script performs quality filtering on a batch of Illumina paired-end
### read sets. Each read set should reside in its own directory, which is a
### subdirectory of the directory passed as input to this script. This script
### simply calls the 'trim_and_clean.sh' script on each of the subdirectories,
### passing the same trimming and cleaning parameters to each.

# Define default parameters
INDIR=$PWD
MINQ=30
AVGQ=10
MINL=62
CPU=4

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
	-h|--help)
	    printf "\nUSAGE: trim_and_clean_batch.sh [-q/-t minimum quality/minimum bases to trim]\n"
	    printf "\nOptions: \t[default]"
	    printf "\n-i --in_dir \t[current directory] \tdirectory of samples"
	    printf "\n-q --min_qual \t[30] \t\t\tminimum quality for trimming"
	    printf "\n-t --trim \t[20] \t\t\tbases to trim"
	    printf "\n-a --avg_qual \t[10] \t\t\tminimum average quality for cleaning"
	    printf "\n-l --length \t[62] \t\t\tminimum length for cleaning"
	    printf "\n-n --numcpus \t[4] \t\t\tnumber of cpus to use\n\n"
	    exit;;
	*)
    	    printf "\nERROR: Invalid script usage. Here is the proper usage for this script:\n"
	    trim_and_clean_batch.sh -h
	    exit 1;;
    esac
    shift
done


# Make sure input directory exists
if [ ! -d "$INDIR" ]
then
    printf "\nERROR: The specified input directory does not exist.\n"
    exit 1
else
    INDIR=$(readlink -f "$INDIR")
fi

# Print parameter configuration
printf "\nINPUT DIRECTORY: %s" "$INDIR"
printf "\nMINIMUM QUALITY (trimming): %s" $MINQ
printf "\nTRIM LENGTH (trimming): %s" $TRIM
printf "\nMINIMUM AVERAGE QUALITY (cleaning): %s" $AVGQ
printf "\nMINIMUM LENGTH (cleaning): %s\n\n" $MINL

# Process each sample subdirectory
for d in $(ls -d "$INDIR"/*/)
do
    if [ ! -z $TRIM ]
    then
	trim_and_clean.sh -i "$d" \
			  -t $TRIM \
			  -a $AVGQ \
			  -l $MINL \
			  -n $CPU
    else
	trim_and_clean.sh -i "$d" \
			  -q $MINQ \
			  -a $AVGQ \
			  -l $MINL \
			  -n $CPU
    fi

    printf "\nFinished processing run %s\n\n" "$(basename "$d")"
done

