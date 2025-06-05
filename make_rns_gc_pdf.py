#!/usr/bin/python

import os, sys
from glob import glob

subjname = sys.argv[1]
topdir = sys.argv[2]

figspath = os.path.join("analyses", subjname, "figs", topdir)
figspath_forward = os.path.join(figspath, "forward")
figspath_forwardthresh = os.path.join(figspath, "forward_thresh")
figspath_backward = os.path.join(figspath, "backward")
figspath_backwardthresh = os.path.join(figspath, "backward_thresh")
figspath_diff = os.path.join(figspath, "diff")

texfname = os.path.join("analyses", subjname, subjname + "_" + topdir + ".tex")
texf = open(texfname, 'w')

subjname_parts = subjname.split("_")
if len(subjname_parts) > 1:
    subjname = "\_".join(subjname_parts)

title = subjname + " Granger Figures"
preamble = "\\let\\mypdfximage\\pdfximage\n\\def\\pdfximage{\\immediate\\mypdfximage}\n" \
    + "\\documentclass[12pt]{article}\n\\usepackage{graphicx, hyperref, longtable, pdflscape}\n" \
    + "\\hypersetup{colorlinks=true,linkcolor=blue,pdftitle={" + title + "}}\n" \
    + "\\renewcommand{\\familydefault}{\\sfdefault}\n\\title{" + title + "}\n" \
    + "\\begin{document}\n\\maketitle\clearpage\pagenumbering{gobble}\n\n" \
    + "\\setlength\\LTleft{-40mm}\\begin{landscape}\n\\hspace{-4cm}\n\\begin{longtable}{|c|c|c|c|c|}\n" \
    + "\caption{Granger causality plots.} \label{tab:long} \\\\\n\n" \
    + "\hline \multicolumn{1}{|c|}{\\textbf{Channel pair}} & \multicolumn{1}{c|}{\\textbf{Forward GC}} & \multicolumn{1}{c|}{\\textbf{Backward GC}} & \multicolumn{1}{c|}{\\textbf{z(Forward GC)}} & \multicolumn{1}{c|}{\\textbf{z(Backward GC)}} \\\\ \hline\n" \
    + "\endfirsthead\n\n" \
    + "\multicolumn{5}{c}%\n" \
    + "{{\\bfseries \\tablename\ \\thetable{} -- continued from previous page}} \\\\\n" \
    + "\hline \multicolumn{1}{|c|}{\\textbf{Channel pair}} & \multicolumn{1}{c|}{\\textbf{Forward GC}} & \multicolumn{1}{c|}{\\textbf{Backward GC}} & \multicolumn{1}{c|}{\\textbf{z(Forward GC)}} & \multicolumn{1}{c|}{\\textbf{z(Backward GC)}} \\\\ \hline\n" \
    + "\endhead\n\n" \
    + "\hline \multicolumn{5}{|r|}{{Continued on next page}} \\\\ \hline\n" \
    + "\endfoot\n\n" \
    + "\hline \hline\n" \
    + "\endlastfoot\n"

texf.write(preamble)

imgfiles_forward = glob(os.path.join(figspath_forward, '*.png'))
imgfiles_forward.sort()

imgfiles_backward = glob(os.path.join(figspath_backward, '*.png'))
imgfiles_backward.sort()

# imgfiles_diff = glob(os.path.join(figspath_diff, '*.png'))
# imgfiles_diff.sort()

# imgfiles_thresh_forward = glob(os.path.join(figspath_forwardthresh, '*.png'))
# imgfiles_thresh_forward.sort()
# imgfiles_thresh_backward = glob(os.path.join(figspath_backwardthresh, '*.png'))
# imgfiles_thresh_backward.sort()

imgsize = 0.37
clusterpics = 6
#total_pairs = int((len(imgfiles_forward)-clusterpics)/2)
total_pairs = int((len(imgfiles_forward))/2)

imgsize2 = 0.5

