# -*- coding: utf-8 -*-
"""
Created on Fri Mar 22 11:28:43 2013

@author: ilya
"""

from pyteomics import fasta, mgf, parser
import pylab

fasta_file = '/home/ilya/src/pyteomics/RhoEcoli.fasta'
mgf_file = '/home/ilya/src/pyteomics/MultiConsensus.mgf'

peptides = set()
with open(fasta_file) as fi:
    for description, sequence in fasta.read(fi):
        new_peptides = parser.cleave(sequence, parser.expasy_rules['trypsin'])
        peptides.update(new_peptides)
        
print "UNIQUE PEPTIDES"
print peptides

with open(mgf_file) as fi:
    for spectrum in mgf.read(fi):
        pylab.figure()
        pylab.xlabel('m/z, Th')
        pylab.ylabel('Intensity, rel.units')
        pylab.bar(spectrum['m/z array'], spectrum['intensity array'], width=0.1, linewidth=2, edgecolor='black')
        pylab.show()
        inp = raw_input("Show more?")
        if inp != "yes":
            break;
            
print "DONE!"