<%@page import="java.util.*"%>
<%@ page import="egprint.cart.*" %>
<%@ include file="common.jsp"%>

<%
   String tier = "8";
    System.out.println("AC = " + activeCustomer);
     if(activeCustomer!=null){tier=activeCustomer.get("Tier");}



    if (catId!=null) {
    category =  Utilities.fetch2("SELECT c.* FROM egprint.category c WHERE  c.id='"+catId+"'").get(0);
    pageTitle = category.get("Description") + " - ";
    }
    else{pageContext.forward("home.jsp");return;}
    ArrayList<HashMap<String, String>> availableOptions = Utilities.fetch3("SELECT p.* FROM egprint.productoptions p, egprint.productoptionsmap pom WHERE p.id=pom.option AND pom.Active='1' AND pom.category ='"+catId+"'");//(ArrayList<HashMap<String, String>>) session.getAttribute("availableOptions");

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <%@ include file="header.jsp"%>

  <link rel="stylesheet" type="text/css" href="<%=base%>css/ui.spinner.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/jquery.ui.selectmenu.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/builder.css" />
  <script type="text/javascript" src="<%=base%>js/spinner.js"></script>
  <script type="text/javascript" src="<%=base%>js/jquery.ui.selectmenu.js"></script>
  <script type="text/javascript" src="<%=base%>js/jsonpath.js"></script>

    <%if(staging){%>
    <script type="text/javascript" src="<%=base%>js/index.js"></script>
    <%}else{%>
    <script type="text/javascript" src="<%=base%>js/index_old.js"></script>
      <%}%>  <script type="text/javascript">

      /**
       Read final product selection and display price & TA
       */
      var mainTree;

      <%
      System.out.println("tier = " + tier+" "+catId);
      JSONArray selections = CartUtilities.cheapBranch(catId,tier);
      if(!staging){selections.remove(3);}
      JSONObject productOptionsBundle= new JSONObject();//CartUtilities.productOptions(catId,tier);
      %>
      var selections = <%=selections%>;//new Array();
      var productOptions = <%=productOptionsBundle%>
      var sets = 1;
      var price,discountPrice,regularPrice,productId;
      var firstLoad=true;
      function getTree(){
          var start = new Date().getTime();
          $.getJSON("<%=base%>utils/?callback=?&action=getCat&a=<%=catId%>&b=<%=tier%>",function(data){
              mainTree=data;

              start = new Date().getTime();
              populateAll();
              firstLoad=false;
              try{
                  $("select.BuilderOption").selectmenu('destroy');
                 $('select.BuilderOption').selectmenu();
                 }catch(e){alert(">>"+e)};


          })
      }


  </script>
