<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs xhtml tei" version="2.0">
    
    <xsl:output 
        method="xml" 
        indent="yes" 
        omit-xml-declaration="no" 
        encoding="UTF-8"/>

    
    <xsl:variable name="DOM" select="document('./http:_www.dom-en-ligne.de_lemlist.php.html')"/>
    

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Classes du DOM:
        p/@class	
        *****
        sDom
        	a/@class lm (lemme du DOM)
        *****
        sVel
        	a/@class lmvar (variante)
        sVeR
        	a/@class lmray (?)
        sNVeL
        	a/@class lmNvar (variante fléchie)
        sAdRef
        	a/@class lmadd (?)
        sRn (Raynouard?)
        	a/@class lmlv (lemme Levy?)
        sRnLv (Raynouard/Levy?)
        	a/@class lmlv (lemme Levy?)
        sLv (Levy?)
        	a/@class lmlv (lemme Levy?)
        sLvP (Petit Levy?)
        	a/@class lmlv (lemme Levy?)
    -->
    <xsl:template match="tei:entry/tei:form[1]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
        <xsl:variable name="maForme">
            <xsl:value-of select="."/>
        </xsl:variable>
        <!-- Zut, leurs fichiers ne sont pas XML conformes,
            car c'est du HTML5 à la noix, avec des <link> non refermés…
            Il va falloir bidouiller.
            Idée, pour se simplifier la vie:
            premier passage, on télécharge tout, on colle dans un dossier. On 
            utilise un script pour en faire du xhtml (cf. XSL_get_DOM.xsl)
            deuxième passage, on récupère et transforme.
            -->
        <xsl:for-each select="$DOM/html/body/p/a[matches(., concat('^\[?', $maForme, '\d?\]?$'))]">
            <xsl:sort select="@class" data-type="text" order="ascending"/>
            <xsl:sort select="." data-type="text" order="ascending"/>
            <xsl:variable 
                name="maRef" 
                select="
                concat('./DOM/',
                substring-before(substring-after(@href, 'http://www.dom-en-ligne.de/'), '&amp;'))"/>
            
           <!-- <xsl:variable 
                name="monFichierExt" 
                select="unparsed-text(@href, 'utf-8')"/>
            <xsl:value-of select="$monFichierExt" disable-output-escaping="yes"/>
            <xsl:variable name="monDocNP">
                <xsl:analyze-string 
                    select="$monFichierExt" 
                    regex="&lt;div.*div&gt;">
                    <xsl:matching-substring>
                        <xsl:value-of select="." disable-output-escaping="yes"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>-->
            <xsl:variable 
                name="monDoc"
                select="document($maRef)"/>
            <!--<xsl:value-of select="$maRef"/>
            <xsl:text>
                
            </xsl:text>
            <xsl:copy-of select="$monDoc"></xsl:copy-of>-->
            
            <form source="#DOM" type="{@class}" cert="unknown">
                <xsl:value-of select="."/>
            </form>
            <xsl:if test="@class != 'lm'">
                <form source="#DOM" type="{$monDoc//xhtml:div/@class}" cert="unknown">
                    <xsl:value-of select="$monDoc//xhtml:p[@class='lemma']//xhtml:b[1]"/>
                </form>
            </xsl:if>
            <xsl:for-each select="$monDoc//xhtml:div[@class]">
                <note source="#DOM" type="{@class}">
                    <xsl:apply-templates mode="copyDOM"/>
                </note>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="xhtml:p" mode="copyDOM">
        <p>
            <xsl:if test="@class">
                <xsl:attribute name="type"><xsl:value-of select="@class"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="copyDOM"/>
        </p>
    </xsl:template>
    <xsl:template match="xhtml:a" mode="copyDOM">
        <ref>
        <xsl:if test="@class">
            <xsl:attribute name="type"><xsl:value-of select="@class"/></xsl:attribute>
        </xsl:if>
            <xsl:if test="@href">
                <xsl:attribute name="target"><xsl:value-of select="concat('http://www.dom-en-ligne.de/', substring-after(@href, '../'))"/></xsl:attribute>
            </xsl:if>
        <xsl:apply-templates mode="copyDOM"/>
        </ref>
    </xsl:template>
    <xsl:template match="xhtml:b" mode="copyDOM">
        <mentioned><xsl:apply-templates mode="copyDOM"/></mentioned>
    </xsl:template>
    <xsl:template match="xhtml:i" mode="copyDOM">
        <hi><xsl:apply-templates mode="copyDOM"/></hi>
    </xsl:template>
    
    <xsl:template match="text()" mode="copyDOM">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
<!-- TODO
        
        
- Identifier les nombres par leur contenu;
- Annoter automatiquement les noms de personne, en fonction de l'emploi des majuscules (plusieurs mots
    de suite commençant par des majuscules);
- Éventuellement, identifier les élisions par la ponctuation;
- Quand on aura aligné les lemmes, ajouter le lemme en fonction du ancestor-or-self::entry/form
- Possibilité d'ajout supervisé de lemmes en fonction du contenu/du contexte, etc.
    
    
    -->    


</xsl:stylesheet>
