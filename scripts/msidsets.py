# -*- coding: utf-8 -*-
'''
Simple script to convert a list of MS-ID hits to a set and have fun with it
'''

in_file = 'SB_082112_1_out.txt'

def import_msid_list(filename):
    buf = []
    with open(filename) as f:
        for line in f:
            l = line.strip()
            # for now we're stopping at the first empty line
            if not l:
                break
            bits = l.split('\t')
            if len(bits) == 2:
                buf.append((bits[0], bits[1]))
    return set(buf)