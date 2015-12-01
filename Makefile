SHELL := /bin/sh

SRC := $(wildcard *.tex)
PDF := $(SRC:.tex=.pdf)

ifeq ($(OS),Windows_NT)
	pdflatexflags := "-aux-directory=.build"
else
	pdflatexflags := -output-directory=.build
endif

all:
	-mkdir .build
	-rm $(PDF)
	for t in $(SRC) ; do \
		pdflatex -shell-escape $(pdflatexflags) $$t ; \
	done
	make links

clean:
	-rm $(PDF)
	-rm -rf .build/*

links:
	-rm $(PDF)
	ln -s .build/*.pdf .

