<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
    <!-- =============== -->
    <!-- WE DONT USE THIS YET -->
    <!-- =============== -->
	
	<!-- ======================= 
		
		usr/X11R6/lib/X11/fonts/truetype/verdana.ttf
		
		
		java org.apache.fop.fonts.apps.TTFReader -enc ansi /usr/X11R6/lib/X11/fonts/truetype/verdana.ttf verdana.xml
	-->
	
    
    <!-- This file is a customization layer for FO only -->
    <!-- ======================= -->
    <!-- Imports -->
    <xsl:import href="/usr/share/xml/docbook/stylesheet/nwalsh/fo/docbook.xsl"/>
    <xsl:include href="common-cust.xsl"/>
    <xsl:include href="fo.ft.titlepages.xsl"/>
    <!--<xsl:include href="customspan.xsl"/>-->
	
   <!-- ======================= -->
   <!-- Fonts -->
   <!-- ======================= -->
	<xsl:param name="body.font.family">Helvetica</xsl:param>
	<xsl:param name="body.font.master" select="'10'"/>
	<xsl:param name="title.font.family">Helvetica</xsl:param>
    
    <!-- ======================= -->
    <!-- Parameters -->
    <!-- ======================= -->
    <!--<xsl:param name="column.count.body" select="2"/>-->
    <xsl:param name="body.start.indent">0pt</xsl:param> 
    <xsl:param name="page.margin.inner" select="'2cm'"/> 
    <xsl:param name="page.margin.outer" select="'1cm'"/>
    <xsl:param name="fop.extensions" select="1"/>
    <xsl:param name="paper.type" select="'A4'"/>
    <xsl:param name="double.sided" select="0"/>
    <xsl:param name="header.rule" select="1"/>
    <xsl:param name="footer.rule" select="1"/>
    
    <xsl:param name="section.autolabel" select="'0'"/>
    
  <!-- Admon Graphics -->
    <xsl:param name="admon.graphics" select="1"/>
    <xsl:param name="admon.textlabel" select="0"/>
    <xsl:param name="admon.graphics.path" select="'../images/admon/'"/>
    <xsl:param name="admon.graphics.extension" select="'.png'"/>
    
    <!-- Callout Graphics -->
    <xsl:param name="callout.unicode" select="1"/>
    <xsl:param name="callout.graphics" select="0"/>
    <xsl:param name="callout.graphics.path" select="'../images/callouts/'"/>
    <xsl:param name="callout.graphics.extension" select="'.png'"/>
  
    <!-- ======================= -->
    <!-- Attribute Sets -->
    <!-- ======================= -->
    
	
	

    <!-- Page Break -->
    <!--<xsl:attribute-set name="section.level1.properties">
      <xsl:attribute name="break-before">page</xsl:attribute>
    </xsl:attribute-set>-->
    
    
    
    <!-- ======================= -->
    <!-- Templates -->
    <!-- ======================= -->
    <!-- Lists -->
    <xsl:attribute-set name="list.item.spacing">
        <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="list.block.spacing">
        <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>
    </xsl:attribute-set>
   
    <!-- Header Design Formatting-->
    <xsl:attribute-set name="header.content.properties">
	    <xsl:attribute name="font-family">Helvetica</xsl:attribute>
	    <xsl:attribute name="font-size">8pt</xsl:attribute>
    </xsl:attribute-set>
	<!--<xsl:param name="header.column.widths">1 1 2</xsl:param>
    <xsl:param name="footer.column.widths">1 2 1</xsl:param>
	
	<xsl:param name="page.margin.top">0.5cm</xsl:param>
	<xsl:param name="region.before.extent">3.5cm</xsl:param>

	<xsl:param name="body.margin.top">4.5cm</xsl:param>
	<xsl:param name="body.margin.bottom">3cm</xsl:param>
	
	<xsl:param name="region.after.extent">2.5cm</xsl:param>
	<xsl:param name="page.margin.bottom">0.5cm</xsl:param>-->
	
    <!-- Running Header/Footer -->
	<xsl:template name="header.content">  
		<xsl:param name="pageclass" select="''"/>
		<xsl:param name="sequence" select="''"/>
		<xsl:param name="position" select="''"/>
		<xsl:param name="gentext-key" select="''"/>
		
		
		
		<xsl:variable name="candidate">
			<!-- sequence can be odd, even, first, blank -->
			<!-- position can be left, center, right -->
			<xsl:choose>
				
				<xsl:when test="$sequence = 'odd' and $position = 'left'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'odd' and $position = 'center'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'odd' and $position = 'right'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'even' and $position = 'left'">  
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'even' and $position = 'center'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'even' and $position = 'right'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'first' and $position = 'left'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'first' and $position = 'right'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'first' and $position = 'center'"> 
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'blank' and $position = 'left'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'blank' and $position = 'center'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'blank' and $position = 'right'">
				</xsl:when>
				
			</xsl:choose>
		</xsl:variable>
		
		<!-- Does runtime parameter turn off blank page headers? -->
		<xsl:choose>
			<xsl:when test="$sequence='blank' and $headers.on.blank.pages=0">
				<!-- no output -->
			</xsl:when>
			<!-- titlepages have no headers -->
			<xsl:when test="$pageclass = 'titlepage'">  
				<!-- no output -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$candidate"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	<xsl:template name="footer.content">
		<xsl:param name="pageclass" select="''"/>
		<xsl:param name="sequence" select="''"/>
		<xsl:param name="position" select="''"/>
		<xsl:param name="gentext-key" select="''"/>
		
		
		<xsl:variable name="candidate">
			<!-- sequence can be odd, even, first, blank -->
			<!-- position can be left, center, right -->
			<xsl:choose>
				
				<xsl:when test="$sequence = 'odd' and $position = 'left'">
					<fo:page-number/>
				</xsl:when>
				
				<xsl:when test="$sequence = 'odd' and $position = 'center'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'odd' and $position = 'right'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'even' and $position = 'left'">  
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'even' and $position = 'center'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'even' and $position = 'right'">
					<fo:page-number/>
				</xsl:when>
				
				<xsl:when test="$sequence = 'first' and $position = 'left'">
				</xsl:when>
				
				<xsl:when test="$sequence = 'first' and $position = 'right'">
					<fo:page-number/>
				</xsl:when>
				
				<xsl:when test="$sequence = 'first' and $position = 'center'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'blank' and $position = 'left'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'blank' and $position = 'center'">
					
				</xsl:when>
				
				<xsl:when test="$sequence = 'blank' and $position = 'right'">
					
				</xsl:when>
				
			</xsl:choose>
		</xsl:variable>
		
		<!-- Does runtime parameter turn off blank page headers? -->
		<xsl:choose>
			<xsl:when test="$sequence='blank' and $headers.on.blank.pages=0">
				<!-- no output -->
			</xsl:when>
			<!-- titlepages have no headers -->
			<xsl:when test="$pageclass = 'titlepage'">  
				<!-- no output -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$candidate"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="head.sep.rule">
		<xsl:if test="$header.rule != 0">
			<xsl:attribute name="border-bottom-width">1pt</xsl:attribute>
			<xsl:attribute name="border-bottom-style">solid</xsl:attribute>
			<xsl:attribute name="border-bottom-color">#FF9933</xsl:attribute>
		</xsl:if>
		</xsl:template>
	
	<xsl:template name="foot.sep.rule">
		<xsl:if test="$footer.rule != 0">
			<xsl:attribute name="border-top-width">1pt</xsl:attribute>
			<xsl:attribute name="border-top-style">solid</xsl:attribute>
			<xsl:attribute name="border-top-color">#FF9933</xsl:attribute>
		</xsl:if>
	</xsl:template>
    
	    <!-- Page Break use &lt?pagebreak?;&gt; to insert a page break -->
	    <xsl:template match="processing-instruction('pagebreak')">
	        <fo:block break-after="page"/>
	    </xsl:template>
	<!-- Page Break use &lt?colbreak?;&gt; to insert a collumn break -->
	<xsl:template match="processing-instruction('colbreak')">
		<fo:block break-after="column"/>
	</xsl:template>
</xsl:stylesheet>
