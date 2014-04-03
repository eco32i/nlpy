# -*- coding: utf-8 -*-
"""
Created on Thu Sep 13 18:47:02 2012
Quick-and-dirty assembly of short reads on HSR ends.
@author: ilya
"""

# HSR1 5' end
# SEED = 'CCGTCCAATTGAGGTCCGAA'
# SEED = 'CCGTCCAATTGAGGTCCG'   # 5'

SEED = 'TTGAGGTCCGAA'
OVERLAP = 3
MAX_ITER = 3
MIN_SEED_LENGTH = 10
RUNID = '@HWI-ST734'

in_file = '/home/ilya/reads/Sample_lane7E1.fastq'
out_file = '/home/ilya/reads/hsr/hsr-asm-t.txt'

def get_next_read(handle):
    '''
    Here we assume the file is properly formatted fastq
    and read all four lines at once.
    '''
    try:
        r_id = handle.readline()
        r = handle.readline()
        plus = handle.readline()
        q = handle.readline()
    except IOError:
        return None, '', ''
    return r_id, r, q

def print_aln(results, f=None):
    '''
    Given a list of tuples (seq, pos) prints an alignment
    padding with whitespace as necessary.
    
    Results list must be SEED position in the read.
    '''
    max_padding = results[-1][1]
    if f:
        for seq, pos in results:
            f.write(' ' * (max_padding - pos) + seq)
    else:
        print ' ' * (max_padding - pos) + seq

def process_reads(f, seed):
    
    def get_new_seed(seq, i, length):
        '''
        Computes new seed from the 5' end of the seq
        by iteratively moving left from position i until
        either 1) the end of sequence is reached or 2) the
        seed reaches length
        '''
        if i > MIN_SEED_LENGTH - OVERLAP:
            return seq[i - MIN_SEED_LENGTH + OVERLAP + 1:MIN_SEED_LENGTH]
        else:
            return seq[:MIN_SEED_LENGTH]    
        
    results = []
    count = found = 0
    print "Using seed:\t%s" % seed
    while True:
        read_id, read_seq, read_q = get_next_read(f)
        if not read_id:
            break
        count += 1
        # This approach breaks if there are point mutations
        # Need to use editing distance or something similar
        seed_pos = read_seq.find(seed)
        if  seed_pos != -1:
            found += 1
            results.append((read_seq, seed_pos))
        if count % 100000 == 0:
            print "Processed %d reads.\t\tFound %d matches so far." % (count, found)
    results.sort(key=lambda x: x[1])
    # Need to add the longest 3' read to the consensus and then
    # backtrack to get new seed!    
    if not results:
        return None, '', []
    r, pos = results[-1]
    i = pos + len(seed)
    consensus = r[:i]
    #new_seed = r[i-OVERLAP-1:i-OVERLAP+len(seed)+1]
    new_seed = get_new_seed(r, pos, len(seed))
    print "Computing seed from:%s\tat:\t%i" % (r, pos)
    print "Consensus: %s\t new seed: %s" % (consensus, new_seed)
    return new_seed, consensus, results
        
with open(in_file) as fi, open(out_file, "w") as fo:
    itr = 1
    seed = consensus = SEED
    while itr <= MAX_ITER:
        print "Iteration %i" % itr
        fo.write("Iteration %i.\tUsing seed: %s\n" % (itr, seed))        
        seed, new_cons, matches = process_reads(fi, seed)
        if not matches:
            print "No matching reads found."
            break
        itr += 1
        consensus = new_cons + consensus
        print_aln(matches, fo)
        fo.write("Found %d matches.\tAdd consensus: %s\n" % (len(matches), new_cons))
        fo.write("Consensus 5'HSR:\t%s\n" % consensus)
        fi.seek(0)
        if not seed or len(seed) < MIN_SEED_LENGTH:
            print "Failed to compute SEED for the next iteration."
            break
        
print "DONE."