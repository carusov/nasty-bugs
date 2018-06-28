#!/bin/bash

# set up default parameters
OUTDIR=$PWD

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-f|--file_name)
	    FNAME="$2"
	    shift;;
	-a|--accession)
	    SRR="$2"
	    shift;;
	-r|--rename)
	    RNAME="$2"
	    shift;;
	-o|--out_dir)
	    OUTDIR="$2"
	    shift;;
	-h|--help)
	    printf "\nUSAGE: download_sra.sh [-f file_name.txt]|[-a SRR_accession]"
	    printf "\nOptions: \t[default]"
	    printf "\n-f --file_name \t\t\ttext file with accessions, one per line"
	    printf "\n\t\t\t\t\t(with optional renaming string)"
	    printf "\n-a --accession \t\t\tSRR run accession number"
	    printf "\n-r --rename \t\t\trenaming string\n\n"
	    exit;;
	*)
    	    printf "\nERROR: Invalid script usage. Here is the proper usage for this script:\n"
	    download_sra.sh -h
	    exit 1;;

    esac
    shift
done

while read -r sra newid; do
    fastq-dump -I --split-files --gzip -O "$OUTDIR" $sra
    mv "$OUTDIR"/"$sra"_1.fastq.gz "$OUTDIR"/"$newid"_R1.fastq.gz
    mv "$OUTDIR"/"$sra"_2.fastq.gz "$OUTDIR"/"$newid"_R2.fastq.gz
    echo "Done with $sra"
done < "$FNAME"
