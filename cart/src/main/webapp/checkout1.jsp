
<%@ page import="org.json.*,java.util.*,egprint.*" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="egprint.Utilities" %>
<%@ include file="common.jsp" %>
<%@include file="checkLogin.jsp"%>
<%
response.setHeader("Pragma","no-cache");    
response.setHeader("Cache-Control","no-cache");
response.setHeader("Expires","-1");
JSONObject theCart=( org.json.JSONObject)session.getAttribute("shoppingCart");
    if(theCart==null)theCart=new JSONObject();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  <title>Checkout - EGPRINT - Your Online Print Super Store</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/jquery-ui.min.js"></script>

  <script type="text/javascript" src="JSON.js"></script>
  <link rel="stylesheet" type="text/css" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/themes/smoothness/jquery-ui.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/ui.spinner.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/jquery.ui.selectmenu.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/register.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/leftPanel.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/topMenu.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/checkout.css" />
  <script type="text/javascript" src="<%=base%>js/spinner.js"></script>
  <script type="text/javascript" src="<%=base%>cos.jsp"></script>
  <script type="text/javascript" src="<%=base%>js/jquery.ui.selectmenu.js"></script>

  <script type="text/javascript" src="<%=base%>js/shipping.js"></script>

  <style type="text/css">

  </style>

  <script>

      /**
       * Redraw breadcrumbs
       **/
      <%
      int currentStep = 1;
      %>
      var currentStep=<%=currentStep%>;
      function nextStep(){

          if(currentStep==5){return;}
          if(currentStep==2){if(cart.shipping.type==2){if(!validate()){return;}}}
          if(currentStep==2){if(cart.shipping.type==-1){alert("Shipping method not selected!");return;}}
          //swapSteps();
          currentStep++;
          refreshBreadCrumbs();
          syncCart(true);


      }

      function disableNext(){}
      function enableNext(){}
      function hh(){
          switch(currentStep){
              case 1:$("#nextStep").toggleClass("Shipping3");break;
              case 2:$("#nextStep").toggleClass("Payment3");break;
          }
      }
      function swapSteps(){



          $("#nextStep, #prevStep").unbind('click hover').fadeOut();
          $("[step="+currentStep+"]").stop().fadeOut(function(){
             //currentStep should be updated by then

              if(currentStep==1) {
                 $("#nextStep").removeClass("Payment3 Payment2 Payment1 Shipping3 Shipping1").addClass("Shipping2").fadeIn().click(function(){nextStep()}).hover(hh,hh);
              }
          else{
                  $("#prevStep").click(prevStep).fadeIn();
              }

              if(currentStep==2) {
                 $("#nextStep").unbind('click').removeClass("Shipping1 Shipping2 Shipping3 Payment3 Payment2").addClass("Payment1").fadeIn();
              }


               $("[step="+currentStep+"]").stop().fadeIn(function(){
                  $("#prevStep").attr("disabled",false);
                   if(currentStep==1){$("#nextStep").attr("disabled",false);}
                   if(currentStep==2&&$("input:radio[name=MainShipOption]:checked").length>0)
                   {$("#nextStep").removeClass("Shipping1 Shipping2 Shipping3 Payment3 Payment2").addClass("Payment2").fadeIn().click(nextStep).hover(hh,hh);}

              });
             equalize();
             $('.CheckoutSpinner').spinner('destroy').attr('style','');
              setTimeout("$('.CheckoutSpinner').spinner({ min: 1, max: 99 ,step:1});",10);
          });


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

          if(currentStep==2){
              if(cart.shipping.totals){refreshShipping();}
             // else {fetchShipping();}
          }
      }

      /**
       * Delayed send
       * Recursive hell...
       */
        function delayedSend(method){

            $("#"+method).submit();return;
            $("input").attr("disabled",true);
            $("#nextStep").attr("disabled",true);
            if(retrieving){setTimeout("delayedSend("+method+")",500);return false;}
            $("form").css({color:"#F00"});
          //  alert(method+" "+$("#cc").serialize()+"<");
           // $("#"+method)[0].submit();
        }

      /**
       * Updates the pricing for a certain field and synchronizes shopping cart.
       * @param field
       */
      var updatingQty="";
      function updateQty(field){
          try{
         var key  = field.attr('key');
         var sets = parseInt(field.val());
         cart.products[key].sets=sets;
         clearTimeout(updatingQty)
         updatingQty=setTimeout("syncCart(false);",750);

         var product = cart.products[key].product;
         var price = parseFloat(product.Price)*sets;
         var fullPrice = parseFloat(product.fullPrice)*sets;
         var discount = parseFloat(product.discount)*sets;
         //alert(JSON.stringify(product));
          /*Update Large product detail*/
          $("#total_"+key+", .sprice_"+key).html("$"+price.toFixed(2));
          $("#discount_"+key).find(".Value").html("($"+discount.toFixed(2)+")");
          $(".sqty_"+key).html(product.Description);
          $(".sset_"+key).html(sets);
          $("#qty_"+key).find(".Value").html("$"+fullPrice.toFixed(2));
              var s = "";
              if(sets>1){s="s";}
          $("#qty_"+key).find(".Desc").html(product.Description + " x "+sets+" set"+s);
          }catch(e){}
          //fetchShipping();
          updateTotal();
          refreshTotal();
      }
      reloadSite=false;
      function remove(key)
      {
          fade($("#static_"+key));
          fade($("#product_"+key));
          fade($("#smallCart_"+key));
          cart.products[key].sets=0;
          syncCart(false);
      }

      function fade(element,handler){
          element.stop().animate({opacity:0},500,function(){$(this).slideUp();updateTotal();equalize();});

      }
      var totalPrice = 0.0;
      var totalShip = 0.0;
      var taxRate = <%=activeCustomer.get("Taxable").equals("1")?"0.07":"0.00"%>;
      function updateTotal(){
           totalPrice = 0.0;
           totalShip = 0.0;

          for(var key in cart.products)
          {
              var qty = cart.products[key];
              var product= qty.product;
              var sets= qty.sets;
              var price = product.Price*sets;
              //if(!cart.shipping.products[key]){product.shipping=0.00;}{}
             // var shipping = product.shipping*sets;
              totalPrice+=price;
              //totalShip+=shipping;
          }
          if(cart.shipping.type!="-1"){refreshShipping();}
          else{refreshTotal();} //To avoid a recursive loop.
      }

      function refreshTotal()
      {
           $(".staticSubTotal").html("$"+totalPrice.toFixed(2));
           $(".staticTax").html("$"+(totalPrice*taxRate).toFixed(2));
           $(".staticShipTotal").html("$"+(totalShip).toFixed(2));
           $(".staticGrandTotal").html("$"+((totalPrice*(1.00+taxRate))+totalShip).toFixed(2));
      }
      /**
       * Synchronize with server side cart.
       */
      var inSync="";
      var retrieving=false;
      function syncCart(redirect){
          var params = new Object();
          params.action="sync";
          params.currentStep=currentStep;
          saveShipping();
          cart.id = parseInt(cart.id)+1;
          params.cart=JSON.stringify(cart);
          if(redirect){
          $(".Overall").fadeIn();
          $("#messageDisplay").fadeIn();
          $("#messageDisplay").centerScreen();
          }
          inSync= $.post("checkout/",params,function(data){
           cart=data;
           if(redirect){setTimeout('$("#goTo2").submit();',1000);return;}
           });
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
          //Equalize colum witdh

         //$(".LeftPanel").height(Math.max($(".RightPanel").height(),600));

         try{
         refreshBreadCrumbs();
          $('.CheckoutSpinner').change(function(){updateQty($(this));});
          $('.CheckoutSpinner').spinner({ min: 1, max: 99 ,step:1});
          $('.RemoveButton').click(function(){remove($(this).attr('key'));});
          if(currentStep==1){$("#prevStep").fadeOut();$("#nextStep").click(function(){nextStep();}).hover(hh,hh); }else{$("#prevStep").click(prevStep).fadeIn();}

          //PreLoad Shopping Cart button Images
          $("<img src='images/Shipping/Shipping_1.png' onload=''/>");
          $("<img src='images/Shipping/Shipping_2.png' onload=''/>");
          $("<img src='images/Shipping/Shipping_3.png' onload=''/>");

          $("<img src='images/Payment/Payment_1.png' onload=''/>");
          $("<img src='images/Payment/Payment_2.png' onload=''/>");
          $("<img src='images/Payment/Payment_3.png' onload=''/>");
         }catch(ee){}
      }

      $(document).ready(function(){init();});
      $(window).unload(function(){
          $(".Overall").hide();
          $("#messageDisplay2").hide();
      })
  </script>
