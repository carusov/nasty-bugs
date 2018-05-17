#!/bin/bash

### Author: Vincent Caruso
### Date: 11/16/2017
### This script copies from the basespace mount point all FASTQ
### files in the specified project whose names match string
### patterns in a user-supplied input file. The user may also
### specify the target directory (default is current directory).


# Define default target directory
TARGET=$PWD

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-i|--in_file)
	    INFILE="$2"
	    shift;;
	-b|--basespace)
	    BS="$2"
	    shift;;
	-p|--project)
	    PROJECT="$2"
	    shift;;
	-t|--target)
	    TARGET="$2"
	    shift;;
	-h|--help|*)
	    printf "\nUSAGE: get_all_samples.sh -i sample_list_file\n"
	    printf "\nOptions: \t[default]"
	    printf "\n-p --project \t[Validation] \t\tproject name"
	    printf "\n-b --basespace \t[~/osphl/basespace/] \tbasespace mount point"
	    printf "\n-t --target \t[current directory] \ttarget directory \n\n"
	    exit;;
	*)

	;;
    esac
    shift
done

if [ -z "$INFILE" ]
then
    printf "\nError: You must specify an input file with the '-i' option\\n"
    exit
fi

INFILE=$(readlink -f "$INFILE")
TARGET=$(readlink -f "$TARGET")


# if no project or mount point specified, use the defaults in 'copy_from_basespace.sh'.
# Otherwise, use the specified project or mount point, or both
if [ -z "$PROJECT" ] && [ -z "$BS" ]; then
    while read -r sample
    do
	copy_from_basespace.sh -n "$sample" -t "$TARGET"
    done < "$INFILE"

elif [ -z "$PROJECT" ]; then
    while read -r sample
    do
	copy_from_basespace.sh -n "$sample" -b "$BS" -t "$TARGET"
    done < "$INFILE"

elif [ -z "$BS" ]; then
    while read -r sample
    do
	copy_from_basespace.sh -n "$sample" -p "$PROJECT" -t "$TARGET"
    done < "$INFILE"

else
    while read -r sample
    do
	copy_from_basespace.sh -n "$sample" -b "$BS" -p "$PROJECT" -t "$TARGET"
    done < "$INFILE"
fi

	      
