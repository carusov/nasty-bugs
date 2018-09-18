#!/bin/bash

### Author: Mark Klick
### Purpose: Modularize Kraken step. This script executes Kraken
### on a specified shuffled/interleaved .fastq.gz file, resulting in,
### a percentage contamination value for known species sequences
### found by Kraken to be present in the .fastq.gz sequencing file
### Resources: Logan Fink type_type_1.1.sh

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -i)
            INDIR="$2"
            shift;;
	-t) TARGET="$2"
	    shift;;
        -h|--help)
            printf "\nUSAGE: run_Kraken.sh -i [input dir] \n"
            exit;;
        *)
            printf "\nERROR: Invalid script usage.\n"
            run_seqSero.sh -h
            exit 1;;
    esac
    shift
done

# Make sure input directory exists
if [ ! -d "$INDIR" ]
then
    echo "directory doesn't exist"
    exit
else
    INDIR=$(readlink -f "$INDIR")
fi

# make kraken_output directory
if [ ! -d "$TARGET" ]
then
    TARGET=$PWD
    TARGET=$(readlink -f "$TARGET")
    mkdir -p "$TARGET"/kraken_output
else
    TARGET=$(readlink -f "$TARGET")
    mkdir -p "$TARGET"/kraken_output
fi

# iterate through .fastq.gz files in input directory and release (mini)Kraken
files=$(ls "$INDIR"/*.fastq.gz)
for f in $files
do
	b=$(basename $f)
	pre=${b%.cleaned*}
	echo "running (mini)Kraken on isolate $pre"
	mkdir -p ./kraken_output/$b/

	#printf "$f \n $b \n $pre"

	kraken --preload --db ~/databases/minikraken_20171019_8GB/ \
        	--gzip-compressed --fastq-input $f > \
		./kraken_output/$b/kraken.output

	kraken-report --db ~/databases/minikraken_20171019_8GB/ \
		--show-zeros ./kraken_output/$b/kraken.output > \
		./kraken_output/$b/kraken.results

	awk '$4 == "S" {print $0}' ./kraken_output/$b/kraken.results \
		| sort -s -r -n -k 1,1 > ./kraken_output/$b/kraken_species.results
	echo $b >> ./kraken_output/$b/top_kraken_species_results
	head -10 ./kraken_output/$b/kraken_species.results >> \
		./kraken_output/$b/top_kraken_species_results
done

