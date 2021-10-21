<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
 xmlns:ead="urn:isbn:1-931666-22-9"
 xmlns:str="http://exslt.org/strings"
 xmlns:ucf="https://lib.uchicago.edu/functions/"
 xmlns:xlink="http://www.w3.org/1999/xlink"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 exclude-result-prefixes="ead str ucf xlink">

<xsl:output omit-xml-declaration="yes"/>

<!-- CONTAINER
     Note:

     The vast majority of <container> elements use one of the following forms:
     <container type="Folder">3</container>
     <container type="othertype">drawer 4</container>

     Because of this, append the @type to the text output for all containers,
     except when a container has been specifically marked as "othertype". 
-->
<xsl:template match="ead:container" priority="2.0">
  <div class="ead_container">
    <xsl:value-of select="concat(@type, ' ')"/> <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="ead:container[@type = 'Othertype']" priority="2.1">
  <div class="ead_container">
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- CORPNAME
     When ead:corpname is a child of ead:controlaccess or ead:inventory,
     output a <div>. Output an <li> when it is a child of ead:namegrp.
     For all other parents, output a <span>. When this element is a
     child of publisher or repository output plain text, otherwise output
     a link back to the search interface. -->
<xsl:template match="ead:corpname" priority="2.0">
  <span class="ead_corpname">
    <xsl:choose>
      <xsl:when test="ancestor::ead:publisher or ancestor::ead:repository">
        <xsl:apply-templates select="@*|node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="corpname"/>
      </xsl:otherwise>
    </xsl:choose>
  </span>
</xsl:template>

<xsl:template match="ead:namegrp/ead:corpname" priority="2.1">
  <li class="ead_corpname">
    <xsl:choose>
      <xsl:when test="ancestor::ead:publisher or ancestor::ead:repository">
        <xsl:apply-templates select="@*|node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates name="corpname"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="corpname"/>
  </li>
</xsl:template>

<xsl:template match="*[   self::ead:controlaccess
                       or self::ead:indexentry   ]/ead:corpname" priority="2.1">
  <div class="ead_corpname">
    <xsl:choose>
      <xsl:when test="ancestor::ead:publisher or ancestor::ead:repository">
        <xsl:apply-templates select="@*|node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates name="corpname"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="corpname"/>
  </div>
</xsl:template>

<xsl:template name="corpname">
  <a class="ead_corpname">
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/organizations/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- FAMNAME -->
<xsl:template match="ead:famname" priority="2.0">
  <span class="ead_famname">
    <xsl:call-template name="famname"/>
  </span>
</xsl:template>

<xsl:template match="ead:namegrp/ead:famname" priority="2.1">
  <li class="ead_famname">
    <xsl:call-template name="famname"/>
  </li>
</xsl:template>

<xsl:template name="famname">
  <a class="ead_famname">
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/people/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- GEOGNAME
     outputs a span, unless the parent is ead:indexentry or ead:namegrp. -->
<xsl:template match="ead:geogname" priority="2.0">
  <span class="ead_geogname">
    <xsl:call-template name="geogname"/>
  </span>
</xsl:template>

<xsl:template match="ead:indexentry/ead:geogname" priority="2.1">
  <dt class="ead_geogname">
    <xsl:call-template name="geogname"/>
  </dt>
</xsl:template>

<xsl:template match="ead:namegrp/ead:geogname" priority="2.1">
  <li class="ead_geogname">
    <xsl:call-template name="geogname"/>
  </li>
</xsl:template>

<xsl:template name="geogname">
  <a class="ead_geogname">
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/places/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- NAME
     usually outputs a span, except when namegrp is the parent. -->
<xsl:template match="ead:name" priority="2.0">
  <span class="ead_name">
    <xsl:call-template name="name"/>
  </span>
</xsl:template>

<xsl:template match="ead:namegrp/ead:name" priority="2.1">
  <li class="ead_name">
    <xsl:call-template name="name"/>
  </li>
</xsl:template>

<xsl:template name="name">
  <a class="ead_name">
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/people/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- OCCUPATION 
     usually outputs a block-level element, unless the parent is a namegrp in
     which case it outputs an li. -->
<xsl:template match="ead:occupation" priority="2.0">
  <span class="ead_occupation">
    <xsl:call-template name="occupation"/>
  </span>
</xsl:template>

<xsl:template match="ead:namegrp/ead:occupation" priority="2.1">
  <li class="ead_occupation">
    <xsl:call-template name="occupation"/>
  </li>
</xsl:template>

<xsl:template name="occupation">
  <a class="ead_occupation">
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/topics/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- PERSNAME
     usually outputs an inline element, except when namegrp is the parent. -->
<xsl:template match="ead:persname" priority="2.0">
  <span class="ead_persname">
    <xsl:call-template name="persname"/>
  </span>
</xsl:template>

<xsl:template match="ead:namegrp/ead:persname" priority="2.1">
  <li class="ead_persname">
    <xsl:call-template name="persname"/>
  </li>
</xsl:template>

<xsl:template name="persname">
  <a class="ead_persname">
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/people/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- SUBJECT
     usually outputs an inline element, except when the child of ead:entry or
     ead:namegrp. -->
<xsl:template match="ead:subject" priority="2.0">
  <span class="ead_subject">
    <xsl:call-template name="subject"/>
  </span>
</xsl:template>

<xsl:template match="ead:entry/ead:subject" priority="2.1">
  <div class="ead_subject">
    <xsl:call-template name="subject"/>
  </div>
</xsl:template>

<xsl:template match="ead:namegrp/ead:subject" priority="2.1">
  <li class="ead_subject">
    <xsl:call-template name="subject"/>
  </li>
</xsl:template>

<xsl:template name="subject">
  <a class="ead_subject">
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/topics/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- BUILD SEARCH LINKS -->
<xsl:template name="build_search_link">
  <xsl:param name="ns"/>
  <xsl:param name="s"/>
  <xsl:value-of select="ucf:bmrc_search_url(
    $ns,
    normalize-space($s)
  )"/>
</xsl:template>

</xsl:stylesheet>
