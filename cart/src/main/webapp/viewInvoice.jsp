<%@page import="java.util.*"%>
<%@page import="egprint.*" %>
<%@ page import="org.json.JSONObject" %>
<%@include file="common.jsp"%>
<%@include file="checkLogin.jsp"%>
<%
 String viewJobId = Utilities.get(request,"j");
 if(viewJobId==null){response.sendRedirect("invoices.jsp");return;}
 HashMap<String,String> invoiceInfo= Utilities.fetch3("SELECT * FROM egprint.invoices WHERE id='"+viewJobId+"'").get(0);

    String selectQuery = "SELECT  ord.*, hh.Description as `HoldType`, hh.FilesRequired, qq.description as `qtyDesc`, qq.TurnAround, qq.TurnAroundUnit, p.ID as `pId`, p.ProductName as `Product` , p.Description,  c.description as `Category`,  st.description as `Stock`, pr.description as `Press`, s.description as `Sides`, w.description as `Width`, h.description as `Height`, l.description as `Lamination`, u.description as  `UV`, score.description as `Score_Diecut`, f.description as `Fold`, o.description as `Other`  " +
                                   "FROM  egprint.ordersininvoice oii, egprint.invoices i, egprint.orders ord, egprint.quantities qq, egprint.product p,  egprint.category c,  egprint.stock st, egprint.press pr, egprint.orderonhold hh, egprint.sides s, egprint.width w, egprint.height h, egprint.lamination l, egprint.uv u, egprint.scorediecut score, egprint.fold f, egprint.other o   " +
                                   "WHERE  p.category=c.id AND  p.stock=st.id AND p.press= pr.id AND p.sides= s.id AND p.width= w.id AND p.height= h.id AND p.lamination=l.id AND p.uv=u.id AND p.scorediecut=score.id AND p.fold=f.id AND ord.HoldStatus=hh.id AND p.other=o.id"+
                          " AND ord.Product=p.id AND ord.quantities = qq.id  AND ord.id=oii.order AND oii.invoice=i.id AND i.id='"+viewJobId+"'";

 ArrayList<HashMap<String,String>> invoiceItems = Utilities.fetch3(selectQuery);

    //Determine Shipping Address (If Any)
 HashMap<String,String> tempItem = invoiceItems.get(0);
 String shippingAddressId = tempItem.get("ShipAddress");
 HashMap<String,String> shippingAddress= null;
 if (!shippingAddressId.equals("0")){
     try {
         shippingAddress = Utilities.fetch3("SELECT * FROM egprint.address a WHERE a.id='"+shippingAddressId+"'").get(0);
     } catch (Exception e) {
         e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
     }
 }
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>EGPRINT - Your Online Print Super Store</title>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/jquery-ui.min.js"></script>

  <script type="text/javascript" src="JSON.js"></script>
  <script type="text/javascript" src="js/dg.js"></script>
  <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/themes/smoothness/jquery-ui.css" />
  <link rel="stylesheet" type="text/css" href="css/ui.spinner.css" />
  <link rel="stylesheet" type="text/css" href="css/jquery.ui.selectmenu.css" />

  <style type="text/css">

      body , html{
          margin:0;
          padding:0;
          font-family:normal 10px verdana; 
      }
      .Body{
          margin: 5px auto;
          border:solid 1px #666;
          box-shadow:#666;
          width:900px;
      }

      table.AdressBlock{
          border-collapse:collapse;
          border-spacing:0;
          font:normal 10px verdana;
      }
      .CompanyAddress{
          float:left;
          height:100px;
          margin-left:15px;
      }
      .BillingAddress{
          float:right;
          height:100px;
          margin-right:15px;
      }
      .ShippingAddress{
          float:right;
          height:100px;
          margin-right:15px;
      }

      .InvoiceNumber{
        clear:both;
        font:bold 16px verdana;
        text-align:center;
      }

      div.Items{
          width:870;
          margin:15px auto;
      }
      table.Items{
          width:100%;
          border-collapse:collapse;
          border-spacing:0;
      }

      table.Items th{
          text-align:left;
      }
      .Spacer{
          clear:both;
          height:50px;
      }

  </style>
  <script type="text/javascript">
      var loadedId = "<%=viewJobId%>";

      function init()
      {
          //Equalize column width
          $(".LeftPanel").height(Math.max($(".RightPanel").height(),600));
          $($(".Details")[0]).css({display:"block"});
          $(".ListTable tr").hover(
                  function(){$(this).find('td').addClass("HighlightRow");$(this).find('td:first').find('img').fadeIn("fast");},
                  function(){$(this).find('td').removeClass("HighlightRow");$(this).find('td:first').find('img').hide();}
                  );

          $(".PDTable tr:even").find('td').addClass("OddRow");
          $(".ODTable tr:even").find('td').addClass("OddRow");
           $(".PDTable tr, .ODTable tr").hover(
                  function(){$(this).find('td').addClass("HighlightRow");},
                  function(){$(this).find('td').removeClass("HighlightRow");}
                  );

      }

      $(document).ready(function(){init();});
  </script>
