<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/adr">

<FMPXMLRESULT xmlns="http://www.filemaker.com/fmpxmlresult">
<ERRORCODE>0</ERRORCODE>
<PRODUCT>
<xsl:attribute name="NAME">
<xsl:value-of select="producer_identifer" />
</xsl:attribute>
<xsl:attribute name="VERSION">
<xsl:value-of select="producer_version"/>
</xsl:attribute>
</PRODUCT>
<DATABASE DATEFORMAT="MM/dd/yy" LAYOUT="summary" TIMEFORMAT="hh:mm:ss">
<xsl:attribute name="RECORDS">
<xsl:value-of select="count(events/event)" />
</xsl:attribute>
<xsl:attribute name="NAME">
<xsl:value-of select="input_document" />
</xsl:attribute>
</DATABASE>
<METADATA>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Title" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Supervisor" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Client" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Scene" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Cue Number" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Start" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Finish" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Version" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Character Name" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Actor Name" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Character Number" TYPE="NUMBER"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Line" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Reason" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Requested By" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Spot" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Note" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Time Budget Mins" TYPE="NUMBER"/>
</METADATA>
<RESULTSET>
<xsl:attribute name="FOUND">
<xsl:value-of select="count(events/event)" />
</xsl:attribute>
<xsl:for-each select="/adr/events/event">
<ROW>
<COL><DATA><xsl:value-of select="title" /></DATA></COL>
<COL><DATA><xsl:value-of select="supervisor" /></DATA></COL>
<COL><DATA><xsl:value-of select="client" /></DATA></COL>
<COL><DATA><xsl:value-of select="scene" /></DATA></COL>
<COL><DATA><xsl:value-of select="cue-number" /></DATA></COL>
<COL><DATA><xsl:value-of select="start" /></DATA></COL>
<COL><DATA><xsl:value-of select="finish" /></DATA></COL>
<COL><DATA><xsl:value-of select="version" /></DATA></COL>
<COL><DATA><xsl:value-of select="character-name" /></DATA></COL>
<COL><DATA><xsl:value-of select="actor-name" /></DATA></COL>
<COL><DATA><xsl:value-of select="character-number" /></DATA></COL>
<COL><DATA><xsl:value-of select="line" /></DATA></COL>
<COL><DATA><xsl:value-of select="reason" /></DATA></COL>
<COL><DATA><xsl:value-of select="requested-by" /></DATA></COL>
<COL><DATA><xsl:value-of select="spot" /></DATA></COL>
<COL><DATA><xsl:value-of select="note" /></DATA></COL>
<COL><DATA><xsl:value-of select="time-budget" /></DATA></COL>
</ROW>
</xsl:for-each>
</RESULTSET>
</FMPXMLRESULT>

</xsl:template>
</xsl:transform>
