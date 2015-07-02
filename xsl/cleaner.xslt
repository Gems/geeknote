<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes" />

  <xsl:template match="*">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="self::div">p</xsl:when>
        <xsl:otherwise><xsl:value-of select="name()" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$name}">
      <xsl:apply-templates select="@* | node()[self::text() or self::*]" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="div[normalize-space(.) = '' and .//br[last()]]" />

  <xsl:template match="span[contains(@style, 'bold') or contains(@style, 'italic') or contains(@style, '-evernote-highlight')]">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="contains(@style, 'bold')">b</xsl:when>
        <xsl:when test="contains(@style, 'italic')">i</xsl:when>
        <xsl:when test="contains(@style, '-evernote-highlight')">highlight</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="{$name}">
      <xsl:apply-templates select="node()[self::text() or self::*]" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="span">
    <xsl:apply-templates select="node()[self::text() or self::*]" />
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
