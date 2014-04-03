# -*- coding: utf-8 -*-
"""
Created on Wed Jan  9 18:12:07 2013

@author: ilya
"""

infile = '/home/ilya/reads/blastresults.txt'

def get_next_hit(handle):
#    hit_buffer = []
    is_header = False
    query = hits = None
    while True:
        line = handle.readline().strip()
        if line.startswith('#'):
            if is_header:
                if line.endswith('hits found'):
                    hits = int(line.split()[1])
                    is_header = False
                    break;
                elif line.startswith('# Query:'):
                    query = line.split()[-1]
            elif line.startswith('# BLASTN'):
                is_header = True
        elif not line:
            break
    return query, hits

cnt = 0
with open(infile) as fi:
    query, hits = get_next_hit(fi)
    while query is not None:
        if hits == 0:
            print 'QUERY: {q} - 0 hits'.format(q=query)
            cnt += 1
        query, hits = get_next_hit(fi)
        
print '%d unknown hits' % cnt