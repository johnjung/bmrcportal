<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
 xmlns:ead="urn:isbn:1-931666-22-9"
 xmlns:str="http://exslt.org/strings"
 xmlns:ucf="https://lib.uchicago.edu/functions/"
 xmlns:xlink="http://www.w3.org/1999/xlink"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 exclude-result-prefixes="ead str ucf xlink">

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
  <div id="{.}"/>
</xsl:template>

<!-- @LABEL -->
<xsl:template match="@label[not(ancestor::ead:dsc)]">
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
    <xsl:apply-templates select="@*[name() != 'expan']|node()"/>
  </abbr>
</xsl:template>

<!-- ABSTRACT -->
<xsl:template match="ead:abstract">
  <xsl:apply-templates select="@label"/>
  <p>
    <xsl:apply-templates select="@*[name() != 'label']|node()"/>
  </p>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:abstract">
  <dt>Abstract</dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
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

<!-- BIBREF -->
<xsl:template match="ead:bibref">
  <xsl:apply-templates select="@*|node()"/>
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

<!-- C -->
<xsl:template match="ead:c">
  <xsl:variable name="c_count" select="count(ancestor-or-self::ead:c)"/>
  <xsl:variable name="c_class">
    <xsl:choose>
      <xsl:when test="$c_count &lt; 10">
        <xsl:value-of select="concat('c0', $c_count)"/>
      </xsl:when> 
      <xsl:otherwise>
        <xsl:value-of select="concat('c', $c_count)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <div class="{concat('c ', $c_class)}">
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- CHANGE -->
<xsl:template match="ead:change">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- CHRONITEM -->
<xsl:template match="ead:chronitem">
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- CHRONLIST -->
<xsl:template match="ead:chronlist">
  <dl>
    <xsl:apply-templates select="@*|node()"/>
  </dl>
</xsl:template>

<!-- COLSPEC -->
<xsl:template match="ead:colspec"/>

<!-- CONTAINER

     The vast majority of <container> elements use one of the following forms:
     <container type="Folder">3</container>
     <container type="othertype">drawer 4</container>

     Because of this, append the @type to the text output for all containers,
     except when a container has been specifically marked as "othertype". 
-->
<xsl:template match="ead:container">
  <div>
    <xsl:value-of select="concat(@type, ' ')"/> <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="ead:container[@type='Othertype']">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- CORPNAME -->
<xsl:template match="ead:corpname">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:corpname[not(ancestor::ead:publisher) and not(ancestor::ead:repository)]">
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/organizations/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<xsl:template match="ead:namegrp/ead:corpname">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<xsl:template match="ead:namegrp/ead:corpname[not(ancestor::ead:publisher) and not(ancestor::ead:repository)]">
  <li>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="build_search_link">
          <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/organizations/'"/>
          <xsl:with-param name="s" select="string(.)"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </li>
</xsl:template>

<!-- CREATION -->
<xsl:template match="ead:creation">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- DAO -->
<xsl:template match="ead:dao">
  <a href="{@href}">
    <xsl:apply-templates select="@*[name() != 'href']|node()"/>
  </a>
</xsl:template>

<!-- DAODESC -->
<xsl:template match="ead:daodesc">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:daogrp/ead:daodesc">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- DAOGRP -->
<xsl:template match="ead:daogrp">
  <ul>
    <xsl:apply-templates select="@*|node()"/>
  </ul>
</xsl:template>

<!-- DAOLOC -->
<xsl:template match="ead:daoloc">
  <a href="{@href}">
    <xsl:apply-templates select="@*[name() != 'href']|node()"/>
  </a>
</xsl:template>

<xsl:template match="ead:daogrp/ead:daoloc">
  <li>
    <a href="{@href}">
      <xsl:apply-templates select="@*[name() != 'href']|node()"/>
    </a>
  </li>
</xsl:template>

<!-- DATE -->
<xsl:template match="ead:date">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:change/ead:date|ead:chronlist/ead:date">
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
      <dl>
        <xsl:apply-templates select="@*|*[not(self::ead:unitid) and not(self::ead:container)]|text()"/>
      </dl>
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

<!-- EADGRP -->
<xsl:template match="ead:eadgrp">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- EADHEADER -->
<xsl:template match="ead:eadheader"/>

<!-- EADID -->
<xsl:template match="ead:eadid"/>

<!-- EDITION -->
<xsl:template match="ead:edition">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- EDITIONSTMT -->
<xsl:template match="ead:editionstmt">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- EMPH -->
<xsl:template match="ead:emph[@render='bold']">
  <strong>
    <xsl:apply-templates select="@*|node()"/>
  </strong>
</xsl:template>