</head>
<body>

<div class="Body">
      <div class="CompanyAddress">
          <div class="Title"><%=((JSONObject)session.getAttribute("activeCompany")).getString("Name")%></div>
          <table  class="AdressBlock">
                  <tr><td>7335 NW 35th St       </td></tr>
                  <tr><td>Miami, FL 33122       </td></tr>
                  <tr><td>Ph: <%=((JSONObject)session.getAttribute("activeCompany")).getString("Phone")%>   </td></tr>
                  <tr><td><%=((JSONObject)session.getAttribute("activeCompany")).getString("Email")%>    </td></tr>
                  <tr><td><%=((JSONObject)session.getAttribute("activeCompany")).getString("FullDomain")%>      </td></tr>
          </table>
      </div>
    <%if (!shippingAddressId.equals("0") && shippingAddress!=null){%>
      <div class="ShippingAddress">
          <div class="Title">Ship To:</div>
          <table  class="AdressBlock">
                  <tr><td><%=shippingAddress.get("Contact")%></td>       </tr>
                  <tr><td><%=shippingAddress.get("Address1")%></td>       </tr>
                  <tr><td><%=shippingAddress.get("Address2")%></td>       </tr>
                  <tr><td><%=shippingAddress.get("City")+", "+shippingAddress.get("State")+" "+shippingAddress.get("Zip")%></td>  </tr>
          </table>
      </div>
      <%}%>
      <div class="BillingAddress">
          <div class="Title">Bill To:</div>
          <table class="AdressBlock">
                <tr><td><%=activeCustomer.get("Business")%></td>       </tr>
                <tr><td><%=activeCustomer.get("Address1")%></td>       </tr>
                <tr><td><%=activeCustomer.get("Address2")%></td>       </tr>
                <tr><td><%=activeCustomer.get("City")+", "+activeCustomer.get("State")+" "+activeCustomer.get("Zip")%></td>  </tr>
            </table>
    </div>
      <div class="InvoiceNumber">
        <%=invoiceInfo.get("Number")%><br>
        <span style="font-size:10px">Order Date: <%=Utilities.s2c(invoiceInfo.get("Date").split(" ")[0])%></span>  
      </div>

      <div class="Items">
         <table class="Items">
             <tr>
                 <th></th>
                 <th>Order #</th>
                 <th>Job Name</th>
                 <th>Description</th>
                 <th width="30px;" align="right">Price</th>
                 <th width="10px;"></th>

                 <th></th>
             </tr>
             <%
                double itemsTotal    =0.00;
                double shippingTotal =0.00;
                 int taxable = 0 ;
                 for(HashMap<String,String> item: invoiceItems){
                     try{taxable = Integer.parseInt(item.get("Taxable"));}catch(Exception e){}

             %>

             <tr>
                 <td></td>
                 <td><%=item.get("id")%></td>
                 <td><%=item.get("JobName")%></td>
                 <td><%=item.get("Category")%><br><span style="font-weight:normal"><%=item.get("Stock")%> + <%=item.get("UV")%><br><%=item.get("Width")%> <%=item.get("Height")%>, <%=item.get("Sides")%>,  <%=item.get("qtyDesc")%> pcs </span></td>
                 <td  align="right">$<%=item.get("Price")%></td>
                 <td></td>
             </tr>
             <%
                 itemsTotal+=Float.valueOf(item.get("Price"));
                 shippingTotal+=Float.valueOf(item.get("ShippingPrice"));
                 }
             
             %>
             <tr><td colspan='3'></td><td align="right">SubTotal:   </td><td align="right">$<%=Utilities.money(""+itemsTotal+"")%>                  </td><td></td>                </tr>
             <tr><td colspan='3'></td><td align="right">Tax:        </td><td align="right">$<%=Utilities.money(""+itemsTotal*taxable*.07)%>                 </td><td></td>            </tr>
             <tr><td colspan='3'></td><td align="right">Shipping:   </td><td align="right">$<%=Utilities.money(""+shippingTotal)%>                  </td><td></td></tr>
             <tr><td colspan='3'></td><td align="right">Order Total: </td><td align="right">$<%=Utilities.money(""+(shippingTotal+(itemsTotal*(1 +taxable*.07))))%>   </td><td></td></tr>
         </table>

      </div>

      <div class="Totals">
      </div>

      <div class="Spacer">

      </div>

</div>
</body>
</html>