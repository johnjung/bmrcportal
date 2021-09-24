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

<!-- NODES AND ATTRIBUTES -->
<xsl:template match="*">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- ELEMENT NODES -->
<xsl:template match="ead:archdesc|ead:corpname|ead:ead|ead:language|ead:persname">
  <xsl:apply-templates/>
</xsl:template>

<!-- TEXT NODES -->
<xsl:template match="text()">
  <xsl:value-of select="."/>
</xsl:template>

<!-- SKIP -->
<xsl:template match="ead:arc|ead:colspec|ead:eadheader|ead:eadid"/>

<!-- CONVERT TO DIV -->
<xsl:template match="ead:archref|ead:author|ead:bibseries|ead:change|ead:container|ead:descrules|ead:div|ead:extent|ead:geogname|ead:langmaterial|ead:langusage|ead:materialspec|ead:note|ead:notestmt|ead:originalsloc|ead:physfacet|ead:physloc|ead:phystech|ead:profiledesc|ead:publisher|ead:repository|ead:sponsor|ead:subarea|ead:subtitle|ead:titlepage|ead:unitdate|ead:did/ead:unittitle">
  <div>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- @AUDIENCE -->
<xsl:template match="@audience"/>

<!-- @LABEL -->
<!-- can occur within abstract -->
<xsl:template match="@label">
  <h3 id="{generate-id(.)}"><xsl:value-of select="."/></h3>
</xsl:template>

<!-- ABSTRACT -->
<xsl:template match="ead:abstract">
  <xsl:apply-templates select="@*"/>
  <p>
    <xsl:apply-templates/>
  </p>
</xsl:template>

<!-- ADDRESS -->
<xsl:template match="ead:address">
  <address>
    <xsl:apply-templates/>
  </address>
</xsl:template>

<!-- ADDRESSLINE -->
<xsl:template match="ead:addressline">
  <xsl:apply-templates/>
  <xsl:if test="following-sibling::ead:addressline"><br/></xsl:if>
</xsl:template>

<!-- BLOCKQUOTE -->
<xsl:template match="ead:blockquote">
  <blockquote>
    <xsl:apply-templates/>
  </blockquote>
</xsl:template>

<!-- C## -->
<xsl:template match="ead:c">
  <div class="c">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- CHRONLIST -->
<xsl:template match="ead:chronlist">
  <dl>
    <xsl:apply-templates/>
  </dl>
</xsl:template>

<!-- CONTAINER TYPE BOX -->
<xsl:template match="ead:container[@type='box'] | ead:container[@type='Box']">
  <div>Box <xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<!-- CONTAINER TYPE FOLDER -->
<xsl:template match="ead:container[@type='folder'] | ead:container[@type='Folder']">
  <div>Folder <xsl:apply-templates/></div>
</xsl:template>

<!-- DAOLOC -->
<xsl:template match="ead:daoloc">
  <a href="{@href}">
    <xsl:value-of select="."/>
  </a>
</xsl:template>

<!-- DID -->
<xsl:template match="ead:archdesc/ead:did">
  <xsl:apply-templates select="ead:head"/>
  <dl>
    <xsl:apply-templates select="*[not(self::ead:head)]"/>
  </dl>
</xsl:template>

<!-- DSC -->
<xsl:template match="ead:dsc">
  <h3 id="{generate-id(.)}">Inventory</h3>
  <xsl:apply-templates/>
</xsl:template>

<!-- EMPH -->
<xsl:template match="ead:emph">
  <em>
    <xsl:apply-templates/>
  </em>
</xsl:template>

<xsl:template match="ead:emph[@render='bold']">
  <strong>
    <xsl:apply-templates/>
  </strong>
</xsl:template>

<!-- ENTRY -->
<xsl:template match="ead:entry">
  <td>
    <xsl:apply-templates/>
  </td>
</xsl:template>

<!-- EVENT -->
<xsl:template match="ead:event">
  <dd>
    <xsl:apply-templates/>
  </dd>
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
    <xsl:apply-templates/>
  </a>
</xsl:template>

<!-- EXTREFLOC -->
<xsl:template match="ead:extrefloc[@href]">
  <a href="{@href}">
    <xsl:apply-templates/>
  </a>
</xsl:template>

<!-- FUNCTION -->
<xsl:template match="ead:function">
  <li>
    <xsl:apply-templates/>
  </li>
</xsl:template>

<!-- GENREFORM -->
<xsl:template match="ead:genreform">
  <li>
    <xsl:apply-templates/>
  </li>
</xsl:template>

