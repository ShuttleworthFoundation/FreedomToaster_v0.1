<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version='1.0'>

<!-- This XSL-FO stylesheet customization is for articles that
     use section elements.  It formats in two columns, with the
     titlepage information centered and spanned on the first page.
     It supports pgwide in figure and table to produce wide tables
     and figures that span both columns.                         
-->

<!--<xsl:import href="../docbook-xsl-1.66.1/fo/docbook.xsl"/>-->

<xsl:output indent="yes"/>

<!--<xsl:param name="column.count.body">2</xsl:param>-->
<xsl:param name="title.margin.left">0pt</xsl:param>
<!--<xsl:param name="generate.toc">
article nop
</xsl:param>-->

<xsl:param name="page.column.spans">1</xsl:param>
<xsl:param name="section.level.pagebreak">0</xsl:param>
<xsl:param name="section.level.columnbreak">0</xsl:param>
<xsl:param name="component.title.column.span">1</xsl:param>

<xsl:attribute-set name="figure.properties">
  <xsl:attribute name="padding-top">1em</xsl:attribute>
  <xsl:attribute name="padding-bottom">1em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="table.properties">
  <xsl:attribute name="padding-top">1em</xsl:attribute>
  <xsl:attribute name="padding-bottom">1em</xsl:attribute>
</xsl:attribute-set>

<xsl:template match="section">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="renderas">
    <xsl:choose>
      <xsl:when test="@renderas = 'sect1'">1</xsl:when>
      <xsl:when test="@renderas = 'sect2'">2</xsl:when>
      <xsl:when test="@renderas = 'sect3'">3</xsl:when>
      <xsl:when test="@renderas = 'sect4'">4</xsl:when>
      <xsl:when test="@renderas = 'sect5'">5</xsl:when>
      <xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="level">
    <xsl:choose>
      <xsl:when test="$renderas != ''">
        <xsl:value-of select="$renderas"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="section.level"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="wrapper.elem">
    <xsl:choose>
      <xsl:when test="$page.column.spans != 0">
        <xsl:text>fo:wrapper</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>fo:block</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$level &lt;= $section.level.pagebreak">
      <fo:block break-before="page"/>
    </xsl:when>
    <xsl:when test="$level &lt;= $section.level.columnbreak">
      <fo:block break-before="column"/>
    </xsl:when>
  </xsl:choose>

  <!-- xsl:use-attribute-sets takes only a Qname, not a variable -->
  <xsl:choose>
    <xsl:when test="$level = 1">
      <xsl:element name="{$wrapper.elem}"
                use-attribute-sets="section.level1.properties">
        <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
        <xsl:call-template name="section.content"/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="$level = 2">
      <xsl:element name="{$wrapper.elem}"
                use-attribute-sets="section.level2.properties">
        <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
        <xsl:call-template name="section.content"/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="$level = 3">
      <fo:wrapper id="{$id}"
                xsl:use-attribute-sets="section.level3.properties">
        <xsl:call-template name="section.content"/>
      </fo:wrapper>
    </xsl:when>
    <xsl:when test="$level = 4">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="section.level4.properties">
        <xsl:call-template name="section.content"/>
      </fo:block>
    </xsl:when>
    <xsl:when test="$level = 5">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="section.level5.properties">
        <xsl:call-template name="section.content"/>
      </fo:block>
    </xsl:when>
    <xsl:otherwise>
      <fo:block id="{$id}"
                xsl:use-attribute-sets="section.level6.properties">
        <xsl:call-template name="section.content"/>
      </fo:block>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="section.content">
  <xsl:call-template name="section.titlepage"/>

  <xsl:variable name="toc.params">
    <xsl:call-template name="find.path.params">
      <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="contains($toc.params, 'toc')
                and (count(ancestor::section)+1) &lt;= $generate.section.toc.level">
    <xsl:call-template name="section.toc">
      <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
    </xsl:call-template>
   <xsl:call-template name="section.toc.separator"/>
  </xsl:if>

  <xsl:apply-templates/>
</xsl:template>

