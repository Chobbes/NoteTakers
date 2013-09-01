#  Copyright (C) 2013 Calvin Beck
#
#  Permission is hereby granted, free of charge, to any person
#  obtaining a copy of this software and associated documentation files
#  (the "Software"), to deal in the Software without restriction,
#  including without limitation the rights to use, copy, modify, merge,
#  publish, distribute, sublicense, and/or sell copies of the Software,
#  and to permit persons to whom the Software is furnished to do so,
#  subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be
#  included in all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
#  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
#  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
#  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.


# Need to attempt to figure out which PDF viewer to use.
UNAME=$(shell uname)

ifeq ($(VIEWER), "")
	ifeq ($(UNAME), Linux)
		VIEWER="evince"
	else ifeq($(UNAME), Darwin)
		VIEWER="open"
	endif
endif

# Variables for LaTeX
LATEX=latexmk  # What we are going to use to build .tex files.
LATEX_FLAGS=-g -pdf -pdflatex='pdflatex -halt-on-error -interaction errorstopmode'

# Find all of the LaTeX files in the directory.
TEX_FILES=$(shell find . -name "*tex" -maxdepth 1 -type f | tr '\n' ' ')

# May also use a preamble file.
PREAMBLE=../preamble.sty

# Names of all of the PDF files that we want to generate.
PDF_FILES=$(TEX_FILES:.tex=.pdf)


# Generate all PDF files for our directory.
all: $(PDF_FILES)

# Rule to open the PDF files in a viewer.
view: all
	$(VIEWER) $(PDF_FILES)

# Rule for PDF file generation.
%.pdf: %.tex $(PREAMBLE)
	$(LATEX) $(LATEX_FLAGS) $<

# Run latexmk's clean.
clean:
	latexmk -c

# These rules don't generate targets.
.PHONY: all view clean
