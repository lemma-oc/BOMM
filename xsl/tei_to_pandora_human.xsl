<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="descendant::tei:w"/>
    </xsl:template>
        
    <xsl:template match="tei:w">
        <xsl:variable name="contenu">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:value-of select="translate(normalize-unicode($contenu, 'NFC'), ' ', '_')"/>
        <xsl:if test="ancestor::tei:note">
            <!-- si le mot fait partie d'un passage fautif, raturé, je le marque par  -->
            <xsl:text>†</xsl:text>
        </xsl:if>
        <!--<xsl:text>&#9;</xsl:text>
        <xsl:value-of select="translate(normalize-unicode(@lemma, 'NFC'), ' ', '_')"/>-->
        <!--<xsl:text>&#9;</xsl:text>
        <xsl:value-of select="substring-after(tokenize(@ana, ' ')[matches(., 'CATTEX2009_MS_pos_')], 'CATTEX2009_MS_pos_')"/>
        <!-\-<xsl:text>(</xsl:text>-\->
        <xsl:text>&#9;</xsl:text>
        <xsl:variable name="morph">
            <xsl:for-each select="tokenize(@ana, ' ')[matches(., 'CATTEX2009_MS_(MODE|TEMPS|PERS.|NOMB.|GENRE|CAS|DEGRE)')]">
                <xsl:value-of select="substring-after(., '#CATTEX2009_MS_')"/>
                <xsl:if test="position() != last()"><xsl:text>|</xsl:text></xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$morph != ''"><xsl:value-of select="$morph"/></xsl:when>
            <xsl:otherwise>_</xsl:otherwise>
        </xsl:choose>
        
        <xsl:text>)</xsl:text>-->
        <!--<xsl:text>&#9;</xsl:text>
        <xsl:text>nihil</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>nihil</xsl:text>-->
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>
    
    <!--<xsl:template match="tei:del"/>
    <xsl:template match="tei:add">
        <xsl:apply-templates/>
    </xsl:template>-->
    
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    <!-- Créer une XSL standard forme  normalisée-->
    <xsl:template match="tei:orig"/>
    <xsl:template match="tei:abbr"/>
    <!--<xsl:template match="tei:note"/>
    <xsl:template match="tei:sic"/><!-\- TODO: faire très attention avec ça -\->-->
    
    <!-- Propre à Montferrand -->
    <xsl:template match="tei:gap">
        <xsl:text>...</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:sic[ancestor::tei:w]">
        <xsl:text>†</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>†</xsl:text>
    </xsl:template>
    <xsl:template match="tei:del[ancestor::tei:w]">
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>
    <xsl:template match="tei:add">
        <xsl:text>\</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>/</xsl:text>
    </xsl:template>
    <xsl:template match="tei:supplied">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    
   
    
    <!-- Normalisation des majuscules -->
    <xsl:template match="text()[. is ancestor::tei:w/descendant::text()[1] and (ancestor::tei:name|ancestor::tei:forename|ancestor::tei:placeName)]">
        <xsl:value-of select="upper-case(substring(., 1, 1))"/>
        <xsl:value-of select="substring(.,2)"/>
    </xsl:template>
    
    
    
</xsl:stylesheet>