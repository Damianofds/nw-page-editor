<?xml version="1.0"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15 http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15/pagecontent.xsd"
  xmlns="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15"
  exclude-result-prefixes="svg xlink"
  version="1.0">

  <xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="no"/>
  <xsl:strip-space elements="*"/>

  <!--<xsl:param name="pagens" select="document('')/*/@xmlns"/> tried this but not!-->
  <xsl:param name="pagens" select="'http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15'"/>
  <!--<xsl:param name="xsins" select="document('')/*/namespace::*[name()='xsi']"/>-->

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="svg:*">
    <xsl:element name="{local-name()}" namespace="{$pagens}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="svg:svg">
    <xsl:element name="PcGts" namespace="{$pagens}">
      <!--<xsl:copy-of select="$xsins"/>-->
      <xsl:copy-of select="document('')/*/namespace::*[name()='xsi']"/>

      <!--<xsl:copy-of select="document('')/@*[local-name()='schemaLocation']"/>-->
      <!--<xsl:copy-of select="document('')/*/@xsi:schemaLocation"/>-->

      <!-- Bug: in nw, transformation does not include 'xsi:' -->
      <xsl:attribute name="xsi:schemaLocation">
        <xsl:value-of select="concat($pagens,' ',$pagens,'/pagecontent.xsd')"/>
      </xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="svg:g[@class='Page']">
    <Page imageWidth="{svg:image/@width}" imageHeight="{svg:image/@height}" imageFilename="{svg:image/@xlink:href}">
      <xsl:apply-templates select="node()"/>
    </Page>
  </xsl:template>

  <xsl:template match="svg:image"/>

  <!--<xsl:template match="svg:g[contains(concat(' ',normalize-space(@class),' '),' TextRegion ')]">-->
  <xsl:template match="svg:g[starts-with(@class,'TextRegion')]">
    <TextRegion>
      <xsl:if test="starts-with(normalize-space(@class),'TextRegion ')">
        <xsl:attribute name="type">
          <xsl:value-of select="substring(@class,12)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*[local-name()!='class'] | node()"/>
    </TextRegion>
  </xsl:template>

  <xsl:template match="svg:g[starts-with(@class,'TableRegion')]">
    <TableRegion>
      <xsl:if test="starts-with(normalize-space(@class),'TableRegion ')">
        <xsl:attribute name="type">
          <xsl:value-of select="substring(@class,13)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*[local-name()!='class'] | node()"/>
    </TableRegion>
  </xsl:template>

  <xsl:template match="svg:g[@class='TextLine' or @class='Word' or @class='Glyph']">
    <xsl:element name="{@class}">
      <xsl:apply-templates select="@*[local-name()!='class'] | node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="svg:text">
    <xsl:if test="normalize-space()">
      <TextEquiv>
        <Unicode>
          <xsl:apply-templates select="node()"/>
        </Unicode>
      </TextEquiv>
    </xsl:if>
  </xsl:template>

  <xsl:template match="svg:tspan">
    <xsl:if test="count(preceding-sibling::*) &gt; 0">
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>
    <xsl:value-of select="node()"/>
  </xsl:template>

  <xsl:template match="svg:polygon[@class='Coords']">
    <Coords>
      <xsl:apply-templates select="@*[local-name()!='class' and local-name()!='id']"/>
    </Coords>
  </xsl:template>

  <xsl:template match="svg:polyline[@class='Baseline']">
    <Baseline>
      <xsl:apply-templates select="@*[local-name()!='class']"/>
    </Baseline>
  </xsl:template>

</xsl:stylesheet>