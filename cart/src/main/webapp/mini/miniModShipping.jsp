<%@page import="java.util.*,egprint.*"%>
<%@ page import="egprint.Utilities" %>
<%
   String order = Utilities.get(request,"order");
   HashMap<String,String> single = Utilities.fetch3("SELECT o.* FROM egprint.orders o WHERE o.id='"+order+"'").get(0);
   ArrayList<HashMap<String,String>> bundle = Utilities.fetch3("select o.* from  egprint.quantities q, egprint.ordersInInvoice oii, egprint.invoices i, egprint.orders o,\n" +
"(select oo.invoice,oo.quantities from egprint.orders oo WHERE oo.id='"+order+"' AND oo.shipsAlone='0') as `ord`\n" +
"WHERE \n" +
"o.quantities=q.id AND \n" +
"o.id = oii.order AND oii.Invoice = i.id and i.Number=ord.invoice and o.quantities = ord.quantities AND o.shipsAlone=0;");

    if(bundle.size()==0){bundle.add(single);}

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title></title>
  <link rel="stylesheet" href="css/miniWindow.css" type="text/css">
  <link rel="stylesheet" href="css/miniModShipping.css" type="text/css">  
  <style type="text/css">
  </style>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/jquery-ui.min.js"></script>

  <script type="text/javascript" src="JSON.js"></script>
  <script>

      function closeFlow(){
         try{ parent.closeFlowWindow();}catch(e){}
         try{ window.opener .closeFlowWindow();}catch(e){}
      }
      function init(){
          $(".Cancel").hover(
                  function(){$(this).addClass("CancelOn");},
                  function(){$(this).removeClass("CancelOn");}
                  ).click(function(){closeFlow()});
      }
      $(document).ready(init);
  </script>
