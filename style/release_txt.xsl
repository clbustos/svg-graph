<?xml version='1.0' encoding='UTF-8'?>

<!--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-->
<xsl:stylesheet 
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>

	<xsl:output indent="yes" method="text"/>

	<xsl:template match='/log'>
FormsTK Change Log
<xsl:apply-templates select='logentry[string-length(normalize-space(msg/text())) > 0]'/>
	</xsl:template>

	<xsl:template match='logentry'>
<xsl:text>============================================================
</xsl:text>
<xsl:value-of select='normalize-space(@revision)'/>	(<xsl:value-of select='date/text()'/>) 	<xsl:value-of select='author/text()'/>
<xsl:text>
</xsl:text>
<xsl:value-of select='msg/text()'/>
<xsl:text>
</xsl:text>
	</xsl:template>
</xsl:stylesheet>
