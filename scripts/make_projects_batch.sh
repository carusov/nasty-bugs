#!/bin/bash

# Create several lyve-SET projects by calling 'make_snp_project.sh' and reading
# the input variables from a file

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-f|--file_name)
	    FNAME="$2"
	    shift;;
	-h|--help|*)
	    printf "\nUSAGE: make_projects_batch.sh -f --file_name variable_file_name\n"
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

while read -r s r; do
    make_snp_project.sh -s $s -r $r
done < "$FNAME"
