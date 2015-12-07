SHELL := /bin/sh

SRC := $(wildcard *.tex)
PDF := $(SRC:.tex=.pdf)
FIGURES := $(filter-out $(wildcard figures/*-crop.pdf), $(wildcard figures/*.pdf))

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
	done

clean:
	-rm $(PDF)
	-rm -rf .build/*

links:
	-rm $(PDF)
	ln -s .build/*.pdf .



