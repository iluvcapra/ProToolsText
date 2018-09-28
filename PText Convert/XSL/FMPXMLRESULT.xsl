<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/adr">

<FMPXMLRESULT xmlns="http://www.filemaker.com/fmpxmlresult">
<ERRORCODE>0</ERRORCODE>
<PRODUCT>
<xsl:attribute name="NAME">
<xsl:value-of select="document_information/producer_identifer" />
</xsl:attribute>
<xsl:attribute name="VERSION">
<xsl:value-of select="document_information/producer_version"/>
</xsl:attribute>
</PRODUCT>
<DATABASE DATEFORMAT="MM/dd/yy" LAYOUT="summary" TIMEFORMAT="hh:mm:ss">
<xsl:attribute name="RECORDS">
<xsl:value-of select="count(events/event)" />
</xsl:attribute>
<xsl:attribute name="NAME">
<xsl:value-of select="document_information/input_document" />
</xsl:attribute>
</DATABASE>
<METADATA>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Title" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Supervisor" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Client" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Scene" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Cue Number" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Reel" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Start" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Start Seconds" TYPE="NUMBER"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Finish" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Finish Seconds" TYPE="NUMBER"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Version" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Character Name" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Actor Name" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Character Number" TYPE="NUMBER"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Line" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Priority" TYPE="NUMBER"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Reason" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Requested By" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Spot" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Shot" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Note" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Time Budget Mins" TYPE="NUMBER"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Effort" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="TV" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="To Be Written" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Omit" TYPE="TEXT"/>
<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="Adlib" TYPE="TEXT"/>
</METADATA>
<RESULTSET>
<xsl:attribute name="FOUND">
<xsl:value-of select="count(events/event)" />
</xsl:attribute>
<xsl:for-each select="/adr/events/event">
<ROW>
<xsl:comment> title </xsl:comment>
<COL><DATA><xsl:value-of select="title" /></DATA></COL>
<xsl:comment> supervisor </xsl:comment>
<COL><DATA><xsl:value-of select="supervisor" /></DATA></COL>
<xsl:comment> client </xsl:comment>
<COL><DATA><xsl:value-of select="client" /></DATA></COL>
<xsl:comment> scene </xsl:comment>
<COL><DATA><xsl:value-of select="scene" /></DATA></COL>
<xsl:comment> cue-number </xsl:comment>
<COL><DATA><xsl:value-of select="cue-number" /></DATA></COL>
<xsl:comment> reel </xsl:comment>
<COL><DATA><xsl:value-of select="reel" /></DATA></COL>
<xsl:comment> start </xsl:comment>
<COL><DATA><xsl:value-of select="start" /></DATA></COL>
<xsl:comment> start-seconds </xsl:comment>
<COL><DATA><xsl:value-of select="start-seconds" /></DATA></COL>
<xsl:comment> finish </xsl:comment>
<COL><DATA><xsl:value-of select="finish" /></DATA></COL>
<xsl:comment> finish-seconds </xsl:comment>
<COL><DATA><xsl:value-of select="finish-seconds" /></DATA></COL>
<xsl:comment> version </xsl:comment>
<COL><DATA><xsl:value-of select="version" /></DATA></COL>
<xsl:comment> character-name </xsl:comment>
<COL><DATA><xsl:value-of select="character-name" /></DATA></COL>
<xsl:comment> actor-name </xsl:comment>
<COL><DATA><xsl:value-of select="actor-name" /></DATA></COL>
<xsl:comment> character-number </xsl:comment>
<COL><DATA><xsl:value-of select="character-number" /></DATA></COL>
<xsl:comment> line </xsl:comment>
<COL><DATA><xsl:value-of select="line" /></DATA></COL>
<xsl:comment> priority </xsl:comment>
<COL><DATA><xsl:value-of select="priority" /></DATA></COL>
<xsl:comment> reason </xsl:comment>
<COL><DATA><xsl:value-of select="reason" /></DATA></COL>
<xsl:comment> requested-by </xsl:comment>
<COL><DATA><xsl:value-of select="requested-by" /></DATA></COL>
<xsl:comment> spot </xsl:comment>
<COL><DATA><xsl:value-of select="spot" /></DATA></COL>
<xsl:comment> shot </xsl:comment>
<COL><DATA><xsl:value-of select="shot" /></DATA></COL>
<xsl:comment> note </xsl:comment>
<COL><DATA><xsl:value-of select="note" /></DATA></COL>
<xsl:comment> time-budget </xsl:comment>
<COL><DATA><xsl:value-of select="time-budget" /></DATA></COL>
<xsl:comment> effort </xsl:comment>
<COL><DATA><xsl:if test="effort" >EFFORT</xsl:if></DATA></COL>
<xsl:comment> tv </xsl:comment>
<COL><DATA><xsl:if test="tv" >TV</xsl:if></DATA></COL>
<xsl:comment> to-be-written </xsl:comment>
<COL><DATA><xsl:if test="to-be-written" >TBW</xsl:if></DATA></COL>
<xsl:comment> omit </xsl:comment>
<COL><DATA><xsl:if test="omit" >OMIT</xsl:if></DATA></COL>
<xsl:comment> adlib </xsl:comment>
<COL><DATA><xsl:if test="adlib" >ADLIB</xsl:if></DATA></COL>
</ROW>
</xsl:for-each>
</RESULTSET>
</FMPXMLRESULT>

</xsl:template>
</xsl:transform>
