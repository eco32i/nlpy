#!/usr/bin/python

# -*- coding: utf-8 -*-
"""
Created on Fri Jun 14 08:58:28 2013
A simple script to identify a set of common elements in a bunch lists.
The lists are taken from tab-delimited files by specifying the column.
Developed to analyze the output of tophat/cufflinks/cuffdiff pipeline output.

This is naive and will probably break for very large files as everything is
loaded to the memory.

@author: ilya
"""

import csv, argparse

parser = argparse.ArgumentParser()
parser.add_argument('files', type=str, nargs='+', 
                        help='csv (or tab-delimited) files to process')
parser.add_argument('-c', '--col', type=str, default='name',
                        help='column to extract the list from')
parser.add_argument('-d', '--delim', type=str, default='\t',
                        help='delimiter char')
parser.add_argument('-v', '--verbosity', action='count',
                        help='increase output verbosity')

args = parser.parse_args()

set_list = []
if args.verbosity >= 1:
    print 'Building sets from input files...'
for filename in args.files:
    with open(filename) as fi:
        if args.verbosity >= 2:
            print '...\tprocessing {f}'.format(f=filename)
        reader = csv.DictReader(fi, delimiter=args.delim)
        temp_set = []
        for rec in reader:
            temp_set.append(rec[args.col])
        set_list.append(set(temp_set))
        
intersect = set_list[0].intersection(*set_list[1:])
if args.verbosity >= 1:
    print '{num} elements are present in all files'.format(num=len(intersect))

for elem in intersect:
    print elem
        
        