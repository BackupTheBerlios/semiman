
HOSTNAME = $(shell hostname)

ifeq ($(HOSTNAME),vipe.technion.ac.il)
	VIPE = 1
endif

ifdef BERLIOS
	ifdef VIPE
		D = $(HOME)/progs/fcs/berlios-site
	else
		D = /var/www/html/seminars-static-berlios
	endif
	WML_FLAGS = -DBERLIOS=BERLIOS
else
	ifdef VIPE
		D = $(HOME)/public_html/freecell-solver/
	else
		D = /var/www/html/seminars-static
	endif
	WML_FLAGS = 
endif
#D = /home/httpd/html/ip-noise

#IMAGES_PRE1 = $(shell cd src && (ls *.tar.gz *.zip *.patch *.css *.png))
#IMAGES = $(addprefix $(D)/,$(IMAGES_PRE1))
IMAGES = $(addprefix $(D)/,style.css)

# WML_FLAGS = -DBERLIOS=BERLIOS

WML_FLAGS += --passoption=2,-X

HTMLS = $(D)/index.html $(D)/links.html $(D)/don_woods.html $(D)/features.html $(D)/old-news.html $(D)/book.html $(D)/docs/index.html $(D)/download/index.html $(D)/berlios/index.html

ARC_DOCS = 

INCLUDES_PROTO = std/logo.wml
INCLUDES = $(addprefix src/,$(INCLUDES_PROTO))

SUBDIRS = $(D)/docs $(D)/download $(D)/berlios

IMAGES += $(addprefix $(D)/docs/,spec.txt site_org.txt requirements.txt)

all : $(SUBDIRS) $(HTMLS) $(IMAGES) $(RAW_SUBDIRS) $(ARC_DOCS)

$(SUBDIRS) :: % : 
	@if [ ! -e $@ ] ; then \
		mkdir $@ ; \
	fi

$(HTMLS) :: $(D)/% : src/%.wml src/.wmlrc template.wml $(INCLUDES)
	cd src && wml $(WML_FLAGS) -DFILENAME="$(notdir $@)" $(patsubst src/%,%,$<) > $@

$(IMAGES) :: $(D)/% : src/%
	cp -f $< $@

$(RAW_SUBDIRS) :: $(D)/% : src/%
	rm -fr $@
	cp -r $< $@
