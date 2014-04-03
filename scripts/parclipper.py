# -*- coding: utf-8 -*-
"""
Created on Tue Sep 11 08:50:13 2012
Exploring PARAlyzer-like algorythm

@author: ilya
"""

PILEUP_FILE = '/home/ilya/reads/b2/Sample_lane7E1_sorted.bam'
BANDWIDTH = 3
MIN_READS_PER_GROUP = 5
MIN_READS_PER_CLUSTER = 5

current_group = []

with open(SAM_FILE) as samfile:
    for pileup_col in samfile.pileup():

print "Done. Found %d peaks" % peaks