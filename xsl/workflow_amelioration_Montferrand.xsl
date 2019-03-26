<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei" version="2.0">

    
    
    

    <xsl:template match="@* | node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
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
