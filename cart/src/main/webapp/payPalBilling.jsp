
<%@ page import="org.json.*,java.util.*,egprint.*" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="egprint.Utilities" %>
<%@ page import="egprint.cart.CartUtilities" %>
<%@include file="common.jsp"%>
<%@include file="checkLogin.jsp"%>
<%
JSONObject theCart=( org.json.JSONObject)session.getAttribute("shoppingCart");
    if(theCart==null)theCart=new JSONObject();

   String token = egprint.Utilities.get(request, "token");
   if (token==null)
   {
     session.setAttribute("message","You have reached an invalid page.");
       Utilities.log("Customer reached invalid page");response.sendRedirect("result.jsp");return;  
   }
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  <title>Checkout - EGPRINT - Your Online Print Super Store</title>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/jquery-ui.min.js"></script>

  <script type="text/javascript" src="JSON.js"></script>
  <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/themes/smoothness/jquery-ui.css" />
  <link rel="stylesheet" type="text/css" href="css/ui.spinner.css" />
  <link rel="stylesheet" type="text/css" href="css/jquery.ui.selectmenu.css" />
  <link rel="stylesheet" type="text/css" href="css/register.css" />
  <link rel="stylesheet" type="text/css" href="css/leftPanel.css" />
  <link rel="stylesheet" type="text/css" href="css/topMenu.css" />
  <link rel="stylesheet" type="text/css" href="css/checkout.css" />
  <script type="text/javascript" src="js/spinner.js"></script>
  <script type="text/javascript" src="cos.jsp"></script>
  <script type="text/javascript" src="js/jquery.ui.selectmenu.js"></script>

  <script type="text/javascript" src="js/shipping.js"></script>

  <style type="text/css">

  </style>
<link rel="stylesheet" href="register.css">

  <script>

      /**
       * Redraw breadcrumbs
       **/
      <%
      int currentStep = 3;
      %>
      var currentStep=<%=currentStep%>;

      function prevStep(){
          if(currentStep==1){return;}
          swapSteps();
          currentStep--;
          refreshBreadCrumbs();
      }


      function disableNext(){}
      function enableNext(){}
      function hh(){
          switch(currentStep){
              case 1:$("#nextStep").toggleClass("Shipping3");break;
              case 2:$("#nextStep").toggleClass("Payment3");break;
          }
      }

      function refreshBreadCrumbs(){
          var distance = 10;
          $("#breadCrumbs > ul > li").each(function(i,element){
              if(i<(currentStep*2)){distance+=$(element).width();}
              if(i==0){return;}//Ignore OpenCap
              if(i==10){return;}//Ignore EndCap

              //Active Divider
              if(i%2==0){if(i<=currentStep*2){$(element).addClass("ActiveDivider");}}
              //Active Step
              if(i%2==1){
                    if(i<=(currentStep*2 -1))
                    {$(element).addClass("ActiveStep");distance+=20;}
                  else{
                     $(element).removeClass("ActiveStep");
                    }

              }

          })

          if (currentStep==5){$(".EndCap").addClass("ActiveEndCap");distance+=10;}
          else{$(".EndCap").removeClass("ActiveEndCap");}

          //Progress bar calculation
          distance=800-distance;
          //alert(distance);
          $("#breadCrumbsUl").stop().animate(
                      {backgroundPosition:"-"+distance+"px -1px"},
                      {duration:1000});
      }

      /**
       * Delayed send
       * Recursive hell...
       */
        function delayedSend(method){

          $(".Overall").fadeIn();
          $("#messageDisplay").fadeIn();
          $("#messageDisplay").centerScreen();
          $.getJSON("billing.jsp?callback=?&token=<%=token%>",function(data){
             // alert(JSON.stringify(data));
              $("#MessageLdr").html(data.error);
          })


        }

      $(document).ready(function() {
  jQuery.fn.centerScreen = function(loaded) {
      var obj = this;
      if(!loaded) {
          obj.css('top', $(window).height()/2-this.height()/2);
          obj.css('left', $(window).width()/2-this.width()/2);
          $(window).resize(function() { obj.centerScreen(!loaded); });
      } else {
          obj.stop();
          obj.animate({ top: $(window).height()/2-this.height()/2, left: $
  (window).width()/2-this.width()/2}, 200, 'linear');
      }
  }
  });



      function init()
      {

          $("#messageDisplay").centerScreen();
          delayedSend('paypal');
         //$(".LeftPanel").height(Math.max($(".RightPanel").height(),600));

         refreshBreadCrumbs();
          $('.CheckoutSpinner').change(function(){updateQty($(this));});
          $('.CheckoutSpinner').spinner({ min: 1, max: 99 ,step:1});
          $('.RemoveButton').click(function(){remove($(this).attr('key'));});

          //PreLoad Shopping Cart button Images
          $("<img src='images/Shipping/Shipping_1.png' onload=''/>");
          $("<img src='images/Shipping/Shipping_2.png' onload=''/>");
          $("<img src='images/Shipping/Shipping_3.png' onload=''/>");

          $("<img src='images/Payment/Payment_1.png' onload=''/>");
          $("<img src='images/Payment/Payment_2.png' onload=''/>");
          $("<img src='images/Payment/Payment_3.png' onload=''/>");

      }

      $(document).ready(function(){init();});
  </script>
</head><body>

