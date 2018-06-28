#!/bin/bash

# Run a batch of lyve-SET projects by calling the 'launch_set.pl' script for each of the project
# names listed in the input file. The project directory should be alread set up with requisite
# cleaned/filtered FASTQ files, any assemblies, and a reference genome. The parameters input to
# this script will be applied to all projects listed in the input file.

# Define default parameters
FLANK=0
FRAC=0.75
COVER=10
CPU=1

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-f|--file_name)
	    FNAME="$2"
	    shift;;
	-i|--in_dir)
	    INDIR="$2"
	    shift;;
	-F|--allowed_flanking)
	    FLANK="$2"
	    shift;;
	-p|--min_alt_frac)
	    FRAC="$2"
	    shift;;
	-c|--min_coverage)
	    COVER="$2"
	    shift;;
	-n|--num_cpus)
	    CPU="$2"
	    shift;;
	-h|--help)
	    printf "\nUSAGE: run_lyve_batch.sh -f --file_name project_list_file [options]\n"
	    printf "\nOptions: \t\tdefault"
	    printf "\n-i --in_dir \t[current directory] \tinput directory"
	    printf "\n-F --allowed_flanking \t0 \t\tallowed flanking distance in bp for"
	    printf "\n\t\t\t\t\tnearby nucleotides to be considered"
	    printf "\n\t\t\t\t\thigh quality"
	    printf "\n-p --min_alt_frac \t0.75 \t\tpercent consensus required for a SNP to"
	    printf "\n\t\t\t\t\tbe called"
	    printf "\n-c --min_coverage \t10 \t\tminimum coverage required for a SNP to"
	    printf "\n\t\t\t\t\tbe called"
	    printf "\n-n --num_cpus \t\t1 \t\tnumber of cpus to use\n\n"
	    exit;;
	*)
    	    printf "\nERROR: Invalid script usage. Here is the proper usage for this script:\n"
	    run_lyve_batch.sh -h
	    exit 1;;
    esac
    shift
done

if [ -z $FNAME ];then
    printf "\nERROR: You must supply a file name containing the project directories to process,\n"
    printf "with one project name per line.\n\n"
    exit
fi

INDIR=$(readlink -f "$INDIR")

while read -r proj
do
    launch_set.pl "$INDIR"/${proj[0]} \
		  --allowedFlanking $FLANK \
		  --min_alt_frac $FRAC \
		  --min_coverage $COVER \
		  --notrees \
		  --numcpus $CPU
done < "$FNAME"
