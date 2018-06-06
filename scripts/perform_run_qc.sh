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

# Define default parameters
ECOLI_LEN=5000000
SAL_LEN=5000000
CAMPY_LEN=1600000
LIST_LEN=3000000


# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-r|--run)
	    RUN="$2"
	    shift;;
	-o|--outdir)
	    OUTDIR="$2"
	    shift;;
	-n|--num_cpus)
	    CPU="$2"
	    shift;;
	-h|--help|*)
	    printf "\nUSAGE: perform_run_qc.sh -r run_ID [options]\n"
	    printf "\nOptions: \t\tdefault"
	    printf "\n-o --outdir \t[current directory] \toutput directory"
	    printf "\n-n --num_cpus \t[8] \tnumber of cpus\n\n"
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

OUTDIR=$(readlink -f "$OUTDIR")

# Download the run first (if necessary)
download_run_basespace.sh -r "$RUN" \
			  -t "$OUTDIR"

# Run the CG Pipeline read metrics script
run_assembly_readMetrics.pl
