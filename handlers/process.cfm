
<cffunction name="getCurrentURL" output="No" access="public" returnType="string">
    <cfset var theURL = getPageContext().getRequest().GetRequestUrl().toString()>
    <cfif len( CGI.query_string )><cfset theURL = theURL & "?" & CGI.query_string></cfif>
    <!--- Hack by Raymond, remove any CFID CFTOKEN --->
	<cfset theUrl = reReplaceNoCase(theUrl, "[&?]*cfid=[0-9]+", "")>
	<cfset theUrl = reReplaceNoCase(theUrl, "[&?]*cftoken=[^&]+", "")>
    <cfreturn theURL>
</cffunction>

<cfsetting showdebugoutput="false" requestTimeout="600">

<cfif not structKeyExists(form, "submit")>
	<cfparam name="ideeventinfo"> 
	
	<cfif not isXML(ideeventinfo)>
		<cfexit>
	</cfif>
	
	<cfset data = xmlParse(ideeventinfo)>
	<cfset dsn = data.event.ide.rdsview.database.xmlattributes.name>
	<cfset table = data.event.ide.rdsview.database.table.xmlattributes.name>
	<cfset dowrap = true>
	<cfset form.maxrows = 1>
<cfelse>
	<cfset dsn = form.dsn>
	<cfset table = form.table>
	<cfset dowrap = false>
	<cfif structKeyExists(form, "maxrows")>
		<cfset form.maxrows = 1>
	<cfelse>
		<cfset form.maxrows = 0>
	</cfif>
</cfif>

<cfparam name="form.sql" default="select * from #table#">
<cfif form.maxrows>
	<cfset maxrows = 50>
<cfelse>
	<cfset maxrows = -1>
</cfif>

<cfquery name="results" datasource="#dsn#" maxrows="#maxrows#">
#preserveSingleQuotes(form.sql)#
</cfquery>

<cfif doWrap>
<cfheader name="Content-Type" value="text/xml">
<response showresponse="true">
<ide>
<view id="mydbview" title="My Database View" icon="handlers/database_inactive.png" />
<body> 
<![CDATA[ 
</cfif>
<style>
body {
	font-family: Arial;
}
textarea {
	width: 100%;
	height: 80px;
}
</style>
<cfoutput>
<h2>Datasource: #dsn#</h2>
<form action="#getCurrentURL()#" method="post">
<input type="hidden" name="dsn" value="#dsn#">
<input type="hidden" name="table" value="#table#">
<textarea name="sql">#form.sql#</textarea>
<input name="submit" type="submit" value="Display">
<input type="checkbox" name="maxrows" value="1" <cfif form.maxrows>checked</cfif>> 
Restrict results to 50 rows
</form>
<p/>
There were #results.recordCount# result(s).
<table border="1">
	<tr>
	<cfloop index="c" list="#results.columnlist#">
		<th>#c#</th>
	</cfloop>
	</tr>
	<cfloop query="results">
	<tr>
		<cfloop index="c" list="#results.columnlist#">
			<td>#htmlEditFormat(results[c][currentRow])#</td>
		</cfloop>
	</tr>
	</cfloop>
</table>
</cfoutput>
<cfif dowrap>
]]> 
</body>
</ide>
</response>
</cfif>