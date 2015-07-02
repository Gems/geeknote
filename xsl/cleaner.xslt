<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" />

  <xsl:template match="*">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="name() = 'span' and contains('bold', @style)">b</xsl:when>
        <xsl:when test="name() = 'span' and contains('italic', @style)">i</xsl:when>
        <xsl:otherwise><xsl:value-of select="name()" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="{$name}">
      <xsl:apply-templates select="@* | text() | *" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:attribute name="{local-name()}">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:copy-of select="." />
  </xsl:template>

  <xsl:template match="@style" />
</xsl:stylesheet>
