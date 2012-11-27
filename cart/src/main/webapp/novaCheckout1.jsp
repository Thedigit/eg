<%@page import="java.util.*"%>
<%

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

form action="https://www.myvirtualmerchant.com/VirtualMerchant/process.do" method="POST">
<form action="upload.jsp" method="POST">
                            Your Total: $1.00 <br/>
                           
                            <input type="text" name="ssl_avs_address" value="123 main st">
                            <input type="text" name="ssl_avs_zip" value="33026">
                            <input type="text" name="ssl_cvv2cvc2" value="846">
                            Credit Card Number: <input type="text" name="ssl_card_number" value="4403190011111111"> <br/>
                            Expiration Date (MMYY): <input type="text" name="ssl_exp_date" size="4" value="0513"> <br/>
                            <br/>
                            <input type="submit" value="Continue">
                            </form>

</body>
</html>