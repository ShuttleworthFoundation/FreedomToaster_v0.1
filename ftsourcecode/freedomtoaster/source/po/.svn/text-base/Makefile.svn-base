# For translation purpose (pot target), you need:
#   xml2po : from gnome-doc-utils package
#   inkscape : for SVG to PNG conversion

MAKECMD=make
XML2POCMD=./xml2po/xml2po.py

HTMLDIR = ../kiosk/locale
PERLDIR = ../kiosk/cgi-bin
IMAGESDIR = ../image-factory
ISODIR = ../isos
LANGS := $(shell sed -e "/^\#/d" ./LINGUAS)
PNG_IMAGES=$(shell cd  $(IMAGESDIR); ls *.svg | sed 's/svg/png/')
PNG_STATIC_IMAGES=$(HTMLDIR)/$(MAKECMDGOALS)/images/logoHelp.png $(HTMLDIR)/$(MAKECMDGOALS)/images/logoPage.png
HTML_LOCALE_FILES=$(shell ls $(HTMLDIR)/en/*.html | sed 's/\/en\//\/$(MAKECMDGOALS)\//')
HTML_LOCALE_HELP_FILES=$(shell ls $(HTMLDIR)/en/help/*.html | sed 's/\/en\//\/$(MAKECMDGOALS)\//')
XML_SAYINGS_FILES=$(shell ls $(HTMLDIR)/en/sayings/*.xml | sed 's/\/en\//\/$(MAKECMDGOALS)\//')
XML_ISO_FILES=$(shell ls ../isos/*/*.xml | grep -v ".*\-[a-z][a-z].xml$$" | sed 's/\.xml/-fr\.xml/g')

MO_FILE=../kiosk/locale/$(MAKECMDGOALS)/LC_MESSAGES/freedomtoaster.mo
VPATH = $(IMAGESDIR):$(HTMLDIR)/$(MAKECMDGOALS)/images

# This target generate a pot file from sources (XHTML, Perl, SVG)
pot: 
	mkdir tmp
	for i in $(HTMLDIR)/en/*.html; do \
		$(XML2POCMD) -m xhtml -a -o tmp/`basename $$i .html`.pot $$i; \
	done
	for i in $(HTMLDIR)/en/help/*.html; do \
		$(XML2POCMD) -m xhtml -a -o tmp/`basename $$i .html`.pot $$i; \
	done
	for i in $(HTMLDIR)/en/sayings/*.xml; do \
		$(XML2POCMD) -a -o tmp/`basename $$i .xml`.pot $$i; \
	done
	for i in $(ISODIR)/*/*.xml; do \
		filename=`basename $$i .xml`; \
		if [ -z "`echo $$filename | grep ".*\-[a-z][a-z]$$"`" ]; then \
			$(XML2POCMD) -a -o tmp/w$$filename.pot $$i; \
		fi; \
	done
	for i in $(PERLDIR)/*.pl; do \
		xgettext --omit-header -o tmp/x`basename $$i`.pot $$i; \
	done
	for i in $(IMAGESDIR)/*.svg; do \
		$(XML2POCMD) -a -o tmp/y`basename $$i`.pot $$i; \
	done
# Merging all pot files
	msgcat tmp/*.pot > tmp/ft.temp.pot
# Compare without headers, unless the files are always different (creation date)
	@if ! cmp --ignore-initial=`head -n 10 freedomtoaster.pot | wc -c` tmp/ft.temp.pot freedomtoaster.pot >/dev/null 2>&1; then \
		mv -f tmp/ft.temp.pot freedomtoaster.pot; \
		echo "New pot has been generated. Please do 'make update-po' to update .po or upload pot to Rosetta"; \
	else \
		echo "No new strings. freedomtoaster.pot unchanged"; \
	fi
	rm -rf tmp
	
update-po:
	@echo "*** Updating PO ***"
	for lang in $(LANGS); do \
		msgmerge -o tmp.po $$lang.po freedomtoaster.pot; \
		if cmp tmp.po $$lang.po >/dev/null 2>&1; then \
			rm -f tmp.po; \
		else \
			mv -f tmp.po $$lang.po; \
		fi; \
	done

# All available languages
# Must recurse makefile, so as MAKECMDGOALS is each time the name of the language
translations: 
	for i in $(LANGS); do \
		$(MAKE) $$i; \
	done

# Images
%.png : %.svg
	if [ ! -d $(HTMLDIR)/$(MAKECMDGOALS)/images ]; then mkdir -p  $(HTMLDIR)/$(MAKECMDGOALS)/images; fi
	$(XML2POCMD) -a -p $(MAKECMDGOALS).po -o $(basename $<)-fr.svg $<
	inkscape --file=$(basename $<)-fr.svg -D -e $(HTMLDIR)/$(MAKECMDGOALS)/images/$@
	rm -rf $(basename $<)-fr.svg

$(PNG_STATIC_IMAGES):
	cp $(subst $(MAKECMDGOALS),en,$@) $@
	
../kiosk/locale/$(MAKECMDGOALS)/%.html : ../kiosk/locale/en/%.html
	if [ ! -d $(dir $@) ]; then mkdir -p  $(dir $@); fi
	$(XML2POCMD) -m xhtml -a -p $(MAKECMDGOALS).po $< > $@

../kiosk/locale/$(MAKECMDGOALS)/%.xml : ../kiosk/locale/en/%.xml
	if [ ! -d $(dir $@) ]; then mkdir -p  $(dir $@); fi
	$(XML2POCMD) -a -p $(MAKECMDGOALS).po $< > $@

../isos/%-$(MAKECMDGOALS).xml: ../isos/%.xml
	$(XML2POCMD) -a -p $(MAKECMDGOALS).po $< > $@

$(MO_FILE): $(MAKECMDGOALS).po
	if [ ! -d $(dir $@) ]; then mkdir -p  $(dir $@); fi
	msgfmt -o $@ $<
	
$(LANGS): $(PNG_IMAGES) $(PNG_STATIC_IMAGES) $(HTML_LOCALE_FILES) $(HTML_LOCALE_HELP_FILES) $(XML_SAYINGS_FILES) $(XML_ISO_FILES) $(MO_FILE)
	@echo "*** Translation of HTML, XML, PNG and MO files for language $@ ***"