</head><body>
<form action="checkout2.jsp" method="POST" id="goTo2" enctype="multipart/form-data"><input type="hidden" value="<%=System.currentTimeMillis()%>"></form>
<div class="Body">

    <%@include file="topMenu.jsp"%>

    <%@include file="leftPanel.jsp"%>
    <div class="RightPanel">


       <div class="Checkout">
           <div id="breadCrumbs">

       <div id="continueButton" class="ContinueButton " onclick="document.location='home.jsp'"></div>
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
               <div id="largeOrdersContainer" step="1" style="<%=(currentStep>1)?"display:none;":""%>">
                  <%  try{
                      if(cart!=null){
                      java.util.Iterator<String> keys = cart.getJSONObject("products").keys();
                      int i = 0;
                      while (keys.hasNext())
                      {
                          i++;
                          String key = keys.next();
                          JSONObject qty = cart.getJSONObject("products").getJSONObject(key);
                          JSONObject product = qty.getJSONObject("product");
                          int sets = qty.getInt("sets");
                          %>

                   <div class="ProductDetail" id="product_<%=key%>">
                      <div class="RemoveDiv"><div class="RemoveButton" key="<%=key%>">X</div></div>
                      <div class="ProductDetailTitle"><%=i%>. <%=product.getString("Category")%> <span class="Sets">(Sets: <input id="sets_<%=key%>" key="<%=key%>" value="<%=qty.get("sets")%>" class="CheckoutSpinner">)</span></div>
                      <div class="ProductDetailHead">
                          <div class="ProductName">
                              <%=product.get("ProductName")%>
                          </div>

                          <div id="total_<%=key%>"class="ProductPrice">
                             $<%=Utilities.money(""+(product.getDouble("Price")*sets))%>
                          </div>
                          <div class="ProductSets">

                          </div>
                      </div>
                       <table class="ProductDetailSpec">
                          <tr id="discount_<%=key%>">
                              <td class="Name">Discount:</td>
                              <td class="Desc">Printing Discount</td>
                              <td class="Value Discount">($<%=Utilities.money(""+(product.getDouble("discount")*sets))%>)</td>
                          </tr>
                          <tr id="qty_<%=key%>">
                              <td class="Name">Quantity:</td>
                              <td class="Desc"><%=product.get("Description")%></td>
                              <td class="Value">$<%=Utilities.money(""+(product.getDouble("fullPrice")*sets))%></td>
                          </tr>
                          <tr>
                              <td class="Name">Size:</td>
                              <td class="Desc"><%=product.get("Width")%> <%=product.get("Height")%></td>
                              <td class="Value"></td>
                          </tr>
                          <tr>
                              <td class="Name">Stock:</td>
                              <td class="Desc"><%=product.get("Stock")%></td>
                              <td class="Value"></td>
                          </tr>
                          <tr>
                              <td class="Name">Sides:</td>
                              <td class="Desc"><%=product.get("Sides")%></td>
                              <td class="Value"></td>
                          </tr>
                          <tr>
                              <td class="Name">Colors:</td>
                              <td class="Desc"><%=product.get("Colors")%></td>
                              <td class="Value"></td>
                          </tr>
                          <tr>
                              <td class="Name">Coating:</td>
                              <td class="Desc"><%=product.get("UV")%></td>
                              <td class="Value"></td>
                          </tr>
                          <tr>
                              <td class="Name">Turn-Around:</td>
                              <td class="Desc"><%=product.get("TurnAround")%> <%=product.get("TurnAroundUnit")%></td>
                              <td class="Value"></td>
                          </tr>
                       </table>



                   </div>
                   <%
                      }
                   }else{%>
                     <div class="ShipOption"> Your cart is empty! </div></div>
                   <%}
                  }catch(Exception e){e.printStackTrace();}

                  %>
               </div>

           </div>
           <div id="staticCart">
               <div class="YourOrder">
                   Your Order
               </div>
               <div class="StaticDetails">
                   <%  try{

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
                               <td class="StaticPrice staticSubTotal">$<%=Utilities.money(cartTotal+"")%></td>
                           </tr>
                           <tr>
                               <td class="StaticNumber"></td>
                               <td class="StaticTotal">Sales Tax: </td>
                               <td class="StaticPrice staticTax">$<%=Utilities.money(cartTotal*tax+"")%></td>
                           </tr>
                           <tr>
                               <td class="StaticNumber"></td>
                               <td class="StaticTotal">Shipping Subtotal: </td>
                               <td class="StaticPrice staticShipTotal"></td>
                           </tr>
                           <tr>
                               <td class="StaticNumber"></td>
                               <td class="StaticGrandTotal">Your total: </td>
                               <td class="StaticTotalPrice staticGrandTotal">$<%=Utilities.money(cartTotal*(1.0+tax)+"")%></td>
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
                    <td colspan="2" align="center"><div id="" class="ContinueLink" onclick="document.location='home.jsp'">Continue Shopping</div></td>
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

  <div class="MessageContainer2" id="messageDisplay">
      <div class="Message2" id="message">
   <div id="info">
       <table height="100" width="100%" border="1"><tr><td>
           <div id="MessageLdr">Calculating Shipping...  <img src='images/ajax-loader.gif'></div>

       </td></tr></table>

      </div>
   </div>
</div>
<div class="Overall" id="mask"></div>
</body></html>