<xsl:template match="ead:emph[@render='bolddoublequote']">
  <strong>
    “<xsl:apply-templates select="@*|node()"/>”
  </strong>
</xsl:template>

<xsl:template match="ead:emph[@render='bolditalic']">
  <strong>
    <em>
      <xsl:apply-templates select="@*|node()"/>
    </em>
  </strong>
</xsl:template>

<xsl:template match="ead:emph[@render='boldsinglequote']">
  <strong>
    ‘<xsl:apply-templates select="@*|node()"/>’
  </strong>
</xsl:template>

<xsl:template match="ead:emph[@render='boldunderline']">
  <strong>
    <u>
      <xsl:apply-templates select="@*|node()"/>
    </u>
  </strong>
</xsl:template>

<xsl:template match="ead:emph[@render='doublequote']">
  “<xsl:apply-templates select="@*|node()"/>”
</xsl:template>

<xsl:template match="ead:emph[@render='italic']">
  <em>
    <xsl:apply-templates select="@*|node()"/>
  </em>
</xsl:template>

<xsl:template match="ead:emph[@render='singlequote']">
  ‘<xsl:apply-templates select="@*|node()"/>’
</xsl:template>

<xsl:template match="ead:emph[@render='sub']">
  <sub>
    <xsl:apply-templates select="@*|node()"/>
  </sub>
</xsl:template>

<xsl:template match="ead:emph[@render='super']">
  <sup>
    <xsl:apply-templates select="@*|node()"/>
  </sup>
</xsl:template>

<xsl:template match="ead:emph[@render='underline']">
  <u>
    <xsl:apply-templates select="@*|node()"/>
  </u>
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

<!-- EVENTGRP -->
<xsl:template match="ead:eventgrp">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- EXPAN -->
<xsl:template match="ead:expan">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:expan[@abbr]">
  <abbr title="{@expan}">
    <xsl:apply-templates select="@*[name() != 'abbr']|node()"/>
  </abbr>
</xsl:template>

<!-- EXTENT -->
<xsl:template match="ead:extent">
  <xsl:apply-templates select="@*|node()"/>
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

<!-- EXTPTRLOC -->
<xsl:template match="ead:extptrloc">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:daogrp/ead:extptrloc | ead:linkgrp/ead:extptrloc">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- EXTREF -->
<xsl:template match="ead:extref[@href]">
  <a href="{@href}">
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<!-- EXTREFLOC -->
<xsl:template match="ead:extrefloc[@href]">
  <a href="{@href}">
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<xsl:template match="ead:daogrp/ead:extrefloc[@href] | ead:linkgrp/ead:extrefloc[@href]">
  <li>
    <a href="{@href}">
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </li>
</xsl:template>

<!-- FAMNAME -->
<xsl:template match="ead:famname">
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/people/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<xsl:template match="ead:namegrp/ead:famname">
  <li>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="build_search_link">
          <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/people/'"/>
          <xsl:with-param name="s" select="string(.)"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </li>
</xsl:template>

<!-- FILEDESC -->
<xsl:template match="ead:filedesc">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- FILEPLAN -->
<xsl:template match="ead:fileplan">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- FRONTMATTER -->
<xsl:template match="ead:frontmatter">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- FUNCTION -->
<xsl:template match="ead:function">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:namegrp/ead:function">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- GENREFORM -->
<xsl:template match="ead:genreform">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:namegrp/ead:genreform">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- GEOGNAME -->
<xsl:template match="ead:geogname">
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/places/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<xsl:template match="ead:indexentry/ead:geogname">
  <dt>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="build_search_link">
          <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/places/'"/>
          <xsl:with-param name="s" select="string(.)"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </dt>
</xsl:template>

<xsl:template match="ead:namegrp/ead:geogname">
  <li>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="build_search_link">
          <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/places/'"/>
          <xsl:with-param name="s" select="string(.)"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </li>
</xsl:template>

<!-- HEAD -->
<xsl:template match="ead:head">
  <xsl:variable name="count">
    <xsl:value-of select="
      count(
        ancestor::ead:accessrestrict |
        ancestor::ead:accruals |
        ancestor::ead:acqinfo |
        ancestor::ead:altformavail |
        ancestor::ead:appraisal |
        ancestor::ead:arrangement |
        ancestor::ead:bibliography |
        ancestor::ead:bioghist |
        ancestor::ead:controlaccess |
        ancestor::ead:custodhist |
        ancestor::ead:descgrp |
        ancestor::ead:did |
        ancestor::ead:dsc |
        ancestor::ead:fileplan |
        ancestor::ead:index |
        ancestor::ead:note |
        ancestor::ead:odd |
        ancestor::ead:originalsloc |
        ancestor::ead:otherfindaid |
        ancestor::ead:phystech |
        ancestor::ead:prefercite |
        ancestor::ead:processinfo |
        ancestor::ead:relatedmaterial |
        ancestor::ead:scopecontent |
        ancestor::ead:separatedmaterial |
        ancestor::ead:userestrict
      )"/>
    </xsl:variable>
  <xsl:if test="$count &gt; 5">
     <xsl:message terminate="yes">ERROR: Elements are too deeply nested under archdesc.</xsl:message>
  </xsl:if>
  
  <xsl:element name="{concat('h', 1 + $count)}">
    <xsl:attribute name="id">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:element>
