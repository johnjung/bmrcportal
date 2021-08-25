<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
 xmlns:ead="urn:isbn:1-931666-22-9"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output omit-xml-declaration="yes"/>

<!-- PARAMETER: EADID -->
<xsl:param name="eadid"/>

<!-- PARAMETER: Q -->
<xsl:param name="q"/>

<!-- CONTINUE -->
<xsl:template match="dsc//did">
  <xsl:apply-templates/>
</xsl:template>

<!-- CONVERT TO P -->
<xsl:template match="ead:corpname | ead:geoname | ead:occupation | ead:unitdate">
<p><xsl:apply-templates/></p>
</xsl:template>

<!-- * -->
<xsl:template match="*">
  <xsl:apply-templates/>
</xsl:template>

<!-- @LABEL -->
<!-- can occur within abstract -->
<xsl:template match="@label">
  <h3 id="{generate-id(.)}"><xsl:value-of select="."/></h3>
</xsl:template>

<!-- ABBR -->
<xsl:template match="ead:abbr">
  <xsl:apply-templates/>
</xsl:template>

<!-- ABSTRACT -->
<xsl:template match="ead:abstract">
  <xsl:apply-templates select="@label"/>
  <xsl:if test="not(@label)"> 
    <h3 id="{generate-id(.)}">Abstract</h3>
  </xsl:if>
  <p><xsl:apply-templates/></p>
</xsl:template>

<!-- ACCESSRESTRICT -->
<xsl:template match="ead:accessrestrict">
  <xsl:if test="not(ead:head)">
    <h3 id="{generate-id(.)}">Access Restrictions</h3>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- ACCRUALS -->
<xsl:template match="ead:accruals">
  <xsl:if test="not(ead:head)">
    <h3 id="{generate-id(.)}">Accruals</h3>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- ACQINFO -->
<xsl:template match="ead:acqinfo">
  <xsl:if test="not(ead:head)">
    <h3 id="{generate-id(.)}">Acquisition Information</h3>
  </xsl:if>
  <xsl:apply-templates/>
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

<!-- ALTFORMAVAIL -->
<xsl:template match="ead:altformavail">
  <xsl:if test="not(ead:head)">
    <h3 id="{generate-id(.)}">Alternate Format Available</h3>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- APPRAISAL -->
<xsl:template match="ead:appraisal">
  <xsl:if test="not(ead:head)">
    <h3 id="{generate-id(.)}">Appraisal</h3>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- ARC -->
<!-- TODO: revisit -->
<xsl:template match="ead:arc"/>

<!-- ARCHDESC -->
<xsl:template match="ead:archdesc">
  <xsl:apply-templates/>
</xsl:template>

<!-- ARCHDESCGRP -->
<xsl:template match="ead:archdescgrp">
  <xsl:apply-templates/>
</xsl:template>

<!-- ARCHREF -->
<xsl:template match="ead:archref">
  <div>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- ARRANGEMENT -->
<xsl:template match="ead:arrangement">
  <xsl:if test="not(ead:head)">
    <h3 id="{generate-id(.)}">Arrangement</h3>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- AUTHOR -->
<xsl:template match="ead:author">
  <div><xsl:apply-templates/></div>
</xsl:template>

<!-- BIBLIOGRAPHY -->
<xsl:template match="ead:bibliography">
  <xsl:if test="not(ead:head)">
    <h3 id="{generate-id(.)}">Bibliography</h3>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- BIBREF -->
<xsl:template match="ead:bibref">
  <div><xsl:apply-templates/></div>
</xsl:template>

<!-- BIBSERIES -->
<xsl:template match="ead:bibseries">
  <div><xsl:apply-templates/></div>
</xsl:template>

<!-- BIOGHIST -->
<xsl:template match="ead:bioghist">
  <xsl:if test="not(ead:head)">
    <h3 id="{generate-id(.)}">Biographical Note</h3>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- BLOCKQUOTE -->
<xsl:template match="ead:blockquote">
  <blockquote><xsl:apply-templates/></blockquote>
</xsl:template>

<!-- C## -->
<xsl:template match="
  ead:c[@level] | 
  ead:c01[@level] | ead:c02[@level] | ead:c03[@level] | ead:c04[@level] |
  ead:c05[@level] | ead:c06[@level] | ead:c07[@level] | ead:c08[@level] |
  ead:c09[@level] | ead:c10[@level] | ead:c11[@level] | ead:c12[@level]"> 
