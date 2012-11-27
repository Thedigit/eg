<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap" %>
<%@include file="common.jsp"%>
<%@include file="checkLogin.jsp"%>

<%

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>EGPRINT - Your Online Print Super Store</title>
    <%@ include file="header.jsp"%>


  <link rel="stylesheet" type="text/css" href="css/myAccount.css" />
  <link rel="stylesheet" type="text/css" href="css/register.css" />
  <script type="text/javascript" src="js/spinner.js"></script>
  <script type="text/javascript" src="js/jquery.ui.selectmenu.js"></script>

  <style type="text/css">



  </style>
  <script type="text/javascript">
      var pass;
      var addObject;
            function submit(updateShipping,updateBilling){
                //Quick autocheck
                addObject = new Object();
                var fields="input.Required";
                if(updateShipping){
                   fields = fields+".ShippingInput"
                }
                if(updateBilling){
                   fields = fields+".BillingInput"
                }
                $(fields).each(function(){

                   var pattern = $(this).attr("fieldType");
                        //Simple required field.
                    if(!pattern){
                      if($(this).val().length==0){
                          alert($(this).attr('name')+" is required");
                          pass=false;
                          return false;
                      }
                        pass=true;
                        addObject[$(this).attr('name')]=$(this).val();  
                    }
                    else{
                          if(!$(this).val().match(pattern))
                          {
                              var format = $(this).attr('format');
                              if(!format){format="";}
                              alert("A valid "+$(this).attr('name')+" is required \n"+format);
                              pass=false;
                              return false;
                          }
                        pass=true;
                        addObject[$(this).attr('name')]=$(this).val();
                    }
                });
                if(!pass){return false;}

               var params = new Object();
               params.action = "updateAddress";
               addObject["id"]=<%=activeCustomer.get("insideId")%>
               if(updateShipping){addObject.updateShipping=true;}
               if(updateBilling){addObject.updateBilling=true;}
               params.addressObject=JSON.stringify(addObject);
              
               $.post("utils/",params,function(){document.location.reload(true);});
               
               }

      function init()
      {
          //Equalize column width
          $(".LeftPanel").height(Math.max($(".RightPanel").height(),600));
          $(".ListTable tr").hover(
                  function(){$(this).find('td').addClass("HighlightRow");},
                  function(){$(this).find('td').removeClass("HighlightRow");}
                  );
          $(".OrderList tr").click(function(){document.location = "orders.jsp?j="+$(this).attr('order');});
          $(".AddressList tr").click(function(){document.location = "addresses.jsp?a="+$(this).attr('address');});
          $("#editBilling" ).click(function(){$(this).fadeOut();$("#billingInfo").animate({height:245},"fast");$("#topBoxes").animate({height:265},"fast",function(){equalize();});$("#billingTable").css({position:"absolute"}).fadeOut("slow");$("#updateBilling").fadeIn("slow");})
          $("#editShipping").click(function(){$(this).fadeOut();$("#shippingInfo").animate({height:245},"fast");$("#topBoxes").animate({height:265},"fast",function(){equalize();});$("#shippingTable").css({position:"absolute"}).fadeOut("slow");$("#updateShipping").fadeIn("slow");})
          $("#saveBilling").click(function(){submit(false,true);}) 
          $("#saveShipping").click(function(){submit(true,false);})
          $('.Required').each(function(){
              var req = $(document.createElement('span')).html("*").addClass("Required");
              $(this).parent().prev().append(req);

          })

      }

      $(document).ready(function(){init();});
  </script>
</head>
<body>

