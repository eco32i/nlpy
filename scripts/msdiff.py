#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
Simple script to identify unique proteolytic peptides for each of the proteins
given in the fasta file

Number of missed cleavages, protease, and the minimum length of the peptide to
report can be specified.

"""
import argparse
from pyteomics import parser, fasta

arg_parser = argparse.ArgumentParser()
arg_parser.add_argument('fasta_file', type=str, 
                        help='fasta file containing protein sequences')
arg_parser.add_argument('-m', '--min', type=int, default=6,
                        help='minimal length of the peptide to report')
arg_parser.add_argument('-M', '--missed', type=int, default=0,
                        help='number of missed cleavages')
arg_parser.add_argument('-e', '--enz', type=str, default='trypsin',
                        help='protease to use for digestion')
arg_parser.add_argument('-v', '--verbosity', action='count',
                        help='increase output verbosity')

args = arg_parser.parse_args()

# TODO: Do it proper way - using os.path
out_file = args.fasta_file + '.peptides'                        
peptides = []

with fasta.read(args.fasta_file) as reader, open(out_file,'w') as writer:
    
    # Build a set of peptides for each fasta sequence 
    if args.verbosity >= 1:
        print 'Building digests...'
    for description, sequence in reader:
        peps = parser.cleave(sequence, parser.expasy_rules[args.enz], args.missed)
        peps = [x for x in peps if len(x) > args.min]
        writer.write('Peptides for {seq} ({enz} cleavage)\n'.format(
            seq=description, enz=args.enz))
        writer.write('...\t{n} missed cleavages\n'.format(n=args.missed))
        writer.write('\n'.join(peps)+'\n')
        peptides.append(set(peps))
        if args.verbosity >= 2:
            print '...\t{n} peptides for {prot}'.format(n=len(peps),prot=description)
        
    # Identify unique peptides for each fasta sequence
    if args.verbosity >= 1:
        print 'Finding unique peptides...'
    for peps in peptides:
        rest = [x for x in peptides if x is not peps]
        unique = peps - set().union(*rest)
        writer.write('\n######### Unique peptides\n')
        writer.write('\n'.join(unique)+'\n')
        if args.verbosity >= 2:
            print '...\t\t{n} unique peptides'.format(n=len(unique))
        
if args.verbosity >= 1:
    print 'Done.'