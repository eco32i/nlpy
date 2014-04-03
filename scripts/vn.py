# -*- coding: utf-8 -*-
"""
Created on Tue Sep 10 22:39:34 2013

@author: ilya
"""
from matplotlib_venn import *
from pylab import *

mouse_complexes = set([
    36092,
    36094,
    36096,
    36098,
    36100,
    36104,
    36108,
    36089,
    27205,
    27202,
    28679,
    28681])
    
human_complexes = set([
    28705,
    36023,
    36026,
    36029,
    36033,
    36037,
    36048,
    36052,
    36055,
    36057,
    36058,
    27205,
    27202,
    28679,
    28681,
    36035,
    36036,
    36122,
    36123])
    
mouse_proteins = set([
    'Tank',
    'Peli1',
    'TLR4',
    'MD2',
    'TRAM',
    'TRIF',
    'TRAF6',
    'TRAF3',
    'TBK1',
    'IKKi',
    'RIP1',
    'CD14'])

human_proteins = set([
    'TLR4',
    'MD2',
    'TRAM',
    'TRIF',
    'TRAF6',
    'TRAF3',
    'TBK1',
    'IKKi',
    'RIP1',
    'CD14',
    'SARM',
    'RIP3',
    'pro-CAP8',
    'FADD',
    'IRF3',
    'IRF7'])    
    
#venn2()
#venn2(subsets=(
#    len(mouse_complexes - human_complexes),
#    len(human_complexes - mouse_complexes),
#    len(human_complexes & mouse_complexes)),
#    set_labels=('Mouse complexes', 'Human complexes'),
#    set_colors=('#fdf6e3', '#93a1a1'))

venn2(subsets=(
    len(mouse_proteins - human_proteins),
    len(human_proteins - mouse_proteins),
    len(human_proteins & mouse_proteins)),
    set_labels=('Mouse protein', 'Human protein'),
    set_colors=('#fdf6e3', '#93a1a1'))
plt.show()