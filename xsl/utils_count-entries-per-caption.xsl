<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        
        <xsl:apply-templates 
            select="descendant::tei:div[@xml:id='glossaire']"/>
        
    </xsl:template>
    
    <xsl:template match="tei:div">
        <xsl:for-each select="tei:caption">
            <xsl:value-of select="."/>
            <xsl:text>  </xsl:text>
            <xsl:variable name="id" select="generate-id(.)"/>
            <xsl:value-of select="count(
                following::tei:entry[generate-id(preceding::tei:caption[1]) = $id ]
                
                )"/>
            <xsl:text>&#xA;</xsl:text>
            
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>