BASE = Zavitan_Final_Report

DEST_DIR = $(BASE)

XML_SOURCES = zavitan.xml userman.xml arch.xml

all: $(DEST_DIR)/index.html $(DEST_DIR)/book.css

html: $(BASE).zip

$(DEST_DIR)/index.html: $(XML_SOURCES)
	xmlto html -o $(BASE) -m glossterm.xsl -m ./filename.xsl -m  ./admon.xsl \
		-m ./css.xsl  \
		./zavitan.xml

$(DEST_DIR)/book.css : book.css
	cp -f $< $@

$(BASE).zip: $(DEST_DIR)/index.html
	rm -f $@
	zip -r $@ $(DEST_DIR)

#fcs-book.pdf: $(XML_SOURCES)
#	xmlto pdf -v --extensions -m glossterm.xsl $<

zavitan.pdf: $(XML_SOURCES)
	db2pdf $<
