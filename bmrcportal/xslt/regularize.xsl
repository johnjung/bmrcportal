<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
 xmlns:ead="urn:isbn:1-931666-22-9"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output omit-xml-declaration="yes"/>

<!-- * -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- ABSTRACT -->
<xsl:template match="ead:abstract">
  <xsl:copy>
    <xsl:if test="not(@label)"> 
      <xsl:attribute name="label">Abstract</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- ACCESSRESTRICT -->
<xsl:template match="ead:accessrestrict">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Access Restrictions</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- ACCRUALS -->
<xsl:template match="ead:accruals">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Accruals</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- ACQINFO -->
<xsl:template match="ead:acqinfo">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Acquisition Information</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- ALTFORMAVAIL -->
<xsl:template match="ead:altformavail">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Alternate Format Available</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- APPRAISAL -->
<xsl:template match="ead:appraisal">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Appraisal</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- ARRANGEMENT -->
<xsl:template match="ead:arrangement">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Arrangement</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- BIBLIOGRAPHY -->
<xsl:template match="ead:bibliography">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Bibliography</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- BIOGHIST -->
<xsl:template match="ead:bioghist">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Biographical Note</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- C## -->
<xsl:template match="
  ead:c01[@level] | ead:c02[@level] | ead:c03[@level] | ead:c04[@level] |
  ead:c05[@level] | ead:c06[@level] | ead:c07[@level] | ead:c08[@level] |
  ead:c09[@level] | ead:c10[@level] | ead:c11[@level] | ead:c12[@level]"> 
  <ead:c>
    <xsl:apply-templates select="@*|node()"/>
  </ead:c>
</xsl:template>

<!-- CONTROLACCESS -->
<xsl:template match="ead:controlaccess">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Controlled Access Headings</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="ead:controlaccess/ead:corpname |
                     ead:controlaccess/ead:famname |
                     ead:controlaccess/ead:function |
                     ead:controlaccess/ead:genreform |
                     ead:controlaccess/ead:geogname |
                     ead:controlaccess/ead:name |
                     ead:controlaccess/ead:occupation |
                     ead:controlaccess/ead:persname |
                     ead:controlaccess/ead:subject">
  <xsl:if test="not(preceding-sibling::ead:corpname) and
                not(preceding-sibling::ead:famname) and
                not(preceding-sibling::ead:function) and
                not(preceding-sibling::ead:genreform) and
                not(preceding-sibling::ead:geogname) and
                not(preceding-sibling::ead:name) and
                not(preceding-sibling::ead:occupation) and
                not(preceding-sibling::ead:persname) and
                not(preceding-sibling::ead:subject)">
    <ead:list>
      <xsl:apply-templates select="." mode="item"/>
      <xsl:for-each select="following-sibling::ead:corpname | following-sibling::ead:famname | following-sibling::ead:function | following-sibling::ead:genreform | following-sibling::ead:geogname | following-sibling::ead:name | following-sibling::ead:occupation | following-sibling::ead:persname | following-sibling::ead:subject">
        <xsl:apply-templates select="." mode="item"/>
      </xsl:for-each>
    </ead:list>
  </xsl:if>
</xsl:template>

<xsl:template match="ead:corpname | ead:famname | ead:function | ead:genreform | ead:geogname | ead:name | ead:occupation | ead:persname | ead:subject" mode="item">
  <ead:item>
    <xsl:copy-of select="."/>
  </ead:item>
</xsl:template>

<!-- CUSTODHIST -->
<xsl:template match="ead:custodhist">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Custodial History</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- DSC -->
<xsl:template match="ead:dsc[not(*)]"/>

<!-- FILEPLAN -->
<xsl:template match="ead:fileplan">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>File List</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- INDEX -->
<xsl:template match="ead:index">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Index</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- LANGMATERIAL -->
<xsl:template match="ead:archdesc/ead:did/ead:langmaterial[not(@label)]">
  <xsl:copy>
    <xsl:attribute name="label">Language</xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- LANGUAGE -->
<xsl:template match="ead:language[not(text())]">
  <xsl:choose>
    <xsl:when test="@langcode='aar'">Afar</xsl:when>
    <xsl:when test="@langcode='eng'">English</xsl:when>
    <xsl:when test="@langcode='fre'">French</xsl:when>
    <xsl:when test="@langcode='ger'">German</xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<!-- ORIGINATION -->
<xsl:template match="ead:archdesc/ead:did/ead:origination[not(@label)]">
  <xsl:copy>
    <xsl:attribute name="label">Creator</xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- OTHERFINDINGAID -->
<xsl:template match="ead:otherfindingaid">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Other Finding Aid</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- PREFERCITE -->
<xsl:template match="ead:prefercite">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Preferred Citation</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- PROCESSINFO -->
<xsl:template match="ead:processinfo">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Processing Information</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- RELATED MATERIAL -->
<xsl:template match="ead:relatedmaterial">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Related Material</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- REPOSITORY -->
<xsl:template match="ead:archdesc/ead:did/ead:repository[not(@label)]">
  <xsl:copy>
    <xsl:attribute name="label">Repository</xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- SCOPECONTENT -->
<xsl:template match="ead:scopecontent">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Scope and Content</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- SEPARATEDMATERIAL -->
<xsl:template match="ead:separatedmaterial">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Separated Material</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- UNITDATE -->
<xsl:template match="ead:archdesc/ead:did/ead:unitdate[not(@label)]">
  <xsl:copy>
    <xsl:attribute name="label">Dates</xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- UNITTITLE -->
<xsl:template match="ead:archdesc/ead:did/ead:unittitle[not(@label)]">
  <xsl:copy>
    <xsl:attribute name="label">Title</xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- USERESTRICT -->
<xsl:template match="ead:userestrict">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Conditions Governing Use</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
