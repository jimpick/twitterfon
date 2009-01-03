from __future__ import with_statement
import re
import sys

class Section:
    def __init__(self, address, size, segment, section):
        self.address = address
        self.size = size
        self.segment = segment
        self.section = section
    def __str__(self):
        return self.section+""

class Symbol:
    def __init__(self, address, size, file, name):
        self.address = address
        self.size = size
        self.file = file
        self.name = name
    def __str__(self):
        return self.name

class Files:
    def __init__(self, id, archive, object):
        self.id = id
        self.archive = archive
        self.object = object
        self.size = 0
    def __str__(self):
        return self.object

#
#
argvs = sys.argv
argc = len(argvs)
#
if (argc != 2):
    print 'Usage: # python %s filename' % argvs[0] 
    quit()

#===============================
# Load the Sections and Symbols
#
sections = []
symbols = []
files = []

with open(argvs[1]) as f:
    in_sections = True
    for line in f:
        m = re.search('^\[([0-9 ]+)\]\s+(.+)\s*$',line )
        if m:
            files.append( Files(m.group(1),m.group(2), "") )
            continue

        m = re.search('^([0-9A-Fx]+)\s+([0-9A-Fx]+)\s+(\[([ 0-9]+)\]|\w+)\s+(.*?)\s*$', line)
        if m:
            if in_sections:
                sections.append(Section(eval(m.group(1)), eval(m.group(2)), m.group(3), m.group(5)))
            else:
                symbols.append(Symbol(eval(m.group(1)), eval(m.group(2)), eval(m.group(4)), m.group(5)))
        else:
            if len(sections) > 0:
                in_sections = False


#===============================
# Gererate the HTML File
#

colors = ['9C9F84', 'A97D5D', 'F7DCB4', '5C755E']
total_height = 1400.0

segments = set()
for s in sections: segments.add(s.segment)
segment_colors = dict()
i = 0
for s in segments:
    segment_colors[s] = colors[i % len(colors)]
    i += 1

total_size = 0
for s in symbols:
    total_size += s.size
    files[ s.file ].size += s.size
 
sections.sort(lambda a,b: a.address - b.address)
symbols.sort(lambda a,b: a.address - b.address)
files.sort(lambda a,b: b.size - a.size)

def section_from_address(addr):
    for s in sections:
        if addr >= s.address and addr < (s.address + s.size):
            return s
    return None

print "<html><head>"
print "  <style>a { color: black; text-decoration: none; font-family:monospace }</style>"
print "<body>"

for obj in files:
    print "%s" % obj.size
    print "%s" % obj.archive
    print "[%s]<br>" % obj.id

print "<table cellspacing='1px'>"
for sym in symbols:
    section = section_from_address(sym.address)
    height = (total_height/total_size) * sym.size
    font_size = 1.0 if height > 1.0 else height
    print "<tr style='background-color:#%s;height:%gem;line-height:%gem;font-size:%gem'><td style='overflow:hidden'>" % \
        (segment_colors[section.segment], height, height, font_size)
    print "%s:" % hex(sym.address)
    print "%s" % (sym.size)
    print( sym.file )
    print "%s" % (files[ sym.file ].archive)

    print "<a href='#%s'>%s</a>" % (sym.name, sym.name)

    print "</td></tr>"
print "</table>"
print "</body></html>"
