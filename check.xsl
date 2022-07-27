<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fc="http://fruschtique.de/ns/igt-catalog" xmlns:fr="http://fruschtique.de/ns/recipe" exclude-result-prefixes="xs" version="2.0">

    <xsl:variable name="path2cat" select="'file:///c:/users/nlutt/documents/websites/graphLab/igt-catalog/igt-catalog.xml'"/>
    <xsl:variable name="path2rcp" select="'file:///C:/Users/nlutt/Documents/Websites/kochbuch/recipes_xml/?select=*.xml;recurse=yes'"/>

    <xsl:variable name="inCat">
        <igdtsInCat>
            <xsl:for-each select="document($path2cat)//fc:ingredient/@id">
                <xsl:sort/>
                <igdtInCat>
                    <xsl:value-of select="."/>
                </igdtInCat>
            </xsl:for-each>
        </igdtsInCat>
    </xsl:variable>

    <xsl:variable name="inRcp">
        <igdtsInRcp>
            <xsl:for-each-group select="collection($path2rcp)//fr:igdtName/@ref" group-by=".">
                <xsl:sort/>
                <igdtInRcp>
                    <xsl:value-of select="current-grouping-key()"/>
                </igdtInRcp>
            </xsl:for-each-group>
        </igdtsInRcp>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:for-each select="$inCat//igdtInCat">  
            <xsl:variable name="x" select="."/>
            <xsl:if test="not(exists($inRcp//igdtInRcp[.=$x]))">
                <xsl:text>&#xa;</xsl:text>
                <xsl:value-of select="$x"/>
            </xsl:if>
        </xsl:for-each>
       
    </xsl:template>

</xsl:stylesheet>
