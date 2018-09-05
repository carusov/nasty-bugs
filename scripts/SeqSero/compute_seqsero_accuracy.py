#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Author: Vincent Caruso
Date written: February 7, 2018
Last modified: March 1, 2018
Purpose: This is a small module to define functions that compute accuracy
    stats from a table of SeqSero serotype results. This table is computed by
    the 'get_seqsero_serotypes.py' script.
"""

import csv
from collections import defaultdict

def compute_summary_stats(serotype_file, ref_dict):
    stat_dict = {}
    with open(serotype_file, 'r') as fi:
        reader = csv.reader(fi, delimiter='\t')
        header = next(reader)
        result_dict = {row[0]: row[-1] for row in reader}
     
    TN = 0       
    TP = 0
    FN = 0
    FP = 0
    for rep, sero in result_dict.items():
        sample = rep.split('-')[0]
        if ref_dict[sample] == 'N/A':
            if sero.split()[0] == 'N/A':
                TN += 1
            else:
                FP += 1
        else:
            if ref_dict[sample] in set(sero.split(',')):
                TP += 1
            elif sero.split()[0] in set(('N/A', 'See')):
                FN += 1
            else:
                FP += 1
    
    stat_dict['TN'] = TN
    stat_dict['TP'] = TP
    stat_dict['FN'] = FN
    stat_dict['FP'] = FP
    stat_dict['Accuracy'] = 100 * (TP + TN) / len(result_dict)
    stat_dict['Sensitivity'] = 100 * TP / (TP + FN) if TP + FN > 0 else 'N/A'
    stat_dict['Precision'] = 100 * TP / (TP + FP) if TP + FP > 0 else 'N/A'
    stat_dict['Specificity'] = 100 * TN / (TN + FP) if TN + FP > 0 else 'N/A'
    stat_dict['Replicates'] = len(result_dict)
    
    return stat_dict


def compute_isolate_stats(serotype_file, ref_dict):
    
    with open(serotype_file, 'r') as fi:
        reader = csv.reader(fi, delimiter='\t')
        header = next(reader)
        result_dict = {row[0]: row[-1] for row in reader}
        
    isolate_dict = defaultdict(lambda: defaultdict(int))

    # first count up the classifcation results
    for rep, sero in result_dict.items():
        isolate = rep.split('-')[0]
        isolate_dict[isolate]['Isolate'] = isolate
        isolate_dict[isolate]['Serotype'] = ref_dict[isolate]
        if ref_dict[isolate] == 'N/A':
            if sero.split()[0] in set(('N/A', 'See')):
                isolate_dict[isolate]['TN'] += 1
                isolate_dict[isolate]['Replicates'] += 1
            else:
                isolate_dict[isolate]['FP'] += 1
                isolate_dict[isolate]['Replicates'] += 1
        else:
            if ref_dict[isolate] in set(sero.split(',')):
                isolate_dict[isolate]['TP'] += 1
                isolate_dict[isolate]['Replicates'] += 1
            elif sero.split()[0] in set(('N/A', 'See')):
                isolate_dict[isolate]['FN'] += 1
                isolate_dict[isolate]['Replicates'] += 1
            else:
                isolate_dict[isolate]['FP'] += 1
                isolate_dict[isolate]['Replicates'] += 1
    
    # now, compute the accuracy stats for each isolate
    for iso, stats in isolate_dict.items():
        TP = stats['TP']
        TN = stats['TN']
        FP = stats['FP']
        FN = stats['FN']
        total = stats['Replicates']
        stats['Accuracy'] = 100 * (TP + TN) / total
        stats['Sensitivity'] = 100 * TP / (TP + FN) if TP + FN > 0 else 'N/A'
        stats['Precision'] = 100 * TP / (TP + FP) if TP + FP > 0 else 'N/A'
        stats['Specificity'] = 100 * TN / (TN + FP) if TN + FP > 0 else 'N/A'
    
    return isolate_dict

if __name__ == "__main__":
#    in_file = os.path.expanduser(sys.argv[1])
#    in_file = os.path.abspath(in_file)
    in_file = '/home/vincent/osphl/validation/sens_and_spec/salmonella/20x/seqsero_serotypes_20x.tsv'
    
    ref_dict = {'VS05': 'Choleraesuis',
                'VS06': 'Typhimurium',
                'VS07': 'Typhimurium',
                'VS08': 'Abaetetuba',
                'VS09': 'Paratyphi A',
                'VS31': 'Saintpaul',
                'VS32': 'Typhimurium',
                'VS33': 'Newport',
                'VS34': 'Enteritidis',
                'VS35': 'Brandenburg'}

    stats = compute_summary_stats(in_file, ref_dict)
    print(stats['Accuracy'], stats['Sensitivity'], stats['Precision'], stats['Specificity'])