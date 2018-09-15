#!/bin/bash

### Author: Vincent Caruso & Mark Klick
### Date Written: June 6, 2018
### Date Modified: September 2018
### Purpose: This script measures basic QC metrics for each sample in a
### specified run, and generates a simple QC report. The script is intended to
### perform the same or similar QC checks that PulseNet performs when they
### receive isolate sequence data, in order to catch samples that would not
### pass PulseNet's QC and flag them for re-sequencing before they are
### submitted to PulseNet. 

# Define default parameters and constants
HEADER="Sample name,Avg read length,Total bases,Min read length,Max read length,Avg quality,Number of reads,Paired end?,Coverage,Read score,Median fragment length,Pass/Fail,Reason for failure\n"

MODE=fast

ECOLI_LEN=5000000
SAL_LEN=5000000
CAMPY_LEN=1600000
LIST_LEN=3000000
VIB_LEN=5000000

ECOLI_COV=40
SAL_COV=30
CAMPY_COV=20
LIST_COV=20
VIB_COV=40

CPU=8


# Parse command-line options
while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
		-t)
			TARGET="$2"
			shift;;
		-r)
			RUN="$2"
			shift;;
		-I)
			INTER="$2"
			shift;;
		-h)
			printf "\nUSAGE: perform_run_qc.sh -r run_ID\n"
			printf "\nOptions: \tdefault"
			printf "\n--num_cpus \t[8] \t\tnumber of CPUs"
			printf "\n--fast \t\t[default] \testimate stats using 1% of reads"
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

if [ -z "$INTER" ]; then
	echo "performing QC on R1 and R2 separately"
else
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
		# pigz "$TARGET"/$pre".fastq"
		# echo $pre " compressed"
    		done
	fi
fi

# Check to see if QC has already been done
if [ -z "$INTER" ]; then
        outfile="$RUN"_QC.csv
    else
        outfile="$RUN"_interleaved_QC.csv
fi

if [ -f "$TARGET"/"$outfile" ]
then

    printf "It appears that QC has already been performed.\n"
    printf "(A file named %s already exists).\n" "$outfile"
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
printf "$HEADER" > "$TARGET"/"$outfile"
printf "\nPerforming run QC...\n\n"

if [ "$MODE" = "fast" ]
then
    params=(--numcpus $CPU --fast)
else
    params=(--numcpus $CPU)
fi

if [ -z "$INTER" ]; then
	echo "RUNNING QC ON R1 and R2 SEPARATELY"

	# Run the CG Pipeline read metrics script
	if [ ! -z "$(ls "$TARGET" | grep "PNUSAC.*\.fastq\.gz")" ]
	then
    		run_assembly_readMetrics.pl "$TARGET"/PNUSAC*.fastq.gz \
				-e $CAMPY_LEN \
				${params[@]} \
			| get_read_metrics_R1R2.awk -v cov=$CAMPY_COV \
	      		>> "$TARGET"/"$outfile"
    		echo "Finished processing Campylobacter samples."
	else
    		echo "No Campylobacter samples found."
	fi

	if [ ! -z "$(ls "$TARGET" | grep "PNUSAE.*\.fastq\.gz")" ]
	then
    		run_assembly_readMetrics.pl "$TARGET"/PNUSAE*.fastq.gz \
				-e $ECOLI_LEN \
				${params[@]} \
			| get_read_metrics_R1R2.awk -v cov=$ECOLI_COV \
	      		>> "$TARGET"/"$outfile"
    		echo "Finished processing E. coli samples."
	else
    		echo "No E. coli samples found."
	fi

	if [ ! -z "$(ls "$TARGET" | grep "PNUSAL.*\.fastq\.gz")" ]
	then
    		run_assembly_readMetrics.pl "$TARGET"/PNUSAL*.fastq.gz \
				-e $LIST_LEN \
				${params[@]} \
			| get_read_metrics_R1R2.awk -v cov=$LIST_COV \
	      		>> "$TARGET"/"$outfile"
    		echo "Finished processing Listeria samples."
	else
    		echo "No Listeria samples found."
	fi

	if [ ! -z "$(ls "$TARGET" | grep "PNUSAS.*\.fastq\.gz")" ]
	then
    		run_assembly_readMetrics.pl "$TARGET"/PNUSAS*.fastq.gz \
				-e $SAL_LEN \
				${params[@]} \
			| get_read_metrics_R1R2.awk -v cov=$SAL_COV \
	      		>> "$TARGET"/"$outfile"
    		echo "Finished processing Salmonella samples."
	else
    		echo "No Salmonella samples found."
	fi

	if [ ! -z "$(ls "$TARGET" | grep "PNUSAV.*\.fastq\.gz")" ]
	then
    		run_assembly_readMetrics.pl "$TARGET"/PNUSAV*.fastq.gz \
				-e $VIB_LEN \
				${params[@]} \
			| get_read_metrics_R1R2.awk -v cov=$VIB_COV \
	      		>> "$TARGET"/"$outfile"
    		echo "Finished processing Vibrio samples."
	else
    		echo "No Vibrio samples found."
	fi