<div class="series"><xsl:apply-templates/></div>
</xsl:template>

<!-- CHANGE -->
<xsl:template match="ead:change">
  <div>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- CHRONITEM -->
<xsl:template match="ead:chronitem">
  <div>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- CHRONLIST -->
<xsl:template match="ead:chronlist">
  <div>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- COLSPEC -->
<xsl:template match="ead:colspec"/>

<!-- CONTAINER TYPE BOX -->
<xsl:template match="ead:container[@type='box'] | ead:container[@type='Box']">
  <div>Box <xsl:apply-templates/></div>
</xsl:template>

<!-- CONTAINER TYPE FOLDER -->
<xsl:template match="ead:container[@type='folder'] | ead:container[@type='Folder']">
  <div>Folder <xsl:apply-templates/></div>
</xsl:template>

<!-- CONTAINER TYPE OTHERTYPE -->
<xsl:template match="ead:container[@type='othertype']">
  <div><xsl:apply-templates/></div>
</xsl:template>

<!-- CONTROLACCESS -->
<xsl:template match="ead:controlaccess">
  <xsl:if test="not(ead:head)">
    <h3 id="{generate-id(.)}">Biographical Note</h3>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- CORPNAME -->
<xsl:template match="ead:corpname">
  <xsl:apply-templates/>
</xsl:template>

<!-- CREATION -->
<xsl:template match="ead:creation">
  <xsl:apply-templates/>
</xsl:template>

<!-- CUSTODHIST -->
<xsl:template match="ead:custodhist">
  <xsl:if test="not(ead:head)">
    <h3 id="{generate-id(.)}">Custodial History</h3>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- DAO -->
<xsl:template match="ead:dao">
  <xsl:apply-templates/>
</xsl:template>

<!-- DAODESC -->
<xsl:template match="ead:daodesc">
  <xsl:apply-templates/>
</xsl:template>

<!-- DAOGRP -->
<xsl:template match="ead:daogrp">
  <xsl:apply-templates/>
</xsl:template>

<!-- DAOLOC -->
<xsl:template match="ead:daoloc">
  <a href="{@href}"><xsl:value-of select="."/></a>
</xsl:template>

<!-- DATE -->
<xsl:template match="ead:date">
  <xsl:apply-templates/>
</xsl:template>

<!-- DESCGRP -->
<xsl:template match="ead:descgrp">
  <xsl:apply-templates/>
</xsl:template>

<!-- DESCRULES -->
<xsl:template match="ead:descrules">
  <div>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- DID -->
<xsl:template match="ead:did">
  <xsl:apply-templates/>
</xsl:template>

<!-- DIMENSIONS -->
<xsl:template match="ead:dimensions">
  <xsl:apply-templates/>
</xsl:template>

<!-- DIV -->
<xsl:template match="ead:div">
  <div>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- DSC -->
<xsl:template match="ead:dsc">
  <xsl:apply-templates/>
</xsl:template>

<!-- DSCGRP -->
<xsl:template match="ead:dscgrp">
  <xsl:apply-templates/>
</xsl:template>

<!-- EAD -->
<xsl:template match="ead:ead">
  <xsl:apply-templates/>
</xsl:template>

<!-- EADGRP -->
<xsl:template match="ead:eadgrp">
  <xsl:apply-templates/>
</xsl:template>

<!-- EADHEADER -->
<xsl:template match="ead:eadheader">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ead:eadheader[@audience='internal']"/>

<!-- EADID -->
<xsl:template match="ead:eadid"/>

<!-- GEOGNAME -->
<xsl:template match="ead:geogname">
<p><xsl:apply-templates/></p>
</xsl:template>

<!-- HEAD -->
<xsl:template match="ead:head">
<h3 id="{generate-id(.)}"><xsl:apply-templates/></h3>
</xsl:template>

<!-- HIGHLIGHT -->
<xsl:template match="ead:highlight">
<span class="highlight"><xsl:value-of select="."/></span>
</xsl:template>

<!-- ITEM -->
<xsl:template match="ead:item">
<li><xsl:apply-templates/></li>
</xsl:template>

<!-- LIST -->
<xsl:template match="ead:list">
<ul><xsl:apply-templates/></ul>
</xsl:template>

<xsl:template match="ead:dsc//ead:list">
<ul class="bullets"><xsl:apply-templates/></ul>
</xsl:template>

