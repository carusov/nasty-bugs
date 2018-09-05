#!/bin/bash

### Author: Vincent Caruso
### Date Written: April 18, 2018
### Last Modified: April 18, 2018
### Purpose: This script computes the mapped coverages of all .bam files in a
### set of lyve-SET projects. It accepts as input a directory (current directory
### by default) and looks for subdirectories that look like lyve-SET projects.
### For each .bam file in each project, it computes the fraction of the
### reference genome covered and the average depth of coverage, printing the
### results to an tab-delimited output file (coverage_stats.txt by default).

# Define default parameters
INDIR=$PWD
OUTFILE=coverage_stats.txt

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-i|--indir)
	    INDIR="$2"
	    shift;;
	-o|--outfile)
	    OUTFILE="$2"
	    shift;;
 	-h|--help)
	    printf "\nUSAGE: compute_mapped_coverage.sh [options]\n"
	    printf "\nOptions: \t[default]"
	    printf "\n-i --indir \t[current directory] \tinput directory"
	    printf "\n-o --outfile \t[./coverage_stats.txt] \toutput file\n\n"
	    exit;;
	*)
    	    printf "\nERROR: Invalid script usage. Here is the proper usage for this script:\n"
	    compute_mapped_coverage.sh -h
	    exit 1;;

    esac
    shift
done

INDIR=$(readlink -f "$INDIR")
OUTFILE=$(readlink -f "$OUTFILE")

printf "\nINPUT DIRECTORY: %s" "$INDIR"
printf "\nOUTPUT FILE: %s\n\n" "$OUTFILE"

calc(){ awk 'BEGIN { print "$*" }'; }

header="Project\tSample\tFraction covered\tAverage depth\n"
printf "$header" > "$OUTFILE"

for dir in $(find "$INDIR"/* -prune -type d)
do
#    dir="${dir%/}"
    if [ -d "$dir"/bam/ ] && [ -d "$dir"/reference/ ]
    then
	if [ "$(ls -A "$dir"/bam)" ] && [ "$(ls -A "$dir"/reference)" ]
	then
	    ref_len=$(awk '/^[ACGT]/ {len+=length($0)} END {print len}' \
			 "$dir"/reference/reference.fasta)

	    for f in $(ls "$dir"/bam/*.bam)
	    do
		sample=${f##*/}
		sample=${sample%.fastq.gz*}
		coverage=($(samtools depth "$f" | \
				   awk '{sum+=$3; count++} END {print count, sum/count}'))
#		frac_covered=$(calc ${coverage[0]} / $ref_len )
		frac_covered=$(echo "scale=4; ${coverage[0]} / $ref_len" | bc)
		avg_depth=${coverage[1]}

		printf "%s\t%s\t%s\t%s\n" "${dir##*/}" "$sample" $frac_covered $avg_depth
		printf "%s\t%s\t%s\t%s\n" "${dir##*/}" "$sample" $frac_covered $avg_depth \
		       >> "$OUTFILE"
	    done
	fi
    fi
done