else
	echo "RUNNING QC ON SHUFFLED/INTERLEAVED READS"
        # Run the CG Pipeline read metrics script
        if [ ! -z "$(ls "$TARGET" | grep "PNUSAC.*\.fastq\.gz")" ]
        then
                run_assembly_readMetrics.pl "$TARGET"/interleaved/PNUSAC*.fastq \
                                -e $CAMPY_LEN \
                                ${params[@]} \
                	| get_read_metrics.awk -v cov=$CAMPY_COV \
                	>> "$TARGET"/"$outfile"
                echo "Finished processing Campylobacter samples."
        else
                echo "No Campylobacter samples found."
        fi

        if [ ! -z "$(ls "$TARGET" | grep "PNUSAE.*\.fastq\.gz")" ]
        then
                run_assembly_readMetrics.pl "$TARGET"/interleaved/PNUSAE*.fastq \
                                -e $ECOLI_LEN \
                                ${params[@]} \
                	| get_read_metrics.awk -v cov=$ECOLI_COV \
                	>> "$TARGET"/"$outfile"
                echo "Finished processing E. coli samples."
        else
                echo "No E. coli samples found."
        fi

        if [ ! -z "$(ls "$TARGET" | grep "PNUSAL.*\.fastq\.gz")" ]
        then
                run_assembly_readMetrics.pl "$TARGET"/interleaved/PNUSAL*.fastq \
                                -e $LIST_LEN \
                                ${params[@]} \
                	| get_read_metrics.awk -v cov=$LIST_COV \
                	>> "$TARGET"/"$outfile"
                echo "Finished processing Listeria samples."
        else
                echo "No Listeria samples found."
        fi

        if [ ! -z "$(ls "$TARGET" | grep "PNUSAS.*\.fastq\.gz")" ]
        then
                run_assembly_readMetrics.pl "$TARGET"/interleaved/PNUSAS*.fastq \
                                -e $SAL_LEN \
                                ${params[@]} \
                	| get_read_metrics.awk -v cov=$SAL_COV \
                	>> "$TARGET"/"$outfile"
                echo "Finished processing Salmonella samples."
        else
                echo "No Salmonella samples found."
        fi

        if [ ! -z "$(ls "$TARGET" | grep "PNUSAV.*\.fastq\.gz")" ]
        then
                run_assembly_readMetrics.pl "$TARGET"/interleaved/PNUSAV*.fastq \
                                -e $VIB_LEN \
                                ${params[@]} \
                	| get_read_metrics.awk -v cov=$VIB_COV \
                	>> "$TARGET"/"$outfile"
                echo "Finished processing Vibrio samples."
        else
                echo "No Vibrio samples found."
        fi
fi

echo "DONE PERFORMING QC"
