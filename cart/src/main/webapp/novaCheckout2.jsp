<%@page import="java.util.*,egprint.*"%>
<%@ page import="org.apache.http.HttpRequest" %>
<%

  HashMap<String,String> params =  getParameters(request);



%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title></title>
  <script>
  </script>
</head>
<body>

<table>
 <%Set<String> it = params.keySet();
  for(String k:it)
  {

    %>
    <tr><td><%=k%></td><td><%=params.get(k)%></td></tr>

 <%

  }
 %>
</body>
</html>
<%!
public HashMap<String,String> getParameters(HttpServletRequest request)
{
  HashMap<String,String> ret = new HashMap<String,String>();
  Enumeration<String> e = request.getParameterNames();
  while(e.hasMoreElements()){
      String key = e.nextElement();
      ret.put(key,egprint.Utilities.get(request,key));

  }
    return ret;
}

%>