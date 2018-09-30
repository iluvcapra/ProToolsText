<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="utf-8" indent="yes" />
<xsl:template match="/adr">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
    
<html>
<head>
    <style>
    @media screen {
        header {
            display: none;
        }
        footer {
            display: none;
        }
    }
    @media print {
        header {
            position: fixed;
            top: 0;
        }
        footer {
            position: fixed;
            bottom: 0;
        }
    }
    
    @page {
        margin-top: 24px;
        margin-bottom: 24px;
    }
    
    table {
        border-collapse: collapse;
        page-break-inside: avoid;
    }
    
    * {
    font-family: "Futura";
        font-size: 11;
    }
    </style>
</head>

<body>
    <header><xsl:value-of select="/adr/events/event[1]/title" /></header>
    <xsl:for-each select="/adr/events/event" >
        
        <table width="100%" height="150px">
        <tr>
            <td width="25%"><strong><xsl:value-of select="cue-number" /></strong></td>
            <td><xsl:value-of select="line" /></td>
        </tr>
        <tr>
            <td style="font-size:9;">Reason: <xsl:value-of select="reason" /></td>
        </tr>
        
        </table>
        <hr />

    </xsl:for-each>
    <footer>ADR Report</footer>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