</head>
<body>
<div class="Body">
    <%@include file="topMenu.jsp"%>
    
    <%@include file="leftPanel.jsp"%>
    <div class="RightPanel">
          <%
              //Ignore this for now.
          if(session.getAttribute("activeCustomer")!=null||true){
            if (category!=null){
          String cat = category.get("id");
        %>

        <div class="ProductTitle"><!--%=category.get("Description")%--></div>
        <div class="ProductImage"><!--img src="/images/c<%=cat%>.jpg" alt=""!--></div>
        <div class="ProductText"><!--%=category.get("Text")%--></div>
        <div class="ProductImage2">
        <!--img class="ProductImage" src="http://d2c6jpv0fksi04.cloudfront.net/images/products/<%=catId%>.jpg" alt="<%=category.get("Description")%>"-->
        <img class="ProductImage" src="/static/products/<%=catName%>.jpg" alt="<%=category.get("Description")%>">

        </div>
        <div class="OptionsDiv">
        <table id="optionsTable" class="OptionsTable">
            <%int mm = 1;%>
                           <tr><td></td><th><span>Size :                </span></th><td class="Blink"> <select class="BuilderOption" id="<%=mm++%>" opt="Size" ><option value="remove">Select Size       </option>   </select></td><td></td></tr>
                           <tr><td></td><th><span>Stock :               </span></th><td class="Blink"> <select class="BuilderOption" id="<%=mm++%>" opt="Stock"  disabled=""><option value="remove">Select Stock      </option>   </select></td><td></td></tr>
                           <tr><td></td><th><span>Sides :               </span></th><td class="Blink"> <select class="BuilderOption" id="<%=mm++%>" opt="Sides"  disabled=""><option value="remove">Select Sides      </option>   </select></td><td></td></tr>
                           <%if(staging){%>
                           <tr><td></td><th><span>Colors :              </span></th><td class="Blink"> <select class="BuilderOption" id="<%=mm++%>" opt="Colors"  disabled=""><option value="remove">Select Colors      </option>   </select></td><td></td></tr>
                           <%}%>
                           <tr><td></td><th><span>Coating :             </span></th><td class="Blink"> <select class="BuilderOption" id="<%=mm++%>" opt="UV" disabled=""><option value="remove">Select Finish     </option>   </select></td><td></td></tr>
                           <%if (catId.equals("16")){%>
                           <tr><td></td><th><span>Pages :               </span></th><td class="Blink"> <select class="BuilderOption" id="<%=mm++%>"opt="Pages"  disabled=""><option value="remove">Select Finish     </option>   </select></td><td></td></tr>
                           <%}%><%if (catId.equals("7")||catId.equals("8")){%>
                           <tr><td></td><th><span>Folding :             </span></th><td class="Blink"> <select class="BuilderOption" id="<%=mm++%>"opt="Fold"  disabled=""><option value="remove">Select Finish     </option>   </select></td><td></td></tr>
                           <%}%>
                           <tr><td></td><th><span>Qty :                 </span></th><td class="Blink"> <select class="BuilderOption" id="<%=mm++%>" opt="QTY" disabled=""><option value="remove">Select Quantity   </option>   </select></td><td></td></tr>
                            <%if(staging){%>
                           <%
                           //Check if there are any product options to display, otherwise skip this section
                               if(availableOptions.size()>0){
                           %>
                           <tr><td></td><td></td><td>
                               <fieldset class="ProductOptions">
                                   <legend>Additional Services</legend>
                               <ul>
                               <%  int i = 0 ;

                               ArrayList<HashMap<String,String>> productOptionsCat = Utilities.fetch3("SELECT p.* FROM egprint.productoptionscategory p");
                                   for (HashMap<String,String> pcat:productOptionsCat){
                                        ArrayList<HashMap<String,String>> productOptions = Utilities.fetch3("SELECT p.* FROM egprint.productoptions p, egprint.productoptionsmap pom WHERE p.id=pom.option AND pom.Active='1' AND pom.category ='"+catId+"' AND p.category="+pcat.get("id")+"");
                                        if(productOptions.size()==0){continue;}
                                       %>
                                   <li>
                                       <h1 class="FakeDropdown"><input class="DropDownCheckbox" type="checkbox" name="category_<%=pcat.get("name")%>" id="category_<%=pcat.get("name")%>"> <label for="category_<%=pcat.get("name")%>"><%=pcat.get("name")%></label></h1>
                                       <div>
                                   <%
                                       //Round Corner special menu
                                       if(pcat.get("id").equals("1")){
                                           %>
                                           <table class="CornerOptions">
                                               <tr>
                                                   <td class="tl"><%if(categoryHasOption(cat, "6")){%><label for="corner_tl">Top<br>Left</label><%}else{%>&nbsp;<%}%></td>
                                                   <td class="tl"><%if(categoryHasOption(cat, "6")){%><input checked="" class="ChangeCorner" type="checkbox" id="corner_tl" name="option_6"><span class="ui-icon ui-icon-triangle-1-se"></span><%}else{%>&nbsp;<%}%></td>
                                                   <td></td>
                                                   <td class="tr"><%if(categoryHasOption(cat, "7")){%><input checked="" class="ChangeCorner"  type="checkbox" id="corner_tr" name="option_7"><span class="ui-icon ui-icon-triangle-1-sw"></span><%}else{%>&nbsp;<%}%></td>
                                                   <td class="tr"><%if(categoryHasOption(cat, "7")){%><label for="corner_tr">Top<br>Right</label><%}else{%>&nbsp;<%}%></td>
                                               </tr>
                                               <tr>
                                                   <td></td>
                                                   <td></td>
                                                   <td class="SampleCorner"><div class="">FRONT</div></td>
                                                   <td></td>
                                                   <td></td>
                                               </tr>
                                               <tr>
                                                   <td class="bl"><%if(categoryHasOption(cat, "8")){%><label for="corner_bl">Lower<br>Left</label><%}else{%>&nbsp;<%}%></td>
                                                   <td class="bl"><%if(categoryHasOption(cat, "8")){%><input checked="" class="ChangeCorner"  type="checkbox" id="corner_bl" name="option_8"><span class="ui-icon ui-icon-triangle-1-ne"></span><%}else{%>&nbsp;<%}%></td>
                                                   <td></td>
                                                   <td class="br"><%if(categoryHasOption(cat, "9")){%><input checked="" class="ChangeCorner"  type="checkbox" id="corner_br" name="option_9"><span class="ui-icon ui-icon-triangle-1-nw"></span><%}else{%>&nbsp;<%}%></td>
                                                   <td class="br"><%if(categoryHasOption(cat, "9")){%><label for="corner_br">Lower<br>Right</label><%}else{%>&nbsp;<%}%></td>
                                               </tr>
                                           </table>


                                           <%}else{

                                for (HashMap<String,String> opt:productOptions){%>
                                       <input type="checkbox" name="option_<%=opt.get("id")%>" id="option_<%=opt.get("id")%>">
                                       <label for="option_<%=opt.get("id")%>"><%=opt.get("Description")%></label><br>
                                       <%}%>
                                       </div>
                                   </li>
                            <%i++;}}%>
                               </ul>
                            </fieldset>
                               </td>
                               <td></td>
                              </tr>
                           <%}%>
                           <%}%>


                            <tr><td></td><th><span>Turn Around :         </span></th><td class="Blink"> <select class="BuilderOption" id="<%=mm++%>" opt="TurnAround" disabled=""><option value="remove">Select Turn Around</option>   </select></td><td></td></tr>

        </table>



         <% ArrayList<HashMap<String,String>> productOptions=new ArrayList<HashMap<String,String>>();
             if (productOptions.size()>0 && !catId.equals("1")){%>
         <table id="optionsTable" class="OptionsTable">
                                      <tr><td></td><th><span>Options :          </span></th><td class="Blink">

            <div class="ProductOptions">
                <div class="ProductOptionsTitle">Product Options</div>
                <%  int i = 0 ;
                    for (HashMap<String,String> opt:productOptions){%>
                   <div class="ProductOptionShort">
                    <input class="ProductOption" type="checkbox" opt="<%=opt.get("id")%>" id="opt<%=opt.get("id")%>" name="opt_<%=opt.get("id")%>">
                    <label class="ProductOption" for="opt_<%=opt.get("id")%>"><%=opt.get("Description")%></label><br>
                   </div>
                <%i++;}%>

            </div>
            </td><td></td></tr></table> 
            <%}%>

        </div>
        <!--Social Media-->
                   <%@ include file="socialMedia.jsp"%>
         <!--Social Media-->
         <%if (staging && productOptions.size()>0 && catId.equals("1")){%>

            <div class="ProductOptions">
                <div class="ProductOptionsTitle">Product Options</div>
                <%  int i = 0 ;
                    for (HashMap<String,String> opt:productOptions){%>
                   <div class="ProductOption">
                    <img src="images/sq.png" alt=""><br>
                    <input class="ProductOption" type="checkbox" opt="<%=opt.get("id")%>" id="opt_<%=opt.get("id")%>" name="opt_<%=opt.get("id")%>">
                    <label class="ProductOption" for="opt_<%=opt.get("id")%>"><%=opt.get("Description")%></label><br>
                   </div>
                <%i++;}%>

            </div>
            <%}%>
        <div class="BottomPricingDiv">
         <div id="prodSpecs" class="BottomPricingSection">
             <span id="prodSpecsTitle" class="BottomPricingTitle">Products features:</span>
             <ul>
                <%
                  ArrayList<HashMap<String,String>> features = Utilities.fetch3("SELECT b.Description FROM enterprise.categoryBullet b WHERE b.category='"+catId+"'");
                    for(HashMap<String,String> feature:features){if (feature.get("Description").equals("")){continue;}%>
                     <li><%=feature.get("Description")%></li>   
                   <% }
                %>
             </ul>
         </div>
         <div id="shippingSpecs" class="BottomPricingSection">
            <h1 id="shippingSpecsTitle" class="BottomPricingTitle">Transit Time Calculator</h1>
            <span class="BottomPricingRegular">Based on your order being placed today before 1:00PM  EST</span><br>
            <span class="BottomPricingRegular">Ship to Zip: <input id="shippingZip" value="<%=activeCustomer==null?"":activeCustomer.get("Zip")%>"><button id="#updateShipping" onclick="fetchShipping();">Calculate</button></span>
            <div class="shippingOptions">
                <table width="100%">
                    <tr>
                        <td><input name="shipOption" type="radio" value="nextDay"></td>
                        <td>Next Day Air</td>
                        <td id="ndaRate"></td>
                    </tr>
                    <tr>
                        <td><input name="shipOption" type="radio" value="expedited2"></td>
                        <td>2nd Day Air</td>
                        <td id="ex2Rate"></td>
                    </tr>
                    <tr>
                        <td> <input name="shipOption" type="radio" value="ground" checked=""></td>
                        <td>Ground</td>
                        <td id="gndRate"></td>
                    </tr>
                </table><br>
                <div class="BottomPricingRegular">Est. Arrival Date:<br> <span id="shippingArrivalDate" class="BottomPricingTitle"></span><br>

                </div>


            </div>
            <%@include file="socialButtons.jsp"%>
         </div>
         <div id="pricingSpecs" class="BottomPricingSection">
             <h1 class="BottomPricingTitle">Product Price</h1>
             <%if (activeCustomer!=null){%>
             <table id="pricingTable">
                 <tr>
                     <td></td>
                     <td>Sets Required:</td>
                     <td class="Right" id="setsCell"><div id="addToCart" class="">
                         <form action="checkout/" method="POST" id="addToCartForm">

                         <input id="sets" name="sets" type="text" value="1">
                         <input id="product" name="product" type="hidden" value="">
                         <input id="" type="hidden" name="action" value="addToCart">

                             <%
                                 if (productOptions.size() > 0) {
                                     for (HashMap<String, String> opt : productOptions) {
                             %>
                             <input type="hidden" id="hiddenOpt_<%=opt.get("id")%>" name="opt_<%=opt.get("id")%>" value="0">
                             <%}
                             }%>
                         </form>

                         </div></td>
                     <td></td>
                 </tr>
                 <tr>
                     <td></td>
                     <td>Regular Price</td>
                     <td class="Right"id="regularPrice"></td>
                     <td></td>
                 </tr>
                 <tr class="DiscountRow">
                     <td></td>
                     <td class="DiscountPrice">Printing Discount</td>
                     <td class="Right DiscountPrice" id="discountPrice"></td>
                     <td></td>
                 </tr>
                 <tr>
                     <td></td>
                     <td class="PriceCell">Your Price</td>
                     <td class="PriceCell Right" id="price"></td>
                     <td></td>
                 </tr>
             </table>
             <div id="addToCartButton" class="AddToCart" onclick=""></div>
             <%}else {%>
             <a href="../login.jsp"><img src="<%=base%>images/online-printing-sign-in.png" style="border:none"/></a>
             <%}%>

         </div>
        </div>
       <%} else {}
        }
        %>
    </div>
    <div id="spacer" style="background:#E1E1E1;clear:left;width:170px"></div>
    <%@include file="footer.jsp"%>

</div>

</body>
</html>
<%!



    private boolean categoryHasOption(String cat, String optionId) {
        return Utilities.fetch3("SELECT p.* FROM egprint.productoptions p, egprint.productoptionsmap pom WHERE p.id=pom.option AND pom.Active='1' AND pom.category ='"+cat+"' AND p.id="+optionId+"").size()>0;
    }
%>