#!/bin/bash

# Execute the 'run_assembly_readMetrics.pl' script on a batch of sample directories.
# The sample directory names should be listed in a file, along with the output file name prefix
# and the expected genome size (for coverage calculation), one set per line.
# This script will run the read metrics script on all .fastq or .fastq.gz files in each
# directory and produce a single tab-delimited file with the results for each directory.
# The output file will be named 'prefix_qc_metrics.tsv', and will be stored in the input directory.

CPU=1

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-f|--file_name)
	    FNAME="$2"
	    shift;;
	-n|--num_cpus)
	    CPU="$2"
	    shift;;
	-h|--help|*)
	    printf "\nUSAGE: run_qc_batch.sh -f --file_name sample_file_name\n"
	    printf "\nOptions: \t\tdefault"
	    printf "\n-n --num_cpus \t\t1 \t\tnumber of cpus to use\n\n"
	    exit;;
	*)

	;;
    esac
    shift
done

if [ -z $FNAME ];then
    printf "\nERROR: You must supply a file name containing the sample directories to process,\n"
    printf "with one directory name, output file prefix, and genome size per line.\n\n"
    exit
fi

while read -r dir prefix size
do
    FOUT="$dir"/"$prefix"_qc_metrics.tsv
    run_assembly_readMetrics.pl "$dir"/*.fastq* -e $size > "$FOUT"
    printf "Finished with directory %s\n" "$dir"
done < "$FNAME"
