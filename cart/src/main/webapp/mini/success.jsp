<%@page import="java.util.*,egprint.Utilities"%>
<%@ page import="org.json.JSONObject" %>
<%
    JSONObject retVar =  (JSONObject)session.getAttribute("result");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

  <title>Payment Successfull</title>
  <script>
      function closeMe(){
          try{top.opener.top.closeFlow(<%=retVar.toString()%>);}catch(e){console.log(e);}
          try{top.closeFlow(<%=retVar.toString()%>);}catch(e){console.log(e);}
          self.close();
      }
      closeMe();
  </script>
</head>
<body>
<button onclick="closeMe()">Proceed to next step</button>
</body>
</html>