for i,f in enumerate(imgfiles_forward):
    fparts = os.path.basename(f).split('_')
    if fparts[0]=="z" or fparts[0]=='thresh':
        break
    elif fparts[0]=="400":
        texf.write("\pagebreak\n")
    seedstr = fparts[1]
    target = fparts[2][:-4]
    label = seedstr + " $\\leftrightarrow$\\\\ " + target
    thisline = "\\begin{tabular}{c}\n" + label + " \n\end{tabular}\n&\n" \
        + "\\begin{tabular}{c}\n\\includegraphics[width=" \
        + str(imgsize) + "\\textwidth]{" + f + "}\n\end{tabular}\n&\n" \
        + "\\begin{tabular}{c}\n\\includegraphics[width=" \
        + str(imgsize) + "\\textwidth]{" + imgfiles_backward[i] + "}\n\end{tabular}\n&\n" \
        + "\\begin{tabular}{c}\n\\includegraphics[width=" \
        + str(imgsize) + "\\textwidth]{" + imgfiles_forward[i+total_pairs] + "}\n\end{tabular}\n&\n" \
        + "\\begin{tabular}{c}\n\\includegraphics[width=" \
        + str(imgsize) + "\\textwidth]{" + imgfiles_backward[i+total_pairs] + "}\n\end{tabular}\n\\\\\n"
    texf.write(thisline)

postamble = "\\end{longtable}\n"
texf.write(postamble)

# thisline = "\pagebreak\n\\begin{tabular}{cc}\\\\\n\includegraphics[width=" + str(imgsize2) \
#     + "\\textwidth]{" + imgfiles_diff[0] + "} & \n" \
#     + "\\includegraphics[width=" + str(imgsize2) \
#     + "\\textwidth]{" + imgfiles_diff[1] + "}\\\\\n\\end{tabular}\n\n"
# texf.write(thisline)

# # forward threshold plots
# thisline = "\pagebreak\n\hspace{-4.5cm}\\begin{tabular}{|c|c|c|c|c|}\n\hline\n & Raw Z-Score & Thresholded, & Thresholded, & Thresholded," \
#     + "\\\\\n& & non-corrected & pixel-corrected & cluster-corrected\\\\\hline\n" \
#     + "Forward IOZ & " \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_forward[-2] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_forward[0] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_forward[1] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_forward[2] + "}\n\end{tabular}\\\\\hline\n" \
#     + "Forward non-IOZ & " \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_forward[-1] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_forward[3] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_forward[4] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_forward[5] + "}\n\end{tabular}\\\\\hline\n" \
#     + "\\end{tabular}\n\n"
# texf.write(thisline)

# # backward threshold plots
# thisline = "\pagebreak\n\hspace{-4.5cm}\\begin{tabular}{|c|c|c|c|c|}\n\hline\n & Raw Z-Score & Thresholded, & Thresholded, & Thresholded," \
#     + "\\\\\n& & non-corrected & pixel-corrected & cluster-corrected\\\\\hline\n" \
#     + "Backward IOZ & " \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_backward[-2] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_backward[0] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_backward[1] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_backward[2] + "}\n\end{tabular}\\\\\hline\n" \
#     + "Backward non-IOZ & " \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_backward[-1] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_backward[3] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_backward[4] + "}\n\end{tabular}\n&\n" \
#     + "\\begin{tabular}{c}\n\\includegraphics[width=" \
#     + str(imgsize) + "\\textwidth]{" + imgfiles_thresh_backward[5] + "}\n\end{tabular}\\\\\hline\n" \
#     + "\\end{tabular}\n\n"
# texf.write(thisline)

texf.write("\\end{landscape}\n\n\\end{document}\n")
texf.close()

os.system("pdflatex -output-directory " + os.path.join("analyses", subjname) + " " + texfname)
os.system("pdflatex -output-directory " + os.path.join("analyses", subjname) + " " + texfname)
