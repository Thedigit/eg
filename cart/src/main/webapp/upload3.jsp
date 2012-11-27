
<%@ page import="org.json.*,java.util.*,egprint.*" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="egprint.Utilities" %>
<%@ page import="egprint.cart.CartUtilities" %>
<%@ page import="egprint.mail.EmailMessage" %>
<%@ page import="egprint.mail.Mailman" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="egprint.quickbooks.QuickBooksUtils" %>
<%@ page import="java.math.BigInteger" %>
<%@ page import="egprint.communications.sms.SMSMessage" %>
<%@include file="common.jsp"%>
<%@include file="checkLogin.jsp"%>
<%@ include file="paypalfunctions.jsp" %>

<%

   // JSONObject cart=( org.json.JSONObject)session.getAttribute("shoppingCart");
    session.setAttribute("shoppingCart",null);
    System.out.println("Cart at upload: \n"+cart);
    if(cart==null){response.sendRedirect("account.jsp");return;}

    //Retrieve Billing Info:
    String type = (String) session.getAttribute("type");
    String method = (String) session.getAttribute("method");
    String note = (String) session.getAttribute("note");
    double totalPayment = Double.valueOf((String)session.getAttribute("totalPayment"));
    int pcode = Integer.valueOf((Integer) session.getAttribute("pcode"));
    JSONObject invoice = (JSONObject) session.getAttribute("invoice");

     //Save or update address.
    JSONObject add = cart.getJSONObject("shipping").getJSONObject("address");
    System.out.println("Adddress>>"+add);
    if(!add.has("id")){add.put("id","-1");}
    if (add.getInt("id") != -1) //Update an existing address
    {
        Utilities.updateAddress(add);
    } else {
        add.put("CustomerId", activeCustomer.get("insideId"));
        add.put("Default", "0");
        int id = Utilities.insertAddress(add);
        add.put("id", id);//This is where we're shipping to.
    }

    /**Determine how many order this customer has placed**/
    int orderCount= 0;
    try {
        orderCount = Integer.parseInt(Utilities.fetch3("SELECT COUNT(o.*) as `total` FROM egprint.orders o WHERE o.customer='" + activeCustomer.get("insideId") + "'").get(0).get("total"));
    } catch (NumberFormatException e) {
        e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
    }


    ArrayList<String> invoices = new ArrayList<String>();
    HashMap<String, String> emailConfirmation = new HashMap<String, String>();
    ArrayList<JSONObject> newOrders = new ArrayList<JSONObject>();
    try {

        java.util.Iterator<String> keys = cart.getJSONObject("products").keys();
        int i = 0;
        while (keys.hasNext()) {
            i++;
            String key = keys.next();
            JSONObject qty = cart.getJSONObject("products").getJSONObject(key);
            JSONObject product = qty.getJSONObject("product");
            JSONObject productOptions = qty.getJSONObject("options");
            int sets = qty.getInt("sets");
            int round = java.math.BigDecimal.ROUND_HALF_UP;
            java.math.BigDecimal itemShipping = new java.math.BigDecimal(CartUtilities.getCartItemShipping(cart, key)).setScale(2, round);
            java.math.BigDecimal partialItemShipping = itemShipping.divide(new java.math.BigDecimal(sets), 2, round);


            for (int j = 1; j <= sets; j++) {
                double shipPrice = 0;
                int stype = cart.getJSONObject("shipping").getInt("type");

                if (stype != 1) {
                    shipPrice = CartUtilities.getCartShipping(cart);
                }
                double itemPrice = product.getDouble("Price");
                double itemTax = itemPrice * ((activeCustomer.get("Taxable").equals("1") ? 0.07 : 0.0));
                java.math.BigDecimal thisItemShipping = itemShipping.subtract(partialItemShipping.multiply(new java.math.BigDecimal((sets - j) + "")));
                itemShipping = itemShipping.subtract(thisItemShipping);
                double itemTotal = itemPrice + itemTax + thisItemShipping.doubleValue();

                JSONObject newOrder = Utilities.createOrder(qty.getString("qty"), activeCustomer.get("insideId"), add.getString("id"), cart.getJSONObject("shipping").getString("type"), cart.getJSONObject("shipping").getString("subtype"), "EG", activeCustomer.get("Taxable"),null, thisItemShipping.setScale(2, round).toString(), pcode, type,invoice,productOptions);
                newOrder.put("set",j);
                newOrder.put("totalSets",sets);
                newOrders.add(newOrder);
                try {

                    emailConfirmation.put(newOrder.getString("order"),
                            "\nINVOICE: " +invoice.getString("number") +
                                    "\n\nSET: " + j + " of " + sets + " \n" +
                                    CartUtilities.getCartItemString(cart, key, activeCustomer.get("Taxable").equals("1")) +
                                    "\n\nTransaction:\n 	Type: " + type + "\n   Method: " + method + "\n   Notes: " + note
                    );
                   // invoices.add(Utilities.getInvoiceHeader() + "-" + newOrder.get("order"));
                    invoices.add(invoice.getString("number"));

                } catch (Exception e) {
                    e.printStackTrace();
                    Utilities.log("Error Creating Orders for " + activeCustomer.get("Customer") + "\n" + e.getMessage());
                }
            }
        }
        StringBuffer emailBody = new StringBuffer("MONEY TIME:\n TOTAL AMOUNT CHARGED: " + Utilities.money(totalPayment + "") + "\nType: " + type + "\n   Method: " + method + "\n   Notes: " + note + "\n SYSTEM TIME: " + (new Date()) + "\n");
        emailBody.append("CUSTOMER:\n" + activeCustomer.get("insideId") + " - " + activeCustomer.get("Customer") +
                activeCustomer.get("Contact") + "\n" +
                activeCustomer.get("Address1") + "\n" +
                activeCustomer.get("City") + ", " +
                activeCustomer.get("State") + " " +
                activeCustomer.get("Zip") + "\n"
        );
        Iterator<String> emailOrders = emailConfirmation.keySet().iterator();
        while (emailOrders.hasNext()) {
            String emailOrder = emailOrders.next();
            emailBody.append((String) emailConfirmation.get(emailOrder) + "\n\n+++++++++++++++++++\n");
        }

        egprint.mail.EmailMessage em = new egprint.mail.EmailMessage("mailbyluna@gmail.com", "orders@egprint.net", "New Order " + activeCustomer.get("insideId") + " - " + activeCustomer.get("Customer"),
                emailBody.toString()
                , "3141", "LennyLand");
        egprint.mail.Mailman.queue.size();
        egprint.mail.Mailman.send(em);

        //SEND SMS MESSAGE FOR FIRST TIME CUSTOMERS
        try {
            System.out.println("orderCount = " + orderCount);
            if(orderCount>=0){
                SMSMessage smsMessage = new SMSMessage();
                smsMessage.setBody("New Customer! "+activeCustomer.get("Contact")+" from "+activeCustomer.get("Customer")+". Phone: "+activeCustomer.get("Phone"));
                smsMessage.setTo("9543589682");
                smsMessage.send();
            }
        } catch (Exception e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
 /*
    session.setAttribute("type",type);
    session.setAttribute("method",method);
    session.setAttribute("note",note); */
    session.setAttribute("newOrders",newOrders);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  <title>Checkout - EGPRINT - Your Online Print Super Store</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/jquery-ui.min.js"></script>

  <script type="text/javascript" src="JSON.js"></script>
  <link rel="stylesheet" type="text/css" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/themes/smoothness/jquery-ui.css" />
  <link rel="stylesheet" type="text/css" href="css/ui.spinner.css" />
  <link rel="stylesheet" type="text/css" href="css/jquery.ui.selectmenu.css" />
  <link rel="stylesheet" type="text/css" href="css/register.css" />
  <link rel="stylesheet" type="text/css" href="css/leftPanel.css" />
  <link rel="stylesheet" type="text/css" href="css/topMenu.css" />
  <link rel="stylesheet" type="text/css" href="css/checkout.css" />
  <script type="text/javascript" src="js/spinner.js"></script>
  <script type="text/javascript" src="js/jquery.ui.selectmenu.js"></script>
    <script type="text/javascript" src="cos.jsp"></script>
    <script type="text/javascript" src="js/shipping.js"></script>



  <style type="text/css">

  </style>
<link rel="stylesheet" href="register.css">

  <script>
       noLogout=true;
      /**
       * Redraw breadcrumbs
       **/
      <%
      int currentStep = Integer.valueOf((session.getAttribute("currentStep")!=null)?(String)session.getAttribute("currentStep"):"4");
      %>
      var currentStep=<%=4%>;
      function nextStep(){
          if(currentStep==4){
              $("#incompleteMessage").css({position:"absolute"}).fadeOut();
              $("#completeMessage").fadeIn();
              try{clearInterval(progressUpdater);}catch(e){}
          }
          if(currentStep==5){return;}
          if(currentStep==2){if(cart.shipping.type==2){if(!validate()){return;}}}
          swapSteps();
          currentStep++;
          refreshBreadCrumbs();


      }
      function prevStep(){
          if(currentStep==1){return;}
          swapSteps();
          currentStep--;
          refreshBreadCrumbs();
      }

      function swapSteps(){
          $("#nextStep, #prevStep").attr("disabled",true);
          $("[step="+currentStep+"]").stop().fadeOut(function(){
             //currentStep should be updated by then
               $("[step="+currentStep+"]").stop().fadeIn(function(){
                  $("#prevStep").attr("disabled",false);
                   if(currentStep==1){$("#nextStep").attr("disabled",false);}
                   if(currentStep==2&&cart.shipping.type!=-1){$("#nextStep").attr("disabled",false);}

              });

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
          if(currentStep==1){$("#nextStep").attr("disabled",false);}
          if (currentStep==5){$(".EndCap").addClass("ActiveEndCap");distance+=10;}
          else{$(".EndCap").removeClass("ActiveEndCap");}

          //Progress bar calculation
          distance=800-distance;
          //alert(distance);
          $("#breadCrumbsUl").stop().animate(
                      {backgroundPosition:"-"+distance+"px -1px"},
                      {duration:1000});


      }


      function remove(key)
      {
          fade($("#static_"+key));
          fade($("#product_"+key));
      }

      function fade(element,handler){
          element.stop().animate({opacity:0},500,function(){$(this).slideUp();});

      }

      var currentProgressTicket;
       var progressUpdater;
       var currentKey;


       function updateProgress()
   {
    currentProgressDiv = $("#pb_"+currentKey);
    $.getJSON('<%=activeCompany.optString("UploadDomain","")%>/UploadStatus?a='+currentProgressTicket+'&jsoncallback=?'
             , function(data) {
             if (data.done=="true")
             {

               currentProgressDiv.html("Upload Complete");
                 var ticket=$("#up_"+currentKey);
                 if(ticket.attr('count')==0){ticket.attr('count','1');}
                 uploadComplete(ticket);


                 return; }
             currentProgressDiv.empty();
             currentProgressDiv.html("<div style='position:absolute;width:320px;z-index:10;'>"+data.timeLeft+" (<b>"+data.percentage+"%</b>)</div>");
            // currentProgressDiv.css({width:data.percentage+"%"});//data.timeLeft+" (<b>"+data.percentage+"%</b>) ");
             var progBar= document.createElement('div','');
             progBar.style.width=data.percentage*3.18+"px";
             $("#sShipPrice_"+currentKey).html(data.percentage+"%");
             progBar.style.position="absolute";
             progBar.style.height="14px";
             progBar.style.border="solid 1px #1485C9";
             progBar.style.background="#1485C9";

             currentProgressDiv.append(progBar);
             });
   }

       function upload(ticket)
       {
            currentProgressTicket = ticket;
            progressUpdater = setInterval("updateProgress();",1000);
       }

       function uploadComplete(ticket)
       {
           var key=ticket.attr('key');
           if(ticket.attr('count')==0){ticket.attr('count','1');return;}
           $("#pb_"+key).stop();
           $("#pb_"+key).animate({backgroundColor:"#F4F4FF"}).html("Upload Complete");
           $("#fu_"+key).slideUp(function(){$("#form_"+key).remove();startUpload();});

         $("#sShipPrice_"+key).html("Complete");
       }
       function startUpload()
       {

          //validate inputs
           var pass=true;
           $("input").each(function(){
               if($(this).val()==""){pass=false;return;}
           });
           if(!pass){alert("All jobs require a name and one file per side.");return;}

           $("#nextStep").attr('disabled',true);
          var forms = $("form");

          if(!forms[0]){nextStep(); return}
          forms[0].submit();
          upload($(forms[0]).attr('ticket'));
          currentKey = $(forms[0]).attr('key');
       }


      function init()
      {
          //Equalize colum witdh
         $(".LeftPanel").height(Math.max($(".RightPanel").height(),600));

         refreshBreadCrumbs();

         //Listener for upload status fields
          $(".UpFrame").bind('load',function (){uploadComplete($(this));});

          //Toggle details();
          $(".DetailsHandle").click(function(){
              var table = $(this).next();
              if($(table).is(":visible")){table.slideUp();}
              else{table.slideDown();}
          })

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
               <div id="largeOrdersContainer" step="4">
                  <%
                       invoices = new ArrayList<String>();
                       emailConfirmation = new HashMap<String,String>();
                       newOrders = (ArrayList<JSONObject>)session.getAttribute("newOrders");
                      int ordIndex=0;
                      try{

                      java.util.Iterator<String> keys = cart.getJSONObject("products").keys();
                      int i = 0;
                      while (keys.hasNext())
                      {
                          i++;
                          String key = keys.next();
                          JSONObject qty = cart.getJSONObject("products").getJSONObject(key);
                          JSONObject product = qty.getJSONObject("product");
                          int sets = qty.getInt("sets");
                          int round =java.math.BigDecimal.ROUND_HALF_UP;
                          java.math.BigDecimal itemShipping = new java.math.BigDecimal(CartUtilities.getCartItemShipping(cart,key)).setScale(2,round);
                          java.math.BigDecimal partialItemShipping = itemShipping.divide(new java.math.BigDecimal(sets),2,round);
                          %>

                   <div class="ProductDetailCheckout" id="product_<%=key%>">
                      <div class="ProductDetailTitle"><%=i%>. <%=product.getString("Category")%> <span class="Sets">(Sets: <%=sets%>)</span></div>
                      <div class="ProductDetailHead">
                          <div class="ProductName">
                              <%=product.get("ProductName")%>
                          </div>
                      </div>
                       <div class="DetailsHandle">+ Details</div>
                       <table class="ProductDetailSpecSmall">
                          <tr id="qty_<%=key%>">
                              <td class="Name">Quantity:</td>
                              <td class="Desc"><%=product.get("Description")%></td>
                          </tr>
                          <tr>
                              <td class="Name">Size:</td>
                              <td class="Desc"><%=product.get("Width")%> x <%=product.get("Height")%></td>
                          </tr>
                          <tr>
                              <td class="Name">Stock:</td>
                              <td class="Desc"><%=product.get("Stock")%></td>
                          </tr>
                          <tr>
                              <td class="Name">Sides:</td>
                              <td class="Desc"><%=product.get("Sides")%></td>
                          </tr>
                          <tr>
                              <td class="Name">Coating:</td>
                              <td class="Desc"><%=product.get("UV")%></td>
                          </tr>
                          <tr>
                              <td class="Name">Turn-Around:</td>
                              <td class="Desc"><%=product.get("TurnAround")%> <%=product.get("TurnAroundUnit")%></td>
                          </tr>
                       </table>
                      <%

                        for (int j = 1 ; j <= sets;j++)
                       {
                      JSONObject newOrder = newOrders.get(ordIndex++);
                      %>
                        <div class="StepTitle2"><div class="ProgTitle">Set <%=j+" of "+sets%></div> <div class="ProgressBar" id="pb_<%=i+"_"+j%>"></div> </div>
                        <div class="ProductDetailHead"><div class="ProgTitle">EG<%=newOrder.get("order")%></div></div>
                       <div><iframe class="UpFrame" id="up_<%=i+"_"+j%>" name="up_<%=i+"_"+j%>" count='0' key='<%=i+"_"+j%>'></iframe></div>
                       <form id="form_<%=i+"_"+j%>" action="<%=activeCompany.optString("UploadDomain","")%>/FileUpload" method="POST" enctype="multipart/form-data" target="up_<%=i+"_"+j%>" key="<%=i+"_"+j%>" ticket="<%=newOrder.getString("ticket")%>">

                        <table class="FileUpload" id="fu_<%=i+"_"+j%>">
                            <tr><td class="UpTitle">Job Name:</td><td style=""><input  class="NiceInput1"  name="jobName" value=""><input type="hidden" name="uploadTicket" value="<%=newOrder.getString("ticket")%>"></td></tr>

                            <tr><td class="UpTitle">Artwork Front:</td><td style=""><!--input id="hideField_<%=i+"_"+j+"f"%>" class="NiceInput" readonly="" class='FileField ' value="...Click Here To Select..."--><input type="file" class="" name="file1" key="<%=i+"_"+j+"f"%>"></td></tr>
                            <%if(product.getString("Sides").toLowerCase().startsWith("two")){%>
                            <tr><td class="UpTitle">Artwork Back: </td><td style=""><!--input id="hideField_<%=i+"_"+j+"b"%>" class="NiceInput" readonly="" class='FileField ' value="...Click Here To Select..."--><input type="file" class="" name="file2" key="<%=i+"_"+j+"b"%>"></td></tr>
                            <%}%>
                            <tr><td class="UpTitle">Notes:</td><td><textarea  cols="30" class="NiceInput"  name="comments" value=""></textarea></td></tr>


                        </table>
                       </form>
                      <% }%>


                   </div>
                   <%

                      }

                  }catch(Exception e){e.printStackTrace();}
                  %>
               </div>

               <div id="finalContainer" class="CheckoutFlow" step="5"  style="<%=(currentStep>5)?"display:none;":""%><%=(currentStep==5)?"display:block;":""%>">
                   <div class="ProductDetail">
                       <div class="ProductDetailTitle">Order Complete</div>
                       <br>
                       Your order is now complete. You may check your status and upgrade your order 24/7 from your account page.
                       <br>
                       <a href="<%=activeCompany.optString("FullDomain","")%>"><%=activeCompany.optString("FullDomain","")%></a>
                   </div>
               </div>
           </div>
           <div id="staticCart">
               <div class="YourOrder">
                   File Upload Status
               </div>
               <div class="StaticDetails">
                   <%  try{

                          int k=0;
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
                                       <span id="sset_<%=key%>">Qty: <%=product.getString("Description")%> x <%=qty.getString("sets")%></span>
                                   </td>
                                   <td class="StaticPrice" id="sprice_<%=key%>"></td>
                              <% for(int j = 1 ; j <= sets;j++){%>
                               </tr>
                               <tr>
                                   <td></td>
                                   <td>Set <%=j%> Upload Status:<br>(EG<%=newOrders.get(k++).getString("order")%>)</td>
                                   <td class="StaticPrice StaticShipPrice" id="sShipPrice_<%=i%>_<%=j%>">Incomplete</td>
                               </tr>
                               <%}%>
                           </table>
                       </div>
                     <%}%>

               </div>
               <div class="StaticTotals">
                   <div style="margin:10px" id="incompleteMessage">
                   <strong>Your order is not complete yet.</strong><br>
                   Please assign a name, and select the appropriate files for each set.
                   Then press the button below to upload the files, and finalize the order.
                   </div>
                   <div style="margin:10px;display:none;" id="completeMessage">
                   <strong>Your order is finalized!.</strong><br>
                   Thank you for your order!<br>
                   You can check the progress of your order 24/7 simply by logging in to this
                   page, and checking under "My Account".
                   </div>
               </div>
               <button id="nextStep" onclick="startUpload();">Upload All Files</button>
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

</body></html>