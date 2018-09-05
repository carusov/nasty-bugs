#!/bin/bash

### Author: Vincent Caruso
### Date written: 12/14/17
### Purpose: This script calls the launch_set.pl script in lyve-SET 1.1.4f.
### It is intended simply to be a record of the analysis that was done for
### the "Assay Accuracy" portion of the MiSeq validation project. This analysis
### calls hqSNPs for a set of four validation sequences, along with three
### clinical isolates included to make a more realistic tree size, and then
### uses the hqSNP calls to create a phylogenetic tree of the sequences. This
### tree is compared to another tree created from the published reference
### assembly sequences corresponding to the four validation sequences, along
### with the three clinical isolates, to verify that tree placement is the
### same for both validation and reference sequences.

# Set default working directory
WDIR=~/osphl/validation/assay_accuracy

# Call the launch_set.pl script
#launch_set.pl "$WDIR"/e_coli \
#	      --allowedFlanking 0 \
#	      --min_alt_frac 0.75 \
#	      --min_coverage 10 \
#	      --numcpus 4

launch_set.pl "$WDIR"/e_coli_ref \
	      --allowedFlanking 0 \
	      --min_alt_frac 0.75 \
	      --min_coverage 10 \
	      --numcpus 4

#launch_set.pl "$WDIR"/s_enterica \
#	      --allowedFlanking 0 \
#	      --min_alt_frac 0.75 \
#	      --min_coverage 10 \
#	      --numcpus 4

launch_set.pl "$WDIR"/s_enterica_ref \
	      --allowedFlanking 0 \
	      --min_alt_frac 0.75 \
	      --min_coverage 10 \
	      --numcpus 4
