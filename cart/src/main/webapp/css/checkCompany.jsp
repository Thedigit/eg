<%@ page import="egprint.Utilities" %>
<%@ page import="org.json.JSONObject" %>
<%
    JSONObject activeCompany = Utilities.determineCompany(request);
    session.setAttribute("activeCompany",activeCompany);
    session.setAttribute("serviceCompany",activeCompany.optString("id","1"));
    System.out.println(activeCompany+" "+((String)session.getAttribute("serviceCompany")));
%>