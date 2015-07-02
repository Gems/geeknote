<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes" encoding="utf-8" />

  <xsl:param name="top-tag" select="'cms:top:'" />
  <xsl:param name="tile-tag" select="'cms:tile:'" />
  <xsl:param name="promoted-tag" select="'cms:promoted:'" />

  <xsl:variable name="authors" select="document('authors.xml')/authors" />

  <xsl:key name="resources" match="/note/resources/resource" use="@hash" />

  <xsl:variable name="cover-candidates" select="/note/content/en-note/p[en-media or a[1][last()][@href = .][contains(., 'youtube.com/')] or contains(text(), 'youtube:')]" />
  <xsl:variable name="promo-cover" select="$cover-candidates[count(preceding-sibling::*) = 0 or preceding-sibling::p[1][last()]/i]" />
  <xsl:variable name="article-cover" select="$cover-candidates[preceding-sibling::*[last() and generate-id() = generate-id($promo-cover)]]" />

  <xsl:template match="/">
    <article>
      <metadata
        title="{normalize-space(/note/title)}"
        description="{normalize-space(/note/content/en-note/descendant::p[normalize-space() != '' and not(descendant::i)][1])}"
        tileColor=""
        pub-date="{/note/created}"
        top-index="{substring-after(/note/tags/tag[contains(., $top-tag)], $top-tag)}"
        tile-size="{substring-after(/note/tags/tag[contains(., $tile-tag)], $tile-tag)}"
        promo-index="{substring-after(/note/tags/tag[contains(., $promoted-tag)], $promoted-tag)}"
        author-name="{$authors/author[@name = current()/note/author]/@screen-name}"
        author-ava="{$authors/author[@name = current()/note/author]/@ava-url}"
      >
        <xsl:attribute name="promo-cover">
          <xsl:apply-templates select="$promo-cover" mode="cover-url" />
        </xsl:attribute>
        <xsl:attribute name="article-cover">
          <xsl:choose>
            <xsl:when test="$article-cover">
              <xsl:apply-templates select="$article-cover" mode="cover-url" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$promo-cover" mode="cover-url" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="tags">
          <xsl:for-each select="/note/tags/tag[not(contains(., 'cms:'))]">
            <xsl:value-of select="." />
            <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </metadata>
      <content>
        <xsl:apply-templates select="/note/content/en-note/*[not(contains(concat(generate-id($promo-cover), generate-id($article-cover)), generate-id()))]" />
      </content>
    </article>
  </xsl:template>

  <xsl:template match="*" mode="cover-url">
    <xsl:choose>
      <xsl:when test="en-media[starts-with(@type, 'image/')]">
        <xsl:value-of select="key('resources', en-media/@hash)/@path" />
      </xsl:when>
      <xsl:when test="a">
        <xsl:value-of select="a/@href" />
      </xsl:when>
      <xsl:when test="contains(text(), 'youtube:')">
        <xsl:value-of select="substring-after(text(), 'youtube:')" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="p[not(a or en-media or img or em or strong or normalize-space(text()) != '')] | highlight">
    <xsl:apply-templates select="node()[self::text() or self::*]" />
  </xsl:template>

  <xsl:template match="en-media">
    <xsl:text>Not supported media</xsl:text>
  </xsl:template>

  <xsl:template match="en-media[starts-with(@type, 'image/')]">
    <img src="{key('resources', @hash)/@path}" />
  </xsl:template>

  <xsl:template match="text()[parent::i/parent::p[parent::en-note and count(preceding-sibling::*) = 0]]">
    <xsl:attribute name="class">teaser</xsl:attribute>
    <xsl:copy />
  </xsl:template>

  <xsl:template match="*">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="self::b[parent::p]">h2</xsl:when>
        <xsl:when test="self::i[parent::p]">blockquote</xsl:when>
        <xsl:when test="self::i">em</xsl:when>
        <xsl:when test="self::b">strong</xsl:when>
        <xsl:otherwise><xsl:value-of select="name()" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$name}">
      <xsl:apply-templates select="@* | node()[self::text() or self::*]" />
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

</xsl:stylesheet>