<!-- GEOGNAME -->
<xsl:template match="ead:imprint/ead:geogname">
  <div>
    <xsl:apply-templates/>
  </div>
</xsl:template>
<xsl:template match="ead:indexentry/ead:geogname">
  <dt>
    <xsl:apply-templates/>
  </dt>
</xsl:template>
<xsl:template match="ead:namegrp/ead:geogname">
  <li>
    <xsl:apply-templates/>
  </li>
</xsl:template>
<xsl:template match="ead:p/ead:geogname">
  <xsl:apply-templates/>
</xsl:template>

<!-- HEAD -->
<xsl:template match="ead:head">
  <h3 id="{generate-id(.)}">
    <xsl:apply-templates/>
  </h3>
</xsl:template>

<!-- HIGHLIGHT -->
<xsl:template match="ead:highlight">
  <span class="highlight">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<!-- IMPRINT -->
<xsl:template match="ead:imprint">
  <ul>
    <xsl:apply-templates/>
  </ul>
</xsl:template>

<!-- ITEM -->
<xsl:template match="ead:change/ead:item">
  <dd>
    <xsl:apply-templates/>
  </dd>
</xsl:template>
<xsl:template match="ead:defitem/ead:item">
  <dt>
    <xsl:apply-templates/>
  </dt>
</xsl:template>
<xsl:template match="ead:list/ead:item">
  <li>
    <xsl:apply-templates/>
  </li>
</xsl:template>

<!-- LABEL -->
<xsl:template match="ead:label">
  <dt>
    <xsl:apply-templates/>
  </dt>
</xsl:template>

<!-- LANGMATERIAL -->
<xsl:template match="ead:archdesc/ead:did/ead:langmaterial">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates/>
  </dd>
</xsl:template>

<!-- LIST -->
<xsl:template match="ead:list">
  <xsl:apply-templates select="ead:head"/>
  <ul>
    <xsl:apply-templates select="*[not(self::ead:head)]"/>
  </ul>
</xsl:template>

<!-- NAMEGRP -->
<xsl:template match="ead:namegrp">
  <ul>
    <xsl:apply-templates/>
  </ul>
</xsl:template>

<!-- OCCUPATION -->
<xsl:template match="ead:namegrp/ead:occupation">
  <div>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- ORIGINATION -->
<xsl:template match="ead:archdesc/ead:did/ead:origination">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates/>
  </dd>
</xsl:template>

<!-- P -->
<xsl:template match="ead:p">
  <p>
    <xsl:apply-templates/>
  </p>
</xsl:template>

<!-- PHYSDESC -->
<xsl:template match="ead:archdesc/ead:did/ead:physdesc">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates/>
  </dd>
</xsl:template>

<!-- REPOSITORY -->
<xsl:template match="ead:archdesc/ead:did/ead:repository">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates/>
  </dd>
</xsl:template>

<!-- REVISIONDESC -->
<xsl:template match="ead:revisiondesc">
  <dl>
    <xsl:apply-templates/>
  </dl>
</xsl:template>

<!-- ROW -->
<xsl:template match="ead:row">
  <tr>
    <xsl:apply-templates/>
  </tr>
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
      <xsl:apply-templates/>
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
    <xsl:apply-templates/>
  </a>
</xsl:template>

<!-- TABLE -->
<xsl:template match="ead:table">
  <table>
    <xsl:apply-templates/>
  </table>
</xsl:template>

<!-- TBODY -->
<xsl:template match="ead:tbody">
  <tbody>
    <xsl:apply-templates/>
  </tbody>
</xsl:template>

<!-- THEAD -->
<xsl:template match="ead:thead">
  <tbody>
    <xsl:apply-templates/>
  </tbody>
</xsl:template>

<!-- TITLE -->
<xsl:template match="ead:title[@render='italic']">
  <em>
    <xsl:apply-templates/>
  </em>
</xsl:template>

<!-- TITLEPROPER -->
<xsl:template match="ead:titleproper">
  <h1>
    <xsl:apply-templates/>
  </h1>
</xsl:template>

<!-- UNITDATE -->
<xsl:template match="ead:archdesc/ead:did/ead:unitdate">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dd>
    <xsl:apply-templates/>
  </dd>
</xsl:template>

<!-- UNITID -->
<xsl:template match="ead:unitid">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dl>
    <xsl:apply-templates/>
  </dl>
</xsl:template>

<!-- UNITTITLE -->
<xsl:template match="ead:archdesc/ead:did/ead:unittitle">
  <dt>
    <xsl:value-of select="@label"/>
  </dt>
  <dl>
    <xsl:apply-templates/>
  </dl>
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