<div class="Body">

    <%@include file="topMenu.jsp"%>

    <%@include file="leftPanel.jsp"%>
    <div class="RightPanel">


       <div class="Checkout">
           <div id="breadCrumbs">

       <div id="continueButton" class="ContinueButton " onclick="document.location='/home.jsp'"></div>
               <ul id="breadCrumbsUl">
               <li class="OpenCap"></li>
               <%
               String steps[] = new String[]{"Checkout","Shipping","Payment","Upload Files","Order Complete"};
               for (int i =  0; i<steps.length;i++)
                {%>
                  <li class="Step"><%=steps[i]%></li>
                  <%if(i==steps.length-1){continue;}//Skip the last divider%>
                  <li class="Divider"></li>
                <%}
               %>
               <li class="EndCap"></li>
               </ul>
           </div>
           <div id="cartFlow">

               <div id="paymentsContainer" class="CheckoutFlow" step="3" style="<%=(currentStep>3)?"display:none;":""%><%=(currentStep==3)?"display:block;":""%>">

               </div>
           </div>
           <div id="staticCart">
               <div class="YourOrder">
                   Your Order
               </div>
               <div class="StaticDetails">
                   <%  try{
                          JSONObject cart = ( org.json.JSONObject)session.getAttribute("shoppingCart");

                          java.util.Iterator<String> keys = cart.getJSONObject("products").keys();
                          int i = 0;
                          double cartTotal=0;
                          double tax = activeCustomer.get("Taxable").equals("1")?.07:0.0;
                          while (keys.hasNext())
                          {
                              i++;
                              String key = keys.next();
                              JSONObject qty = cart.getJSONObject("products").getJSONObject(key);
                              JSONObject product = qty.getJSONObject("product");
                              int sets=qty.getInt("sets");
                              cartTotal+=product.getDouble("Price")*sets;
                              %>
                       <div class="StaticProductDetail" id="static_<%=key%>">
                           <table class="StaticTable">
                               <tr>
                                   <td class="StaticNumber"><%=i%>.</td>
                                   <td class="StaticTitle" >
                                        <%=product.get("ProductName")%><br>
                                       <span>Qty: <span class="sqty_<%=key%>"><%=product.getString("Description")%></span> x <span class="sset_<%=key%>"><%=qty.getString("sets")%></span></span>
                                   </td>
                                   <td class="StaticPrice sprice_<%=key%>">$<%=Utilities.money(""+(product.getDouble("Price")*sets))%></td>
                               </tr>
                               <tr>
                                   <td></td>
                                   <td>Shipping Via: <span class="StaticShipping sship_<%=key%>">TBD</span></td>
                                   <td class="StaticPrice StaticShipPrice sShipPrice_<%=key%>"></td>
                               </tr>
                           </table>
                       </div>
                     <%}%>

               </div>
               <div class="StaticTotals">
                     <table class="StaticTable">
                           <tr>
                               <td class="StaticNumber"></td>
                               <td class="StaticTotal">Cart Subtotal: </td>
                               <td class="StaticPrice staticSubTotal"></td>
                           </tr>
                           <tr>
                               <td class="StaticNumber"></td>
                               <td class="StaticTotal">Sales Tax: </td>
                               <td class="StaticPrice staticTax"></td>
                           </tr>
                           <tr>
                               <td class="StaticNumber"></td>
                               <td class="StaticTotal">Shipping Subtotal: </td>
                               <td class="StaticPrice staticShipTotal"></td>
                           </tr>
                           <tr>
                               <td class="StaticNumber"></td>
                               <td class="StaticGrandTotal">Your total: </td>
                               <td class="StaticTotalPrice staticGrandTotal"></td>
                           </tr>
                      </table>
               </div>
               <table width="100%" style="margin:10px 0 0 0;">
                   <tr>
                    <td align="right"  height="40"><div id="nextStep" class="CartButton <%if(currentStep==1){%>Shipping2<%} else if(currentStep==2){%>Payment1<%} else{%><%}%>" ></div></td>
                   </tr>
                   <tr>
                    <td align="left"  height="40"><div id="prevStep" class="CartButton Prev3" style="display:none;" ></div></td>
                   </tr>
                   <tr>
                    <td colspan="2" align="center"><div id="" class="ContinueLink" onclick="document.location='/home.jsp'">Continue Shopping</div></td>
                   </tr>
               </table>



                       <%

                      }catch(Exception e){e.printStackTrace();}
                      %>
               <div class="CallExpert">
                 <img src="images/callExpert.jpg" alt="">
               </div>
           </div>


       </div>


    </div>
    <%@include file="footer.jsp"%>

</div>
  <div class="MessageContainer2" id="messageDisplay" style="display:block;">
      <div class="Message2" id="message">
   <div id="info">
       <table height="100" width="100%" border="1"><tr><td>
           <div id="MessageLdr">Reading confirmation from PayPal... <img src='/images/ajax-loader.gif'><br>
               Do not close or reload this window. This process may take up to a minute.
           </div>

       </td></tr></table>

      </div>
   </div>
</div>
<div class="Overall" id="mask"  style="display:block;"></div>
<script type="text/javascript">

    $(".Overall").fadeIn();
    $("#messageDisplay").fadeIn();
    $("#messageDisplay").centerScreen();
    $.getJSON("billing.jsp?callback=?&token=<%=token%>",function(data){
       // alert(JSON.stringify(data));
        $("#MessageLdr").html(data.error);
    })

</script>
</body></html>