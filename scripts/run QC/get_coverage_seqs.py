#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Feb  3 13:48:09 2018

@author: vincent
"""

import os, sys

info_files = sys.argv[1:3]
info_files = [os.path.expanduser(f) for f in info_files]
info_files = [os.path.abspath(f) for f in info_files]

genome_size = float(sys.argv[3])
coverage = float(sys.argv[4])

def eng2float(num_string):
    if num_string[-1] in '0123456789':
        return(float(num_string))
    elif num_string[-1] == 'k':
        return(1e3 * float(num_string[:-1]))
    elif num_string[-1] == 'M':
        return(1e6 * float(num_string[:-1]))
    elif num_string[-1] == 'G':
        return(1e9 * float(num_string[:-1]))
    else:
        print("That number string was not recognized")
        return(None)

avg_len = 0
for f in info_files:
    with open(f, 'r') as fr:
        totals = fr.readline()
        totals = totals.split(',')
        seqs = totals[1].split()[0]
        seqs = (eng2float(seqs))
        nucs = totals[2].split()[0]
        nucs = (eng2float(nucs))
        avg_len += nucs / seqs
    
req_seqs = genome_size * coverage / avg_len
if (req_seqs > seqs):
#    print("Requested coverage is larger than the maximum possible for this isolate.")
    print(int(seqs))
else:
    print(int(req_seqs))