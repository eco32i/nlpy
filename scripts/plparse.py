#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
A simple parser to convert PLink Xlink search results page to a HADDOCK
unambiguous constraints file by looking for <tr> and <td> tags, treating
<tr> as a single line.

in_file = '/home/ilya/src/xmass/IdProTable_1.html'

"""
import re, argparse, HTMLParser

parser = argparse.ArgumentParser()
parser.add_argument('plink_file', type=str, 
                        help='.html file containing plink output')
parser.add_argument('-L', '--length', type=float, default=11.4,
                        help='cross-linker length')
parser.add_argument('-d', '--dminus', type=float, default=1.0,
                        help='low end extent')
parser.add_argument('-D', '--dplus', type=float, default=2.0,
                        help='high end extent')
parser.add_argument('-v', '--verbosity', action='count',
                        help='increase output verbosity')

class PLinkParser(HTMLParser.HTMLParser):

    def __init__(self):
        #super(TxtParser, self).__init__()
        HTMLParser.HTMLParser.__init__(self)
        self.buf = []
        self._line = ''
        self._row = False
        self._td = False
        self._td_count = 0
        self._grab = False
        
    def handle_starttag(self, tag, attrs):
        ntag = tag.upper()
        if ntag == 'TR':
            self._row = True
        elif ntag == 'TD':
            self._td = True
            self._td_count += 1
        
    def handle_endtag(self, tag):
        ntag = tag.upper()
        if ntag == 'TR':
            self._row = False
            self._td_count = 0
            if self._line:
                self.buf.append(self._line)
            self._line = ''
        elif ntag == 'TD':
            self._td = False
        
    def handle_data(self, data):
        if self._td and self._td_count == 1 and data.strip().isdigit():
            self._grab = True
        elif self._td_count == 2 and self._grab:
            self._line += data.strip()
            self._grab = False
        
def get_restraints(line):
    r = re.compile(r'(?P<segid1>\w+)[(](?P<resid1>\d+)[)]-(?P<segid2>\w+)[(](?P<resid2>\d+)[)]')        
    m = r.search(line)
    tmpl = 'assign (resid {r1} and name n and segid {s1}) (resid {r2} and name n and segid {s2}) {length} {dminus} {dplus}\n'
    return tmpl.format(
        r1=m.group('resid1'),
        s1=m.group('segid1'),
        r2=m.group('resid2'),
        s2=m.group('segid2'),
        length=args.length,
        dminus=args.dminus,
        dplus=args.dplus
        )
    
args = parser.parse_args()
tp = PLinkParser()

if args.verbosity >= 1:
    print 'Parsing {fname} ...'.format(fname=args.plink_file)
with open(args.plink_file, 'r') as f:
    tp.feed(f.read())

if args.verbosity >= 1:
    print 'Generating constraints ...'     
with open('plparse.output', 'w') as f:
    f.writelines([get_restraints(s) for s in tp.buf])

if args.verbosity >= 2:
    for i,line in enumerate(tp.buf):
        print '%d:\t%s' % (i,line)
