#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Author: Vincent Caruso
Date written: February 7, 2018
Last modified: March 1, 2018
Purpose: 
@author: vincent
"""

import sys, os, csv, re
from compute_seqsero_accuracy import compute_summary_stats, compute_isolate_stats

in_path = os.path.expanduser(sys.argv[1])
in_path = os.path.abspath(in_path)
#in_path = '/home/vincent/osphl/validation/sens_and_spec/salmonella/'
out_file = os.path.expanduser(sys.argv[2])
out_file = os.path.abspath(out_file)
#out_file = '/home/vincent/osphl/validation/sens_and_spec/salmonella/test_stats.tsv'
mode = sys.argv[3]

ref_dict = {'VS01': 'N/A',
            'VS02': 'N/A',
            'VS03': 'N/A',
            'VS04': 'N/A',
            'VS05': 'Choleraesuis',
            'VS06': 'Typhimurium',
            'VS07': 'Typhimurium',
            'VS08': 'Abaetetuba',
            'VS09': 'Paratyphi A',
            'VS21': 'N/A',
            'VS22': 'N/A',
            'VS23': 'N/A',
            'VS24': 'N/A',
            'VS25': 'N/A',
            'VS31': 'Saintpaul',
            'VS32': 'Typhimurium',
            'VS33': 'Newport',
            'VS34': 'Enteritidis',
            'VS35': 'Brandenburg'}

dirs = next(os.walk(in_path))[1]
dirs.sort()
dirs = [os.path.join(in_path, d) for d in dirs]

with open(out_file, 'w') as of:
    
    if mode == '--iso':
        header = ['Isolate', 'Coverage', 'Serotype', 'Replicates', 'TP', 'TN', 'FP', 'FN', 
                  'Accuracy', 'Sensitivity', 'Precision', 'Specificity']
        writer = csv.DictWriter(of, fieldnames=header, delimiter='\t')
        writer.writeheader()
        
        for d in dirs:
            sero_file = next(f for f in os.listdir(d) if re.match(r'^seqsero_serotypes.*\.tsv', f))
            sero_file = os.path.join(d, sero_file)
            isolate_stats = compute_isolate_stats(sero_file, ref_dict)
            
            for iso, stats in isolate_stats.items():
                stats['Coverage'] = d.split('/')[-1].title()
                writer.writerow(stats)
            
    else:
        header = ['Coverage', 'Replicates', 'TP', 'TN', 'FP', 'FN', 'Accuracy', 'Sensitivity', 'Precision', 'Specificity']
        writer = csv.DictWriter(of, fieldnames=header, delimiter='\t')
        writer.writeheader()
        
        for d in dirs:
            sero_file = next(f for f in os.listdir(d) if re.match(r'^seqsero_serotypes.*\.tsv', f))
            sero_file = os.path.join(d, sero_file)
            stats = compute_summary_stats(sero_file, ref_dict)
            stats['Coverage'] = d.split('/')[-1]
            writer.writerow(stats)
    