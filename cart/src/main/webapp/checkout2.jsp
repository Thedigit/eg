
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

  <script type="text/javascript" src="<%=base%>js/shipping2.js"></script>

  <style type="text/css">

  </style>

  <script>

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
      /**
       * Redraw breadcrumbs
       **/
      <%
      int currentStep = 2;
      %>
      var currentStep=<%=currentStep%>;
      function nextStep(){

          if(currentStep==5){return;}
          if(currentStep==2){if(cart.shipping.type==2){if(!validate()){return;}}}
          if(currentStep==2){if(cart.shipping.type==-1){alert("Shipping method not selected!");return;}}
          swapSteps();
          currentStep++;
          refreshBreadCrumbs();
          syncCart(false);


      }

      function prevStep()
      {document.location="checkout1.jsp";}

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



      function fade(element,handler){
          element.stop().animate({opacity:0},500,function(){$(this).slideUp();updateTotal();equalize();});

      }
      var totalPrice = 0.0;
      var totalShip = 0.0;
      var taxRate = <%=activeCustomer.get("Taxable").equals("1")?"0.07":"0.00"%>;
      function updateTotal(){
           totalPrice = 0.0;
           totalShip = 0.0;
          // alert(JSON.stringify(cart));
          for(var key in cart.products)
          {
              var qty = cart.products[key];
              var product= qty.product;
              var sets= qty.sets;
              var price = product.Price*sets;
              totalPrice+=price;
          }
         // if(cart.shipping.type!="-1"){refreshShipping();refreshTotal();}
         // else{refreshTotal();} //To avoid a recursive loop.
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
      function syncCart(refresh){
          if(firstLoad==1){alert("back" +refresh);firstLoad=false;return;}
          var params = new Object();
          params.action="sync";
          params.currentStep=currentStep;
          saveShipping();
          cart.id = parseInt(cart.id)+1;
          params.cart=JSON.stringify(cart);

          try{inSync.abort();retrieving=false;}catch(ee){}
          retrieving=true;

          $(".Overall").height($(document).height()).fadeIn();
          if(!refresh){
          $("#messageDisplay2").fadeIn();
          $("#messageDisplay2").centerScreen();}
          else{$("#messageDisplay2").fadeIn();
          $("#messageDisplay2").centerScreen();}
          inSync= $.post("checkout/",params,function(data){

              if(!refresh){setTimeout('firstLoad=1;document.location="checkout3.jsp";',1000);return;}
           cart=data;
              try{
           updateTotal();
              }catch(e){}
           // alert(reloadSite);
           retrieving=false;
              //document.location.reload(true);
              // alert(JSON.stringify(cart));
              $(".Overall").fadeOut();
              $("#messageDisplay2").fadeOut();
           });
      }

          $(document).ready(function() {

});
      var firstLoad=true;
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
          firstLoad=false;   
         }catch(ee){}
      }

      $(document).ready(function(){init();});
      $(window).unload(function(){
          $(".Overall").hide();
          $("#messageDisplay2").hide();
      })
  </script>
