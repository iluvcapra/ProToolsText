<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template match="/pttext">
<adr>
<producer_identifer><xsl:value-of select="producer_identifer" /></producer_identifer>
<producer_version><xsl:value-of select="producer_version" /></producer_version>
<events>
    <xsl:for-each select="/pttext/events/event">
        <xsl:choose >
            <xsl:when test="clip_muted">
            </xsl:when>
    <xsl:otherwise>
    <event>
        <title> <xsl:value-of select="session_name" /> </title>
        <supervisor><xsl:value-of  select="userField[name = 'Supv']/value" /> </supervisor>
        <client> <xsl:value-of select="userField[name = 'Client']/value" /> </client>
        <scene> <xsl:value-of select="userField[name = 'Sc']/value" /> </scene>
        <cue-number> <xsl:value-of  select="userField[name = 'QN']/value" /> </cue-number>
        <start> <xsl:value-of select="start" /> </start>
        <finish> <xsl:value-of select="finish" /> </finish>
        <version> <xsl:value-of select="userField[name = 'Ver']/value" /> </version>
        <character-name> <xsl:value-of select="userField[name = 'Char']/value" /> </character-name>
        <actor-name> <xsl:value-of select="userField[name = 'Actor']/value" /> </actor-name>
        <character-number> <xsl:value-of select="userField[name = 'CN']/value" /> </character-number>
        <line> <xsl:value-of select="name" /> </line>
        <reason> <xsl:value-of select="userField[name = 'R']/value" /> </reason>
        <requested-by> <xsl:value-of select="userField[name = 'Rq']/value" /> </requested-by>
        <spot> <xsl:value-of select="userField[name = 'Spot']/value" /> </spot>
        <note> <xsl:value-of select="userField[name = 'Note']/value" /> </note>
        <time-budget> <xsl:value-of select="userField[name = 'Mins']/value" /> </time-budget>
    </event>
     </xsl:otherwise>
     </xsl:choose>
    </xsl:for-each>
</events>
</adr>
</xsl:template>

</xsl:transform>