</xsl:template>

<!-- HIGHLIGHT -->
<xsl:template match="ead:highlight">
  <span class="highlight">
    <xsl:apply-templates select="@*|node()"/>
  </span>
</xsl:template>

<!-- IMPRINT -->
<xsl:template match="ead:imprint">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- ITEM -->
<xsl:template match="ead:change/ead:item">
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<xsl:template match="ead:defitem/ead:item">
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<xsl:template match="ead:list/ead:item">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- INDEX -->
<xsl:template match="ead:index">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- INDEXENTRY -->
<xsl:template match="ead:index">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- LABEL -->
<xsl:template match="ead:label">
  <dt>
    <xsl:apply-templates select="@*|node()"/>
  </dt>
</xsl:template>

<!-- LANGMATERIAL -->
<xsl:template match="ead:langmaterial">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:langmaterial">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*[name() != 'label']|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:langmaterial">
  <dt>Language</dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
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

<!-- LB -->
<xsl:template match="ead:lb">
  <br/>
</xsl:template>

<!-- LEGALSTATUS -->
<xsl:template match="ead:legalstatus">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- LINKGRP -->
<xsl:template match="ead:linkgrp">
  <ul>
    <xsl:apply-templates select="@*|node()"/>
  </ul>
</xsl:template>

<!-- LIST -->
<xsl:template match="ead:list">
  <xsl:apply-templates select="ead:head"/>
  <ul>
    <xsl:apply-templates select="@*|*[not(self::ead:head)]|text()"/>
  </ul>
</xsl:template>

<!-- LISTHEAD -->
<xsl:template match="ead:listhead">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- MATERIALSPEC -->
<xsl:template match="ead:materialspec">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:materialspec">
  <dt>Material Specific Details</dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- NAME -->
<xsl:template match="ead:name">
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/people/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<xsl:template match="ead:namegrp/ead:name">
  <li>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="build_search_link">
          <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/people/'"/>
          <xsl:with-param name="s" select="string(.)"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </li>
</xsl:template>

<!-- NAMEGRP -->
<xsl:template match="ead:namegrp">
  <ul>
    <xsl:apply-templates select="@*|node()"/>
  </ul>
</xsl:template>

<!-- NOTE -->
<xsl:template match="ead:note">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:dsc//ead:did/ead:note">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="ead:namegrp/ead:note">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:note">
  <dt>Note</dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- NOTESTMT -->
<xsl:template match="ead:notestmt">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- NUM -->
<xsl:template match="ead:num">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- OCCUPATION -->
<xsl:template match="ead:occupation">
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/topics/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<xsl:template match="ead:namegrp/ead:occupation">
  <li>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="build_search_link">
          <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/topics/'"/>
          <xsl:with-param name="s" select="string(.)"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </li>
</xsl:template>

<!-- ODD -->
<xsl:template match="ead:odd">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- ORIGINALSLOC -->
<xsl:template match="ead:originalsloc">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- ORIGINATION -->
<xsl:template match="ead:origination">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:origination">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*[name() != 'label']|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:origination">
  <dt>Origination</dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- OTHERFINDINGAID -->
<xsl:template match="ead:otherfindingaid">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- P -->
<xsl:template match="ead:p">
  <p>
    <xsl:apply-templates select="@*|node()"/>
  </p>
</xsl:template>

<!-- PERSNAME -->
<xsl:template match="ead:persname">
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/people/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<xsl:template match="ead:namegrp/ead:persname">
  <li>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="build_search_link">
          <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/people/'"/>
          <xsl:with-param name="s" select="string(.)"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </li>
</xsl:template>

<!-- PHYSDESC -->
<xsl:template match="ead:physdesc">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- top of archival description. note that in this part of the document, this
     element usually, but not always, contains an extent, although the label
     attribute is always on the physdesc. -->
<xsl:template match="ead:archdesc/ead:did/ead:physdesc">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*[name() != 'label']|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:physdesc">
  <dt>Physical Description</dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- PHYSFACET -->
<xsl:template match="ead:physfacet">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- PHYSLOC -->
<xsl:template match="ead:physloc">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:physloc">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*[name() != 'label']|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:physloc">
  <dt>Physical Location</dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- PHYSTECH -->
