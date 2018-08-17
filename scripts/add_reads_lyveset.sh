#!/bin/bash

### Author: Mark Klick
### Date written: 8/13/18
### Last modified: 8/13/18
### Purpose: This script adds reads to a lyve_set project

# Define default parameters

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
		-p|--lyveset_project)
			LYVE_PROJ="$2"
			shift;;
		-i|--input_dir)
			DIR="$2"
			shift;;
		-r|--ref_assembly)
                        REF="$2"
                        shift;;
		-g|--run_launch_set)
                        RUN="$2"
                        shift;;
		-h|--help)
			printf "example: add_reads_lyveset -p [new project] -i [fastq file directory] -r [reference assembly]"
			exit;;
		*)
			printf "\nERROR: Invalid script usage. Here is the proper usage for this script:\n"
			add_reads_lyveset.sh -h
			exit 1;;
    esac
    shift
done

if [ -z "$LYVE_PROJ" ]; then
        echo "LYVE_PROJ project already created"
else
	echo "creating a lyve_set project called $LYVE_PROJ"
	set_manage.pl "$LYVE_PROJ" --create
fi

if [ -z "$DIR" ]; then
	echo "no fastq read file directory supplied"
else
	DIR=$(readlink -f "$DIR")
	files=$(ls "$DIR")
	for f in $files
	do
        	#echo "$(basename "$f")"
        	echo "$f is added to the lyve_set project $LYVE_PROJ"
        	set_manage.pl "$LYVE_PROJ" --add-reads "$DIR"/$f 
	done 
fi

if [ -z "$REF" ]; then
	echo "no reference argument supplied"
else
	#REF=$(readlink -f "$REF")
	echo "adding $REF to the lyve_set project"
	set_manage.pl "$LYVE_PROJ" --change-reference "$REF"
fi

if [ -z "$RUN" ]; then
	echo "you decided not to run launch_set.pl"
else
	echo "running launch_set.pl"
	launch_set.pl "$LYVE_PROJ" --numcpus 8
fi

