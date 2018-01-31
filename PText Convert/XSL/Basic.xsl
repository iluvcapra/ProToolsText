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
<xsl:apply-templates mode="main" />
</event>
</xsl:for-each>
</events>
</pttext>
</xsl:template>

<!-- Mapping App-specified fields  -->

<xsl:template match="field[key = 'PT.Clip.Start']" mode="main">
<start><xsl:value-of select="value" /></start>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Finish']" mode="main">
<finish><xsl:value-of select="value" /></finish>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Name']" mode="main">
<name><xsl:value-of select="value" /></name>
</xsl:template>

<xsl:template match="field[key = 'PT.Clip.Number']" mode="main">
<track_seq><xsl:value-of select="value" /></track_seq>
</xsl:template>

<xsl:template match="field[key = 'PT.Session.Name']" mode="main">
<session_name><xsl:value-of select="value" /></session_name>
</xsl:template>

<xsl:template match="field[property = 'PT.Track.Inactive']" mode="main">
<track_inactive />
</xsl:template>

<xsl:template match="field[property = 'PT.Track.Muted']" mode="main">
    <track_muted />
</xsl:template>

<xsl:template match="field[property = 'PT.Track.Solo']" mode="main">
    <track_solo />
</xsl:template>

<xsl:template match="field[property = 'PT.Track.Hidden']" mode="main">
    <track_hidden />
</xsl:template>

<xsl:template match="field[key = 'PT.Track.Name']" mode="main">
    <track_name><xsl:value-of select="value" /></track_name>
</xsl:template>

<xsl:template match="field[key = 'PT.Track.Comment']" mode="main">
    <track_comment><xsl:value-of select="value" /></track_comment>
</xsl:template>

<xsl:template match="field[property = 'PT.Clip.Muted']" mode="main">
    <clip_muted />
</xsl:template>


<!-- Extracting all unmateched fields -->

<xsl:variable name="userFields">
    <userFields>
        <xsl:apply-templates select="field" mode="uf" />
    </userFields>
</xsl:variable>

<xsl:template match="field" mode="uf">
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
