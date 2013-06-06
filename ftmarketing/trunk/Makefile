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

DATE=`date +%Y%m%d`

all:	wp brochure usecase

wp: wpun wpgv wpngo

wpun:	getimages
	
	mkdir -p build/whitepaper

	xmllint --xinclude --noent whitepaper/UN-whitepaper.xml > build/whitepaper/temp.xml
	
	java com.icl.saxon.StyleSheet -o build/whitepaper/temp.fo build/whitepaper/temp.xml $(FOXSL)
	
	fop -c libs/userconfig.xml -fo build/whitepaper/temp.fo -pdf build/whitepaper/temp.pdf
	
	pdftk build/whitepaper/temp.pdf output build/whitepaper/UN-whitepaper.pdf background images/pg_0004.pdf
	
	rm build/whitepaper/temp.fo
	rm build/whitepaper/temp.xml
	rm build/whitepaper/temp.pdf

wpgv:	getimages
	
	mkdir -p build/whitepaper

	xmllint --xinclude --noent whitepaper/GOV-whitepaper.xml > build/whitepaper/temp.xml
	
	java com.icl.saxon.StyleSheet -o build/whitepaper/temp.fo build/whitepaper/temp.xml $(FOXSL)
	
	fop -c libs/userconfig.xml -fo build/whitepaper/temp.fo -pdf build/whitepaper/temp.pdf
	
	pdftk build/whitepaper/temp.pdf output build/whitepaper/GOV-whitepaper.pdf background images/pg_0004.pdf
	
	rm build/whitepaper/temp.fo
	rm build/whitepaper/temp.xml
	rm build/whitepaper/temp.pdf

wpngo:	getimages
	
	mkdir -p build/whitepaper

	xmllint --xinclude --noent whitepaper/NGO-whitepaper.xml > build/whitepaper/temp.xml
	
	java com.icl.saxon.StyleSheet -o build/whitepaper/temp.fo build/whitepaper/temp.xml $(FOXSL)
	
	fop -c libs/userconfig.xml -fo build/whitepaper/temp.fo -pdf build/whitepaper/temp.pdf
	
	pdftk build/whitepaper/temp.pdf output build/whitepaper/NGO-whitepaper.pdf background images/pg_0004.pdf
	
	rm build/whitepaper/temp.fo
	rm build/whitepaper/temp.xml
	rm build/whitepaper/temp.pdf
	
brochure:	getimages
	
	mkdir -p build/brochure

	xmllint --xinclude --noent brochure/brochure.xml > build/brochure/temp.xml
	
	java com.icl.saxon.StyleSheet -o build/brochure/temp.fo build/brochure/temp.xml $(FOXSL)
	
	fop -c libs/userconfig.xml -fo build/brochure/temp.fo -pdf build/brochure/temp.pdf
	
	pdftk build/brochure/temp.pdf output build/brochure/brochure.pdf background images/pg_0004.pdf
	
	rm build/brochure/temp.fo
	rm build/brochure/temp.xml
	rm build/brochure/temp.pdf

usecase:	getimages
	
	mkdir -p build/usecase

	xmllint --xinclude --noent casestudy/usecases.xml > build/usecase/temp.xml
	
	java com.icl.saxon.StyleSheet -o build/usecase/temp.fo build/usecase/temp.xml $(FOXSL)
	
	fop -c libs/userconfig.xml -fo build/usecase/temp.fo -pdf build/usecase/temp.pdf
	
	pdftk build/usecase/temp.pdf output build/usecase/usecases.pdf background images/pg_0004.pdf
	
	rm build/usecase/temp.fo
	rm build/usecase/temp.xml
	rm build/usecase/temp.pdf
	
casestudy:	csir mtn tshwane
	
csir:	getimages
	
	mkdir -p build/casestudy

	xmllint --xinclude --noent casestudy/casestudy-csir.xml > build/casestudy/temp.xml
	
	java com.icl.saxon.StyleSheet -o build/casestudy/temp.fo build/casestudy/temp.xml $(FOXSL)
	
	fop -c libs/userconfig.xml -fo build/casestudy/temp.fo -pdf build/casestudy/temp.pdf
	
	pdftk build/casestudy/temp.pdf output build/casestudy/csir.pdf background images/pg_0004.pdf
	
	rm build/casestudy/temp.fo
	rm build/casestudy/temp.xml
	rm build/casestudy/temp.pdf

mtn:	getimages
	
	mkdir -p build/casestudy

	xmllint --xinclude --noent casestudy/casestudy-science-center.xml > build/casestudy/temp.xml
	
	java com.icl.saxon.StyleSheet -o build/casestudy/temp.fo build/casestudy/temp.xml $(FOXSL)
	
	fop -c libs/userconfig.xml -fo build/casestudy/temp.fo -pdf build/casestudy/temp.pdf
	
	pdftk build/casestudy/temp.pdf output build/casestudy/science-center.pdf background images/pg_0004.pdf
	
	rm build/casestudy/temp.fo
	rm build/casestudy/temp.xml
	rm build/casestudy/temp.pdf

tshwane:	getimages
	
	mkdir -p build/casestudy

	xmllint --xinclude --noent casestudy/casestudy-tshwane-uni.xml > build/casestudy/temp.xml
	
	java com.icl.saxon.StyleSheet -o build/casestudy/temp.fo build/casestudy/temp.xml $(FOXSL)
	
	fop -c libs/userconfig.xml -fo build/casestudy/temp.fo -pdf build/casestudy/temp.pdf
	
	pdftk build/casestudy/temp.pdf output build/casestudy/tshwane-uni.pdf background images/pg_0004.pdf
	
	rm build/casestudy/temp.fo
	rm build/casestudy/temp.xml
	rm build/casestudy/temp.pdf

getimages:

	mkdir -p build/images
	cp images/*.* build/images
