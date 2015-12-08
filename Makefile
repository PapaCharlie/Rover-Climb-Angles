SHELL := /bin/bash

SRC := $(wildcard *.tex)
PDF := $(SRC:.tex=.pdf)
FIGURES := $(filter-out *-crop.pdf, $(shell find figures -name "*.pdf" -type f))

all:
	-mkdir .build
	-rm $(PDF)
	for t in $(SRC) ; do \
		pdflatex -shell-escape -output-directory=.build $$t ; \
	done
	make links

crop:
	for fig in $(FIGURES) ; do \
		pdfcrop $$fig ; \
		mv `echo $$fig | sed "s/.pdf/-crop.pdf/g"` $$fig ; \
	done

clean:
	-rm $(PDF)
	-rm -rf .build/*

links:
	-rm $(PDF)
	ln -s .build/*.pdf .

