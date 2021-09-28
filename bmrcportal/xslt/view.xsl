<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
 xmlns:ead="urn:isbn:1-931666-22-9"
 xmlns:xlink="http://www.w3.org/1999/xlink"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 exclude-result-prefixes="ead xlink">

<xsl:output omit-xml-declaration="yes"/>

<!-- PARAMETER: EADID -->
<xsl:param name="eadid"/>

<!-- PARAMETER: Q -->
<xsl:param name="q"/>

<!-- @* -->
<xsl:template match="@*"/>

<!-- @AUDIENCE = 'internal' -->
<xsl:template match="*[@audience='internal']" priority="9"/>

<!-- @ID -->
<xsl:template match="@id">
  <xsl:attribute name="id">
    <xsl:value-of select="@id"/>
  </xsl:attribute>
</xsl:template>

<!-- @LABEL -->
<xsl:template match="@label">
  <h3 id="{generate-id(.)}"><xsl:value-of select="."/></h3>
</xsl:template>

<!-- ABBR -->
<xsl:template match="ead:abbr">
  <abbr>
    <xsl:apply-templates select="@*|node()"/>
  </abbr>
</xsl:template>

<xsl:template match="ead:abbr[@expan]">
  <abbr title="{@expan}">
    <xsl:apply-templates select="@*|node()"/>
  </abbr>
</xsl:template>

<!-- ABSTRACT -->
<xsl:template match="ead:abstract">
  <xsl:apply-templates select="@label"/>
  <p>
    <xsl:apply-templates select="@*|node()"/>
  </p>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:abstract">
  <div>
    Abstract: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- ACCESSRESTRICT -->
<xsl:template match="ead:accessrestrict">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- ACCRUALS -->
<xsl:template match="ead:accruals">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- ACQINFO -->
<xsl:template match="ead:acqinfo">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- ADDRESS -->
<xsl:template match="ead:address">
  <address>
    <xsl:apply-templates select="@*|node()"/>
  </address>
</xsl:template>

<!-- ADDRESSLINE -->
<xsl:template match="ead:addressline">
  <xsl:apply-templates select="@*|node()"/>
  <xsl:if test="following-sibling::ead:addressline"><br/></xsl:if>
</xsl:template>

<!-- ALTFORMAVAIL -->
<xsl:template match="ead:altformavail">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- APPRAISAL -->
<xsl:template match="ead:appraisal">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- ARC -->
<xsl:template match="ead:arc"/>

<!-- ARCHDESC -->
<xsl:template match="ead:archdesc">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- ARCHDESCGRP -->
<xsl:template match="ead:archdescgrp">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- ARCHREF -->
<xsl:template match="ead:archref">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- ARRANGEMENT -->
<xsl:template match="ead:arrangement">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- AUTHOR -->
<xsl:template match="ead:author">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:frontmatter//ead:author">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- BIBSERIES -->
<xsl:template match="ead:bibseries">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- BIOGHIST -->
<xsl:template match="ead:bioghist">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- BLOCKQUOTE -->
<xsl:template match="ead:blockquote">
  <blockquote>
    <xsl:apply-templates select="@*|node()"/>
  </blockquote>
</xsl:template>

<!-- C## -->
<xsl:template match="ead:c">
  <div class="c">
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- CHANGE -->
<xsl:template match="ead:change">
  <dl>
    <xsl:apply-templates select="@*|node()"/>
  </dl>
</xsl:template>

<!-- CHRONLIST -->
<xsl:template match="ead:chronlist">
  <dl>
    <xsl:apply-templates select="@*|node()"/>
  </dl>
</xsl:template>

<!-- COLSPEC -->
<xsl:template match="ead:colspec"/>

<!-- CONTAINER-->
<xsl:template match="ead:container">
  <div>
    <xsl:value-of select="concat(@type, ' ')"/> <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- CORPNAME -->
<xsl:template match="ead:corpname">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- DAO -->
<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:dao">
  <div>
    Digital Archival Object: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- DAOGRP -->
<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:daogrp">
  <div>
    Digital Archival Object Group: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- DAOLOC -->
<xsl:template match="ead:daoloc">
  <a href="{@href}">
    <xsl:value-of select="."/>
  </a>
</xsl:template>

<!-- DATE -->
<xsl:template match="ead:date">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:change/ead:date">
  <dt>
    <xsl:apply-templates select="@*|node()"/>
  </dt>
</xsl:template>

<!-- DEFITEM -->
<xsl:template match="ead:defitem">
  <dl>
    <xsl:apply-templates select="@*|node()"/>
  </dl>
</xsl:template>

<!-- DESCGRP -->
<xsl:template match="ead:descgrp">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- DESCRULES -->
<xsl:template match="ead:descrules">
  <div class="descrules">
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- DID -->
<xsl:template match="ead:archdesc/ead:did">
  <xsl:apply-templates select="ead:head"/>
  <dl>
    <xsl:apply-templates select="@*|*[not(self::ead:head)]|text()"/>
  </dl>
