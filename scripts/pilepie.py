#!/usr/bin/python

# -*- coding: utf-8 -*-
"""
Created on Tue Sep 11 08:50:13 2012
Fast and stupid sequence coverage plotter.
Takes samtools-produced .pileup file as input, produces ggplot2-like
coverage graph complete with kernel density estimation function.

@author: ilya shamovsky 
"""
from pylab import *
from ggstyle import rstyle, rhist
from itertools import chain
from scipy.stats.kde import gaussian_kde
import numpy as np

# dpi for print quality output. Change to 72 or 96 for screen output.
# TODO: Make this args
matplotlib.rcParams['savefig.dpi'] = 300

# TODO: Make this args
PILEUP_FILE = '/home/ilya/reads/hsr/E1_1r.pileup'
    
cov_list = []
pos_list = []
hdata = []
with open(PILEUP_FILE) as f:
    for line in f:
        chro, coord, ref_seq, reads, matches, score = line.split('\t')
        base_position = int(coord)        
        base_coverage = int(reads)
        cov_list.append(base_coverage)
        pos_list.append(base_position)
        hdata.append([base_position,] * base_coverage)

coverage = np.array(cov_list)
position = np.array(pos_list)

hda = list(chain.from_iterable(hdata))
start = min(position)
end = max(position)
pos_space = np.linspace(start, end, end-start)

kde = gaussian_kde(hda)
kde_pdf = kde.evaluate(pos_space)

fig = plt.figure()
# TODO: make this args
#fig.patch.set_alpha(0)

ax = fig.add_subplot(111)
# TODO: Make normed an args
hist, bis, patches = rhist(ax, np.array(hda), normed=True, facecolor="#dc322f", edgecolor='#dc322f', alpha=0.2)

# scale signal
new_max = max(hist)
kde_pdf = kde_pdf / max(kde_pdf) * new_max

plot(pos_space, kde_pdf, color='#268bd2', alpha=0.8)
ax.legend()
ax.set_xlabel('HSR1 nt')
ax.set_ylabel('Coverage')
ax.title.set_fontsize(18)
ax.fill_between(pos_space, kde_pdf, color="#268bd2", alpha=0.4)
rstyle(ax)
show()