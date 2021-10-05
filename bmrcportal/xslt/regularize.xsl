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

<xsl:template match="ead:bibliography/ead:bibref">
  <xsl:if test="not(preceding-sibling::ead:bibref)">
    <ead:list>
      <xsl:apply-templates select="." mode="item"/>
      <xsl:for-each select="following-sibling::ead:bibref">
        <xsl:apply-templates select="." mode="item"/>
      </xsl:for-each>
    </ead:list>
  </xsl:if>
</xsl:template>

<xsl:template match="ead:bibref" mode="item">
  <ead:item>
    <xsl:copy-of select="."/>
  </ead:item>
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
<xsl:template match="ead:c01 | ead:c02 | ead:c03 | ead:c04 | ead:c05 | 
                     ead:c06 | ead:c07 | ead:c08 | ead:c09 | ead:c10 | 
                     ead:c11 | ead:c12"> 
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
                     ead:controlaccess/ead:subarea |
                     ead:controlaccess/ead:subject |
                     ead:controlaccess/ead:title">
  <xsl:if test="not(preceding-sibling::ead:corpname) and
                not(preceding-sibling::ead:famname) and
                not(preceding-sibling::ead:function) and
                not(preceding-sibling::ead:genreform) and
                not(preceding-sibling::ead:geogname) and
                not(preceding-sibling::ead:name) and
                not(preceding-sibling::ead:occupation) and
                not(preceding-sibling::ead:persname) and
                not(preceding-sibling::ead:subarea) and
                not(preceding-sibling::ead:subject) and
                not(preceding-sibling::ead:title)">
    <ead:list>
      <xsl:apply-templates select="." mode="item"/>
      <xsl:for-each select="following-sibling::ead:corpname | following-sibling::ead:famname | following-sibling::ead:function | following-sibling::ead:genreform | following-sibling::ead:geogname | following-sibling::ead:name | following-sibling::ead:occupation | following-sibling::ead:persname | following-sibling::ead:subarea | following-sibling::ead:subject">
        <xsl:apply-templates select="." mode="item"/>
      </xsl:for-each>
    </ead:list>
  </xsl:if>
</xsl:template>

<xsl:template match="ead:corpname | ead:famname | ead:function | ead:genreform | ead:geogname | ead:name | ead:occupation | ead:persname | ead:subarea | ead:subject" mode="item">
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
<xsl:template match="ead:dsc">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Inventory</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="ead:dsc[not(*)]"/>

<!-- EADHEADER, FRONTMATTER -->
<xsl:template match="ead:eadheader">
  <xsl:copy-of select="."/>
  <xsl:if test="not(//ead:frontmatter)">
    <ead:frontmatter>
      <ead:titlepage>
        <ead:titleproper>
          <!-- omit <num> elements embedded inside <titleproper> -->
          <xsl:value-of select="//ead:titleproper[1]/text()"/>
        </ead:titleproper>
        <xsl:copy-of select="//ead:author[1]"/>
      </ead:titlepage>
    </ead:frontmatter>
  </xsl:if>
</xsl:template>

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

<!-- ODD -->
<xsl:template match="ead:odd">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Other Descriptive Data</ead:head>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
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

<!-- PHYSDESC -->
<xsl:template match="ead:physdesc[not(@label)]">
  <xsl:copy>
    <xsl:attribute name="label">Size</xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- PHYSLOC -->
<xsl:template match="ead:physloc">
  <xsl:copy>
    <xsl:if test="not(@label)"> 
      <xsl:attribute name="label">Physical Location</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- PHYSTECH -->
<xsl:template match="ead:phystech">
  <xsl:copy>
    <xsl:if test="not(ead:head)">
      <ead:head>Physical Characteristics and Technical Requirements</ead:head>
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

<xsl:template match="ead:relatedmaterial/ead:archref">
  <xsl:if test="not(preceding-sibling::ead:archref)">
    <ead:list>
      <xsl:apply-templates select="." mode="item"/>
      <xsl:for-each select="following-sibling::ead:archref">
        <xsl:apply-templates select="." mode="item"/>
      </xsl:for-each>
    </ead:list>
  </xsl:if>
</xsl:template>

<xsl:template match="ead:archref" mode="item">
  <ead:item>
    <xsl:copy-of select="."/>
  </ead:item>
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

<!-- UNITID -->
<xsl:template match="ead:archdesc/ead:did/ead:unitid[not(@label)]">
  <xsl:copy>
    <xsl:attribute name="label">Identifier</xsl:attribute>
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

<xsl:template match="ead:archdesc/ead:did//ead:userestrict | ead:dsc//ead:userestrict">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

</xsl:stylesheet>
