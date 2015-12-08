SHELL := /bin/bash

SRC := $(wildcard *.tex)
PDF := $(SRC:.tex=.pdf)
FIGURES := $(filter-out *-crop.pdf, $(shell find figures -name "*.pdf" -type f))
FIGURES += $(filter-out *-crop.pdf, $(shell find maps -name "*.pdf" -type f))
DTMS := $(wildcard data/DTEEC*.IMG)

.PHONY: all $(DTMS)

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

# Download all the DTM currently tracked in this repo
wget:
	cd data && wget -i datasets.txt

# Download the Golang dependencies
goget:
	go get "github.com/siravan/fits"

# Build the Golang program
dijkstra:
	cd dijkstra && go build

# Compute the traversability map for a DTM
$(DTMS):
	$(eval FITS := $(subst .IMG,.fits,$@))
	$(eval BIN := $(subst .IMG,.bin,$@))
	test -e $(FITS) || img2fits "$@"
	if [ ! -e $(BIN) ] ; then \
		make dijkstra && dijkstra/dijkstra $(FITS) ; \
	fi
	cd outputs ; matlab -nodesktop -nosplash -r "load_and_plot('$(FITS)');exit"
