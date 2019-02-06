# nasty-bugs
Scripts for PHL pathogen genomic data

# Authors: Vincent Caruso and Mark Klick
# Dates for commit history: 
>>May 17th 2018 - June 28th 2018 (Vincent Caruso -- carusov)

>>August 17th 2018 - December 14th 2018 (Mark Klick -- markklick206)

# Purpose: 
This bioinformatic pipeline consists of several computational modules: Quality Control Pipeline, Computational Species Typing, Virulence/Antimicrobial Resistance Pipeline, and Isolate Relatedness Analysis Pipeline. Each module consists of multiple steps which utilize an array of state-of-the-art open source software tools. These open-source software tools are recommended, used, and considered the best-practices by a consensus of bioinformaticians within and outside of the public health domain

**QC PIPELINE**

CG-Pipeline https://github.com/lskatz/CG-Pipeline  
>Software tools  
>>run_assembly_shuffleReads.pl  
>>run_assembly_trimClean.pl  

Contamination Check  
>Software tools  
>>Kraken https://ccb.jhu.edu/software/kraken/ https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4053813/   

Read Metrics  
>Software tools  
>>run_assembly_readMetrics.pl  
>>>Cluster density  
>>>Q30  
>>>Average read length  
>>>Depth of sequencing coverage  

**Computational Species Typing Pipeline**  
Salmonella  
>Software tools  
>>MASH https://github.com/marbl/Mash/releases  
>>SeqSero https://github.com/denglab/SeqSero  

**Isolate Relatedness Analysis Pipeline**
Determine Reference Assembly  
>Software tools  
>>CLC BIO  
>>>Find Best Match reference sequence based on kmer spectra  
>>>>pulseNETplus reference sequence/assembly database  
>>MASH https://github.com/marbl/Mash/releases  

hqSNP Analysis  
>Software tools  
>>LyveSet 1.1.4f https://github.com/lskatz/lyve-SET  
>>>Phylogeny/dendrogram of how isolates cluster 
>>>Pairwise SNP Matrix 
>>FigTree 


LYVE-SET Overview:    
>>0: Read Cleaning       
https://github.com/lskatz/CG-Pipeline/blob/master/scripts/run_assembly_trimClean.pl  
>>1: Mapping Sequencing Reads to a Reference Genome  
https://www.sanger.ac.uk/science/tools/smalt-0   
>>2: Variant detection, i.e., detecting SNPs  
http://varscan.sourceforge.net/   
Koboldt DC, Chen K, Wylie T, Larson DE, McLellan MD, Mardis ER, Weinstock GM, Wilson RK, & Ding L (2009). VarScan: variant detection in massively parallel sequencing of individual and pooled samples. Bioinformatics (Oxford, England), 25 (17), 2283-5 PMID: 19542151  
>>3: Creating the Phylogenetic tree/ dendogram  
https://sco.h-its.org/exelixis/web/software/raxml/index.html   
A. Stamatakis: "RAxML Version 8: A tool for Phylogenetic Analysis and Post-Analysis of Large Phylogenies". In Bioinformatics, 2014, open access.    

OSPHL LYVE-SET Overview:  
Github https://github.com/carusov/nasty-bugs     
>>-1: Download Sequencing files  
https://github.com/carusov/nasty-bugs/tree/master/scripts/download%20scripts     
>>0: Read Cleaning and trimming  
https://github.com/carusov/nasty-bugs/blob/master/scripts/Filtering%20and%20decontamination/trim_and_clean.sh     
>>1: Running Lyve-SET!  
https://github.com/carusov/nasty-bugs/blob/master/scripts/SNP%20scripts/add_reads_lyveset.sh    


