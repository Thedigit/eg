<%@page import="java.util.*,egprint.*,org.json.*"%>
<%
    if (base ==null) {base=pageContext.getServletContext().getContextPath()+"/";}

session.setAttribute("staging",new Boolean((request.getContextPath().contains("staging"))));
    
//HashMap<String,String> activeCustomer = (HashMap<String,String>) session.getAttribute("activeCustomer");
String easyName ="not logged in";
   // String getURL=request.getRequestURL().toString();
    if(activeCustomer!=null){easyName=activeCustomer.get("Customer");}

    System.out.println(easyName+"> url "+getURL);
    if(!getURL.contains("index")){ session.setAttribute("categoryId",null);}
if(activeCustomer!=null){easyName="Hello, "+activeCustomer.get("Customer");}

//String catId = (String) session.getAttribute("categoryId");
  //  HashMap<String,String> category =null;
    if (catId!=null) {
   try{category =  Utilities.fetch2("SELECT c.* FROM egprint.category c WHERE c.id='"+catId+"'").get(0);}catch(Exception e){e.printStackTrace();}
    }
%>

<script type="text/javascript">
    $(document).ready(function(){
    $(".Categories ul li").hover(function(){$(this).addClass("ItemHover");},function(){$(this).removeClass("ItemHover");})
                        $(".CartItem").hover(function(){$(this).addClass("ItemHover");},function(){$(this).removeClass("ItemHover");})
                        $(".CartItem").click(function(){var specs = $(this).next(); if(specs.is(":visible")){specs.slideUp(equalize)}else{specs.slideDown(equalize)}});

    $("#clearCart").click(function(){clearCart();});

    <%if (request.getContextPath().contains("staging")){%>
    $("body").css({backgroundColor:"#000"});
    <%}%>
    });

       /**
       * Clears the shopping cart
       */
      function clearCart()
      {
          var params = new Object();
          params.action="clearCart";
          $.post("checkout/",params,function(data){
           document.location="index.jsp";
          });
      }

    /**
     * Equalizes Colums
     */

      function equalize(){
          //Reset heights:
          if(typeof noEqualize!="undefined"){return;}
          $(".RightPanel").css({height:""});
          $(".LeftPanel").css({height:""});
          //Calculate true height of left panel
          var lh = 9;
          $(".LeftPanel").children().each(function(){lh+=$(this).height();});

          var rh = Math.max( $(".RightPanel").height(),$("#staticCart").height());
          if(lh>rh){
           //  $(".RightPanel").height(lh);
          }
          else{
           $(".LeftPanel").height(rh);  
          }
          $("#spacer").height(Math.max($(".RightPanel").height()-$(".LeftPanel").height(),0));

      }
    $(document).ready(function(){equalize();})
</script>
    <div class="LeftPanel">
        <div class="Welcome"><%=easyName%></div>

        <div id="Cart" class="CartMini">
          <div class="CartTitle">Order Summary</div>
                    <%  try{

            if(cart !=null){
        %>
           <div id="CartItems" class="CartItems">
           <ul>
               <%
                   double totalForCart = 0;
               java.util.Iterator<String> keys = cart.getJSONObject("products").keys();
                      int i = 0;
                      while (keys.hasNext())
                      {
                          i++;

                          String key = keys.next();
                          JSONObject qty = cart.getJSONObject("products").getJSONObject(key);
                          JSONObject product = qty.getJSONObject("product");
                          int sets = qty.getInt("sets");
                          totalForCart+=product.getDouble("Price")*sets;
                          %>
               <li id="smallCart_<%=key%>">
               <div class="CartItem"><span class="ItemTitle">[ <span class="sset_<%=key%>"><%=sets%></span> ] <%=product.getString("Category")%></span><span class="ItemTotal sprice_<%=key%>">$<%=Utilities.money(product.getDouble("Price")*sets+"")%></span></div>
                   <div class="ItemSpecs">
                       <table>
                           <tr><th><span>Qty:</span></th><td><%=product.get("Description")%></td></tr>
                           <tr><th><span>Size:</span></th><td><%=product.get("Width")%> x <%=product.get("Height")%></td></tr>
                           <tr><th><span>Sides:</span></th><td><%=product.get("Sides")%></td></tr>
                           <tr><th><span>UV:</span></th><td><%=product.get("UV")%></td></tr>
                           <tr><th><span>Stock:</span></th><td><%=product.get("Stock")%></td></tr>
                       </table>
                    </div>
               </li>
               <%}%>
           </ul>
           </div>
           <div class="CartTotal">
               <span id="CartTotal"><strong>Total: </strong><span class="staticSubTotal"><%=totalForCart%></span></span>
           </div>
           <div class="CartControls">
               <%
                String endPoint = "checkout.jsp";
            try{
                endPoint = Utilities.fetch2("SELECT e.checkOut as `EndPoint` from egprint.endpoints e").get(0).get("EndPoint");
            }catch(Exception ee){}
               %>
              <button id="clearCart" class="OrangeButton">Clear Cart</button>
              <button class="OrangeButton" onclick="document.location = '<%=endPoint%>'"><strong>Checkout</strong></button>
           </div>
                    <%
            }
            }catch(Exception e){}
        %>
        </div>

        <div class="Categories">
            <div class="CategoriesTitle">Product Categories</div>
            <ul>

            <%
            ArrayList<HashMap<String,String>> categories = Utilities.fetch2("SELECT c.* FROM egprint.category c WHERE c.active='1' ORDER BY c.Order");
            try{
            for (HashMap<String,String> cat: categories)
            {
            String highlight = "";
               if ((category!=null)&&cat.get("id").equals(category.get("id"))){highlight="Highlight";}
            %>
            <li class="<%=highlight%>"><a class="CategoryLink <%=highlight%>" href="<%=base%>products/<%=cat.get("Description").replaceAll(" ","")%>"><%=cat.get("Description")%></a></li>
            <%}}catch(Exception ee){}%>
                </ul>
        </div>
        <div style="text-align:center; height:218px;">
            <img src="<%=base%>images/home/Seal.png" alt="">
        </div>
        <div style="text-align:center;" id="ppAdd">

        </div>
    </div>