<?xml version="1.0"?>

<xsl:stylesheet 
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output omit-xml-declaration="yes"/>

<xsl:template match="/">
  <div>
    <h2>Contents</h2>
    <ul>
      <xsl:apply-templates select="//h2"/>
    </ul>
  </div>
</xsl:template>

<xsl:template match="h2">
  <li>
    <a href="{concat('#', @id)}">
      <xsl:value-of select="."/>
    </a>
    <xsl:if test="following-sibling::h3">
      <ul>
        <xsl:apply-templates select="following-sibling::h3[preceding-sibling::h2[1] = current()]"/>
      </ul>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="h3">
  <li>
    <a href="{concat('#', @id)}">
      <xsl:value-of select="."/>
    </a>
    <xsl:if test="following-sibling::h4">
      <ul>
        <xsl:apply-templates select="following-sibling::h4[preceding-sibling::h3[1] = current()]"/>
      </ul>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="h4">
  <li>
    <a href="{concat('#', @id)}">
      <xsl:value-of select="."/>
    </a>
    <xsl:if test="following-sibling::h5">
      <ul>
        <xsl:apply-templates select="following-sibling::h5[preceding-sibling::h4[1] = current()]"/>
      </ul>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="h5">
  <li>
    <a href="{concat('#', @id)}">
      <xsl:value-of select="."/>
    </a>
    <xsl:if test="following-sibling::h6">
      <ul>
        <xsl:apply-templates select="following-sibling::h6[preceding-sibling::h5[1] = current()]"/>
      </ul>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="h6">
  <li>
    <a href="{concat('#', @id)}">
      <xsl:value-of select="."/>
    </a>
  </li>
</xsl:template>

</xsl:stylesheet>
