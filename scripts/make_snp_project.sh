#!/bin/bash

### Author: Vincent Caruso
### Date: 11/16/2017
### This script creates a new lyve-SET project with the given sample name and populates
### it with the filtered (trimmed and cleaned)) FASTQ files from the isolates of that
### sample. If provided with a reference name, it will also search a directory of
### reference genome assemblies, and if a match is found, this reference will also be
### added to the project.

# Define default variables values
REFDIR=~/references
WDIR=$PWD

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-s|--sname)
	    NAME="$2"
	    shift;;
	-w|--work_dir)
	    WDIR="$2"
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
	    printf "\nUSAGE: make_snp_project.sh -s --sname sample_name\n"
	    printf "\nOptions: \t[default]"
	    printf "\n-w --work_dir \t[current directory] \t\tworking directory of samples"
	    printf "\n-r --ref_assembly \t\t\t\treference assembly name"
	    printf "\n-d --ref_dir \t[~/osphl/validation/references] reference directory"
	    printf "\n-t --target \t[current directory/sample name] target project directory\n"
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
WDIR=$(readlink -f "$WDIR")
REFDIR=$(readlink -f "$REFDIR")

if [ -z "$TARGET" ]; then
    TARGET=$(readlink -f "$NAME")
else
    TARGET=$(readlink -f "$TARGET")
fi


# Create lyve-SET project
set_manage.pl "$TARGET" --create


# Check to see if specified sample file(s) exist
files=$(ls "$WDIR" | grep "$NAME")
if [ -z "$files" ]; then
    printf "\nWarning: the sample was not found in the working directory."
    printf "\nNo FASTQ read files will be added to the sample project.\n"
else
    # Add sample FASTQ reads to project
    for f in $files
    do
	set_manage.pl "$TARGET" --add-reads "$WDIR"/$f
    done
    COUNT=$(ls "$TARGET"/reads | wc -l)
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
