<%@page import="java.util.*,egprint.Utilities"%>
<%
    if(base==null){base="";}
%>
    <div class="BottomPanel">
        <%
        String _companyCode= Utilities.determineCompany(request).getString("Alias");
        ArrayList<HashMap<String,String>> _templates = Utilities.fetch3("SELECT * FROM enterprise.templatePages t WHERE t.Active='1' AND t.HardLink='1' AND t.Company='"+_companyCode+"'");
        for(HashMap<String,String> _template: _templates){%>
        <a href="<%=base%>pages/<%=_template.get("ShortName")%>" class="TopMenuItem"> <%=_template.get("Name")%> </a>
        <%}%>
    </div>
    <div class="BottomPanel2">Copyright <%=new GregorianCalendar().get(Calendar.YEAR)%></div>

<script type="text/javascript" src="<%=base%>js/googleAnalytics.js"></script>