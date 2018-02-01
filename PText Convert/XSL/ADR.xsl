<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template match="/pttext">
<pttext>
<producer_identifer><xsl:value-of select="producer_identifer" /></producer_identifer>
<producer_version><xsl:value-of select="producer_version" /></producer_version>
<events>

</events>
</pttext>
</xsl:template>

</xsl:transform>