</xsl:template>

<!--
     A <did> may contain: 
       0 or more <unitid> elements
       0 or more containers
       0 or more other elements

     Get a count of these elements:
       Count (1) if unitid is present
       Count (1) for each de-duped container
       Count (1) if any other element is present

     Output each row separately, as a flexbox, and give each a class name that
     includes the number of columns. If there is a <unitid>, output it. Then, for
     each <container>, output the type, followed by the contents of the node.
     Finally, put every other element in the right-most column along with a label
     for each element type.

     abstract     -> "Abstract"
     container    -> "Container"
     dao          -> "Digital Archival Object"
     daogrp       -> "Digital Archival Object Group"
     head         -> ""
     langmaterial -> "Language"
     materialspec -> "Material Specific Details"
     note         -> "Note"
     origination  -> "Origination"
     physdesc     -> "Physical Description"
     physloc      -> "Physical Location"
     repository   -> "Repository"
     unitdate     -> "Date"
     unittitle    -> "Title"
-->

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did">
  <xsl:variable name="column_count" select="number(
                                              boolean(
                                                count(
                                                  ead:unitid
                                                )
                                              )
                                            ) +
                                            count(ead:container) +
                                            number(
                                              boolean(
                                                count(
                                                  ead:abstract |
                                                  ead:container |
                                                  ead:dao |
                                                  ead:daogrp |
                                                  ead:head |
                                                  ead:langmaterial |
                                                  ead:materialspec |
                                                  ead:note |
                                                  ead:origination |
                                                  ead:physdesc |
                                                  ead:physloc |
                                                  ead:repository |
                                                  ead:unitdate |
                                                  ead:unittitle
                                                )
                                              )
                                            )"/>
  <div class="{concat('did did_', string($column_count))}">
    <xsl:apply-templates select="ead:unitid|ead:container"/>
    <div>
      <xsl:apply-templates select="@*|*[not(self::ead:unitid) and not(self::ead:container)]|text()"/>
    </div>
  </div>
</xsl:template>

<!-- DIV -->
<xsl:template match="ead:div">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- DSC -->
<xsl:template match="ead:dsc">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- EAD -->
<xsl:template match="ead:ead">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- EADHEADER -->
<xsl:template match="ead:eadheader"/>

<!-- EADID -->
<xsl:template match="ead:eadid"/>

<!-- EMPH -->
<xsl:template match="ead:emph">
  <em>
    <xsl:apply-templates select="@*|node()"/>
  </em>
</xsl:template>

<xsl:template match="ead:emph[@render='bold']">
  <strong>
    <xsl:apply-templates select="@*|node()"/>
  </strong>
</xsl:template>

<!-- ENTRY -->
<xsl:template match="ead:entry">
  <td>
    <xsl:apply-templates select="@*|node()"/>
  </td>
</xsl:template>

<!-- EVENT -->
<xsl:template match="ead:event">
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- EXTENT -->
<xsl:template match="ead:extent">
  <xsl:apply-templates select="@*|node()"/>
  <xsl:value-of select="concat(' ', @type)"/>
</xsl:template>

<!-- EXTPTR -->
<xsl:template match="ead:extptr[@href]">
  <a href="{@href}">
    <xsl:choose>
      <xsl:when test="@title">
        <xsl:value-of select="@title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@href"/>
      </xsl:otherwise>
    </xsl:choose>
  </a>
</xsl:template>

<!-- EXTREF -->
<xsl:template match="ead:extref[@xlink:href]">
  <a href="{@xlink:href}">
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- EXTREFLOC -->
<xsl:template match="ead:extrefloc[@href]">
  <a href="{@href}">
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- FUNCTION -->
<xsl:template match="ead:function">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- GENREFORM -->
<xsl:template match="ead:genreform">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- GEOGNAME -->
<xsl:template match="ead:geogname">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="ead:indexentry/ead:geogname">
  <dt>
    <xsl:apply-templates select="@*|node()"/>
  </dt>
</xsl:template>

<xsl:template match="ead:namegrp/ead:geogname">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<xsl:template match="ead:p/ead:geogname">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- HEAD -->
<xsl:template match="ead:head">
  <h3 id="{generate-id(.)}">
    <xsl:apply-templates select="@*|node()"/>
  </h3>
</xsl:template>

<!-- HIGHLIGHT -->
<xsl:template match="ead:highlight">
  <span class="highlight">
    <xsl:apply-templates select="@*|node()"/>
  </span>
</xsl:template>

<!-- IMPRINT -->
<xsl:template match="ead:imprint">
  <ul>
    <xsl:apply-templates select="@*|node()"/>
  </ul>