<div class="Body">
    <%@include file="topMenu.jsp"%>

    <%@include file="leftPanel.jsp"%>
    <div class="RightPanel">
          <%
          if(session.getAttribute("activeCustomer")!=null){
           %>

           <%

 HashMap<String,String> defaultAddress = Utilities.fetch2("SELECT c.*,a.* FROM egprint.customer c , egprint.address a WHERE c.insideId=a.customerId AND a.defaultShip=1 AND c.insideId='"+((HashMap<String,String>) session.getAttribute("activeCustomer")).get("insideId")+"'").get(0);// ORDER BY a.Default DESC,a.id DESC").get(0);

%>
<div id="myAccount">
    <div class="BreadCrumb">
        <span class="BCDark">Home</span>
        <span class="BCDivider">&gt;</span>
        <span class="BCLight">My Account</span>

        <span class="Logout2"><span class="BCDivider"> &lt; </span><a href="login?action=logout">Logout</a></span>

    </div>
    <div id="welcome">
        <div class="MAWelcome">Welcome Back, <span><%=activeCustomer.get("Business")%></span></div>
        <div class="MAUnwelcome">If you're not <span><%=activeCustomer.get("Business")%></span>, <a href="login?action=logout">click here</a></div>
    </div>
    <!----><div id="invoices" onclick="document.location='invoices.jsp'">
        Invoices
    </div>
    <div style="clear:both"></div>
    <div id="topBoxes">
        <div id="billingInfo" class="MAInfoDiv1">
            <div class="Title1">
            <div style="float:left">Billing Information</div>
            <div id="editBilling"class="EditLink">Edit</div>    
            </div>
            <table id="billingTable">
                <tr><td><%=activeCustomer.get("Customer")%></td></tr>
                <tr><td id="contact"><%=activeCustomer.get("Contact")%></td></tr>
                <tr>
                    <td>
                        <span id="address1"><%=activeCustomer.get("Address1")%></span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span id="city"><%=activeCustomer.get("City")%></span>,
                        <span id="state"><%=activeCustomer.get("State")%></span>
                        <span id="zip"><%=activeCustomer.get("Zip")%></span>
                    </td>
                </tr>
                <tr><td id="phone"><%=activeCustomer.get("Phone")%></td></tr>
            </table>
            <div id="updateBilling">
            <table>
                <tr><td>Contact: </td><td><input name="contact"     id="contactField"   class="BillingInput NiceInput Required" value="<%=activeCustomer.get("Contact")%>"></td></tr>
                <tr><td>Address: </td><td><input name="address1"    id="addressField"   class="BillingInput NiceInput Required" value="<%=activeCustomer.get("Address1")%>"></td></tr>
                <tr><td>City:    </td><td><input name="city"        id="cityField"      class="BillingInput NiceInput Required" value="<%=activeCustomer.get("City")%>"></td></tr>
                <tr><td>State:   </td><td><input name="state"       id="stateField"     class="BillingInput NiceInput Required" value="<%=activeCustomer.get("State")%>" fieldType="^[a-zA-Z]{2}$" format="2 Letter State: XX"></td></tr>
                <tr><td>Zip:     </td><td><input name="zip"         id="zipField"       class="BillingInput NiceInput Required" value="<%=activeCustomer.get("Zip")%>" fieldType="^[0-9]{5}$" format="5 Digit Zip: xxxxx"></td></tr>
                <tr><td>Phone:   </td><td><input name="phone"       id="phoneField"     class="BillingInput NiceInput Required" value="<%=activeCustomer.get("Phone")%>" fieldType="^[0-9]{3}-[0-9]{3}-[0-9]{4}$" format="10 Digit: xxx-xxx-xxxx"></td></tr>
                <tr><td>&nbsp;   </td><td></td></tr>
                <tr><td><span id="saveBilling" class="EditLink">Save</span>   </td><td><span id="" class="EditLink" onclick="document.location.reload(true)">Cancel</span> </td></tr>

            </table>

            </div>
        </div>
        <div id="shippingInfo" class="MAInfoDiv1">
            <div class="Title1">
            <div style="float:left">Default Shipping Address</div>
            <div id="editShipping" class="EditLink">Edit</div>    
            </div>

            <table id="shippingTable">
                <tr><td><%=defaultAddress.get("Customer")%></td></tr>
                <tr><td id="scontact"><%=defaultAddress.get("Contact")%></td></tr>
                <tr>
                    <td>
                        <span id="saddress1"><%=defaultAddress.get("Address1")%></span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span id="scity"><%=defaultAddress.get("City")%></span>,
                        <span id="sstate"><%=defaultAddress.get("State")%></span>
                        <span id="szip"><%=defaultAddress.get("Zip")%></span>
                    </td>
                </tr>
                <tr><td id="sphone"><%=defaultAddress.get("Phone")%></td></tr>
               <tr><td>&nbsp;</td></tr>
                <tr><td></td></tr>
            </table>
            <div id="updateShipping">
            <table>
                <tr><td>Contact: </td><td><input name="bcontact"  id="bcontactField"    class="ShippingInput NiceInput Required"  value="<%=defaultAddress.get("Contact")%>"></td></tr>
                <tr><td>Address: </td><td><input name="baddress1" id="baddressField"    class="ShippingInput NiceInput Required"  value="<%=defaultAddress.get("Address1")%>"></td></tr>
                <tr><td>City:    </td><td><input name="bcity"     id="bcityField"       class="ShippingInput NiceInput Required"     value="<%=defaultAddress.get("City")%>"></td></tr>
                <tr><td>State:   </td><td><input name="bstate"    id="bstateField"      class="ShippingInput NiceInput Required"    value="<%=defaultAddress.get("State")%>" fieldType="^[a-zA-Z]{2}$" format="2 Letter State: XX"></td></tr>
                <tr><td>Zip:     </td><td><input name="bzip"      id="bzipField"        class="ShippingInput NiceInput Required"      value="<%=defaultAddress.get("Zip")%>" fieldType="^[0-9]{5}$" format="5 Digit Zip: xxxxx"></td></tr>
                <tr><td>Phone:   </td><td><input name="bphone"    id="bphoneField"      class="ShippingInput NiceInput Required"    value="<%=defaultAddress.get("Phone")%>" fieldType="^[0-9]{3}-[0-9]{3}-[0-9]{4}$" format="10 Digits: xxx-xxx-xxxx"></td></tr>
                <tr><td>&nbsp;   </td><td></td></tr>
                <tr><td><span id="saveShipping" class="EditLink">Save</span>   </td><td><span class="EditLink" onclick="document.location.reload(true)">Cancel</span> </td></tr>

            </table>
        </div>
       </div>    
    </div>
    <div id="messages" class="MAInfoDiv">
        <div class="Title1">
        <img src="images/MyLast.png"  alt=""> Notifications
        </div>
        <%if(activeCustomer.get("BugTaxable").equals("1")){%>
         <div class="Notification">
            <div class="Title1">Upload your Tax Resell Certificate</div>
             We require your 2011 Tax Resell Certificate.
             Starting on <strong>Tuesday, March 1st</strong> taxes will be applied to <strong>all</strong> orders until tax exempt status can be verified<br>
              <iframe id="hidFrame" name="hidFrame" width="0" height="0" style="display:none;"></iframe>
              <form method="POST" action="register/" id="registrationForm" enctype="multipart/form-data" target="hidFrame">
              <input type="hidden" name="custId"  id="taxCustId" value="<%=activeCustomer.get("insideId")%>">
              <input type="hidden" name="Company" id="taxCompany" value="<%=activeCustomer.get("Customer")%>">
              <input type="hidden" name="taxOnly" id="taxOnly" value="true">
              <input type="file" name="taxId"><input type="submit" value="Go">
              </form>
         </div>
        <%}%>
    </div>

    <div id="history" class="MAInfoDiv">
        <div class="Title2">
        <img src="images/MyAccount.png"  alt=""> Recent Orders
        <span><a href="orders.jsp">View All</a></span>
        </div>

        <%
            ArrayList<HashMap<String,String>> recentOrders = Utilities.fetch2("select DATE(o.orderDate) as `Date`,o.id as `orderId`,o.HoldStatus, o.Invoice, (o.Taxable*.07*o.Price+o.Price +o.ShippingPrice) as `OrderTotal`,o.JobName,o.trackingNumber,s.id as `Status`, s.Status as `StatusDesc`,DATE(o.DueDate) as `DueDate` from egprint.orders o, egprint.status s WHERE o.status=s.id  AND o.Customer='"+activeCustomer.get("insideId")+"'ORDER BY o.OrderDate DESC LIMIT 15");
            if (recentOrders==null){recentOrders= new ArrayList<HashMap<String,String>> ();}
        %>
        <table class="ListTable OrderList">
            <thead>
            <tr>
                <th></th>
                <th style="width:50px">Job ID</th>
                <th>Name</th>
                <th style="width:270px">Description</th>
                <th style="width:90px">Status</th>
                <th style="width:90px">Job Ready By</th>
                <th></th>
            </tr>
            <tr><th class="Spacer"></th></tr>
            </thead>
            <tbody>
        <%
            String selectQuery="";
            for(HashMap<String,String> order:recentOrders){
            try{
             selectQuery = "SELECT  ord.*, hh.Description as `HoldType`, hh.FilesRequired, qq.description as `qtyDesc`, qq.TurnAround, qq.TurnAroundUnit, p.ID as `pId`, p.ProductName as `Product` , p.Description,  c.description as `Category`,  st.description as `Stock`, pr.description as `Press`, s.description as `Sides`, w.description as `Width`, h.description as `Height`, l.description as `Lamination`, u.description as  `UV`, score.description as `Score_Diecut`, f.description as `Fold`, o.description as `Other`  " +
                                "FROM  egprint.orders ord, egprint.quantities qq, egprint.product p,  egprint.category c,  egprint.stock st, egprint.press pr, egprint.orderonhold hh, egprint.sides s, egprint.width w, egprint.height h, egprint.lamination l, egprint.uv u, egprint.scorediecut score, egprint.fold f, egprint.other o   " +
                                "WHERE  p.category=c.id AND  p.stock=st.id AND p.press= pr.id AND p.sides= s.id AND p.width= w.id AND p.height= h.id AND p.lamination=l.id AND p.uv=u.id AND p.scorediecut=score.id AND p.fold=f.id AND ord.HoldStatus=hh.id AND p.other=o.id"+
                       " AND ord.Product=p.id AND ord.quantities = qq.id AND ord.id='"+order.get("orderId")+"'";
           
            HashMap<String,String> desc = Utilities.fetch3(selectQuery).get(0);


        %>
            <tr order="<%=order.get("orderId")%>" >
                <td></td>
                <td><%=order.get("orderId")%></td>
                <td>&nbsp;&nbsp;<%=order.get("JobName")%></td>
                <td><%=desc.get("Category")%><%if(!desc.get("Category").equals("Custom")){%><br><span style="font-weight:normal"><%=desc.get("Stock")%> + <%=desc.get("UV")%><br><%=desc.get("Width")%> <%=desc.get("Height")%>, <%=desc.get("Sides")%>,  <%=desc.get("qtyDesc")%> pcs<%}%> </span></td>
                <td><%if(order.get("HoldStatus").equals("0")||order.get("HoldStatus").equals("1")){%><%=order.get("StatusDesc")%><%} else {%><span style="color:#F00;">On Hold</span><%}%></td>
                <td><%=Utilities.s2c(order.get("DueDate"))%><!--a class="Reorder" href="">Reorder</a--></td>
                <td></td>
            </tr>
        <%} catch(Exception ee){
            System.out.println("selectQuery = " + selectQuery);ee.printStackTrace();}}%>
            </tbody>
        </table>
    </div>


    <div id="addressBook" class="MAInfoDiv">
        <div class="Title2">
        <img src="images/MyAccount.png" alt=""> Address Book
        <span><a href="addresses.jsp">View All</a></span>
        </div>
       
    </div>
    <div id="points" class="MAInfoDiv">
        <div class="Title2">
        <img src="images/MyRewards.png" alt=""> Reward Points
        </div>
        <%String rewards = Utilities.fetch2("SELECT CAST(SUM(o.Price)*10 AS SIGNED) as `Points` FROM egprint.orders o WHERE o.Customer='"+activeCustomer.get("insideId")+"'").get(0).get("Points");%>
        <span>Total Points: <%=rewards==null?0:rewards%></span>
    </div>

</div>

        <%
        }
        %>
    </div>
    <%@include file="footer.jsp"%>
</div>

</body>
</html>