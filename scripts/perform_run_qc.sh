#!/bin/bash

### Author: Vincent Caruso
### Date Written: June 6, 2018
### Date Modified: June 6, 2018
### Purpose: This script measures basic QC metrics for each sample in a
### specified run, and generates a simple QC report. The script is intended to
### perform the same or similar QC checks that PulseNet performs when they
### receive isolate sequence data, in order to catch samples that would not
### pass PulseNet's QC and flag them for re-sequencing before they are
### submitted to PulseNet. 

# Define default parameters and constants
HEADER="Sample\tAvg read length\tTotal bases\tMin read length\tMax read length\tAvg quality\tNumber of reads\tPaired end?\tCoverage\tRead score\tMedian fragment length\tPass/Fail\tReason for failure\n"

MODE=fast

ECOLI_LEN=5000000
SAL_LEN=5000000
CAMPY_LEN=1600000
LIST_LEN=3000000
CPU=1


# Parse command-line options
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
	-n|--num_cpus)
	    CPU="$2"
	    shift;;
	--fast)
	    MODE=fast
	    ;;
	--full)
	    MODE=full
	    ;;
	-h|--help|*)
	    printf "\nUSAGE: perform_run_qc.sh -r run_ID [options]\n"
	    printf "\nOptions: \tdefault"
	    printf "\n-t --target \t[./run_ID] \toutput directory"
	    printf "\n-n --num_cpus \t[8] \t\tnumber of cpus"
	    printf "\n--fast \t\t[default] \testimate stats using 1%% of reads"
	    printf "\n--full \t\t\t\tcompute stats using all reads\n\n"
	    exit;;
	*)
	;;
    esac
    shift
done


# Check for run name parameter
if [ -z "$RUN" ]
then
    printf "\nERROR: You must provide a run name. Type 'perform_run_qc.sh -h'"
    printf "\nfor help on script usage.\n\n"
    exit 1
fi

# Create output directory name if not provided
if [ -z "$TARGET" ]
then
    TARGET="$RUN"
fi

TARGET=$(readlink -f "$TARGET")

# Print parameter configuration
printf "\nRUN NAME: %s" "$RUN"
printf "\nOUTPUT DIRECTORY: %s" "$TARGET"
printf "\nNUMBER OF CPUS REQUESTED: %d" $CPU
printf "\nMODE: %s\n\n" "$MODE"


# Create output directory if it doesn't exist
if [ ! -d "$TARGET" ]
then
    mkdir -p "$TARGET"
fi

# Download the run first (if necessary)
printf "Downloading samples...\n"
download_run_basespace.sh -r "$RUN" \
			  -t "$TARGET"

# Assemble read pair files into a single interleaved file
if [ ! -d "$TARGET"/interleaved ]
then
    mkdir "$TARGET"/interleaved
fi

# Clean up temporary files from any previously interrupted processing
rm -f "$TARGET"/interleaved/temp.fastq

if [ ! -z "$(ls "$TARGET" | grep ".*_R1.*\.fastq\.gz")" ]
then

    printf "Interleaving paired-end FASTQ files...\n"
    for f in $(ls "$TARGET"/*_R1*.fastq.gz)
    do
	bn=$(basename $f)
	pre=${bn%_R1*}
	suf=${bn#*_R1}

	if [ ! -f "$TARGET"/interleaved/$pre".fastq" ]
	then

	    run_assembly_shuffleReads.pl "$TARGET"/$pre"_R1"$suf \
					 "$TARGET"/$pre"_R2"$suf \
					 > temp.fastq
	    mv temp.fastq "$TARGET"/interleaved/$pre".fastq"

	fi
	
	    echo $pre "shuffled"
	    #	pigz "$TARGET"/$pre".fastq"
	    #	echo $pre " compressed"

    done
fi

echo

# Check to see if QC has already been done
if [ -f "$TARGET"/"$RUN"_qc.tsv ]
then

    printf "It appears that QC has already been performed.\n"
    printf "(A file named %s already exists).\n" "$RUN"_qc.tsv
    printf "Do you still want to perform QC? (y/n)\n"
    read -s -n 1 reply

    while [[ ! $reply =~ [yYnN]{1} ]]
    do
	printf "That is an invalid choice. Please enter 'y' or 'n'.\n"
	read -s -n 1 reply
    done

    if [[ $reply =~ [nN]{1} ]]
    then
	exit
    fi
fi


# Initialize output file header
printf "$HEADER" > "$TARGET"/"$RUN"_qc.tsv
printf "\nPerforming run QC...\n\n"

if [ "$MODE" = "fast" ]
then
    params=(--numcpus $CPU --fast)
else
    params=(--numcpus $CPU)
fi

# Run the CG Pipeline read metrics script
if [ ! -z "$(ls "$TARGET" | grep "PNUSAC.*\.fastq\.gz")" ]
then
    run_assembly_readMetrics.pl "$TARGET"/interleaved/PNUSAC*.fastq \
				-e $CAMPY_LEN \
				${params[@]} \
	| get_read_metrics.awk -v cov=20 \
	      >> "$TARGET"/"$RUN"_qc.tsv
    echo "Finished processing Campylobacter samples."
else
    echo "No Campylobacter samples found."
fi

if [ ! -z "$(ls "$TARGET" | grep "PNUSAE.*\.fastq\.gz")" ]
then
    run_assembly_readMetrics.pl "$TARGET"/interleaved/PNUSAE*.fastq \
				-e $ECOLI_LEN \
				${params[@]} \
	| get_read_metrics.awk -v cov=40 \
	      >> "$TARGET"/"$RUN"_qc.tsv
    echo "Finished processing E. coli samples."
else
    echo "No E. coli samples found."
fi

if [ ! -z "$(ls "$TARGET" | grep "PNUSAL.*\.fastq\.gz")" ]
then
    run_assembly_readMetrics.pl "$TARGET"/interleaved/PNUSAL*.fastq \
				-e $LIST_LEN \
				${params[@]} \
	| get_read_metrics.awk -v cov=20 \
	      >> "$TARGET"/"$RUN"_qc.tsv
    echo "Finished processing Listeria samples."
else
    echo "No Listeria samples found."
fi

if [ ! -z "$(ls "$TARGET" | grep "PNUSAS.*\.fastq\.gz")" ]
then
    run_assembly_readMetrics.pl "$TARGET"/interleaved/PNUSAS*.fastq \
				-e $SAL_LEN \
				${params[@]} \
	| get_read_metrics.awk -v cov=30 \
	      >> "$TARGET"/"$RUN"_qc.tsv
    echo "Finished processing Salmonella samples."
else
    "No Salmonella samples found."
fi

echo
