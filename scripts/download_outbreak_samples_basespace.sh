#!/bin/bash

### Author: Mark Klick
### Date written: 8/10/18
### Last modified: 8/10/18
### Purpose: This script downloads FASTQ data files for all samples from in a list
### called sample_IDs.txt

# Define default parameters
BASESPACE=~/basespace

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
		-s|--sampleIDs)
			SAMPLE_IDS="$2"
			shift;;
		-t|--target)
			TARGET="$2"
			shift;;
		-b|--basespace)
			BASESPACE="$2"
			shift;;
		-h|--help)
			printf "\nUSAGE: download_outbreak_samples_basespace.sh -s --sampleIDs sample_IDs.txt [options]\n"
			printf "\nOptions \t[default]"
			printf "\n-t --target \t\t\t\ttarget directory"
			printf "\n-b --basespace \t["$BASESPACE"] \tbasespace mount point"
			printf "\n\n"
			exit;;
		*)
			printf "\nERROR: Invalid script usage. Here is the proper usage for this script:\n"
			download_outbreak_samples_basespace.sh -h
			exit 1;;

	esac
	shift
done


# Check to see if basespace is mounted
if [ ! "$(ls -A $BASESPACE)" ]
then
    basemount -c routine "$BASESPACE"
fi

# Create the default target directory name if necessary
if [ -z "$TARGET" ]
then
    TARGET=$PWD/
fi

# Check to see if target directory exists, and create it if needed
if [ ! -d "$TARGET" ]
then
    mkdir -p "$TARGET"
fi

TARGET=$(readlink -f "$TARGET")

# Download the sample FASTQ files
cat "$TARGET"/"$SAMPLE_IDS" | while read -r line
do
    echo "id read from file - $line"
    download_sample_basespace.sh  -n "$line" -b "$BASESPACE" -t "$TARGET"

done
