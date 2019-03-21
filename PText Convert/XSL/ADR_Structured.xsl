<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="utf-8" indent="yes" />

    <xsl:key name="titles" match="events/event" use="field[key = 'Title']/value" />
    <xsl:key name="titles-character" match="events/event" use="concat(field[key = 'PT.Track.Name']/value, field[key = 'Title']/value)" />
    
<xsl:template match="/pttext">
<spotting-notes>
    <xsl:comment>Be advised this XML format is under active development and the schema may change at any time</xsl:comment>
    <xsl:copy-of select="document-information" />
    <xsl:for-each select="events/event[ count( . | key('titles', field[key = 'Title']/value )[1]) = 1]" >
        <title>
            <xsl:variable name="thisTitle" select="field[key = 'Title']/value" />
            <title><xsl:value-of select="$thisTitle" /></title>
            <xsl:if test="field[key = 'Supv']" >
                <supervisor><xsl:value-of select="field[key = 'Supv']/value" /> </supervisor>
            </xsl:if>
            
            <xsl:if test="field[key = 'Client']" >
                <client> <xsl:value-of select="field[key = 'Client']/value" /> </client>
            </xsl:if>
        
            <xsl:for-each select="/pttext/events/event[ count(.| key('titles-character', concat(field[key = 'PT.Track.Name']/value, $thisTitle ))[1]) = 1]" >
                <xsl:sort select="number(field[key = 'CN']/value)" data-type="number" />
            <xsl:variable name="thisCharacter" select="concat(field[key = 'PT.Track.Name']/value, $thisTitle)" />
            <character>
                <xsl:attribute name="order"><xsl:number value="position()" /></xsl:attribute>
                <name><xsl:value-of select="field[key = 'PT.Track.Name']/value" /></name>
                <actor><xsl:value-of select="field[key = 'Actor']/value" /></actor>
                <number><xsl:value-of select="field[key = 'CN']/value" /></number>
                <xsl:for-each select="/pttext/events/event[concat(field[key = 'PT.Track.Name']/value,field[key = 'Title']/value) = $thisCharacter]" >
                    <cue>
                    <cue-number><xsl:value-of select="field[key = 'QN']/value" /></cue-number>
                    <line><xsl:value-of select="field[key = 'PT.Clip.Name']/value" /></line>
                    <xsl:if test="field[key = 'Sc']" >
                        <scene> <xsl:value-of select="field[key = 'Sc']/value" /> </scene>
                    </xsl:if>
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
                    <xsl:if test="field[key = 'Mins']" >
                        <time-budget> <xsl:value-of select="number(field[key = 'Mins']/value)" /> </time-budget>
                    </xsl:if>
                    <xsl:if test="field/property = 'EFF'" >
                        <effort />
                    </xsl:if>
                    <xsl:if test="field/property = 'TV'" >
                        <tv />
                    </xsl:if>
                    <xsl:if test="field/property = 'TBW'" >
                        <to-be-written />
                    </xsl:if>
                    <xsl:if test="field/property = 'OMIT'" >
                        <omit />
                    </xsl:if>
                    <xsl:if test="field/property = 'ADLIB'" >
                        <adlib />
                    </xsl:if>
                    <xsl:if test="field/property = 'OPT'" >
                        <optional />
                    </xsl:if>
                    </cue>
                    </xsl:for-each>
            </character>
            </xsl:for-each>
        </title>
        </xsl:for-each>
</spotting-notes>
</xsl:template>
</xsl:transform>