</head><body>

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



               <div id="shippingContainer" class="CheckoutFlow" step="2" style="display:block;">
                   <div class="ShipOptionMain">
                       <div class="StepTitle">
                           Shipping Options
                       </div>
                       <div class="ShippingOptions">
                        <table>
                            <tr><td><input type="radio" name="MainShipOption" value="2"></td><td>UPS</td><td></td></tr>
                            <%if(activeCustomer.get("State")!=null&&activeCustomer.get("State").equalsIgnoreCase("FL")){%><tr><td><input type="radio" name="MainShipOption" value="1"></td><td>Pickup</td><td></td></tr><%}%>
                            
                        </table>
                       </div>
                   </div>
                   <div class="ShipOption Hide" option="1">
                       <div class="StepTitle">Pickup</div>
                       <div class="ShipReadyDate"><strong>Estimated Ready Date:</strong><br> All products will be ready on, or before <strong><%=theCart.optString("lastJobDate","")%></strong></div>
                       <div class="PickupInstructions">
                           Details:
                           <ul>
                           <li>Pickup Hours: M-F From 8:00AM To 5:30PM</li>
                           <li>Depending on selected turnarounds, some products may be completed sooner</li>
                           <li>You will be notified by email when each product is ready for pickup</li>
                           <li>You can check product status 24/7 from your account for estimated completion dates</li>
                           </ul>

                       </div>
                   </div>
                   <div class="ShipOption Hide" option="2">
                       <div class="StepTitle">UPS</div>
                       <div class="ShipReadyDate"><strong>Estimated Ship Date:</strong><br> All products will ship on, or before <strong><%=theCart.optString("lastJobDate")%></strong></div>
                       <div class="StepTitle2" style="margin:20px 0 5px 0;">Shipping Address</div>
                       <div class="ShipAddress">

                           <select class="AddressBook MenuSelect" id="addressBook" name="State" size="1">
                            <option value="" selected="">Load From Address Book</option>
                            <%
                             ArrayList<HashMap<String,String>> addressBook = Utilities.fetch2("SELECT a.id, a.Alias, a.Contact,a.Business,a.Address1,A.City,A.State,A.Zip FROM egprint.address a WHERE a.customerId='"+activeCustomer.get("insideId")+"' ORDER BY a.Default DESC");
                                if(addressBook==null){%><option>No addresses have been saved</option><%}
                               else{
                                for(HashMap<String,String> address:addressBook){
                                    %>
                               <option value='<%=Utilities.h2j(address).toString().replaceAll("'","&#39;")%>'><%//Replace for single quote charater%>
                                   <%=address.get("Alias")%> - <%=address.get("Business")%> | <%=address.get("Address1")%> | <%=address.get("City")%>, <%=address.get("State")%> <%=address.get("Zip")%> | &nbsp;
                               </option>
                               <%
                                }
                               }
                            %>
                           </select>
                           <table>
                    <tr>
                        <td class="LeftField">Contact</td>
                        <td><input class="Required NiceInput" name="Contact"></td>
                    </tr>
                    <tr>
                        <td class="LeftField">Company</td>
                        <td><input class="Required NiceInput" name="Company"></td>
                    </tr>
                    <tr>
                        <td class="LeftField">Address</td>
                        <td><input class="Required NiceInput" name="Address"></td>
                    </tr>
                    <tr>
                    <tr>
                        <td class="LeftField">City</td>
                        <td><input class="Required NiceInput" name="City"></td>
                    </tr>
                    <tr>
                        <td class="LeftField">State</td>
                        <td>
                            <select class="Required MenuSelect" id="stateSelect" name="State" size="1">
                                <option selected value="">State...</option>
                                <option value="AL">Alabama</option>
                                <option value="AK">Alaska</option>
                                <option value="AZ">Arizona</option>
                                <option value="AR">Arkansas</option>
                                <option value="CA">California</option>
                                <option value="CO">Colorado</option>
                                <option value="CT">Connecticut</option>
                                <option value="DE">Delaware</option>
                                <option value="FL">Florida</option>
                                <option value="GA">Georgia</option>
                                <option value="HI">Hawaii</option>
                                <option value="ID">Idaho</option>
                                <option value="IL">Illinois</option>
                                <option value="IN">Indiana</option>
                                <option value="IA">Iowa</option>
                                <option value="KS">Kansas</option>
                                <option value="KY">Kentucky</option>
                                <option value="LA">Louisiana</option>
                                <option value="ME">Maine</option>
                                <option value="MD">Maryland</option>
                                <option value="MA">Massachusetts</option>
                                <option value="MI">Michigan</option>
                                <option value="MN">Minnesota</option>
                                <option value="MS">Mississippi</option>
                                <option value="MO">Missouri</option>
                                <option value="MT">Montana</option>
                                <option value="NE">Nebraska</option>
                                <option value="NV">Nevada</option>
                                <option value="NH">New Hampshire</option>
                                <option value="NJ">New Jersey</option>
                                <option value="NM">New Mexico</option>
                                <option value="NY">New York</option>
                                <option value="NC">North Carolina</option>
                                <option value="ND">North Dakota</option>
                                <option value="OH">Ohio</option>
                                <option value="OK">Oklahoma</option>
                                <option value="OR">Oregon</option>
                                <option value="PA">Pennsylvania</option>
                                <option value="RI">Rhode Island</option>
                                <option value="SC">South Carolina</option>
                                <option value="SD">South Dakota</option>
                                <option value="TN">Tennessee</option>
                                <option value="TX">Texas</option>
                                <option value="UT">Utah</option>
                                <option value="VT">Vermont</option>
                                <option value="VA">Virginia</option>
                                <option value="WA">Washington</option>
                                <option value="WV">West Virginia</option>
                                <option value="WI">Wisconsin</option>
                                <option value="WY">Wyoming</option>
                                </select>
                                </td>
                    </tr>
                    <tr>
                        <td class="LeftField">Zip Code</td>
                        <td><input id="shipZip" class="Required NiceInput" name="Zip" fieldType="^[0-9]{5}$" format="5 Digit Zip: xxxxx" maxlength="5"> </td>
                    </tr>
                    <tr>
                        <td class="LeftField"><input type="checkbox" name="saveAddress" checked="true">Save address as:</td>
                        <td><input class="NiceInput" name="Alias"></td>
                    </tr>
                           </table>

                       </div>

                       <div class="StepTitle2" style="margin:20px 0 5px 0;">Shipping Options for Zip Code: <span id="zipVerify"></span></div>
                       <div class="ShipOptions">
                           <table>
                                <tr>
                                    <td><input name="shipOption" type="radio" value="nextDay" stype="UPS-Next Day"></td>
                                    <td>Next Day Air</td>
                                    <td id="nda"><img src="images/ajax-loader.gif" alt="Loading..."></td>
                                </tr>
                                <tr>
                                    <td><input name="shipOption" type="radio" value="expedited2" stype="UPS-2 Day"></td>
                                    <td>2nd Day Air</td>
                                    <td id="ex2"><img src="images/ajax-loader.gif" alt="Loading..."></td>
                                </tr>
                                <tr>
                                    <td> <input name="shipOption" type="radio" value="ground" checked="" stype="UPS-Ground"></td>
                                    <td>Ground</td>
                                    <td id="gnd"><img src="images/ajax-loader.gif" alt="Loading..."></td>
                                </tr>
                                <tr>
                                    <td> <input name="shipOption" type="radio" value="self" disabled=""></td>
                                    <td>I will use my own UPS Account</td>
                                    <td>$3.00 (Handling fee)</td>
                                </tr>
                                <tr>
                                    <td> <input id="shipOptionInsure" name="shipOptionInsure" type="checkbox" checked=""></td>
                                    <td>Add Insurance</td>
                                    <td id="insuranceTotal"></td>
                                </tr>
                                <tr>
                                    <td> <input id="shipOptionSignature" name="shipOptionSignature" type="checkbox"></td>
                                    <td>Add Signature Confirmation</td>
                                    <td id="confirmationTotal"></td>
                                </tr>
                                <tr>
                                    <td> <input name="shipOptionCustom" type="checkbox"  disabled=""></td>
                                    <td>Ship with custom label</td>
                                    <td>(Coming soon)</td>
                                </tr>
                           </table>
                       </div>
                       <div class="PickupInstructions">
                           <div class="StepTitle2" style="margin:20px 0 5px 0;">Details</div>
                           <ul>
                           <li>Depending on selected turnarounds, some products may be completed sooner</li>
                           <li>You will receive a tracking number by email when a product is shipped.</li>
                           <li>You can check product status 24/7 from your account for estimated completion dates / tracking numbers.</li>
                           </ul>
                       </div>
                   </div>
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
  <div class="MessageContainer2" id="messageDisplay2">
      <div class="Message2" id="message2">
   <div id="info">
       <table height="100" width="100%" border="1"><tr><td>
           <div id="MessageLdr">Finalizing Order... <img src='images/ajax-loader.gif'></div>

       </td></tr></table>

      </div>
   </div>
</div>

<div class="Overall" id="mask"></div>
</body></html>