<xsl:template match="ead:phystech">
  <xsl:apply-templates select="@*|node()"/>
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
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- PUBLICATIONSTMT -->
<xsl:template match="ead:publicationstmt">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- PUBLISHER -->
<xsl:template match="ead:publisher">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- PTR -->
<xsl:template match="ead:ptr">
  <a href="{concat('#', @target)}">
    <xsl:value-of select="@title"/>
  </a>
</xsl:template>

<xsl:template match="ead:ptrgrp/ead:ptr">
  <li>
    <a href="{concat('#', @target)}">
      <xsl:value-of select="@title"/>
    </a>
  </li>
</xsl:template>

<!-- PTRGRP -->
<xsl:template match="ead:ptrgrp">
  <ul>
    <xsl:apply-templates select="@*|node()"/>
  </ul>
</xsl:template>

<!-- PTRLOC -->
<xsl:template match="ead:ptrloc">
  <div id="{@id}"/>
</xsl:template>

<!-- RELATEDMATERIAL -->
<xsl:template match="ead:relatedmaterial">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- REPOSITORY -->
<xsl:template match="ead:repository">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:repository">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*[name() != 'label']|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:repository">
  <dt>Repository</dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- REF -->
<xsl:template match="ead:ptrgrp/ead:ref">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- REFLOC -->
<xsl:template match="ead:refloc">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:daogrp/ead:refloc | ead:linkgrp/ead:refloc">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- RESOURCE -->
<xsl:template match="ead:resource">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:daogrp/ead:resource | ead:linkgrp/ead:resource">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
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

<!-- RUNNER -->
<xsl:template match="ead:runner"/>

<!-- SCOPECONTENT -->
<xsl:template match="ead:scopecontent">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- SEPARATEDMATERIAL -->
<xsl:template match="ead:separatedmaterial">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- SERIESSTMT -->
<xsl:template match="ead:seriesstmt">
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
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- SUBJECT -->
<xsl:template match="ead:subject">
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="build_search_link">
        <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/topics/'"/>
        <xsl:with-param name="s" select="string(.)"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<xsl:template match="ead:entry/ead:subject">
  <div>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="build_search_link">
          <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/topics/'"/>
          <xsl:with-param name="s" select="string(.)"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </div>
</xsl:template>

<xsl:template match="ead:namegrp/ead:subject">
  <li>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="build_search_link">
          <xsl:with-param name="ns" select="'https://bmrc.lib.uchicago.edu/topics/'"/>
          <xsl:with-param name="s" select="string(.)"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </a>
  </li>
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

<!-- TGROUP -->
<xsl:template match="ead:tgroup">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- THEAD -->
<xsl:template match="ead:thead">
  <thead>
    <xsl:apply-templates select="@*|node()"/>
  </thead>
</xsl:template>

<!-- TITLE -->
<xsl:template match="ead:namegrp/ead:title">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="ead:title[@render='italic']">
  <em>
    <xsl:apply-templates select="@*|node()"/>
  </em>
</xsl:template>

<xsl:template match="ead:namegrp/ead:title">
  <li>
    <xsl:apply-templates select="@*|node()"/>
  </li>
</xsl:template>

<!-- TITLEPAGE -->
<xsl:template match="ead:titlepage">
  <xsl:apply-templates select="ead:titleproper"/>
</xsl:template>

<!-- TITLEPROPER -->
<xsl:template match="ead:titleproper">
  <h1>
    <xsl:apply-templates select="@*|node()"/>
  </h1>
</xsl:template>

<!-- TITLESTMT -->
<xsl:template match="ead:titlestmt">
  <xsl:apply-templates select="@*|node()"/>
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
    <xsl:apply-templates select="@*[name() != 'label']|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:unitdate">
  <dt>Date</dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- UNITID -->
<xsl:template match="ead:unitid">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- top of archival description -->
<xsl:template match="ead:archdesc/ead:did/ead:unitid">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates select="@*[name() != 'label']|node()"/>
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
    <xsl:apply-templates select="@*[name() != 'label']|node()"/>
  </dd>
</xsl:template>

<!-- inventory -->
<xsl:template match="ead:dsc//ead:did/ead:unittitle">
  <dt>Title</dt>
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<!-- USERESTRICT -->
<xsl:template match="ead:userestrict">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- BUILD SEARCH LINKS -->
<xsl:template name="build_search_link">
  <xsl:param name="ns"/>
  <xsl:param name="s"/>
  <xsl:value-of select="ucf:bmrc_search_url(
    $ns,
    $s
  )"/>
</xsl:template>

</xsl:stylesheet>
