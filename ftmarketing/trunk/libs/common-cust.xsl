<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <!-- This file is a common customization layer -->
    <!-- ======================= -->
    
    <!-- ======================= -->
    <!-- Parameters -->
    <!-- ======================= -->
    
    <!-- Extensions -->
     <xsl:param name="use.extensions" select="1"/>
    <xsl:param name="saxon.extensions" select="1"/>
    <xsl:param name="tablecolumns.extension" select="1"/>
    <xsl:param name="callouts.extensions" select="1"/> 
    
    <!-- General Formatting-->
    <xsl:param name="draft.mode" select="'no'"/>
  <!--<xsl:param name="variablelist.as.blocks" select="1"/> Use <?dbfo term-width=".75in"?> -->
    <xsl:param name="shade.verbatim" select="1"/>
    <xsl:param name="hyphenate">false</xsl:param>
    <xsl:param name="alignment">left</xsl:param>
    
    <!-- Cross References -->
    <xsl:param name="insert.xref.page.number" select="'yes'"/>
    <xsl:param name="xref.with.number.and.title" select="1"/>
    
    <!-- Indexes -->
    <xsl:param name="generate.index" select="0"/>
    
    <!-- Glossaries -->
    <xsl:param name="glossterm.auto.link" select="1"/>
    <xsl:param name="firstterm.only.link" select="1"/>
    <xsl:param name="glossary.collection">../common/glossary.xml</xsl:param>
    <xsl:param name="glossentry.show.acronym" select="'primary'"/>
    
    <!-- Bibliographies -->
    <xsl:param name="bibliography.collection">../common/biblio.xml</xsl:param>
    <xsl:param name="bibliography.numbered" select="1"/>
    
    <!-- Captions -->
  <xsl:param name="formal.procedures" select="0"/>
    <xsl:param name="formal.title.placement">
        figure before
        example before 
        equation before 
        table before 
        procedure before
    </xsl:param>
    <!-- TOC -->
  <xsl:param name="generate.toc">
    appendix  toc,title
    article/appendix  nop
    article   nop
    book      toc,title
    chapter   title
    part      toc,title
    preface   toc,title
    qandadiv  toc
    qandaset  toc
    reference toc,title
    set       toc,title
  </xsl:param>
    <!-- ======================= -->
    <!-- Templates -->
    <!-- ======================= -->
  <!-- Section level heading styles -->
  <xsl:attribute-set name="section.title.level1.properties">
    <xsl:attribute name="font-size">
      <xsl:value-of select="$body.font.master * 1.5"/>
      <xsl:text>pt</xsl:text>
    </xsl:attribute>
    <!--<xsl:attribute name="border-top">0.5pt solid gray</xsl:attribute>-->
    <xsl:attribute name="padding-top">15pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">10pt</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="section.title.level1.properties">
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="section.title.level2.properties">
    <xsl:attribute name="font-size">
      <xsl:value-of select="$body.font.master * 1.4"/>
      <xsl:text>pt</xsl:text>
    </xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="section.title.level3.properties">
    <xsl:attribute name="font-size">
      <xsl:value-of select="$body.font.master * 1.3"/>
      <xsl:text>pt</xsl:text>
    </xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="section.title.level4.properties">
    <xsl:attribute name="font-size">
      <xsl:value-of select="$body.font.master * 1.2"/>
      <xsl:text>pt</xsl:text>
    </xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="section.title.level5.properties">
    <xsl:attribute name="font-size">
      <xsl:value-of select="$body.font.master * 1.1"/>
      <xsl:text>pt</xsl:text>
    </xsl:attribute>
  </xsl:attribute-set>
	
    <!-- Inline Formatting -->
    <xsl:template match="guibutton">
        <xsl:call-template name="inline.boldseq"/>
    </xsl:template>
    <xsl:template match="filename">
        <xsl:call-template name="inline.boldmonoseq"/>
    </xsl:template>
    <xsl:template match="interface">
      <xsl:call-template name="inline.boldseq"/>
    </xsl:template>
    <xsl:template match="option">
      <xsl:call-template name="inline.boldseq"/>
    </xsl:template>
    <xsl:template match="guilabel">
      <xsl:call-template name="inline.boldseq"/>
    </xsl:template>
    <xsl:template match="keycap">
      <xsl:call-template name="inline.boldseq"/>
    </xsl:template>
    <xsl:template match="application">
      <xsl:call-template name="inline.boldseq"/>
    </xsl:template>
    
</xsl:stylesheet>
