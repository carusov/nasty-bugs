#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Author: Vincent Caruso
Date Written: February 1, 2018
Date Last Modified: February 1, 2018
Purpose: This script reads in a series of result files from a SeqSero analysis
and extracts the seroptype formulas and names. These values are then written to
a tab-delimited file.
Usage: python3 get_seqsero_serotypes.py [sample_directory_path] [output_file_path]
"""

import sys, os, re, csv

# get the sample directory
if len(sys.argv) > 1:
    sample_path = os.path.expanduser(sys.argv[1])
    sample_path = os.path.abspath(sample_path)
    
    if not(os.path.isdir(sample_path)):
        raise ValueError("Sorry, that's not a valid sample directory!")
        
else:
    sample_path = os.getcwd()
    
# get the output file name
if len(sys.argv) > 2:
    out_file = os.path.expanduser(sys.argv[2])
    out_file = os.path.abspath(out_file)
    
    if not(os.path.isdir(os.path.dirname(out_file))):
        os.mkdir(os.path.dirname(out_file))
        
else:
    out_file = os.path.join(os.getcwd(), 'seqsero_serotypes.tsv')
    
    
# get the sample names
samples = os.listdir(sample_path)
samples = [s for s in samples if re.match("^VS\d{2}", s)]
samples.sort()

field_dict = {'Input files': 'Isolate',
              'O antigen prediction': 'O antigen',
              'H1 antigen prediction(fliC)': 'H1 antigen',
              'H2 antigen prediction(fljB)': 'H2 antigen',
              'Predicted antigenic profile': 'Profile',
              'Predicted serotype(s)': 'Serotype',
              'Sdf prediction': 'Sdf'}


# find and process results files for each sample
with open(out_file, 'w') as of:
    res_list = []
    for s in samples:
        result_path = os.path.join(sample_path, s)
        results = os.listdir(result_path)
        pattern = r".*_seqsero_result\.txt$"
        results = [r for r in results if re.match(pattern, r)]
        
        for r in results:
            with open(os.path.join(result_path, r), 'r') as rf:
                values = rf.readlines()
                values = [ [e.strip() for e in v.split(':', 1)] for v in values]
                values = {field_dict[v[0]]: v[1] for v in values if v[0] in field_dict}
                # extract isolate name from file name
                values['Isolate'] = values['Isolate'].split()[0].split('_')[0]
                # collapse multiple serotype predictions into comma-separated values
                values['Serotype'] = ','.join(values['Serotype'].rstrip('*').split(' or '))
                res_list.append(values)
    
    header = ['Isolate', 'O antigen', 'H1 antigen', 'H2 antigen', 'Profile', 'Sdf', 'Serotype']
    writer = csv.DictWriter(of, fieldnames=header, delimiter='\t')
    writer.writeheader()
    writer.writerows(res_list)
     
            