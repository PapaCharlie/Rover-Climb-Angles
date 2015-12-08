SHELL := /bin/bash

SRC := $(wildcard *.tex)
PDF := $(SRC:.tex=.pdf)
FIGURES := $(filter-out *-crop.pdf, $(shell find figures -name "*.pdf" -type f))
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

$(DTMS):
	$(eval FITS := $(subst .IMG,.fits,$@))
	$(eval BIN := $(subst .IMG,.bin,$@))
	test -e $(FITS) || img2fits "$@"
	if [ test ! -e $(BIN) ] ; then \
		cd dijkstra && go build && cd .. && dijkstra/dijkstra $(FITS) ; \
	fi
	cd outputs ; matlab -nodesktop -nosplash -r "load_and_plot('$(FITS)')"
