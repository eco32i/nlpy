# -*- coding: utf-8 -*-
"""
A simple parser to convert MASCOT search results page to a plain text file
Extracts tables from the file by looking for <tr> and <td> tags, treating
<tr> as a single line.

"""
import HTMLParser

in_file = '/home/ilya/Notebook/Peptide Summary Report (SB_090512_Ilya4_QX).html'
out_file = 'SB_090512_4_out.txt'

class TxtParser(HTMLParser.HTMLParser):

    def __init__(self):
        #super(TxtParser, self).__init__()
        HTMLParser.HTMLParser.__init__(self)
        self.buf = []
        self._line = ''
        self._row = False
        self._td = False
        
    def handle_starttag(self, tag, attrs):
        ntag = tag.upper()
        if ntag == 'TR':
            self._row = True
        elif ntag == 'TD':
            self._td = True
        
    def handle_endtag(self, tag):
        ntag = tag.upper()
        if ntag == 'TR':
            self._row = False
            self.buf.append(self._line + '\n')
            self._line = ''
        elif ntag == 'TD':
            self._td = False
        
    def handle_data(self, data):
        if self._td and data.strip() != '' and not data.endswith(':'):
            self._line += data + '\t'
        
tp = TxtParser()

with open(in_file, 'r') as f:
    tp.feed(f.read())
    
with open(out_file, 'w') as f:
    f.writelines(tp.buf)
        
print "Done. Converted %s to %s" % (in_file, out_file)
