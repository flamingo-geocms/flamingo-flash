<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:template match="/">
<xsl:variable name="returntype" select="@returntype"/>
<html>
<body>
<div class="blockTitle">Configuration Reference Guide</div>
<div class="blockContent">
<p>
<font size="4"><xsl:value-of select="//component/name"/></font>
</p>
<p>
<xsl:value-of disable-output-escaping="no" select="//component/description"/>
</p>

<span class="bluebold">Version and Changelog</span>
<br/>
<xsl:choose>
<xsl:when test="//version">
<xsl:value-of select="//version"/><br/>
</xsl:when>
</xsl:choose>
<xsl:for-each select="//change">
<xsl:value-of select="."/><br/>
</xsl:for-each>

<p>
<span class="bluebold">Component Files</span>
<br/>
<xsl:choose>
<xsl:when test="//file">
<xsl:for-each select="//file">
<xsl:value-of select="."/>
<br/>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
No files<br/>
</xsl:otherwise>
</xsl:choose>
</p>
<p>
<span class="bluebold">String id's</span>
<br/>
<xsl:choose>
<xsl:when test="//configstring">
<xsl:for-each select="//configstring">
<xsl:value-of select="name"/>:<xsl:value-of select="description"/>
<br/>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
No string id's<br/>
</xsl:otherwise>
</xsl:choose>
</p>
<p>
<span class="bluebold">Cursor id's</span>
<br/>
<xsl:choose>
<xsl:when test="//configcursor">
<xsl:for-each select="//configcursor">
<xsl:value-of select="name"/>:<xsl:value-of select="description"/>
<br/>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
No cursor id's<br/>
</xsl:otherwise>
</xsl:choose>
</p>
<p>
<span class="bluebold">Style id's</span>
<br/>
<xsl:choose>
<xsl:when test="//configstyle">
<xsl:for-each select="//configstyle">
<xsl:value-of select="name"/>:<xsl:value-of select="description"/>
<br/>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
No style id's<br/>
</xsl:otherwise>
</xsl:choose>
</p>
<xsl:choose>
<xsl:when test="example">
<p>
<span class="bluebold">Example</span><br/>
<textarea name="code" class="xml" rows="10" cols="60">
<xsl:value-of disable-output-escaping="no" select="."/>
</textarea>
<br/>
</p>
</xsl:when>
</xsl:choose>
<p>
<div class="blockTitle">Configuration tags</div>
<xsl:choose>
<xsl:when test="//configtags">
<xsl:for-each select="//configtags">
<xsl:choose>
<xsl:when test="//configtag">
<xsl:for-each select="//configtag">

<table width="100%" border="1">
<tr>
<th colspan="2">Configuration Tag Name: <xsl:value-of select="name"/></th>
</tr>
<tr><td class="bluebold" width="130">Description</td><td><xsl:value-of select="description"/></td></tr>
<tr><td class="bluebold">Hierarchy</td><td><xsl:value-of select="hierarchy"/></td></tr>
<xsl:choose>
<xsl:when test="example">
<tr><td class="bluebold">Example</td><td><textarea name="code" class="xml" rows="10" cols="60">
<xsl:value-of disable-output-escaping="no" select="example"/>
</textarea></td></tr>
</xsl:when>
</xsl:choose>
<xsl:choose>
<xsl:when test="attribute">
<tr><td colspan="2"><span class="bluebold">Attributes</span><br/>
<table border="1">
<xsl:for-each select="attribute">
<tr>
<xsl:if test="(position() mod 2 = 1)">
<xsl:attribute name="bgcolor">#EEEEFF</xsl:attribute>
</xsl:if>
<td width="128" class="lightbold"><xsl:value-of select="name"/></td><td><xsl:value-of select="description"/></td>
</tr>
</xsl:for-each>
</table>
</td></tr>
</xsl:when>
<xsl:otherwise>
<tr><td class="bluebold">Attributes</td><td>None</td></tr>
</xsl:otherwise>
</xsl:choose>
</table><br/>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<p>No configuration tags</p>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<p>No configuration tags</p>
</xsl:otherwise>
</xsl:choose>
</p>
</div>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
