#!/bin/bash

### Author: Vincent Caruso
### Date: 11/16/2017
### This script creates a new lyve-SET project with the given sample name and populates
### it with the filtered (trimmed and cleaned)) FASTQ files from the isolates of that
### sample. If provided with a reference name, it will also search a directory of
### reference genome assemblies, and if a match is found, this reference will also be
### added to the project.

# Define default variables values
REFDIR=~/osphl/validation/references
SAMPDIR=$PWD

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-s|--samp_name)
	    NAME="$2"
	    shift;;
	-w|--samp_dir)
	    SAMPDIR="$2"
	    shift;;
	-r|--ref_assembly)
	    REF="$2"
	    shift;;
	-d|--ref_dir)
	    REFDIR="$2"
	    shift;;
	-t|--target_dir)
	    TARGET="$2"
	    shift;;
	-h|--help|*)
	    printf "\nUSAGE: make_snp_project.sh -s --samp_name sample_name\n"
	    printf "\nOptions: \t[default]"
	    printf "\n-w --samp_dir \t[current directory] \t\t\tsample FASTQ directory"
	    printf "\n-r --ref_assembly \t\t\t\t\treference assembly name"
	    printf "\n-d --ref_dir \t[~/osphl/validation/references] \treference directory"
	    printf "\n-t --target \t[current directory/sample name] \ttarget project directory, if different from sample name\n"
	    printf "\nNote: If more than one assembly matches the reference assembly name"
	    printf "\ngiven, they will all be added to the project, but only the last name"
	    printf "\nwill be used as the reference, unless you change the symlink in"
	    printf "\nthe project's 'reference' directory.\n\n"
	    exit;;
	*)

	;;
    esac
    shift
done


# Construct file paths
SAMPDIR=$(readlink -f "$SAMPDIR")
REFDIR=$(readlink -f "$REFDIR")

if [ -z "$TARGET" ]; then
    TARGET=$(readlink -f "$NAME")
else
    TARGET=$(readlink -f "$TARGET")
fi


# Create lyve-SET project
set_manage.pl "$TARGET" --create


# Add sample FASTQ reads to project
if [ ! -d "$SAMPDIR"/"$NAME" ]; then
    printf "\nWarning: the sample was not found in the sample directory."
    printf "\nNo FASTQ read files will be added to the sample project.\n"
else
    COUNT=0
#    for f in $(ls "$SAMPDIR"/"$NAME"/clean/*.fastq* | egrep "VS[0-9]{2}-[0-9]-.+"); do
   for f in $(ls "$SAMPDIR"/"$NAME"/clean/*.fastq*); do
	set_manage.pl "$TARGET" --add-reads "$f"
	let COUNT=COUNT+1
    done
    printf "\n%d FASTQ files added to project %s\n\n" $COUNT "$TARGET"
fi


# Add reference assembly to project, if provided
if [ -z "$REF" ]; then
    printf "\nWarning: No reference assembly name provided, so no assembly has been added to the project.\n"
else
    ASS=$(ls "$REFDIR" | grep "$REF")
    if [ -z "$ASS" ]; then
	printf "\nWarning: No match was found in %s for reference assembly %s." "$REFDIR" "$REF"
	printf "\nNo references have been added to the project."
    else
	COUNT=0
	for a in $ASS; do
	    set_manage.pl "$TARGET" --change-reference "$REFDIR"/$a
	    LAST=$a
	    let COUNT=COUNT+1
	done
	printf "\n%d reference assemblies have been added to project %s." $COUNT "$TARGET"
	printf "\nReference '%s' will be used by lyve-SET by default." "$LAST"
	printf "\nIf you want to use a different reference, change the symlink found"
	printf "\nin "$TARGET"/reference/\n\n"
    fi
fi