<!-- NOTE -->
<xsl:template match="ead:note">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="ead:note[@label='Note']">
<p><strong>Note</strong></p><xsl:apply-templates/>
</xsl:template>

<!-- NUM -->
<xsl:template match="ead:num"/>

<!-- ORIGINATION -->
<xsl:template match="ead:origination">
<p class="note"><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="ead:origination[@label='Collector']">
<p><strong>Collector</strong></p><p><xsl:apply-templates/></p>
</xsl:template>

<!-- P -->
<xsl:template match="ead:p">
<p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="ead:dsc//ead:p">
<p class="note"><xsl:apply-templates/></p>
</xsl:template>

<!-- PHYSDESC -->
<xsl:template match="ead:physdesc[@label='Size'] | ead:physdesc[@label='size'] | ead:physdesc[@label='Alternate Extent Statement']">
<p><strong>Size</strong></p><xsl:apply-templates/>
</xsl:template>

<xsl:template match="ead:physdesc">
<p class="note"><xsl:apply-templates/></p>
</xsl:template>

<!-- PROFILEDESC -->
<xsl:template match="ead:profiledesc">
  <p><strong>Profile Description</strong></p><xsl:apply-templates/>
</xsl:template>

<!-- PUBLICATIONSTMT -->
<xsl:template match="ead:publicationstmt">
<p><strong>Publication Statement</strong></p><xsl:apply-templates/>
</xsl:template>

<!-- PUBLISHER -->
<xsl:template match="ead:publisher">
<xsl:apply-templates/><br/>
</xsl:template>

<!-- REPOSITORY -->
<xsl:template match="ead:repository">
<p><strong>Repository</strong></p><xsl:apply-templates/>
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

<!-- TITLE -->
<xsl:template match="ead:title">
  <xsl:apply-templates/>
</xsl:template>

<!-- TITLEPAGE -->
<xsl:template match="ead:titlepage">
<xsl:apply-templates/>
</xsl:template>

<!-- TITLEPROPER -->
<xsl:template match="ead:titleproper">
<h1><xsl:apply-templates/></h1>
</xsl:template>

<!-- TITLESTMT -->
<xsl:template match="ead:titlestmt">
<xsl:apply-templates/>
</xsl:template>

<!-- UNITDATE -->
<xsl:template match="ead:unitdate">
<p><strong>Dates</strong></p><p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="ead:dsc//ead:unitdate">
<p class="note"><xsl:apply-templates/></p>
</xsl:template>

<!-- UNITID -->
<xsl:template match="ead:unitid"/>

<!-- UNITTITLE -->
<xsl:template match="ead:unittitle">
<h1><xsl:apply-templates/></h1>
</xsl:template>

<xsl:template match="ead:unittitle[@label='Title'] | ead:unittitle[@label='title'] | ead:unittitle[@label='Collection Title']">
<p><strong>Title</strong></p><p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="ead:archref/ead:unittitle">
<p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template
 match="
  ead:c[@level and not(@level='file')]/ead:did/ead:unittitle | 
  ead:c01[@level and not(@level='file')]/ead:did/ead:unittitle | ead:c02[@level and not(@level='file')]/ead:did/unittitle |
  ead:c03[@level and not(@level='file')]/ead:did/ead:unittitle | ead:c04[@level and not(@level='file')]/ead:did/unittitle |
  ead:c05[@level and not(@level='file')]/ead:did/ead:unittitle | ead:c06[@level and not(@level='file')]/ead:did/unittitle |
  ead:c07[@level and not(@level='file')]/ead:did/ead:unittitle | ead:c08[@level and not(@level='file')]/ead:did/unittitle |
  ead:c09[@level and not(@level='file')]/ead:did/ead:unittitle | ead:c10[@level and not(@level='file')]/ead:did/unittitle |
  ead:c11[@level and not(@level='file')]/ead:did/ead:unittitle | ead:c12[@level and not(@level='file')]/ead:did/unittitle">
	<h3 id="{generate-id()}"><xsl:apply-templates/></h3>
</xsl:template>

<!-- NAVIGATION -->

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

<!-- skip these for finding aids like MTS.abbottsengstacke.xml -->
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

<xsl:template name="searchcount">
<xsl:value-of select="concat(' (', count(//ead:highlight), ')')"/>
</xsl:template>

</xsl:stylesheet>
