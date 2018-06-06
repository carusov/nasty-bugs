#!/bin/bash

# Create several lyve-SET projects by calling 'make_snp_project.sh' and reading
# the input variables from a file

REFDIR=~/references
OUTDIR=$PWD

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-f|--file_name)
	    FNAME="$2"
	    shift;;
	-w|--work_dir)
	    WDIR="$2"
	    shift;;
	-r|--ref_dir)
	    REFDIR="$2"
	    shift;;
	-o|--out_dir)
	    OUTDIR="$2"
	    shift;;
	-h|--help|*)
	    printf "\nUSAGE: make_projects_batch.sh -f --file_name variable_file_name\n"
	    printf "Options: \t[default]"
	    printf "\n-w --work_dir \t[current directory] \t\tworking sample directory"
	    printf "\n-r --ref_dir \t[%s] \treference assembly directory" "$REFDIR"
	    printf "\n-o --out_dir \t[current directory] \t\toutput directory\n\n"
	    exit;;
	*)

	;;
    esac
    shift
done

if [ -z $FNAME ]; then
    printf "\nERROR: You must supply a file name containing the sample and reference names\n"
    printf "on each line\n\n"
    exit
fi

WDIR=$(readlink -f "$WDIR")
REFDIR=$(readlink -f "$REFDIR")
OUTDIR=$(readlink -f "$OUTDIR")

# Create output directory if necessary
if [ ! -d "$OUTDIR" ];
then
    mkdir "$OUTDIR"
fi

while read -r s r; do
    make_snp_project.sh -s $s -w "$WDIR" -r $r -d "$REFDIR" -t "$OUTDIR"/$s
done < "$FNAME"