</head>
<body>
<div class="Wrapper">
   <div class="Total">Modify Shipping</div>
       <div class="Body">
           <div class="Spacer"></div>

       <%if(bundle.size()>1){%>
           <div class="Bundle">This order is part of a shipping bundle.</div>
       <%}%>
           <table class="OrdersTable">
               <tr>
                   <th>Upgrade</th>
                   <th colspan="4">Select Shipping Type</th>
               </tr>
               <tr>
                   <th>Order</th>
                   <th>Pick Up</th>
                   <th>Ground</th>
                   <th>2nd Day</th>
                   <th>Next Day</th>
               </tr>

                <tr>

                     <td>
                         <%for (HashMap<String,String> o:bundle){%>
                         <%=o.get("id")%><br>
                      <%}%>
                    </td>
                     <td><input type="radio" name="p" value='0' id="s0%>"> </td>
                     <td><input type="radio" name="g" value='1' id="s1%>"> </td>
                     <td><input type="radio" name="s" value='2' id="s2%>"> </td>
                     <td><input type="radio" name="n" value='3' id="s3%>"> </td>
                </tr>

               </table>
           <%
            String Name,Company,Address,City,State,Zip="";
            Name=Company=Address=City=State=Zip="";
           if (!single.get("ShipOption").equals("1")){
             HashMap<String,String> shipTo = Utilities.fetch3("SELECT a.* FROM egprint.Address a WHERE a.id ='"+single.get("ShipAddress")+"'").get(0);
               Name=shipTo.get("Contact");
               Company=shipTo.get("Business");
               Address=shipTo.get("Address1");
               City=shipTo.get("City");
               State=shipTo.get("State");
               Zip=shipTo.get("Zip");
           }%>
           <div class="ShipTo">
               <fieldset>
       <legend>Ship To:</legend>
       <div class="">

           <form method="POST" action="register/" id="registrationForm" onsubmit="" enctype="multipart/form-data" target="_self">

                       <div class="RegDiv" title="Company Information">
                           <table>
                               <tr>
                                   <td class="LeftField">Name</td>
                                   <td><input class="Required NiceInput" name="First" value="<%=Name%>"></td>
                               </tr>
                               <tr>
                                   <td class="LeftField">Company</td>
                                   <td><input class="Required NiceInput" name="Company" value="<%=Company%>"></td>
                               </tr>
                               <tr>
                                   <td class="LeftField">Address</td>
                                   <td><input class="Required NiceInput" name="Address" value="<%=Address%>"></td>
                               </tr>
                               <tr>
                               <tr>
                                   <td class="LeftField">City</td>
                                   <td><input class="Required NiceInput" name="City" value="<%=City%>"></td>
                               </tr>
                               <tr>
                                   <td class="LeftField">State</td>
                                   <td>
                                       <select class="Required MenuSelect" id="stateSelect" name="State" size="1">
                                           <option value="">State...</option>
                                           <option value="AL" <%= (State.equalsIgnoreCase("AL"))?"selected":""%>>Alabama</option>
                                           <option value="AK" <%= (State.equalsIgnoreCase("AK"))?"selected":""%>>Alaska</option>
                                           <option value="AZ" <%= (State.equalsIgnoreCase("AZ"))?"selected":""%>>Arizona</option>
                                           <option value="AR" <%= (State.equalsIgnoreCase("AR"))?"selected":""%>>Arkansas</option>
                                           <option value="CA" <%= (State.equalsIgnoreCase("CA"))?"selected":""%>>California</option>
                                           <option value="CO" <%= (State.equalsIgnoreCase("CO"))?"selected":""%>>Colorado</option>
                                           <option value="CT" <%= (State.equalsIgnoreCase("CT"))?"selected":""%>>Connecticut</option>
                                           <option value="DE" <%= (State.equalsIgnoreCase("DE"))?"selected":""%>>Delaware</option>
                                           <option value="FL" <%= (State.equalsIgnoreCase("FL"))?"selected":""%>>Florida</option>
                                           <option value="GA" <%= (State.equalsIgnoreCase("GA"))?"selected":""%>>Georgia</option>
                                           <option value="HI" <%= (State.equalsIgnoreCase("HI"))?"selected":""%>>Hawaii</option>
                                           <option value="ID" <%= (State.equalsIgnoreCase("ID"))?"selected":""%>>Idaho</option>
                                           <option value="IL" <%= (State.equalsIgnoreCase("IL"))?"selected":""%>>Illinois</option>
                                           <option value="IN" <%= (State.equalsIgnoreCase("IN"))?"selected":""%>>Indiana</option>
                                           <option value="IA" <%= (State.equalsIgnoreCase("IA"))?"selected":""%>>Iowa</option>
                                           <option value="KS" <%= (State.equalsIgnoreCase("KS"))?"selected":""%>>Kansas</option>
                                           <option value="KY" <%= (State.equalsIgnoreCase("KY"))?"selected":""%>>Kentucky</option>
                                           <option value="LA" <%= (State.equalsIgnoreCase("LA"))?"selected":""%>>Louisiana</option>
                                           <option value="ME" <%= (State.equalsIgnoreCase("ME"))?"selected":""%>>Maine</option>
                                           <option value="MD" <%= (State.equalsIgnoreCase("MD"))?"selected":""%>>Maryland</option>
                                           <option value="MA" <%= (State.equalsIgnoreCase("MA"))?"selected":""%>>Massachusetts</option>
                                           <option value="MI" <%= (State.equalsIgnoreCase("MI"))?"selected":""%>>Michigan</option>
                                           <option value="MN" <%= (State.equalsIgnoreCase("MN"))?"selected":""%>>Minnesota</option>
                                           <option value="MS" <%= (State.equalsIgnoreCase("MS"))?"selected":""%>>Mississippi</option>
                                           <option value="MO" <%= (State.equalsIgnoreCase("MO"))?"selected":""%>>Missouri</option>
                                           <option value="MT" <%= (State.equalsIgnoreCase("MT"))?"selected":""%>>Montana</option>
                                           <option value="NE" <%= (State.equalsIgnoreCase("NE"))?"selected":""%>>Nebraska</option>
                                           <option value="NV" <%= (State.equalsIgnoreCase("NV"))?"selected":""%>>Nevada</option>
                                           <option value="NH" <%= (State.equalsIgnoreCase("NH"))?"selected":""%>>New Hampshire</option>
                                           <option value="NJ" <%= (State.equalsIgnoreCase("NJ"))?"selected":""%>>New Jersey</option>
                                           <option value="NM" <%= (State.equalsIgnoreCase("NM"))?"selected":""%>>New Mexico</option>
                                           <option value="NY" <%= (State.equalsIgnoreCase("NY"))?"selected":""%>>New York</option>
                                           <option value="NC" <%= (State.equalsIgnoreCase("NC"))?"selected":""%>>North Carolina</option>
                                           <option value="ND" <%= (State.equalsIgnoreCase("ND"))?"selected":""%>>North Dakota</option>
                                           <option value="OH" <%= (State.equalsIgnoreCase("OH"))?"selected":""%>>Ohio</option>
                                           <option value="OK" <%= (State.equalsIgnoreCase("OK"))?"selected":""%>>Oklahoma</option>
                                           <option value="OR" <%= (State.equalsIgnoreCase("OR"))?"selected":""%>>Oregon</option>
                                           <option value="PA" <%= (State.equalsIgnoreCase("PA"))?"selected":""%>>Pennsylvania</option>
                                           <option value="RI" <%= (State.equalsIgnoreCase("RI"))?"selected":""%>>Rhode Island</option>
                                           <option value="SC" <%= (State.equalsIgnoreCase("SC"))?"selected":""%>>South Carolina</option>
                                           <option value="SD" <%= (State.equalsIgnoreCase("SD"))?"selected":""%>>South Dakota</option>
                                           <option value="TN" <%= (State.equalsIgnoreCase("TN"))?"selected":""%>>Tennessee</option>
                                           <option value="TX" <%= (State.equalsIgnoreCase("TX"))?"selected":""%>>Texas</option>
                                           <option value="UT" <%= (State.equalsIgnoreCase("UT"))?"selected":""%>>Utah</option>
                                           <option value="VT" <%= (State.equalsIgnoreCase("VT"))?"selected":""%>>Vermont</option>
                                           <option value="VA" <%= (State.equalsIgnoreCase("VA"))?"selected":""%>>Virginia</option>
                                           <option value="WA" <%= (State.equalsIgnoreCase("WA"))?"selected":""%>>Washington</option>
                                           <option value="WV" <%= (State.equalsIgnoreCase("WV"))?"selected":""%>>West Virginia</option>
                                           <option value="WI" <%= (State.equalsIgnoreCase("WI"))?"selected":""%>>Wisconsin</option>
                                           <option value="WY" <%= (State.equalsIgnoreCase("WY"))?"selected":""%>>Wyoming</option>
                                           </select>
                                           </td>
                               </tr>
                               <tr>
                                   <td class="LeftField">Zip Code</td>
                                   <td><input class="Required NiceInput" name="Zip" fieldType="^[0-9]{5}$" format="5 Digit Zip: xxxxx" value="<%=Zip%>"></td>
                               </tr>
                           </table>
                       </div>
                     </form>

       </div>
        </fieldset>
           </div>
   </div>
   <div class="Cancel">Cancel</div>

</div>

</body>
</html>