</xsl:template>

<!-- ITEM -->
<xsl:template match="ead:change/ead:item">
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<xsl:template match="ead:defitem/ead:item">
  <dt>
    <xsl:apply-templates select="@*|node()"/>
  </dt>
</xsl:template>

<xsl:template match="ead:list/ead:item">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- LABEL -->
<xsl:template match="ead:label">
  <dt>
    <xsl:apply-templates select="@*|node()"/>
  </dt>
</xsl:template>

<!-- LANGMATERIAL -->
<xsl:template match="ead:langmaterial">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:langmaterial">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:langmaterial">
  <div>
    Language: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- LANGUAGE -->
<xsl:template match="ead:language">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- LANGUSAGE -->
<xsl:template match="ead:langusage">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- LIST -->
<xsl:template match="ead:list">
  <xsl:apply-templates select="ead:head"/>
  <ul>
    <xsl:apply-templates select="@*|*[not(self::ead:head)]|text()"/>
  </ul>
</xsl:template>

<!-- MATERIALSPEC -->
<xsl:template match="ead:materialspec">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:materialspec">
  <div>
    Material Specific Details: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- NAMEGRP -->
<xsl:template match="ead:namegrp">
  <ul>
    <xsl:apply-templates select="@*|node()"/>
  </ul>
</xsl:template>

<!-- NOTE -->
<xsl:template match="ead:dsc//ead:did/ead:note">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:note">
  <div>
    Note: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- NOTESTMT -->
<xsl:template match="ead:notestmt">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- OCCUPATION -->
<xsl:template match="ead:namegrp/ead:occupation">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- ORIGINALSLOC -->
<xsl:template match="ead:originalsloc">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- ORIGINATION -->
<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:origination">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:origination">
  <div>
    Origination: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- P -->
<xsl:template match="ead:p">
  <p>
    <xsl:apply-templates select="@*|node()"/>
  </p>
</xsl:template>

<!-- PERSNAME -->
<xsl:template match="ead:persname">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- PHYSDESC -->
<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:physdesc">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:physdesc">
  <div>
    Physical Description: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- PHYSFACET -->
<xsl:template match="ead:physfacet">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- PHYSLOC -->
<xsl:template match="ead:physloc">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:physloc">
  <div>
    Physical Location: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- PHYSTECH -->
<xsl:template match="ead:phystech">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- PREFERCITE -->
<xsl:template match="ead:prefercite">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- PROCESSINFO -->
<xsl:template match="ead:processinfo">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- PROFILEDESC -->
<xsl:template match="ead:profiledesc">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- PUBLISHER -->
<xsl:template match="ead:publisher">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- RELATEDMATERIAL -->
<xsl:template match="ead:relatedmaterial">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- REPOSITORY -->
<xsl:template match="ead:repository">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:repository">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:repository">
  <div>
    Repository: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- REVISIONDESC -->
<xsl:template match="ead:revisiondesc">
  <dl>
    <xsl:apply-templates select="@*|node()"/>
  </dl>
</xsl:template>

<!-- ROW -->
<xsl:template match="ead:row">
  <tr>
    <xsl:apply-templates select="@*|node()"/>
  </tr>
</xsl:template>

<!-- SEPARATEDMATERIAL -->
<xsl:template match="ead:separatedmaterial">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- SPONSOR -->
<xsl:template match="ead:sponsor">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- SUBAREA -->
<xsl:template match="ead:subarea">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- SUBJECT -->
<xsl:template match="ead:entry/ead:subject">
  <div>
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="concat(
          '/search/?f=',
          . 
        )"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </div>
</xsl:template>
<xsl:template match="ead:subject">
  <a>
    <xsl:attribute name="href">
      <xsl:value-of select="concat(
        '/search/?f=',
        . 
      )"/>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- SUBTITLE -->
<xsl:template match="ead:subtitle">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- TABLE -->
<xsl:template match="ead:table">
  <table>
    <xsl:apply-templates select="@*|node()"/>
  </table>
</xsl:template>

<!-- TBODY -->
<xsl:template match="ead:tbody">
  <tbody>
    <xsl:apply-templates select="@*|node()"/>
  </tbody>
</xsl:template>

<!-- THEAD -->
<xsl:template match="ead:thead">
  <tbody>
    <xsl:apply-templates select="@*|node()"/>
  </tbody>
</xsl:template>

<!-- TITLE -->
<xsl:template match="ead:title[@render='italic']">
  <em>
    <xsl:apply-templates select="@*|node()"/>
  </em>
</xsl:template>

<!-- TITLEPAGE -->
<xsl:template match="ead:titlepage">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- TITLEPROPER -->
<xsl:template match="ead:titleproper">
  <h1>
    <xsl:apply-templates select="@*|node()"/>
  </h1>
</xsl:template>

