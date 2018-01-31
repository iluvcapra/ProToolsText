<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/pttext">
<pttext>
<!-- Note: This XML schema is under active development and may change at any time -->
<producer_identifer><xsl:value-of select="producer_identifer" /></producer_identifer>
<producer_version><xsl:value-of select="producer_version" /></producer_version>
<events>
<xsl:for-each select="events/event">
<event>
<xsl:apply-templates mode="remap" />
</event>
</xsl:for-each>
</events>
</pttext>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Start']" mode="remap">
<start><xsl:value-of select="value" /></start>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Finish']" mode="remap">
<finish><xsl:value-of select="value" /></finish>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Name']" mode="remap">
<name><xsl:value-of select="value" /></name>
</xsl:template>

<xsl:template match="field[key = 'PT.Track.Name']" mode="remap">
<track_name><xsl:value-of select="value" /></track_name>
</xsl:template>

<xsl:template match="field[key = 'PT.Track.Comment']" mode="remap">
<track_comment><xsl:value-of select="value" /></track_comment>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Number']" mode="remap">
<seq><xsl:value-of select="value" /></seq>
</xsl:template>

<xsl:template match="field[key = 'PT.Session.Name']" mode="remap">
<session_name><xsl:value-of select="value" /></session_name>
</xsl:template>

<xsl:template match="field[property = 'PT.Track.Inactive']" mode="remap">
<track_inactive/>
</xsl:template>

<xsl:template match="field" mode="remap">
<userField>
<xsl:choose>
<xsl:when test="property">
<property><xsl:value-of select="property" /></property>
</xsl:when>
<xsl:when test="key">
<name><xsl:value-of select="key" /></name>
<value><xsl:value-of select="value" /></value>
</xsl:when>
</xsl:choose>
</userField>
</xsl:template>

</xsl:transform>
