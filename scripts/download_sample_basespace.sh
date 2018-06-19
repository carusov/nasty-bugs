#!/bin/bash

### Author: Vincent Caruso
### Date: 11/16/2017
### This script copies files that contain a given string from a user-specified
### project on Illumina's BaseSpace platform. In order to execute the script,
### the user must have the BaseSpace account mounted on the local machine via
### the BaseMount API.

# Define default variables values
BASESPACE=~/basespace
TARGET=$PWD
#MODE=regex


### SETUP ###
# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-n|--name_pattern)
	    PATTERN="$2"
	    shift;;
	-b|--basespace)
	    BASESPACE="$2"
	    shift;;
	-p|--project)
	    PROJECT="$2"
	    shift;;
	-t|--target_dir)
	    TARGET="$2"
	    shift;;
	-r|--run)
	    RUN="$2"
	    shift;;
	-h|--help)
	    printf "\nUSAGE: download_sample_basespace.sh -n sample_name_pattern\n"
	    printf "\nOptions: \t[default]"
	    printf "\n-p --project \t[guess from sample name pattern] \tproject name"
	    printf "\n-t --target \t[current directory] \t\t\ttarget directory"
	    printf "\n-b --basespace \t[~/basespace] \t\t\t\tbasespace mount point"
	    printf "\n-r --run \t[NONE] \t\t\trun name (only used for exact matching)"
	    printf "\n\n"
	    exit;;
	*)
	    printf "\nERROR: Invalid script usage. Here is the proper usage for this script:\n"
	    download_sample_basespace.sh -h
	    exit 1;;

    esac
    shift
done



BASESPACE=$(readlink -f "$BASESPACE")


# Check parameters
if [ -z "$PATTERN" ]
then
    
    printf "\nERROR: You must specify a sample name pattern.\n\n"
    exit 1;

fi
    
if [ -z "$PROJECT" ]
then
    
    # Try to guess the project from the sample name pattern
    if [[ "$PATTERN" =~ "PNUSAC" ]]
    then
	
	PROJECT="PRJNA239251"
	
    elif [[ "$PATTERN" =~ "PNUSAE" ]]
    then
	
	PROJECT="PRJNA218110"
	
    elif [[ "$PATTERN" =~ "PNUSAL" ]]
    then
	
	PROJECT="PRJNA212117"
	
    elif [[ "$PATTERN" =~ "PNUSAS" ]]
    then
	
	PROJECT="PRJNA230403"
	
    elif [[ "$PATTERN" =~ "PNUSAF" ]]
    then
	
	PROJECT="PRJNA266293"
	
    else
	
	printf "\nERROR: Could not guess the project from the sample name pattern.\n"
	printf "Please specify a project name and try again.\n\n"
	exit 1;
	
    fi
fi

if [ -z "$RUN" ]
then
    
    MODE=regex

else

    MODE=exact

fi


### MAIN SCRIPT ###

# Check to see if basespace is mounted
if [ ! "$(ls -A $BASESPACE)" ]
then
    
    basemount -c routine "$BASESPACE"
    
fi

# Make sure the project exists
if [ ! -d "$BASESPACE"/Projects/"$PROJECT" ];
then
    
    printf "\nERROR: Project ${PROJECT} does not exist. Double-check the project name and try again.\n\n"
    exit 1;
    
else
    
    SDIR="$BASESPACE"/Projects/"$PROJECT"/Samples/

fi


# Replace '_' with '-' to match MiSeq file names
pattern=${PATTERN//_/-}
samples=$(ls "$SDIR" | grep "$PATTERN")

# Check to see if any matching samples were found
if [ -z "$samples" ]
then
    
    printf "No matching samples were found. Nothing was downloaded.\n\n"
    exit 2
    
fi

# Create the target directory if necessary
if [ ! -d "$TARGET" ]
then
    
    mkdir -p "$TARGET"
    
fi

TARGET=$(readlink -f "$TARGET")

# Clean up any partially downloaded files from a previous interrupted session
rm -f "$TARGET"/temp_R*.gz


if [ "$MODE" = "regex" ]
then

    # Iterate over all samples matching PATTERN in reverse order (newest first)
    echo "$samples" | sort -r | while read -r s
    do
	
	name=$(ls "$SDIR"/"$s"/Files | grep "_R1")
	name=${name%%_*}
	
	# Check to see if sample already exists locally
	if [ -f "$TARGET"/"$name"*R1*.fastq.gz ] &&
	       [ -f "$TARGET"/"$name"*R2*.fastq.gz ]
	then
	    
	    printf "Sample %s already exists locally\n" "$s"
	    
	else
	    # Download any missing FASTQ files
	    if [ ! -f "$TARGET"/"$name"*R1*.gz ]
	    then
		
		newname=${name}_R1.fastq.gz
		cp "$SDIR"/"$s"/Files/*R1*.gz "$TARGET"/temp_R1.gz
		mv "$TARGET"/temp_R1.gz "$TARGET"/"$newname"
		chmod 664 "$TARGET"/"$newname"
		
	    fi
	    
	    if [ ! -f "$TARGET"/"$name"*R2*.gz ]
	    then
		
		newname=${name}_R2.fastq.gz
		cp "$SDIR"/"$s"/Files/*R2*.gz "$TARGET"/temp_R2.gz
		mv "$TARGET"/temp_R2.gz "$TARGET"/"$newname"
		chmod 664 "$TARGET"/"$newname"
		
	    fi

	    printf "Finished downloading sample %s\n" "$s"
	    
	fi
    done

elif [ "$MODE" = "exact" ]
then

    found=0

    # Check to see if sample already exists locally
    pattern=${PATTERN//_/-}
    if [ $(ls "$TARGET" | grep "$pattern".*"$RUN" | wc -l) -eq 2 ]
    then
	
	printf "Sample %s from run %s already exists locally\n" "$PATTERN" "$RUN"

    else
	# Iterate over samples in reverse order (newest to oldest)
	while read -r s
	do
	    
	    name=$(ls "$SDIR"/"$s"/Files | grep "_R1")
	    name=${name%%_*}
	    
	    if [[ $name =~ "$RUN" ]]
	    then
		found=1
		
		if [ ! -f "$TARGET"/"$name"*R1*.gz ]
		then
		    
		    newname=${name}_R1.fastq.gz
		    cp "$SDIR"/"$s"/Files/*R1*.gz "$TARGET"/temp_R1.gz
		    mv "$TARGET"/temp_R1.gz "$TARGET"/"$newname"
		    chmod 664 "$TARGET"/"$newname"
		    
		fi
		
		if [ ! -f "$TARGET"/"$name"*R2*.gz ]
		then
		    
		    newname=${name}_R2.fastq.gz
		    cp "$SDIR"/"$s"/Files/*R2*.gz "$TARGET"/temp_R2.gz
		    mv "$TARGET"/temp_R2.gz "$TARGET"/"$newname"
		    chmod 664 "$TARGET"/"$newname"
		    
		fi

		printf "Finished downloading sample %s\n" "$s"
		break

	    fi
	done <<< $(echo "$samples" | sort -r)

	if [ $found -ne 1 ]
	then
	    printf "No samples matching %s were found in run %s.\n" "$PATTERN" "$RUN"
	    printf "Nothing was downloaded.\n"
	fi
    fi

fi
