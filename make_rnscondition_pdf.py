#!/usr/bin/python

import os, sys
from glob import glob

subjname = sys.argv[1]
condition = sys.argv[2]
condition_parts = condition.split("_")
condition_str = "\_".join(condition_parts)
subjdir = os.path.join("data", subjname)
figspath = os.path.join(subjdir, "figs", condition)

texfname = os.path.join(subjdir, subjname + "_" + condition + ".tex")
texf = open(texfname, 'w')

title = subjname + " " + condition_str
preamble = "\\documentclass[12pt]{article}\n\\usepackage{graphicx, pdflscape}\n" \
    + "\\renewcommand{\\familydefault}{\\sfdefault}\n\\title{" + title + "}\n" \
    + "\\begin{document}\n\\maketitle\clearpage\pagenumbering{gobble}\n\n\\begin{landscape}\n"

texf.write(preamble)

imgfiles = glob(os.path.join(figspath, '*.png'))
imgfiles.sort()

for f in imgfiles:
    fname_parts = f.split("_")
    ftextname = "\_".join(fname_parts)
    thisline = "\\section{" + ftextname + "}\n\n"
    texf.write(thisline)
    thisline = "\\includegraphics[width=1.3\\textwidth]{" + f + "}\n\n"
    texf.write(thisline)

postamble = "\\end{landscape}\n\n\\end{document}\n"
texf.write(postamble)

texf.close()

os.system("pdflatex -output-directory " + subjdir + " " + texfname)
