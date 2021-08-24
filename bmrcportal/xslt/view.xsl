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

<!-- SKIP -->
<!--
<xsl:template match="author | did | eadheader | dsc/head | langmaterial | langusage | publisher"/>
-->

<!-- CONVERT TO P -->
<xsl:template match="ead:corpname | ead:geoname | ead:occupation | ead:unitdate">
<p><xsl:apply-templates/></p>
</xsl:template>

<!-- * -->
<xsl:template match="*">
<xsl:apply-templates/>
</xsl:template>

<!-- ABSTRACT -->
<xsl:template match="ead:abstract">
<p><strong>Abstract</strong></p><p><xsl:apply-templates/></p>
</xsl:template>

<!-- ADDRESSLINE -->
<xsl:template match="ead:addressline">
<xsl:apply-templates/><br/>
</xsl:template>

<!-- AUTHOR -->
<xsl:template match="ead:author">
<p><xsl:apply-templates/></p>
</xsl:template>

<!-- C## -->
<xsl:template match="
  ead:c[@level] | 
  ead:c01[@level] | ead:c02[@level] | ead:c03[@level] | ead:c04[@level] |
  ead:c05[@level] | ead:c06[@level] | ead:c07[@level] | ead:c08[@level] |
  ead:c09[@level] | ead:c10[@level] | ead:c11[@level] | ead:c12[@level]"> 
<div class="series"><xsl:apply-templates/></div>
</xsl:template>

<!-- CONTAINER TYPE BOX -->
<xsl:template match="ead:container[@type='box'] | ead:container[@type='Box']">
<p class="box">Box <xsl:apply-templates/></p>
</xsl:template>

<!-- CONTAINER TYPE FOLDER -->
<xsl:template match="ead:container[@type='folder'] | ead:container[@type='Folder']">
<p class="folder">Folder <xsl:apply-templates/></p>
</xsl:template>

<!-- CONTAINER TYPE OTHERTYPE -->
<xsl:template match="ead:container[@type='othertype']">
<p class="othertype"><xsl:apply-templates/></p>
</xsl:template>

<!-- CONTROLACCESS (subject headings) -->
<xsl:template match="ead:controlaccess">
  <h3 id="{generate-id(.)}">Indexed Terms</h3>
  <ul><xsl:apply-templates/></ul>
</xsl:template>

<xsl:template match="ead:controlaccess/ead:address | ead:controlaccess/ead:blockquote | ead:controlaccess/ead:chronlist | ead:controlaccess/ead:controlaccess | ead:controlaccess/ead:corpname | ead:controlaccess/ead:famname | ead:controlaccess/ead:function | ead:controlaccess/ead:genreform | ead:controlaccess/ead:geogname | ead:controlaccess/ead:head | ead:controlaccess/ead:list | ead:controlaccess/ead:name | ead:controlaccess/ead:note | ead:controlaccess/ead:occupation | ead:controlaccess/ead:p | ead:controlaccess/ead:persname | ead:controlaccess/ead:subject | ead:controlaccess/ead:table | ead:controlaccess/ead:title">
	<li>
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat(
                  '/search/?q=',
                  . 
                )"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </li>
</xsl:template>

<!-- DAOLOC -->
<xsl:template match="ead:daoloc">
<p><a href="{@href}"><xsl:value-of select="."/></a></p>
</xsl:template>

<!-- DATE -->
<xsl:template match="ead:date">
<xsl:text> </xsl:text><xsl:apply-templates/>
</xsl:template>

<xsl:template match="ead:publicationstmt/ead:date">
<xsl:apply-templates/><br/>
</xsl:template>

<!-- DID -->
<xsl:template match="ead:did">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="ead:dsc//ead:did">
<div class="did"><xsl:apply-templates/></div>
</xsl:template>

<!-- DSC -->
<xsl:template match="ead:dsc">
  <xsl:apply-templates/>
</xsl:template>

<!-- EAD -->
<xsl:template match="ead:ead">
<!--
<div id="sidebar">
    <div id="search">
        <h2>Search this Finding Aid</h2>
        <form action="view.php" id="searchform" method="get">
            <input name="eadid" type="hidden" value="{$eadid}"/>
            <input name="q" type="text" value="{$q}"/>
            <input type="submit" value="Search"/>
            <p>
                <span class="plainsidebarlink" id="previousmatch">Previous Match</span>
                <span class="plainsidebarlink" id="nextmatch">Next Match</span>
            </p>
        </form>
    </div>
</div>
<div id="toc">
</div>
-->
<div id="text"><xsl:apply-templates/></div>
</xsl:template>

<!-- EADHEADER -->
<xsl:template match="ead:eadheader"/>

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
<xsl:template match="ead:title[@render='italic']">
<em><xsl:apply-templates/></em>
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
