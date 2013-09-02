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

ifndef VIEWER
	ifeq ($(UNAME), Linux)
		VIEWER="evince"
	endif
	ifeq ($(UNAME), Darwin)
		VIEWER="open"
	endif
endif

# Variables for LaTeX
LATEX=latexmk  # What we are going to use to build .tex files.
LATEX_FLAGS=-g -pdf -pdflatex='pdflatex -halt-on-error -interaction errorstopmode'

# Find all of the subdirectories which should contain notes.  These
# need to be sorted by day.  We ignore the template directory. Also
# find all of the LaTeX files.
NOTE_DIRECTORIES=$(shell find ./*/ -type d | grep -v 'template/' | grep -v 'docs/' | grep -v $(MAIN_DIR) | tr '\n' ' ')
TEX_FILES=$(shell find ./*/ -name "*tex" -type f | grep -v 'template.tex' | grep -v $(MAIN_DIR) | tr '\n' ' ')

# Get the name of the class.
CLASS_NAME=$(shell basename $(PWD))

# Name of the main .tex file. This is the file which includes all of
# the individual days.
MAIN_DIR=main
MAIN_TEX_FILE=$(CLASS_NAME).tex
MAIN_PDF_FILE=$(MAIN_TEX_FILE:.tex=.pdf)

# Class for the main .tex file.
DOCUMENT_CLASS=article

# May also use several preamble files.
PREAMBLES=preamble.sty

# Name for todays notes.
TODAY_NAME=$(CLASS_NAME)-$(shell date "+%Y-%m-%d")


all: $(MAIN_DIR)/$(MAIN_PDF_FILE)

# Rule to generate all of the individual note PDFs.
individuals:
	for dir in $(NOTE_DIRECTORIES); do \
		make -C $$dir; \
	done

# Rule for generating the main .tex file.
$(MAIN_DIR)/$(MAIN_TEX_FILE): $(TEX_FILES) $(PREAMBLES)
	mkdir -p $(MAIN_DIR)
	printf "\\\documentclass{$(DOCUMENT_CLASS)}\n" > $@
	printf "\\\usepackage{subfiles}\n" >> $@

	for file in $(PREAMBLES); do \
		printf "\\\usepackage{../$$file}\n" | sed s/.sty// >> $@; \
	done

	printf "\n" >> $@
	printf "\\\begin{document}\n" >> $@
	printf "\\\tableofcontents\n\n" >> $@

	for file in $(TEX_FILES); do \
		printf "\\\subfile{../$$file}\n" | sed s/.tex// >> $@; \
	done

	printf "\n\\\end{document}\n" >> $@

# Rule to build the main PDF.
$(MAIN_DIR)/$(MAIN_PDF_FILE): $(MAIN_DIR)/$(MAIN_TEX_FILE)
	cd $(MAIN_DIR); \
	$(LATEX) $(LATEX_FLAGS) $(shell basename $<)

# Open the main PDF.
view: $(MAIN_DIR)/$(MAIN_PDF_FILE)
	$(VIEWER) $(MAIN_DIR)/$(MAIN_PDF_FILE)

# Generate the directory for the current day.
today: $(TODAY_NAME)

$(TODAY_NAME):
	mkdir $(TODAY_NAME)
	cp template/Makefile $(TODAY_NAME)/Makefile
	cp template/template.tex $(TODAY_NAME)/$(TODAY_NAME).tex
	sed -i '' 's|MAIN_TEX_FILE|$(MAIN_TEX_FILE)|g' $(TODAY_NAME)/$(TODAY_NAME).tex
	sed -i '' 's|MAIN_DIR|$(MAIN_DIR)|g' $(TODAY_NAME)/$(TODAY_NAME).tex

# Rule for PDF file generation.
%.pdf: %.tex $(PREAMBLES)
	$(LATEX) $(LATEX_FLAGS) $<

# Run latexmk's clean.
clean:
	cd $(MAIN_DIR); \
	latexmk -c

.PHONY: clean today view individuals
