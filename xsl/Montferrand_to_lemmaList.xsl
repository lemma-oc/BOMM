<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        
        <xsl:result-document href="../referentiels/addLemmas_Montferrand.txt">
            <xsl:apply-templates select="//entry[not(form[@source='#DOM']) and form[@source='#DOMlike']]/form[@source='#DOMlike']"/>
        </xsl:result-document>
        
        <xsl:result-document href="../referentiels/NP_Montferrand.txt">
            <xsl:apply-templates select="//form[@source='none']"/>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template match="form">
        <xsl:apply-templates/>
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>
    
    
</xsl:stylesheet>