<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fc="http://fruschtique.de/ns/igt-catalog" xmlns:fr="http://fruschtique.de/ns/recipe" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:fs="http://expath.org/ns/file" exclude-result-prefixes="#all">

    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="path" select="'file:///C:/Users/nlutt/Documents/Websites/Ingredients/'"/>
    <xsl:variable name="igt-catalog" select="concat($path, 'igt-catalog.xml')"/>

    <xsl:template match="/">

        <!-- generate new ingredient catalog -->
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes" exclude-result-prefixes="#all" href="{concat($path, 'temp.xml')}">
            <xsl:element name="fc:igtCatalog">
                <xsl:attribute name="xsi:schemaLocation">http://fruschtique.de/ns/igt-catalog igt-catalog.xsd</xsl:attribute>
                <xsl:element name="fc:classes">
                    <xsl:for-each select="document($igt-catalog)//fc:class">
                        <xsl:sort select="@id" collation="http://saxon.sf.net/collation?lang=de-DE"/>
                        <xsl:copy-of select="." copy-namespaces="no"/>
                    </xsl:for-each>
                </xsl:element>

                <xsl:element name="fc:ingredients">
                    <xsl:for-each select="document($igt-catalog)//fc:ingredient">
                        <xsl:sort select="@id" collation="http://saxon.sf.net/collation?lang=de-DE"/>
                        <xsl:copy-of select="." copy-namespaces="no"/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>

        <xsl:variable name="src" select="concat($path, 'temp.xml')"/>
        <xsl:variable name="dst" select="concat($path, 'igt-catalog.xml')"/>
        <xsl:sequence select="fs:move($src, $dst)"/>

        <!-- generate new ingredient catalog in json format -->
        <xsl:result-document method="text" encoding="UTF-8" indent="yes" exclude-result-prefixes="#all" href="{concat($path, 'temp.json')}">
            <xsl:variable name="xx">
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    <array key="ingredients">
                        <xsl:for-each select="document($igt-catalog)//fc:ingredient">
                            <xsl:sort select="@id" collation="http://saxon.sf.net/collation?lang=de-DE"/>
                            <map>
                                <string key="id">
                                    <xsl:value-of select="@id"/>
                                </string>
                                <string key="label">
                                    <xsl:value-of select="fc:igtLabel"/>
                                </string>
                                <string key="normName">
                                    <xsl:value-of select="replace(lower-case(fc:igtLabel), '_', ' ')"/>
                                </string>
                                <array key="synonyms">
                                    <xsl:for-each select="fc:igtSyn">
                                        <string>
                                            <xsl:value-of select="."/>
                                        </string>
                                    </xsl:for-each>
                                </array>
                            </map>
                        </xsl:for-each>
                    </array>
                </map>
            </xsl:variable>
            <xsl:sequence select="xml-to-json($xx)"/>
        </xsl:result-document>

        <xsl:variable name="src" select="concat($path, 'temp.json')"/>
        <xsl:variable name="dst1" select="concat($path, 'igt-catalog.json')"/>
        <xsl:sequence select="fs:copy($src, $dst1)"/>

        <!-- generate ingredient catalog as "dict of dicts" (in Python jargon) for jupyter notebook in json format -->
        <xsl:result-document method="text" encoding="UTF-8" indent="yes" exclude-result-prefixes="#all" href="{concat($path, 'temp-jup.json')}">
            <xsl:variable name="yy">
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:for-each select="document($igt-catalog)//fc:ingredient">
                        <xsl:sort select="@id" collation="http://saxon.sf.net/collation?lang=de-DE"/>
                        <xsl:if test="@id != ''">
                            <map key="{@id}">
                                <string key="i-name">
                                    <xsl:value-of select="fc:igtLabel"/>
                                </string>
                                <string key="i-class">
                                    <xsl:value-of select="fc:igtClass"/>
                                </string>
                            </map>
                        </xsl:if>
                    </xsl:for-each>
                </map>
            </xsl:variable>
            <xsl:sequence select="xml-to-json($yy)"/>
        </xsl:result-document>

        <!-- generate type 'refType' for igt-catalog schema -->
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes" exclude-result-prefixes="#all" href="{concat($path, '../kochbuch/tools/refType.xsd')}">

            <xsl:element name="xs:schema">
                <xsl:attribute name="targetNamespace">http://fruschtique.de/ns/recipe</xsl:attribute>
                <xsl:attribute name="elementFormDefault">qualified</xsl:attribute>
                <xsl:element name="xs:simpleType">
                    <xsl:attribute name="name">refType</xsl:attribute>
                    <xsl:element name="xs:restriction">
                        <xsl:attribute name="base">xs:string</xsl:attribute>
                        <xs:enumeration value=""/>
                        <xsl:for-each select="document($igt-catalog)//fc:ingredient">
                            <xs:enumeration value="{@id}"/>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>

        <!-- generate HTML datalist element for recipe forms: autocompletion of ingredient reference input -->
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes" exclude-result-prefixes="#all" omit-xml-declaration="yes" href="{concat($path, 'datalist-for-autocomplete.html')}">
            <xsl:for-each select="document($igt-catalog)//fc:ingredient">
                <xsl:sort select="@id" collation="http://saxon.sf.net/collation?lang=de-DE"/>
                <option value="{@id}"/>
            </xsl:for-each>
        </xsl:result-document>

        <!-- generate css file for ingredient class coloring -->
        <xsl:result-document method="text" encoding="UTF-8" indent="no" exclude-result-prefixes="#all" omit-xml-declaration="yes" href="{concat($path, 'ingredient-classes.css')}">
            <xsl:for-each select="//fc:class">
                <xsl:variable name="palette" select="concat($path, 'palette.xml')"/>
                <xsl:variable name="class" select="./@classID"/>
                <xsl:variable name="color" select="document($palette)//fc:color[@for = $class]/@rgb"/>
                <xsl:value-of select="concat('&#13;', '.i-', $class, ' { fill: #', $color, '; stroke: #', $color, '; background-color: #', $color, ' }')"/>
            </xsl:for-each>
        </xsl:result-document>

        <xsl:variable name="s" select="concat($path, '../kochbuch/tools/refType.xsd')"/>
        <xsl:variable name="t1" select="concat($path, '../tools/refType.xsd')"/>
        <xsl:sequence select="fs:copy($s, $t1)"/>

    </xsl:template>

</xsl:stylesheet>
