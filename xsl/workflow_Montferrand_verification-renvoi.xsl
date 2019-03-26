<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    <xsl:output method="text"/>
    
    
    <xsl:template match="/">
        <xsl:apply-templates select="descendant::tei:entry[descendant::tei:xr]"/>
    </xsl:template>
    <xsl:template 
        match="tei:entry[descendant::tei:xr]">
        <xsl:variable
        name="maRef"
        select="substring-after(tei:xr/tei:ref[1]/@target, '#')"
        />
        <xsl:if 
            test="tei:form[@type=('lm', 'lmlv')]
            != /descendant::tei:entry[@xml:id=$maRef]/tei:form[@type=('lm', 'lmlv')]
            ">
            <xsl:text>Lemme entrée </xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text> différent renvoi </xsl:text>
            <xsl:value-of select="//tei:entry[@xml:id=$maRef]/@n"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="tei:form[@type=('lm', 'lmlv')]"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="//tei:entry[@xml:id=$maRef]/tei:form[@type=('lm', 'lmlv')]"/>
            <xsl:text>&#xA;</xsl:text>
            
        </xsl:if>
        
    </xsl:template>
    
    
</xsl:stylesheet>