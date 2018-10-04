#!/bin/bash

### Author: Mark Klick
### Date written: 10/3/18
### Purpose: This script takes a list of PNUSAS****** ids that are
### stored on each line of a text file. [sampleIDs.txt].

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
                -s|--sampleIDs)
                        SAMPLE_IDS="$2"
                        shift;;
		-p|--parse)
			PARSE="$2"
			shift;;
                -t|--target)
                        TARGET="$2"
                        shift;;
                -h|--help)
                        printf "\nUSAGE: run_seqSero_batch -s [sampleIDs.txt]\n"
                        exit;;
                *)
                        printf "\nERROR: Invalid script usage\n"
                        run_seqSero_batch.sh -h
			exit 1;;

    esac
    shift
done

# Make sure the target directory exists
# Create the default target directory name if necessary
if [ -z "$TARGET" ]
then
    TARGET=$PWD
else
    echo "\nusing the specified $TARGET directory\n"
fi

TARGET=$(readlink -f "$TARGET")

# check our parse flag to see if the SAMPLE_IDs.txt file needs to be parsed
if [ -z "$PARSE" ]
then
        grep PNUSAS.* "$TARGET"/"$SAMPLE_IDS" | cat | while read -r line line2
        do
                echo "$line2" >> "$TARGET"/seqSero_sample_IDs.txt
        done
        SAMPLE_IDS="seqSero_sample_IDs.txt"
else
        echo "using the specified $SAMPLE_IDs file"
fi

outfile=BATCH_seqSero_results.txt

# execute our run_seqSero.sh script on each PNUSAS****** in our SAMPLE_IDs.txt
cat "$TARGET"/"$SAMPLE_IDS" | while read -r line
do
    echo "\nPERFORMING SEQSERO\nid read from file - $line"
    run_seqSero.sh -s "$line"
    cat "$TARGET"/"$line"/SeqSero_result_*/Seqsero_result.txt >> "$TARGET"/"$outfile"

done

python3 ~/nasty-bugs/scripts/SeqSero/get_seqsero_serotypes_mod.py "$SAMPLE_IDS"
