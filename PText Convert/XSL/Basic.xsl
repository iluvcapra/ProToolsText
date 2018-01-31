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
<xsl:apply-templates />
</event>
</xsl:for-each>
</events>
</pttext>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Start']">
<start><xsl:value-of select="value" /></start>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Finish']">
<finish><xsl:value-of select="value" /></finish>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Name']">
<name><xsl:value-of select="value" /></name>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Number']">
<track_seq><xsl:value-of select="value" /></track_seq>
</xsl:template>

<xsl:template match="field[key = 'PT.Session.Name']">
<session_name><xsl:value-of select="value" /></session_name>
</xsl:template>

<xsl:template match="field[property = 'PT.Track.Inactive']">
<track_inactive />
</xsl:template>

<xsl:template match="field[property = 'PT.Track.Muted']">
    <track_muted />
</xsl:template>

<xsl:template match="field[property = 'PT.Track.Solo']">
    <track_solo />
</xsl:template>

<xsl:template match="field[property = 'PT.Track.Hidden']">
    <track_hidden />
</xsl:template>

<xsl:template match="field[key = 'PT.Track.Name']">
    <track_name><xsl:value-of select="value" /></track_name>
</xsl:template>

<xsl:template match="field[key = 'PT.Track.Comment']">
    <track_comment><xsl:value-of select="value" /></track_comment>
</xsl:template>

<xsl:template match="field[property = 'PT.Clip.Muted']">
    <clip_muted />
</xsl:template>

<xsl:template match="field">
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
