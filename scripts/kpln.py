#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
A simple converter from .csv wide-table format to a long table format that
can be used with Kaplan-Meyers survival analysis

MIT License 2014 Ilya Shamovsky
"""
import os, argparse, csv

parser = argparse.ArgumentParser()
parser.add_argument('csv_file', type=str, 
                        help='.csv file')
parser.add_argument('-d', '--delim', type=str, default='\t',
                        help='delimiter symbol')
parser.add_argument('-e', '--event', type=str, default='1',
                        help='event symbol')
parser.add_argument('-v', '--verbosity', action='count',
                        help='increase output verbosity')


    
args = parser.parse_args()
base, ext = os.path.splitext(args.csv_file)
output_csv = '{0}_kpln{1}'.format(base, ext)

if args.verbosity >= 1:
    print 'Parsing {fname} ...'.format(fname=args.csv_file)
    print 'Writing output to {fname} ...'.format(fname=output_csv)
    
with open(args.csv_file, 'rU') as fi, open(output_csv, 'wb') as fo:
    reader = csv.reader(fi, delimiter=args.delim)
    writer = csv.writer(fo, delimiter=args.delim)
    header = reader.next()
    writer.writerow(header)
    if args.verbosity >= 1:
        print 'Header:\t{0}'.format('\t'.join(header))     
        
    for rec in reader:
        if not rec:
            break
        values = [int(x) for x in rec[1:]]
        # We need list of lists to utilize csv.writer later on
        buf = max(values) * [[rec[0]]]
        i = 0
        for line in buf:
            cline = list(line)
            for col in values:
                if col <= i:
                    cline.append('')
                else:
                    cline.append(args.event)
            writer.writerow(cline)
            i += 1

