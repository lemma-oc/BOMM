<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <!--<xsl:output method="text"/>-->
    
    <xsl:variable name="DOM" select="document('./http:_www.dom-en-ligne.de_lemlist.php.html')"/>
    
    <xsl:template match="/">
        <xsl:variable name="passage1">
        <root>
        <xsl:apply-templates select="descendant::tei:entry"/>
        </root>
        </xsl:variable>
        
        <xsl:for-each select="distinct-values($passage1//@href)">
            <xsl:text>wget </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>&#xA;</xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tei:entry">
        <xsl:apply-templates select="tei:form[1]"/>
    </xsl:template>
    
    <xsl:template match="tei:form">
        <xsl:variable name="maForme">
            <xsl:value-of select="."/>
        </xsl:variable>
        <xsl:for-each select="$DOM/html/body/p/a[matches(., concat('^\[?', $maForme, '\d?\]?$'))]">
            <xsl:sort select="@class" data-type="text" order="ascending"/>
            <xsl:sort select="." data-type="text" order="ascending"/>
            <lien href="{@href}"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>