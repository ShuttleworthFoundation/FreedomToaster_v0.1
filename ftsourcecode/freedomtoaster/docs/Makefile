# To be able to build correctly the Freedom Toaster documentation, you'll need the
# following software
#
# inkscape :     is used to convert from .svg graphics to .png images
# java :            used for xslt transformation and pdf generation. The JAVA_HOME env should be set
#                      along with the CLASSPATH containing link to saxon.jar and saxon653.jar
#                      http://saxon.sourceforge.net/
# fop 0.20.5 :   tool to generate pdf from .fo file - http://xmlgraphics.apache.org/fop/
# docbook-xsl : stylesheets for processing DocBook XML files
# 
# For translation purpose, you'll need:
# xml2pot : from poxml KDE package
# xml2po : from gnome-doc-utils package, used to extract strings from .svg graphics
#
# When you want to build doc for a particular language, add the LNG=langcode to the make command
# Ex: make im LNG=de / make all LNG=fr

MAKECMD=make

ifndef "HTMLXSL"
HTMLXSL=libs/html-cust.xsl
endif

ifndef "HTMLCHUNKXSL"
HTMLCHUNKXSL=libs/html-chunk-cust.xsl
endif

ifndef "FOXSL"
FOXSL= libs/fo-cust.xsl
endif

