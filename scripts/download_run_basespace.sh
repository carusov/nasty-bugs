#!/bin/bash

### Author: Vincent Caruso
### Date written: 4/30/18
### Last modified: 4/30/18
### Purpose: This script downloads FASTQ data files for all samples from a
### user-specified MiSeq run.

# Define default parameters
TARGET=$PWD
BASESPACE=~/osphl/basespace

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-r|--run)
	    RUN="$2"
	    shift;;
	-t|--target)
	    TARGET="$2"
	    shift;;
	-b|--basespace)
	    BASESPACE="$2"
	    shift;;
	-h|--help|*)
	    printf "\nUSAGE: download_run_basespace.sh -r --run run_ID [options]"
	    printf "\nOptions \t[default]"
	    printf "\n-t --target \t[./run_ID] \t\t\t\ttarget directory"
	    printf "\n-b --basespace \t["$BASESPACE"] \tbasespace mount point"
	    printf "\n\n"
	    exit;;
	*)
	;;

    esac
    shift
done


# Check to see if basespace is mounted
if [ ! "$(ls -A $BASESPACE)" ]
then
    basemount -c routine "$BASESPACE"
fi

# Make sure the specified run exists
if [ ! -d "$BASESPACE"/Runs/"$RUN" ]
then
    printf "\nERROR: The specified run does not exist. Please double-check the"
    printf "\nrun ID and try again."
    printf "\nSpecified run ID: %s" "$RUN"
    printf "\n\n"
    exit 1
fi

# Check to see if target directory exists
if [ ! -d "$TARGET" ]
then
    mkdir -p "$TARGET"
fi

TARGET=$(readlink -f "$TARGET")

# Print parameter configuration message
printf "\nRUN ID: %s" "$RUN"
printf "\nTARGET DIRECTORY: %s" "$TARGET"
printf "\nBASESPACE MOUNT POINT: %s" "$BASESPACE"
printf "\n\n"

# Extract run project and sample ID info
get_run_info.awk "$BASESPACE"/Runs/"$RUN"/Files/SampleSheet.csv \
		 > "$TARGET"/sample_IDs.txt

# Download the sample FASTQ files
cat "$TARGET"/sample_IDs.txt | while read -r p s
do
    if [ ! -d "$TARGET"/"$s" ]
    then
	mkdir "$TARGET"/"$s"
    fi
    
    download_sample_basespace.sh  -p "$p" \
				  -n "$s" \
				  -t "$TARGET"/"$s" \
				  -b "$BASESPACE" \
				  -m exact \
				  -r "$RUN"

done

printf "\n\n"
