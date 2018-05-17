# Author: Vincent Caruso
# Date written: February 5, 2018
# Last modified: February 5, 2018
# Purpose: This script is written to facilitate the Limit of Detection analysis
# for the MiSeq validation study. It takes as input a directory of sample
# directories (each sample directory containing one or more pairs of .fastq
# files for one or more sequencing replicates), a genome size for the samples,
# and a set of values that define a sequence of coverages. It then computes,
# for each coverage level in the sequence, the number of sequences required
# for each isolate (using actual sequence lengths estimated from the .fastq
# files) to meet the requested coverage, and then downsamples the .fastq files
# and stores the result under the user specified output directory. If no input
# and/or output directory are given, the current directory is assumed for
# both/either.

# Define defaults
INDIR="$PWD"
PREFIX=VS
OUTDIR="$PWD"

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
	-i|--input_dir)
	    INDIR="$2"
	    shift;;
	-p|--prefix)
	    PREFIX="$2"
	    shift;;
	-t|--top_cov)
	    HIGH_COV="$2"
	    shift;;
	-l|--low_cov)
	    LOW_COV="$2"
	    shift;;
	-s|--step)
	    STEP="$2"
	    shift;;
	-g|--genome)
	    GENOME="$2"
	    shift;;
	-o|--output_dir)
	    OUTDIR="$2"
	    shift;;
	-h|--help|*)
	    printf "\nUSAGE: downsample_seqs.sh -t/--top_cov top_coverage -l/--low_cov low_coverage"
	    printf "\n\t\t\t-s/--step step_size -g/--genome genome_size [options]\n"
	    printf "\nOptions: \t\t[default]"
	    printf "\n-i --input_dir \t\t[current directory] \tinput directory of sample directories"
	    printf "\n-p --prefix \t\t[ VS ] \t\t\tsample name prefix"
	    printf "\n-o --output_dir \t[current directory] \toutput directory\n\n"
	    exit;;
	*)

	;;
    esac
    shift
done

# Check input directory
if [ ! -d "$INDIR" ];then
    echo "ERROR: The specified input directory does not exist, haha!"
    exit 1
fi

if [ ! -d "$OUTDIR" ];then
    mkdir -p "$OUTDIR"
fi

OUTDIR=$(readlink -f "$OUTDIR")

# Check sequence parameters
posint='^[0-9]+$'
if ! [[ $HIGH_COV =~ $posint ]]; then
    echo "ERROR: Top coverage value is not a valid positive integer."
    exit 2
elif ! [[ $LOW_COV =~ $posint ]]; then
    echo "ERROR: Low coverage value is not a valid positive integer."
    exit 2
elif ! [[ $STEP =~ $posint ]]; then
    echo "ERROR: Step value is not a valid positive integer."
    exit 2
elif [[ $HIGH_COV -lt $LOW_COV ]]; then
    echo "ERROR: Top coverage value must be greater than or equal to low coverage value. Duh."
    exit 2
elif ! [[ $GENOME =~ $posint ]]; then
    echo "ERROR: Genome size is not a valid positive integer."
    exit 2
fi

pushd "$INDIR"

# Execute downsampling
for sam in $(ls -d "$PREFIX"*);
do
    pushd "$sam"

    for rep in $(ls *R1*.fastq.gz);
    do
	prefix=${rep%_R1*}
	suffix=${rep#$prefix"_R1"}
	sname=${prefix%_S*_L*}
	gzip -kdf $sname*".gz"
	suffix=${suffix%.gz}
	r1=$prefix"_R1"$suffix
	r2=$prefix"_R2"$suffix
	i1=$sname"_R1_info.txt"
	i2=$sname"_R2_info.txt"

	usearch -fastx_info $r1 -output $i1
	usearch -fastx_info $r2 -output $i2

	for ((cov=$LOW_COV;cov<=$HIGH_COV;cov+=$STEP));
	do
	    if [ ! -d "$OUTDIR"/$cov"x" ]; then
		mkdir "$OUTDIR"/$cov"x"
	    fi

	    samdir="$OUTDIR"/$cov"x"/"$sam"
	    
	    if [ ! -d "$samdir" ]; then
		mkdir "$samdir"
	    fi
	    
	    seqs=$(get_coverage_seqs.py $i1 $i2 $GENOME $cov)
	    echo $cov"x seqs: " $seqs

	    usearch -fastx_subsample $r1 \
		    -reverse $r2 \
		    -sample_size $seqs \
		    -fastqout "$samdir"/$sname"_"$cov"x_R1.fastq" \
		    -output2 "$samdir"/$sname"_"$cov"x_R2.fastq"

	    echo
	    echo "Done with coverage "$cov
	    echo
	done

	rm $r1 $r2 $i1 $i2
	
	echo
	echo "Done with replicate "$sname
	echo
    done

    popd
    echo
    echo "Done with sample "$sam
    echo
done

popd
