<%@page import="java.util.*,egprint.*"%>
<%
   String total = (String)session.getAttribute("miniTotal");
   //total = "10.95";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title></title>
  <style type="text/css">
      body,html{margin:0;padding:0;}
      .Wrapper{
          width:379px;
          height:544px;
          background:#FFF;
          border:solid 3px #999;
          -moz-border-radius:5px;
          -webkit-border-radius:5px;
          border-radius:5px;
          margin:0px;
      }

      .Total,.Cancel{
          height:30px;
          font: bold 24px arial;
          text-align:center;
          background-color:#ED7700;
          color:#333;
      }
      .Body{
          height:484px;
      }

      .CC,.PP{
          margin:15px auto;
          text-align:center;
          font:normal 16px arial;
      }
      .Cancel          {
          background-color: #ff3333;
          color:#333;
      }

      #cc{
          width:100%;
          font: normal 12px arial;
          color:#666666;
          text-align:left;
      }
          input.NiceInput{
    border-style:inset;
    border-top:solid 1px #999;
    border-left:solid 1px #999;
    border-right:solid 1px #DDD;
    border-bottom:solid 1px #DDD;
    background: #fbfbbb;          
    -moz-border-radius:3px;
    -webkit-border-radius:3px;
    border-radius:3px;
    padding:1px 2px 1px 5px;

    font:normal 12px Arial;
    color:#666;
    height:20px;
    width:200px;
}

  </style>
  <script>
  </script>
</head>
<body>
<div class="Wrapper">
   <div class="Total">Your total is $<%=total%></div>
       <div class="Body">
       <fieldset>
       <legend>Pay With Credit Card</legend>
       <div class="CC">

             <form action="miniBillingControl.jsp" method="POST" id="cc">

                        <img src="images/cardAccept.jpg" alt="" height="15px">
                        <table>
                        <tr><td>Credit Card#:</td><td><input type="text" class="NiceInput" name="ssl_card_number" value=""  maxlength="16"></td></tr>
                        <tr><td>Expiration:</td><td>Month(MM):<input type="text" class="NiceInput" style="width:25px;" name="ssl_exp_date_M" value="" maxlength="2"> Year(YY):<input type="text" class="NiceInput" name="ssl_exp_date_Y"  style="width:25px;" value="" maxlength="2"></td></tr>
                        <tr><td>Sec. Code:</td><td><input type="text" class="NiceInput" name="ssl_cvv2cvc2" value="" maxlength="4"></td></tr>
                        <tr><td>Billing Add:</td><td><input type="text" class="NiceInput" name="ssl_avs_address" value=""></td></tr>
                        <tr><td>Billing Zip:</td><td><input type="text" class="NiceInput" name="ssl_avs_zip" value="" maxlength="5"></td></tr>
                        </table>
                        <input type="submit" value="Pay Now">
                        </form>
       </div>
        </fieldset>
       <fieldset>
       <legend>Pay With PayPal</legend>
       <div class="PP">
           <form action="paypalfunctions.jsp">
           <input type="image" name='send' src='https://www.paypal.com/en_US/i/btn/btn_xpressCheckout.gif' border='0' align='top' alt='Check out with PayPal' onclick="type(2);"/>
               </form>
       </div>
        </fieldset>
       <fieldset>
       <legend>Place order under terms</legend>
       <div class="PP">
           <input type="submit" value="Bill me later">
       </div>
        </fieldset>
   </div>
   <div class="Cancel">Cancel</div>

</div>

</body>
</html>