PNG_IMAGES=$(shell ls images/*.svg | sed 's/svg/png/')
DATE=`date +%Y%m%d`
DAY = $(shell date "+%F")
HOUR = $(shell date "+%R%z")

ifndef LNG
TRANSLATE_COMMONS= # empty string
LNG_EXT= # empty string
PO2XMLCMD=@: # null command
XML2POCMD=@: # null command
else
TRANSLATE_COMMONS=translate-commons
LNG_EXT=-$(LNG)
PO2XMLCMD=po2xml
XML2POCMD=xml2po
endif

SEDCMD=sed -e  '4s/..\/common/..\/build\/common/' -e '7s/<book>/<book lang="$(LNG)">/'

all: am im mm cm um

am:	getimages $(TRANSLATE_COMMONS)
	mkdir -p build/assembly

	$(PO2XMLCMD) assembly/assemblymanual.xml assembly/po/$(LNG).po | $(SEDCMD) > assembly/assemblymanual-$(LNG).xml

	xmllint --xinclude --noent assembly/assemblymanual$(LNG_EXT).xml > build/assembly/temp.xml

	java com.icl.saxon.StyleSheet -o build/assembly/temp.fo build/assembly/temp.xml $(FOXSL)

	fop -c libs/userconfig.xml -fo build/assembly/temp.fo -pdf build/assembly/assemblymanual$(LNG_EXT).pdf

	rm build/assembly/temp.*
	rm assembly/assemblymanual-*.xml

im:	getimages $(TRANSLATE_COMMONS)
	mkdir -p build/installation

	$(PO2XMLCMD) installation/installation.xml installation/po/$(LNG).po | $(SEDCMD) > installation/installation-$(LNG).xml

	xmllint --xinclude --noent installation/installation$(LNG_EXT).xml > build/installation/temp.xml

	java -Xmx256M com.icl.saxon.StyleSheet -o build/installation/temp.fo build/installation/temp.xml $(FOXSL)

	fop -c libs/userconfig.xml -fo build/installation/temp.fo -pdf build/installation/installation$(LNG_EXT).pdf

	rm build/installation/temp.*
	rm installation/installation-*.xml

mm:	getimages $(TRANSLATE_COMMONS)
	mkdir -p build/maintenance

	$(PO2XMLCMD) maintenance/maintenancemanual.xml maintenance/po/$(LNG).po | $(SEDCMD) > maintenance/maintenancemanual-$(LNG).xml

	xmllint --xinclude --noent maintenance/maintenancemanual$(LNG_EXT).xml > build/maintenance/temp.xml

	java -Xmx256M com.icl.saxon.StyleSheet -o build/maintenance/temp.fo build/maintenance/temp.xml $(FOXSL)

	fop -c libs/userconfig.xml -fo build/maintenance/temp.fo -pdf build/maintenance/maintenancemanual$(LNG_EXT).pdf

	rm build/maintenance/temp.*
	rm maintenance/maintenancemanual-*.xml
	
cm:	getimages $(TRANSLATE_COMMONS)
	mkdir -p build/customization

	$(PO2XMLCMD) customization/customizationmanual.xml customization/po/$(LNG).po | $(SEDCMD) > customization/customizationmanual-$(LNG).xml

	xmllint --xinclude --noent customization/customizationmanual$(LNG_EXT).xml > build/customization/temp.xml

	java -Xmx256M com.icl.saxon.StyleSheet -o build/customization/temp.fo build/customization/temp.xml $(FOXSL)

	fop -c libs/userconfig.xml -fo build/customization/temp.fo -pdf build/customization/customizationmanual$(LNG_EXT).pdf

	rm build/customization/temp.*
	rm customization/customizationmanual-*.xml

um:	getimages $(TRANSLATE_COMMONS)
	mkdir -p build/user

	$(PO2XMLCMD) user/usermanual.xml user/po/$(LNG).po | $(SEDCMD) > user/usermanual-$(LNG).xml

	xmllint --xinclude --noent user/usermanual$(LNG_EXT).xml > build/user/temp.xml

	java -Xmx256M com.icl.saxon.StyleSheet -o build/user/temp.fo build/user/temp.xml $(FOXSL)

	fop -c libs/userconfig.xml -fo build/user/temp.fo -pdf build/user/usermanual$(LNG_EXT).pdf

	rm build/user/temp.*
	rm user/usermanual-*.xml

%.png : %.svg
	$(XML2POCMD) -p images/po/$(LNG).po -o $*$(LNG_EXT).svg $<
	inkscape --file=$*$(LNG_EXT).svg -D -e $@

.PHONY: images
images: $(PNG_IMAGES)
	rm -f images/*-??.svg

getimages: images
	mkdir -p build/images
	cp -r images/*.png build/images/
	cp -r images/*.gif build/images/

	mkdir -p build/images/admon
	cp -r images/admon/*.png build/images/admon/

	mkdir -p build/images/callouts
	cp -r images/callouts/*.png build/images/callouts/

	mkdir -p build/images/navig
	cp -r images/navig/*.gif build/images/navig/

translate-commons:
	mkdir -p build/common
	for f in common/*.xml ;	 do \
		po2xml $$f common/po/$(LNG).po > build/common/`basename $$f`; \
	done

	cp common/global.ent build/common/global.ent
	
%.pot : %.xml 
	xml2pot $< | sed 's/^"POT-Creation.*$$/"POT-Creation-Date: $(DAY) $(HOUR)\\n"/' > $@

pot: assembly/assemblymanual.pot installation/installation.pot maintenance/maintenancemanual.pot customization/customizationmanual.pot user/usermanual.pot common.pot images.pot

common.pot: 
	for i in common/*.xml; do \
		xml2pot $$i > common/`basename $$i .xml`.po; \
	done
	msgcat common/*.po | sed 's/^"POT-Creation.*$$/"POT-Creation-Date: $(DAY) $(HOUR)\\n"/' > common/common.temp.pot
	rm -f common/*.po
	if cmp common/common.temp.pot common/common.pot >/dev/null 2>&1; then \
		rm -f common/common.temp.pot; \
	else \
		mv -f common/common.temp.pot common/common.pot; \
	fi

images.pot:
	for i in images/*.svg; do \
		xml2po -o images/`basename $$i .svg`.po $$i; \
	done
	msgcat images/*.po > images/images.temp.pot
	rm -f images/*.po
	if cmp images/images.temp.pot images/images.pot >/dev/null 2>&1; then \
		rm -f images/images.temp.pot; \
	else \
		mv -f images/images.temp.pot images/images.pot; \
	fi

clean:
	rm -rf build/common
	rm -rf build/images
	rm -f images/*.png
