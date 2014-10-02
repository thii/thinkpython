LATEX = latex

DVIPS = dvips

PDFFLAGS = -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress \
           -dCompressPages=true -dUseFlateCompression=true  \
           -dEmbedAllFonts=true -dSubsetFonts=true -dMaxSubsetPct=100


%.dvi: %.tex
	$(LATEX) $<

%.ps: %.dvi
	$(DVIPS) -o $@ $<

%.pdf: %.ps
	ps2pdf $(PDFFLAGS) $<

%.html:
	touch $@

all:	book.tex
	makeindex book
	pdflatex book
	mv book.pdf thinkpython.pdf
	evince thinkpython.pdf

hevea:	book.tex header.html footer.html
	# replace the pdfs with eps
	sed s/.pdf/.eps/g book.tex > thinkpython.tex
	latex thinkpython
	rm -rf html
	mkdir html
	hevea -fix -O -e latexonly htmlonly thinkpython
# the following greps are a kludge to prevent imagen from seeing
# the definitions in latexonly, and to avoid headers on the images
	grep -v latexonly thinkpython.image.tex > a; mv a thinkpython.image.tex
	sed s/\\\\usepackage{fancyhdr}//g thinkpython.image.tex > a; mv a thinkpython.image.tex
	imagen -png thinkpython
	hacha thinkpython.html
	cp up.png next.png back.png html
	mv index.html thinkpython.css thinkpython*.html thinkpython*.png *motif.gif html

DEST = /home/downey/public_html/greent/thinkpython

epub:	hevea
	ebook-convert html/index.html thinkpython.epub --author-sort=Downey --authors="Allen B. Downey" --book-producer="Green Tea Press" --cover=cover.png --title="Think Python" --title-sort="Think Python" --language=en --publisher="Green Tea Press" --pubdate=2014-06

mobi:	hevea
	ebook-convert html/index.html thinkpython.mobi --author-sort=Downey --authors="Allen B. Downey" --book-producer="Green Tea Press" --cover=cover.png --title="Think Python" --title-sort="Think Python" --language=en --publisher="Green Tea Press" --pubdate=2014-06

distrib:
	rm -rf dist
	mkdir dist dist/tex dist/tex/figs
	rsync -a thinkpython.pdf html dist
	rsync -a Makefile book.tex latexonly htmlonly dist/tex
	rsync -a figs/*.fig figs/*.pdf dist/tex/figs
	cd dist; zip -r thinkpython.tex.zip tex
	cd dist; zip -r thinkpython.html.zip html
	rsync -a dist/* $(DEST)
	chmod -R o+r $(DEST)/*
	cd $(DEST)/..; sh back

plastex:
	# Before running plastex, we need the current directory in PYTHONPATH
	# export PYTHONPATH=$PYTHONPATH:.
	python Filist.py book.tex > book.plastex
	rm -rf /home/downey/thinkpython/trunk/book
	plastex --renderer=DocBook --theme=book --image-resolution=300 --filename=book.xml book.plastex
	rm -rf /home/downey/thinkpython/trunk/book/.svn

plastest:
	# Before running plastex, we need the current directory in PYTHONPATH
	# export PYTHONPATH=$PYTHONPATH:.
	python Filist.py test.tex > test.plastex
	rm -rf /home/downey/thinkpython/trunk/test
	plastex --renderer=DocBook --theme=test --filename=test.xml test.plastex
	rm -rf /home/downey/thinkpython/trunk/test/.svn

xxe:
	~/Downloads/xxe-perso-4_8_0/bin/xxe book/book.xml

OREILLY = /home/downey/oreilly/thinkpython

oreilly:
	rsync -a book.tex $(OREILLY)
	rsync -a book/ $(OREILLY)
	rsync -a figs/* $(OREILLY)/figs
	rsync -a thinkpython.pdf $(OREILLY)/pdf

clean:
	rm -f *~ *.aux *.log *.dvi *.idx *.ilg *.ind *.toc



