#!/bin/bash

### Author: Vincent Caruso
### Date: 11/16/2017
### This script copies files that contain a given string from a user-specified
### project on Illumina's BaseSpace platform. In order to execute the script,
### the user must have the BaseSpace account mounted on the local machine via
### the BaseMount API.

# Define default variables values
BASESPACE=~/osphl/basespace
MODE=regex

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
	-m|--mode)
	    MODE="$2"
	    shift;;
	-r|--run)
	    RUN="$2"
	    shift;;
	-h|--help|*)
	    printf "\nUSAGE: copy_from_basespace.sh -n sample_name_pattern\n"
	    printf "\nOptions: \t[default]"
	    printf "\n-p --project \t[Validation] \t\tproject name"
	    printf "\n-t --target \t[current directory] \ttarget directory"
	    printf "\n-b --basespace \t[~/osphl/basespace/] \tbasespace mount point"
	    printf "\n-m --mode \t[regex] \tmatching mode"
	    printf "\n-r --run \t[] \trun name (only used for exact matching)"
	    printf "\n\n"
	    exit;;
	*)

	;;
    esac
    shift
done


BASESPACE=$(readlink -f "$BASESPACE")


# Check parameters
if [ -z "$PATTERN" ]
then
    printf "\nERROR: You must specify a sample name pattern.\n\n"
    exit 1;
elif [ -z "$PROJECT" ]
then
    printf "\nERROR: You must specify a project name.\n\n"
    exit 1;
elif [ "$MODE" == "exact" ] && [ -z "$RUN" ]
then
    printf "\nERROR: You must specify a run name when using exact matching mode.\n\n"
    exit 1;
elif [ "$MODE" == "regex" ] && [ ! -z "$RUN" ]
then
    printf "\nWARNING: The run name is ignored when using regex matching mode.\n\n"
elif [ "$MODE" != "exact" ] && [ "$MODE" != "regex" ]
then
    printf "\nERROR: The mode must be either 'regex' or 'exact'.\n\n"
    exit 1;
fi

# Check to see if basespace is mounted
if [ ! "$(ls -A $BASESPACE)" ]
then
    basemount -c routine "$BASESPACE"
fi

# Make sure the project exists
if [ ! -d "$BASESPACE"/Projects/"$PROJECT" ];
then
    printf "\nERROR: Project '${PROJECT}' does not exist. Double-check the name and try again.\n\n"
    exit 1;
else
    SDIR="$BASESPACE"/Projects/"$PROJECT"/Samples/
    SAMPLES=$(ls "$SDIR" | grep "$PATTERN")
fi


# Create the target directory if necessary
if [ ! -d "$TARGET" ]; then
    mkdir -p "$TARGET"
fi

TARGET=$(readlink -f "$TARGET")


echo "$SAMPLES" | while read -r s
do
    # Replace '_' with '-' in sample names to match MiSeq file naming
    s_file=${s//_/-}

    # Check to see if files already exist before copying/downloading
    if [ -f "$TARGET"/"$s_file"*R1*.gz ] && [ -f "$TARGET"/"$s_file"*R2*.gz ]
    then
	printf "Sample '%s' already exists locally\n" "$s"

    else
	next=$(ls "$SDIR"/"$s"/Files/ | grep _R1)

	if [[ ( $MODE == "regex" ) || ( $MODE == "exact"  &&  $next =~ "$RUN" ) ]]
	then
	    if [ ! -f "$TARGET"/"$s_file"*R1*.gz ]
	    then
		newname=${next//_S*001\./_R1\.}
		cp "$SDIR"/"$s"/Files/*R1*.gz "$TARGET"/temp_R1.gz
		mv "$TARGET"/temp_R1.gz "$TARGET"/"$newname"
	    fi
	    
	    if [ ! -f "$TARGET"/"$s_file"*R2*.gz ]
	    then
		newname=${next//_S*001\./_R2\.}
		cp "$SDIR"/"$s"/Files/*R2*.gz "$TARGET"/temp_R2.gz
		mv "$TARGET"/temp_R2.gz "$TARGET"/"$newname"

		s_file=($s_file)
		chmod 664 "$TARGET"/${s_file[0]}*.gz
		printf "Finished downloading sample %s\n" "$s"
	    fi
	fi
    fi
done
