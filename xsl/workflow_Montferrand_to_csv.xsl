<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="text"/>

    <xsl:template match="/">
        <xsl:text>ID</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>token</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>cert</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>lemma</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>pos</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>subc</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>mood</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>tns</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>per</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>number</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>gen</xsl:text>
        <!-- Pas de notation des cas ou degrés d'adj. ? -->
        <xsl:text>&#xA;</xsl:text>

        <xsl:apply-templates select="descendant::tei:w"/>
    </xsl:template>

    <xsl:template match="tei:w">
        <xsl:text>w_</xsl:text>
        <xsl:number count="tei:w" level="any" format="00000"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:variable name="monW" as="xs:string">
            <xsl:choose>
                <!-- mot qui termine par s, on essaie sans le s -->
                <xsl:when test="ends-with(lower-case(.), 's') and string-length(.) > 1">
                    <xsl:value-of select="concat('^', lower-case(.), '?', '$')"/>
                </xsl:when>
                <!-- Je teste/prends le risque de rajouter un s à ceux qui n'en ont pas. 
                    Il faudra vérifier l'impact sur le nombre de *** -->
                <xsl:when test="not(ends-with(lower-case(.), 's')) and string-length(.) > 2">
                    <xsl:value-of select="concat('^', lower-case(.), 's?', '$')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('^', lower-case(.), '$')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--<xsl:value-of select="$monW"/>-->
        <xsl:variable name="monWlitteral" select="lower-case(.)" as="xs:string"/>
        <xsl:variable name="monWlitteralPreservedCase" select="." as="xs:string"/>
                <xsl:apply-templates/><!-- J'imprime le mot -->
        <xsl:if test="ancestor::tei:note">
            <!-- si le mot fait partie d'un passage fautif, raturé, je le marque par  -->
            <xsl:text>†</xsl:text>
        </xsl:if>
        <xsl:text>&#9;</xsl:text>
        <!-- Les lemmes peuvent avoir trois niveaux de certitude:
            *** renvoi au lemme existant dans l'édition Lodge
            **  lemme calculé automatiquement, sans ambiguïté
            *   entrée à désambiguïser
            0   pas de correspondance trouvée
        -->
        <xsl:choose>
            <xsl:when test="@lemmaRef">
                <xsl:variable name="Ref" select="substring-after(@lemmaRef, '#')"/>
                <xsl:text>***</xsl:text>
                <xsl:text>&#9;</xsl:text>
                <xsl:apply-templates
                    select="/(descendant::tei:entry[@xml:id = $Ref] | descendant::tei:re[@xml:id = $Ref] | descendant::tei:form[@xml:id = $Ref]/(ancestor::tei:re|ancestor::tei:entry)[1])"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="count(/descendant::tei:form[not(@source or @type) and matches(lower-case(.), $monW)]) = 1"> 
                        <xsl:text>**</xsl:text>
                        <xsl:text>&#9;</xsl:text>
                        <xsl:apply-templates select="/descendant::tei:form[not(@source or @type) and matches(lower-case(.), $monW)]/(ancestor::tei:re|ancestor::tei:entry)[1]"/>
                    </xsl:when>
                    <xsl:when test="count(/descendant::tei:form[not(@source or @type) and matches(lower-case(.), $monW)]) > 1">
                        <xsl:text>*</xsl:text>
                        <xsl:text>&#9;</xsl:text>
                        <xsl:value-of 
                            select="/descendant::tei:form[not(@source or @type) and matches(lower-case(.), $monW)]/ancestor::tei:entry/tei:form[@type=('lm','lmlv')]" 
                            separator="|"/>
                        <xsl:text>&#9;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Et c'est là que le défi intéressant commence: récupérer un maximum d'entrées automatiquement -->
                        <xsl:choose>
                            <!-- Toutes ces abréviations de prénoms -->
                            <xsl:when 
                                test="$monWlitteralPreservedCase = ('A', 'B', 'D', 'E', 'G', 'H', 'J', 'Jo', 'M', 'P', 'R', 'S', 'T', 'V', 'W', 'Wmet') 
                                and following::element()[1] = '.'">
                                <xsl:text>**</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:value-of select="$monWlitteralPreservedCase"/>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>nom</xsl:text>
                                <xsl:text>propre</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>masculin</xsl:text>
                            </xsl:when>
                            
                            <!-- Mots très fréquents -->
                            <!-- d/d et s/s, unités de compte ou mots-outils -->
                            <xsl:when test="$monWlitteral = 'd'">
                                <xsl:choose>
                                    <xsl:when test='following::element()[1] = ("’", "&apos;")'>
                                        <xsl:text>**</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>de</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>préposition</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="matches(preceding::tei:w[1], '([DCLXVI]+|[dclxvi]+)')">
                                        <xsl:text>**</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>denier</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>nom</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>masculin</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>*</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>de|denier</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>préposition|nom</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>masculin</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <!-- Unités de compte -->
                            <xsl:when test="$monWlitteral = 's'">
                                <xsl:choose>
                                    <xsl:when test="matches(preceding::tei:w[1], '([DCLXVI]+|[dclxvi]+)')">
                                        <xsl:text>**</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>sol</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>nom</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>masculin</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>0</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text></xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text></xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text>&#9;</xsl:text>
                                        <xsl:text></xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </xsl:when>
                            <!-- las/los/li/le/lhi/l/lh -->
                            <xsl:when test="$monWlitteral = ('las','los','li','la','lo','lhi','l','lh', 'lor')">
                                <!-- Et maintenant, le vraiment dur, deviner si c'est un pronom ou déterminant -->
                                <xsl:variable name="folWpos">
                                    <xsl:variable name="monFolW" select="lower-case(following::tei:w[1])"/>
                                    <xsl:choose>
                                        <xsl:when test="following::tei:w[1]/@lemmaRef">
                                            <xsl:variable name="Ref" select="substring-after(following::tei:w[1]/@lemmaRef, '#')"/>
                                            <xsl:value-of 
                                                select="/(descendant::tei:entry[@xml:id = $Ref] | descendant::tei:re[@xml:id = $Ref] | descendant::tei:form[@xml:id = $Ref])/ancestor::tei:entry/tei:gramGrp/tei:pos"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of 
                                                select="/descendant::tei:form[not(@source or @type) and matches(., $monFolW)]/ancestor::tei:entry/tei:gramGrp/tei:pos"
                                                />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="$folWpos = 'verbe'">
                                        <xsl:choose>
                                            <xsl:when test="$monWlitteral = 'las'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>las4</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pronom</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pluriel</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>féminin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = 'la'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>la2</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pronom</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>singulier</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>féminin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = 'los'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>los2</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pronom</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pluriel</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>masculin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = ('li','le','lhi','lh')">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>lo3|li3|li4</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pronom</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>singulier</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>masculin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = 'l'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>lo3|la2</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pronom</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>singulier</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>masculin|féminin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = 'lo'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>lo3</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pronom</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>singulier</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>masculin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = 'lor'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>lor</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pronom</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pluriel</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>masculin|féminin</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Si pas de verbe suivant, on considère que déterminant -->
                                        <xsl:choose>
                                            <xsl:when test="$monWlitteral = 'las'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>las4</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>déterminant</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pluriel</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>féminin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = 'la'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>la</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>déterminant</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>singulier</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>féminin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = 'los'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>los</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>déterminant</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pluriel</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>masculin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = ('li','le','lhi','lh')">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>lo2</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>déterminant</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>singulier</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>masculin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = 'l'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>lo2|la</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>déterminant</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>singulier</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>masculin|féminin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = 'lo'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>lo2|lo|lo4|lo5</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>déterminant|pronom</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>singulier</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>masculin</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$monWlitteral = 'lor'">
                                                <xsl:text>*</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>lor</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>possessif</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>pluriel</xsl:text>
                                                <xsl:text>&#9;</xsl:text>
                                                <xsl:text>masculin|féminin</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>0</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                                <xsl:text>&#9;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>

    <xsl:template match="tei:entry | tei:re">
        <!--        
            lemma
        -->
        <xsl:value-of select="ancestor-or-self::tei:entry/tei:form[@type = ('lm', 'lmlv')]"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:choose>
            <xsl:when test="child::tei:gramGrp">
                <xsl:apply-templates select="child::tei:gramGrp"/>
            </xsl:when>
            <xsl:when test="ancestor-or-self::tei:entry/tei:gramGrp">
                <xsl:apply-templates select="child::tei:entry/tei:gramGrp"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#9;</xsl:text>
                <xsl:text>&#9;</xsl:text>
                <xsl:text>&#9;</xsl:text>
                <xsl:text>&#9;</xsl:text>
                <xsl:text>&#9;</xsl:text>
                <xsl:text>&#9;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:gramGrp">
        <xsl:value-of select="tei:pos"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="tei:subc"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="tei:mood"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="tei:tns"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="tei:per"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="tei:number"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="tei:gen"/>
    </xsl:template>
    
    
    <xsl:template match="tei:gap">
        <xsl:text>...</xsl:text>
    </xsl:template>

</xsl:stylesheet>