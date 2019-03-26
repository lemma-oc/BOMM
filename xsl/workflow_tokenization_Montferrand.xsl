<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei" version="2.0">

    
    
    

    <xsl:template match="@* | node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:variable name="copyWithAnchors">
            <xsl:apply-templates mode="addAnchors"/>
        </xsl:variable>
        <xsl:copy-of select="$copyWithAnchors"/>
        <!--<xsl:variable name="tokenize">
            <xsl:apply-templates select="$copyWithAnchors" mode="tokenize"/>
        </xsl:variable>
        <xsl:variable name="tagPunctuation">
            <xsl:apply-templates select="$tokenize" mode="tagPunctuation"/>
        </xsl:variable>
        <xsl:apply-templates select="$tagPunctuation" mode="handlePunctuation"/>-->
    </xsl:template>
    
    
    
    <xsl:template match="text()[ancestor::tei:l and not(ancestor::tei:w)  
        and not(ancestor::tei:damage) and not(ancestor::tei:note) and not(normalize-space(.) = '')
        and not((ancestor::tei:date|ancestor::tei:add|ancestor::tei:head)[@resp='editor'])
        ]"
        name="tokenise"
        mode="addAnchors">
        <xsl:variable name="regex"
            select='"(^|\s+|&apos;|’|‘)([\wéèçàäëïöüÿ-]+)($|\s+|&apos;|’|‘|[.,;:!?…«»])"'
            as="xs:string"
        />
        <xsl:analyze-string select="." regex="{$regex}">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test='regex-group(1) =  "&apos;"
                        or regex-group(1) = ("’", "‘")
                        '>
                        <pc><xsl:value-of select="regex-group(1)"/></pc>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <w><xsl:value-of select="regex-group(2)"/></w>
                <xsl:choose><!-- J'ai voulu éviter une regex pour la ponctuation, mais ce peut être contestable -->
                    <xsl:when test='
                        regex-group(3) = "." or
                        regex-group(3) = "," or
                        regex-group(3) = ";" or
                        regex-group(3) = ":" or
                        regex-group(3) = "!" or
                        regex-group(3) = "?" or
                        regex-group(3) = "…" or
                        regex-group(3) =  "&apos;" or
                        regex-group(3) = ("’","‘") or
                        regex-group(3) = ("«","»", "—")
                        '>
                        <pc><xsl:value-of select="regex-group(3)"/></pc>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="regex-group(3)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:choose>
                    <xsl:when test="
                        matches(., $regex)">
                        <xsl:call-template name="tokenise"/><!-- récursivité -->
                    </xsl:when>
                    <xsl:when test="matches(., '[.,;:!?…«»—]')">
                        <xsl:analyze-string select="." regex="[.,;:!?…«»—]">
                            <xsl:matching-substring>
                                <pc><xsl:value-of select="."/></pc>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:if test="normalize-space(.) != '' " >
                                    <xsl:comment>Vérif 2:</xsl:comment>
                                </xsl:if>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="normalize-space(.) != '' " >
                            <xsl:comment>Vérif 1:</xsl:comment>
                        </xsl:if>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    
    <!-- Je remise pour l'instant tout le code emprunté à la tokenisation LAKME, et je tente
        de tokeniser plus simplement. 
    -->

    <!--<xsl:template match="text()[ancestor::tei:body and not(ancestor::tei:w) and not(ancestor::tei:head) 
        and not(ancestor::tei:damage) and not(ancestor::tei:note) and not(normalize-space(.) = '')
        and not((following::node()[1] | preceding::node()[1])/local-name() = 'w')
        ]"
        mode="addAnchors">
        <xsl:analyze-string select="." regex="(\s+|&apos;)">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="matches(., '\s+')">
                        <anchor type="wordBoundary"/>
                    </xsl:when>
                    <xsl:when test='matches(., "&apos;")'>
                        <anchor type="wordBoundary" subtype="elision"/>
                        <pc type="supplied">'</pc>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>ERROR</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template match="element()[ancestor::tei:body and not(ancestor::tei:w) and not(ancestor::tei:head) 
        and not(ancestor::tei:damage) and not(ancestor::tei:note) and not(normalize-space(.) = '')]" mode="tokenize">
        <xsl:copy>
            <xsl:apply-templates select="attribute::*"/>
            <xsl:apply-templates select="child::tei:anchor | child::element()" mode="tokenize"/>
            <!-\- DEBUG: il n'y a aucune ancre, ou le mot ne fait qu'une ligne -\->
            <xsl:if test="not(descendant::tei:anchor)">
                <xsl:comment>ERROR ??</xsl:comment>
                <w><xsl:apply-templates/></w>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:anchor[@type = 'wordBoundary']" mode="tokenize">
        <xsl:choose>
            <xsl:when 
                test="preceding-sibling::tei:anchor[@type = 'wordBoundary']">
                <xsl:variable name="precedingAnchor"
                    select="preceding-sibling::tei:anchor[@type = 'wordBoundary'][1]"/>
                <w>
                    <xsl:if test="@subtype = 'elision'">
                        <xsl:attribute name="rend">elision</xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates
                        select="preceding-sibling::node()[preceding-sibling::tei:anchor[1] is $precedingAnchor]"
                        mode="#default"/>
                </w>
                <xsl:if test="not(@subtype = 'elision')">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:when
                test="not(preceding-sibling::tei:anchor[@type = 'wordBoundary']) and parent::tei:l">
                <w>
                    <xsl:apply-templates 
                        select="preceding-sibling::node()" 
                        mode="#default"/>
                </w>
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>ERROR ??</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
        <!-\- Et les derniers mots de la ligne -\->
        <xsl:if test="not(following-sibling::tei:anchor[@type = 'wordBoundary']) and parent::tei:l">
            <w>
                <xsl:apply-templates 
                    select="following-sibling::node()" 
                    mode="#default"/>
            </w>
        </xsl:if>
    </xsl:template>
    
    <!-\- gestion de la ponctuation -\->
    <xsl:template match="text()[ancestor::tei:w]" mode="tagPunctuation">
        <xsl:analyze-string select="." regex="[.,;:!?«»]">
            <xsl:matching-substring><pc type="supplied"><xsl:value-of select="."/></pc></xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <xsl:template mode="handlePunctuation" match="tei:w[descendant::tei:pc]">
        <xsl:choose>
            <!-\- Quand il n'y a que des ponctuations et de l'espace, on supprime le mot -\->
            <xsl:when test="count(child::node() except (child::tei:pc|child::text()[normalize-space(.) = '']) ) = 0">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <!-\- On commence par copier les nœuds de ponctuation qui seraient au début du mot -\->
                <xsl:apply-templates select="child::node()[position() = 1 and local-name() = 'pc']"/>
                <!-\- Puis le mot -\->
                <w>
                    <xsl:apply-templates select="@* | node() except tei:pc"/>
                </w>
                <!-\- Puis la ponctuation qui suit -\->
                <xsl:apply-templates select="child::node()[position() = last() and local-name() = 'pc']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
-->
</xsl:stylesheet>