<xsl:template name="formal.object">
  <xsl:param name="placement" select="'before'"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="content">
    <xsl:if test="$placement = 'before'">
      <xsl:call-template name="formal.object.heading">
        <xsl:with-param name="placement" select="$placement"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="$placement != 'before'">
      <xsl:call-template name="formal.object.heading">
        <xsl:with-param name="placement" select="$placement"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="keep.together">
    <xsl:call-template name="dbfo-attribute">
      <xsl:with-param name="pis"
                      select="processing-instruction('dbfo')"/>
      <xsl:with-param name="attribute" select="'keep-together'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="self::figure">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="figure.properties">
	<xsl:if test="$keep.together != ''">
	  <xsl:attribute name="keep-together.within-column"><xsl:value-of
	                  select="$keep.together"/></xsl:attribute>
	</xsl:if>
	<xsl:if test="@pgwide = 1">
	  <xsl:attribute name="span">all</xsl:attribute>
	</xsl:if>

        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:when>
    <xsl:when test="self::example">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="example.properties">
	<xsl:if test="$keep.together != ''">
	  <xsl:attribute name="keep-together.within-column"><xsl:value-of
	                  select="$keep.together"/></xsl:attribute>
	</xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:when>
    <xsl:when test="self::equation">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="equation.properties">
	<xsl:if test="$keep.together != ''">
	  <xsl:attribute name="keep-together.within-column"><xsl:value-of
	                  select="$keep.together"/></xsl:attribute>
	</xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:when>
    <xsl:when test="self::table">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="table.properties">
	<xsl:if test="$keep.together != ''">
	  <xsl:attribute name="keep-together.within-column"><xsl:value-of
	                  select="$keep.together"/></xsl:attribute>
	</xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:when>
  <xsl:when test="self::informaltable">
  	<fo:block id="{$id}"
  		xsl:use-attribute-sets="table.properties">
  		<xsl:if test="$keep.together != ''">
  			<xsl:attribute name="keep-together.within-column"><xsl:value-of
  				select="$keep.together"/></xsl:attribute>
  		</xsl:if>
  		<xsl:copy-of select="$content"/>
  	</fo:block>
  </xsl:when>
    <xsl:when test="self::procedure">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="procedure.properties">
	<xsl:if test="$keep.together != ''">
	  <xsl:attribute name="keep-together.within-column"><xsl:value-of
	                  select="$keep.together"/></xsl:attribute>
	</xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:when>
    <xsl:otherwise>
      <fo:block id="{$id}"
                xsl:use-attribute-sets="formal.object.properties">
	<xsl:if test="$keep.together != ''">
	  <xsl:attribute name="keep-together.within-column"><xsl:value-of
	                  select="$keep.together"/></xsl:attribute>
	</xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- enable span of titlepage stuff -->
<xsl:template match="article">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="master-reference">
    <xsl:call-template name="select.pagemaster"/>
  </xsl:variable>

  <fo:page-sequence hyphenate="{$hyphenate}"
                    master-reference="{$master-reference}">
    <xsl:attribute name="language">
      <xsl:call-template name="l10n.language"/>
    </xsl:attribute>
    <xsl:attribute name="format">
      <xsl:call-template name="page.number.format">
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="initial-page-number">
      <xsl:call-template name="initial.page.number">
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:attribute name="force-page-count">
      <xsl:call-template name="force.page.count">
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:attribute name="hyphenation-character">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-character'"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="hyphenation-push-character-count">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-push-character-count'"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="hyphenation-remain-character-count">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-remain-character-count'"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:apply-templates select="." mode="running.head.mode">
      <xsl:with-param name="master-reference" select="$master-reference"/>
    </xsl:apply-templates>

    <xsl:apply-templates select="." mode="running.foot.mode">
      <xsl:with-param name="master-reference" select="$master-reference"/>
    </xsl:apply-templates>

    <fo:flow flow-name="xsl-region-body">
      <fo:block id="{$id}">
        <xsl:if test="$component.title.column.span != 0">
	  <xsl:attribute name="span">all</xsl:attribute>
	</xsl:if>
        <xsl:call-template name="article.titlepage"/>
      </fo:block>

      <xsl:variable name="toc.params">
        <xsl:call-template name="find.path.params">
          <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:if test="contains($toc.params, 'toc')">
        <xsl:call-template name="component.toc"/>
        <xsl:call-template name="component.toc.separator"/>
      </xsl:if>
      <xsl:apply-templates/>
    </fo:flow>
  </fo:page-sequence>
</xsl:template>

<xsl:template match="abstract" mode="titlepage.mode">
  <fo:block>
    <xsl:attribute name="space-after">3em</xsl:attribute>
    <xsl:if test="title"> <!-- FIXME: add param for using default title? -->
      <xsl:call-template name="formal.object.heading"/>
    </xsl:if>
    <xsl:apply-templates mode="titlepage.mode"/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