<!-- UNITDATE -->
<xsl:template match="ead:unitdate">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:unitdate">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:unitdate">
  <div>
    Date: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- UNITID -->
<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:unitid">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:unitid">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- UNITTITLE -->
<xsl:template match="ead:unittitle">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:unittitle">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:unittitle">
  <div>
    Date: <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- USERESTRICT -->
<xsl:template match="ead:userestrict">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!--**************
    * NAVIGATION *
    ************** -->

<!--
<xsl:template match="text()" mode="nav"/>

<xsl:template match="*" mode="nav">
<xsl:apply-templates mode="nav"/>
</xsl:template>

<xsl:template match="ead:dsc" mode="nav">
<xsl:variable name="searchcount"><xsl:if test="count(.//ead:highlight)"><xsl:value-of select="concat(' (', count(.//ead:highlight), ')')"/></xsl:if></xsl:variable>
<li><a href="#{generate-id(.)}"><xsl:value-of select="concat('INVENTORY', $searchcount)"/></a></li><xsl:apply-templates mode="nav"/>
</xsl:template>

<xsl:template match="ead:head" mode="nav">
<xsl:variable name="searchcount"><xsl:if test="count(..//ead:highlight)"><xsl:value-of select="concat(' (', count(..//ead:highlight), ')')"/></xsl:if></xsl:variable>
<li><a href="#{generate-id(.)}"><xsl:value-of select="concat(., $searchcount)"/></a></li>
</xsl:template>

<xsl:template match="ead:descgrp/ead:head" mode="nav"/>

<xsl:template match="ead:bibliography | ead:dsc/ead:head | ead:scopecontent/ead:head[position() &gt; 1]" mode="nav"/>

<xsl:template 
 match="
  ead:c[not(@level = 'file') and ead:did/ead:unittitle//text()] | 
  ead:c01[not(@level = 'file') and ead:did/ead:unittitle//text()] | ead:c02[not(@level = 'file') and ead:did/ead:unittitle//text()] |
  ead:c03[not(@level = 'file') and ead:did/ead:unittitle//text()] | ead:c04[not(@level = 'file') and ead:did/ead:unittitle//text()] |
  ead:c05[not(@level = 'file') and ead:did/ead:unittitle//text()] | ead:c06[not(@level = 'file') and ead:did/ead:unittitle//text()] |
  ead:c07[not(@level = 'file') and ead:did/ead:unittitle//text()] | ead:c08[not(@level = 'file') and ead:did/ead:unittitle//text()] |
  ead:c09[not(@level = 'file') and ead:did/ead:unittitle//text()] | ead:c10[not(@level = 'file') and ead:did/ead:unittitle//text()] |
  ead:c11[not(@level = 'file') and ead:did/ead:unittitle//text()] | ead:c12[not(@level = 'file') and ead:did/ead:unittitle//text()]" mode="nav"> 
<xsl:variable name="searchcount"><xsl:if test="count(.//ead:highlight)"><xsl:value-of select="concat(' (', count(.//ead:highlight), ')')"/></xsl:if></xsl:variable>
<li><a href="#{generate-id(ead:did/ead:unittitle)}"><xsl:value-of select="concat(ead:did/ead:unittitle, $searchcount)"/></a>
  <xsl:if 
    test="
    descendant::ead:c[not(@level = 'file') and ead:did/ead:unittitle//text()] | 
    descendant::ead:c01[not(@level = 'file') and ead:did/ead:unittitle//text()] | descendant::ead:c02[not(@level = 'file') and ead:did/ead:unittitle//text()] |
    descendant::ead:c03[not(@level = 'file') and ead:did/ead:unittitle//text()] | descendant::ead:c04[not(@level = 'file') and ead:did/ead:unittitle//text()] |
    descendant::ead:c05[not(@level = 'file') and ead:did/ead:unittitle//text()] | descendant::ead:c06[not(@level = 'file') and ead:did/ead:unittitle//text()] |
    descendant::ead:c07[not(@level = 'file') and ead:did/ead:unittitle//text()] | descendant::ead:c08[not(@level = 'file') and ead:did/ead:unittitle//text()] |
    descendant::ead:c09[not(@level = 'file') and ead:did/ead:unittitle//text()] | descendant::ead:c10[not(@level = 'file') and ead:did/ead:unittitle//text()] |
    descendant::ead:c11[not(@level = 'file') and ead:did/ead:unittitle//text()] | descendant::ead:c12[not(@level = 'file') and ead:did/ead:unittitle//text()]"> 
  <ul><xsl:apply-templates mode="nav"/></ul>
  </xsl:if>
</li>
</xsl:template>
-->

<xsl:template name="searchcount">
  <xsl:value-of select="concat(' (', count(//ead:highlight), ')')"/>
</xsl:template>

</xsl:stylesheet>
