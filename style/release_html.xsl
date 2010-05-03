<?xml version='1.0' encoding='UTF-8'?>

<!--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-->
<xsl:stylesheet 
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>

	<xsl:output indent="yes" method="html"/>

  <xsl:include href='common.xsl'/>

	<xsl:param name='version'/>
	<xsl:param name='release'/>
	<xsl:param name='previous'/>
	<xsl:param name='last'/>

	<xsl:template match='/log'>
		<HTML>
			<HEAD><TITLE>FormsTK Change Log</TITLE></HEAD>
			<BODY>
				<H1 ALIGN='center'>FormsTK Change Log</H1>
				<H2 ALIGN='center'><xsl:value-of select='$release'/> (<xsl:value-of 
						select='$version'/>)</H2>
				<H3 ALIGN='center'>Since previous minor release
				(<xsl:value-of select='$previous'/>)
				</H3>

        <xsl:call-template name='do-executive-summary'>
          <xsl:with-param name='nodeset' select='previous'/>
        </xsl:call-template>

				<xsl:apply-templates select='previous/logentry[string-length(normalize-space(msg/text())) > 0]'/>

				<H3 ALIGN='center'>Since last major release
				(<xsl:value-of select='$last'/>)
				</H3>

        <xsl:call-template name='do-executive-summary'>
          <xsl:with-param name='nodeset' select='last'/>
        </xsl:call-template>

				<xsl:apply-templates select='last/logentry[string-length(normalize-space(msg/text())) > 0]'/>
			</BODY>
		</HTML>
	</xsl:template>

	<xsl:template match='versioninfo'>
		<xsl:value-of select='@release'/> (<xsl:value-of select='normalize-space( substring-after( @version, ":" ))'/>)
		<xsl:value-of select='@date'/>
	</xsl:template>

	<xsl:template match='logentry'>
    <xsl:param name='message'><xsl:call-template 
      name='strip-announcements'><xsl:with-param name='text' 
      select='msg/text()'/></xsl:call-template></xsl:param>

		<DIV STYLE='display: block; 
			border: 2px solid #444;
			background-color: #ddf;
			margin-bottom: 10px;'>

			<DIV STYLE='display: block;
				float: right;
				background-color: #DfD;
				margin: 0px;
				padding: 2px;'><xsl:value-of select='date/text()'/></DIV>
			<DIV STYLE='display: block;
				background-color: #DfD;
				margin: 0px;
				padding: 2px;'><xsl:value-of select='@revision'/></DIV>

			<PRE><xsl:call-template name='word-wrap'><xsl:with-param
        name='T' select='$message'/></xsl:call-template></PRE>

			<DIV STYLE='display: block;
				background-color: #DfD;
				margin: 0px;
				padding: 2px;'><xsl:value-of select='author/text()'/></DIV>
		</DIV>
	</xsl:template>


  <xsl:template name='word-wrap'>
    <xsl:param name='L'/>
    <xsl:param name='T'/>
    <xsl:param name='LL'>80</xsl:param>
    <xsl:variable name="cr" select="'&#xa;'"/>

    <xsl:variable name='NT' select='normalize-space($T)'/>
    <xsl:variable name='NL' select='normalize-space($L)'/>
    <xsl:variable name='LT' select='concat( $NL, " ", $NT )'/>

    <xsl:choose>
      <xsl:when test='contains( $L, $cr )'>
        <xsl:value-of 
          select='normalize-space(substring-before( $L, $cr ))'/><xsl:text>
</xsl:text><xsl:call-template name='word-wrap'><xsl:with-param name='T' 
          select='concat( substring-after( $L, $cr ), " ", 
              $T)'/></xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test='string-length( $NT ) = 0'>
            <xsl:value-of select='normalize-space($L)'/>
          </xsl:when>
          <xsl:when test='string-length(normalize-space(concat( $L, " ", 
                  substring-before($NT, " ")))) &lt;= $LL'>
            <xsl:choose>
              <xsl:when test='substring-before($T, $cr) = 
                substring-before($NT, " ")'>
                <xsl:value-of select='concat($NL, " ", 
                    substring-before($T, $cr))'/><xsl:text>
</xsl:text><xsl:call-template name='word-wrap'><xsl:with-param name='T' 
                  select='substring-after($T, $cr)'/></xsl:call-template>
              </xsl:when>
              <xsl:when test='not( contains( $NT, " " ) )'>
                <xsl:value-of select='normalize-space($LT)'/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name='word-wrap'><xsl:with-param name='L' 
                  select='concat($L, " ", 
                      substring-before($T, " "))'/><xsl:with-param
                  name='T' select='substring-after($T, " ")'/></xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test='string-length(normalize-space(concat(
                   $L, " ", $NT))) &lt;= $LL'>
            <xsl:value-of select='$LT'/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select='$NL'/><xsl:text>
</xsl:text><xsl:call-template name='word-wrap'><xsl:with-param name='T' 
              select='$T'/></xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name='announce-callback'>
    <xsl:param name='announcement'/>
    <LI><xsl:value-of select='$announcement'/></LI>
  </xsl:template>

  <xsl:template name='do-executive-summary'>
    <xsl:param name='nodeset'/>
    
		<DIV STYLE='display: block; 
			border: 2px solid #444;
			background-color: #EEF;
			margin-bottom: 10px;'>

			<DIV STYLE='display: block;
				background-color: #ADA;
				margin: 0px;
				padding: 2px;'>Executive Summary</DIV>

      <UL>
        <xsl:for-each select='$nodeset/logentry[contains(msg/text(), "@@")]'>
          <xsl:call-template name='get-announce'>
            <xsl:with-param name='text' select='msg/text()'/>
          </xsl:call-template>
        </xsl:for-each>
      </UL>
    </DIV>
  </xsl:template>
</xsl:stylesheet>
