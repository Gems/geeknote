<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" />

  <xsl:template match="/">
    ---
    title:
    description: {первый абзац в тексте}
    tileColor:
    date: { /note/created }
    topIndex: { cms:top:N }
    tileSize: { cms:tile:N }
    tileCover: { первое изображение в статье или картинка из первого видео }
    promoIndex: { cms:promoted:N }
    promoCover: { первое изображение в статье или картинка из первого видео }
    articleCover: { второе изображение или видео в статье из двух последовательных или первое изображение или видео }
    authorName: { /note/author }
    authorAva: { ./img/{/note/author}.jpg }
    tags: { /note/tags (через запятую) }
    ---
    
  </xsl:template>
</xsl:stylesheet>
