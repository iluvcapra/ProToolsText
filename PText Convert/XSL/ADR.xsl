<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template match="/pttext">
<adr>
    <xsl:copy-of select="document_information" />
<events>
    <xsl:for-each select="/pttext/events/event">
    <event>
        <title> <xsl:value-of select="field[key = 'PT.Session.Name']/value" /> </title>
        
        <xsl:if test="field[key = 'Supv']" >
        <supervisor><xsl:value-of select="field[key = 'Supv']/value" /> </supervisor>
        </xsl:if>
        
        <xsl:if test="field[key = 'Client']" >
        <client> <xsl:value-of select="field[key = 'Client']/value" /> </client>
        </xsl:if>
        
        <xsl:if test="field[key = 'Sc']" >
        <scene> <xsl:value-of select="field[key = 'Sc']/value" /> </scene>
        </xsl:if>
        
        <cue-number> <xsl:value-of  select="field[key = 'QN']/value" /> </cue-number>
        <xsl:if test="field[key = 'Reel']" >
        <reel> <xsl:value-of select="field[key = 'Reel']/value" /> </reel>
        </xsl:if>
        
        <start> <xsl:value-of select="field[key = 'PT.Clip.Start']/value" /> </start>
        <start-seconds><xsl:value-of select="field[key = 'PT.Clip.Start.Seconds']/value" /></start-seconds>
        <finish> <xsl:value-of select="field[key = 'PT.Clip.Finish']/value" /> </finish>
        <finish-seconds><xsl:value-of select="field[key = 'PT.Clip.Finish.Seconds']/value" /></finish-seconds>
        
        <xsl:if test="field[key = 'Ver']" >
        <version> <xsl:value-of select="field[key = 'Ver']/value" /> </version>
        </xsl:if>
        
        <character-name> <xsl:value-of select="field[key = 'Char']/value" /> </character-name>
        <actor-name> <xsl:value-of select="field[key = 'Actor']/value" /> </actor-name>
        <xsl:if test="field[key = 'CN']" >
        <character-number> <xsl:value-of select="number(field[key = 'CN']/value) | 1" /> </character-number>
        </xsl:if>
        
        <line> <xsl:value-of select="field[key = 'PT.Clip.Name']/value" /> </line>
        <xsl:if test="field[key = 'P']" >
        <priority> <xsl:value-of select="number(field[key = 'P']/value) | 1" /> </priority>
        </xsl:if>
        <xsl:if test="field[key = 'R']" >
        <reason> <xsl:value-of select="field[key = 'R']/value" /> </reason>
        </xsl:if>
        <xsl:if test="field[key = 'Rq']" >
        <requested-by> <xsl:value-of select="field[key = 'Rq']/value" /> </requested-by>
        </xsl:if>
        <xsl:if test="field[key = 'Spot']" >
        <spot> <xsl:value-of select="field[key = 'Spot']/value" /> </spot>
        </xsl:if>
        <xsl:if test="field[key = 'Shot']" >
            <shot> <xsl:value-of select="field[key = 'Shot']/value" /> </shot>
        </xsl:if>
        
        <xsl:if test="field[key = 'Note']" >
        <note> <xsl:value-of select="field[key = 'Note']/value" /> </note>
        </xsl:if>
        <xsl:if test="field[name = 'Mins']" >
        <time-budget> <xsl:value-of select="number(field[name = 'Mins']/value)" /> </time-budget>
        </xsl:if>
        <xsl:if test="field[name = 'EFF']" >
            <effort/>
        </xsl:if>
        <xsl:if test="field[name = 'TV']" >
            <tv/>
        </xsl:if>
        <xsl:if test="field[name = 'TBW']" >
            <to-be-written/>
        </xsl:if>
        <xsl:if test="field[name = 'OMIT']" >
            <omit/>
        </xsl:if>
    </event>
    </xsl:for-each>
</events>
</adr>
</xsl:template>

</xsl:transform>
