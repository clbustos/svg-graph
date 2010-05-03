<?xml version='1.0' encoding='UTF-8'?>

<!--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-->
<xsl:stylesheet 
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>

  <xsl:template name='get-announce'>
    <xsl:param name='text'/>
    <xsl:if test='contains( $text, "@@" )'>
      <xsl:call-template name='announce-callback'>
        <xsl:with-param name='announcement'><xsl:value-of 
          select='substring-before( 
              substring-after( $text, "@@" ), "@@" )'/></xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='get-announce'>
        <xsl:with-param name='text' select='substring-after(
            substring-after( $text, "@@" ), "@@" )'/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name='strip-announcements'>
    <xsl:param name='text'/>
    <xsl:choose>
      <xsl:when test='contains( $text, "@@" )'><xsl:value-of 
          select='substring-before( $text, "@@" )'/><xsl:call-template
          name='strip-announcements'><xsl:with-param
          name='text'><xsl:value-of
          select='substring-after( substring-after( $text, "@@" ), "@@" )'
          /></xsl:with-param></xsl:call-template></xsl:when>
      <xsl:otherwise>
        <xsl:value-of select='$text'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
