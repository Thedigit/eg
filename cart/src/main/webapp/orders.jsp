<%@page import="java.util.*"%>
<%@page import="egprint.*" %>
<%@ include file="common.jsp" %>
<%@include file="checkLogin.jsp"%>
<%
// HashMap<String,String> activeCustomer = (HashMap<String,String>) session.getAttribute("activeCustomer");
   if (catId!=null) {
    category =  Utilities.fetch2("SELECT c.* FROM egprint.category c WHERE c.id='"+catId+"'").get(0);
    }
 int orderCount = Integer.valueOf(Utilities.fetch2("SELECT COUNT(*) as `c` FROM egprint.orders o WHERE o.Customer='"+activeCustomer.get("insideId")+"'").get(0).get("c"));
 session.setAttribute("orderCount",orderCount);

 String viewJobId = Utilities.get(request,"j");

 int limit = 20;
 int displayable = 13;
 int totalPages  = (int) Math.ceil(((double)orderCount)/limit);

 int currentPage =  Math.min(Math.max(Integer.valueOf(Utilities.get(request,"page","1")),1),totalPages); //Avoid over/underflow attacks

 int offset = limit*(currentPage-1);

 ArrayList<HashMap<String,String>> orders = Utilities.fetch2("SELECT o.* ");
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
  <link rel="stylesheet" type="text/css" href="css/topMenu.css" />
  <link rel="stylesheet" type="text/css" href="css/leftPanel.css" />
  <link rel="stylesheet" type="text/css" href="css/rightPanel.css" />
  <link rel="stylesheet" type="text/css" href="css/orders.css" />
  <link rel="stylesheet" type="text/css" href="css/checkout.css" />
  <link rel="stylesheet" type="text/css" href="css/register.css" />
  <script type="text/javascript" src="js/spinner.js"></script>
  <script type="text/javascript" src="js/jquery.ui.selectmenu.js"></script>

  <style type="text/css">



  </style>
  <script type="text/javascript">
      var loadedId = "<%=viewJobId%>";
      var pass;
      var addObject;
            function submit(){
                //Quick autocheck
                addObject = new Object();
                $("input.Required").each(function(){

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
               addObject["id"]=<%=activeCustomer.get("id")%>
               params.addressObject=JSON.stringify(addObject);

               $.post("utils/",params,function(){document.location.reload(true);});

               }

      /**
       * Set breadCrumb bar to current status
       * @param id
       */
      function refreshBreadCrumbs(currentStep){
                var distance = 10;
                $("#breadCrumbs > ul > li").each(function(i,element){
                    if(i<(currentStep*2)){distance+=$(element).width();}
                    if(i==0){return;}//Ignore OpenCap
                    if(i==12){return;}//Ignore EndCap

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
                if (currentStep==6){$(".EndCap").addClass("ActiveEndCap");distance+=25;}
                else{$(".EndCap").removeClass("ActiveEndCap");}

                //Progress bar calculation
                distance=800-distance;
                //alert(distance);
                $("#breadCrumbsOrd").stop().animate(
                            {backgroundPosition:"-"+distance+"px -1px"},
                            {duration:1000});

               
                
            }

      function close(){

              $("#messageDisplay").fadeOut();
              $("#mask").fadeOut(function(){$("#mask").fadeOut();});
              $(".FileSpace").fadeOut();
      }

      /**
       * Load Mask
       * @param id
       */
      function details(id){

          $("#info").hide();
          $("#messageLdr").show();

          $(".Close").click(function(){
              close();
              
          });

          $(".Overall").height($("body").height()).fadeIn();
          $("#messageDisplay").fadeIn();
          $("#messageDisplay").centerScreen();
        loadInfo(id);
      }
      function pulse(div,on){
          if (on) {div.animate({backgroundColor:"#F99"},750,function(){pulse($(this),!on)});}
          else    {div.animate({backgroundColor:"#F00"},750,function(){pulse($(this),!on)});}
      }
      function loadInfo(id){
         loadedId=id; 
         var params = new Object();
          params.action="loadInfo";
          params.id=id;
          $.getJSON("utils/?callback=?",params,function(data){
              try{
              $("#messageTitle").html("Order #"+id+" Details");
              //Product Status
              var statusStep = parseInt(data.Status);
              if (statusStep<=1){statusStep=1;}
              if (statusStep==98){statusStep=4;}
              if (statusStep==99){statusStep=5;}
              if (statusStep>99){statusStep=6;}
              if (data.ShipOption!=1){
                  $(".LastBC").html("Shipped");
                  $("#odShip").html("UPS - "+data.ShipSpeed);
                  $("#odShipTitle").html("Tracking #");
                  $("#odTracking").html('<a href="http://wwwapps.ups.com/WebTracking/track?trackNums='+data.TrackingNumber+'&track.x=Track" target="_blank" onclick="">'+data.TrackingNumber+'</a>');
              }
              else{
                  $(".LastBC").html("Picked Up");
                  $("#odShip").html("Pick Up");
                  $("#odShipTitle").html("Picked Up By:");
                  $("#odTracking").html(data.Signer);

              }

              $("#dueDate").html(data.DueDate + " "+statusStep);

              //Product Images
              $("#jobName").html(data.JobName);
              $("#imageFront").attr('src',"<%=activeCompany.optString("UploadDomain","")%>/barcode/"+id+".jpg");
              $(".AB").remove();
              if(data.Sides.indexOf("One")==-1){
                var imageTd = $(document.createElement("td"));
                var imageDiv = $(document.createElement("div"));
                var image = $(document.createElement("img"));
                image.attr('src',"<%=activeCompany.optString("UploadDomain","")%>/barcode/"+id+".jpg?p=2").attr("id","imageBack");
                imageDiv.addClass("ArtworkBack").append(image);
                imageTd.addClass("AB").append(imageDiv);
                var txtTd = $(document.createElement("td"));
                txtTd.addClass("AB").html("Back");
                imageTd.insertAfter($("#ifI"));
                txtTd.insertAfter($("#ifT"));  
              }
              //Files required
                  
                  $(".UploadNew").hide();
                  if(data.UploadTicket && data.UploadTicket!=""){

              if(data.FilesRequired=="1"){
                  $(".UploadNew").show();
                  pulse($(".UploadNew"),true);
                  $("#uploadTicket").val(data.UploadTicket);
                  $("#form_1").attr("ticket",data.UploadTicket);
                  $(".FileBack, .FileFront").show();
                  if(data.Colors.indexOf("Gold")!=-1){
                     $(".FileGold").show();
                  }else{
                     $(".FileGold").hide();
                  }
                  if(data.Colors.indexOf("Silver")!=-1){
                     $(".FileSilver").show();
                  }else{
                     $(".FileSilver").hide();
                  }
                  if(data.Product.indexOf("Spot")!=-1){
                     $(".FileSpot").show();
                  }else{
                     $(".FileSpot").hide();
                  }
                  if(data.Sides.indexOf("One")!=-1){
                   $(".FileBack").hide();
                  }
              }
                  }
              //Product Details
              $("#pdCategory").html(data.Category);
              $("#pdProduct").html(data.Product);
              $("#pdQty").html(data.qtyDesc);
              $("#pdSize").html(data.Width +data.Height);
              $("#pdSides").html(data.Sides);
              $("#pdColors").html(data.Colors);
              $("#pdCoating").html(data.UV);
              $("#pdTA").html(data.TurnAround+" "+data.TurnAroundUnit);
              //Order Details
              $("#odInvoice").html(data.Invoice);
              $("#odDate").html(data.OrderDate);
              $("#odDueDate").html(data.DueDate);
              $("#odPrice").html("$"+data.Totals);
              $("#odBalance").html("$"+data.BalanceDue);
                  if(data.BalanceDue=="0.00"){$(".PayNow").hide();}else{$(".PayNow").show();}
              //Status Detail
              $(".OrderStatus").removeClass("Red");
               $("#oneStatus").html("Order On Schedule");    
              if(parseInt(data.HoldStatus)>1)
              {
                $("#oneStatus").html("Order On Hold: "+data.HoldType);
                  $(".OrderStatus").addClass("Red");
              }
              //Launch
              $("#messageLdr").remove();
              $("#message").append($("#info"));
              $("#MessageLdr").hide();
              $("#info").fadeIn(function(){refreshBreadCrumbs(statusStep);});

              }catch(e){alert(e);}
          });
      }



      function updateProgress()
  {
   currentProgressDiv = $("#pb_"+1);
   $.getJSON('<%=activeCompany.optString("UploadDomain","")%>/UploadStatus?a='+currentProgressTicket+'&jsoncallback=?'
            , function(data) {
            if (data.done=="true")
            {

              currentProgressDiv.html("Upload Complete");
              /*var progBar= document.createElement('div','');
              progBar.style.width=100+"%";
              progBar.style.height="14px";
              progBar.style.border="solid 1px #AAA";
              progBar.style.backgroundImage="url(https://upload.egdeal.com/progress.png)";
              currentProgressDiv.append(progBar); */
              window.location.reload(true);

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
            //progBar.style.backgroundImage="url(https://upload.egdeal.com/progress.png)";
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
          close();
          $("#sendForm").click(function(){startUpload();});

      }
      function startUpload()
      {

         //validate inputs
          var pass=true;
          $("input").each(function(){
              if($(this).attr('skip')){return;}
              if($(this).val()==""){pass=false;return;}
          });
         // if(!pass){alert("All jobs require a name and one file per side.");return false;}
         var forms = $("#form_1");

         if(!forms[0]){return;}
         forms[0].submit();
         upload($(forms[0]).attr('ticket'));
         currentKey = $(forms[0]).attr('key');
      }

      var mini;
      function modifyShipping(){
          mini = new PAYPAL.apps.DGFlow({expType:"light"});
          mini.startFlow("mini/miniModShipping.jsp?order="+loadedId);

      }

      function closeFlowWindow(){
        mini.closeFlow();
      }

      $(document).ready(function() {
    jQuery.fn.centerScreen = function(loaded) {
        var obj = this;
        if(!loaded) {
            obj.css('top', Math.max(30,$(window).height()/2-this.height()/2));
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
          //Equalize column width
          $(".LeftPanel").height(Math.max($(".RightPanel").height(),600));
          $($(".Details")[0]).css({display:"block"});
          $(".ListTable tr").hover(
                  function(){$(this).find('td').addClass("HighlightRow");$(this).find('td:first').find('img').fadeIn("fast");},
                  function(){$(this).find('td').removeClass("HighlightRow");$(this).find('td:first').find('img').hide();}
                  ).click(function(){details($(this).attr('order'));});

          $(".PDTable tr:even").find('td').addClass("OddRow");
          $(".ODTable tr:even").find('td').addClass("OddRow");
           $(".PDTable tr, .ODTable tr").hover(
                  function(){$(this).find('td').addClass("HighlightRow");},
                  function(){$(this).find('td').removeClass("HighlightRow");}
                  );

                 
          $('.Required').each(function(){
              var req = $(document.createElement('span')).html("*").addClass("Required");
              $(this).parent().prev().append(req);

          });

          $(".cs").click(function(){alert("Coming Soon!");});
          $(".ModShip").click(function(){modifyShipping();});

          //Disguise file upload button:
         // $(".RealFile").fadeTo(0,'0');
         // $(".RealFile").change(function(){
         // $('#hideField_'+$(this).attr('key')).val($(this).val());});
          
          $(".UploadNew").click(function(){$(".FileSpace").slideDown();$(this).stop().css({backgroundColor:"#F00"})});
          $("#sendForm").click(function(){startUpload();})
          <%if (viewJobId!=null){%>
          details(<%=viewJobId%>);

          //enable printing.
          $("#clickPrint").click(function(){window.print();})
          <%}%>

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

 HashMap<String,String> defaultAddress = Utilities.fetch2("SELECT c.*,a.* FROM egprint.customer c , egprint.address a WHERE c.insideId=a.customerId AND c.insideId='"+((HashMap<String,String>) session.getAttribute("activeCustomer")).get("insideId")+"' ORDER BY a.Default DESC,a.id DESC").get(0);

%>
<div id="myAccount">
    <div class="BreadCrumb">
        <span class="BCDark">Home</span>
        <span class="BCDivider">&gt;</span>
        <span class="BCDark">My Account</span>
        <span class="BCDivider">&gt;</span>
        <span class="BCLight">Orders</span>

        <span class="Logout2"><span class="BCDivider"> &lt; </span><a href="login?action=logout">Logout</a></span>

    </div>

    <div id="history" class="MAInfoDiv">
        <div class="Title2">
        <img src="images/MyAccount.png" alt=""> Orders
        <span class="Pages">
            <%if(currentPage>1){%><a href="orders.jsp?page=1"><img src="images/endArrow_L.gif" alt=""></a><%}else{%><img src="images/endArrow_L_disabled.gif" alt=""><%}%>
            <%if(currentPage>1){%><a href="orders.jsp?page=<%=Math.max(1,currentPage-1)%>"><img src="images/singleArrow_L.gif" alt=""></a><%}else{%><img src="images/singleArrow_L_disabled.gif" alt=""><%}%>
            <%for(int i = Math.max(1,currentPage-displayable) ; i <= Math.min(totalPages,currentPage+displayable);i++){%> <a href="orders.jsp?page=<%=i%>" class="PageNumber <%if(i==currentPage){%>PageSelected<%}%>"><%=i%></a> <%}%>
            <%if(currentPage<totalPages){%><a href="orders.jsp?page=<%=Math.min(totalPages,currentPage+1)%>"><img src="images/singleArrow_R.gif" alt=""></a><%}else{%><img src="images/singleArrow_R_disabled.gif" alt=""><%}%>
            <%if(currentPage<totalPages){%><a href="orders.jsp?page=<%=totalPages%>"><a href="orders.jsp?page=<%=totalPages%>"><img src="images/endArrow_R.gif" alt=""></a><%}else{%><img src="images/endArrow_R_disabled.gif" alt=""><%}%> </span>
        </div>

        <%
            ArrayList<HashMap<String,String>> recentOrders = Utilities.fetch2("select o.id, DATE(o.orderDate) as `Date`, o.Invoice, (o.Taxable*.07*o.Price+o.Price +o.ShippingPrice) as `OrderTotal`,o.JobName,o.trackingNumber,s.id as `Status`, s.Status as `StatusDesc`,DATE(o.DueDate) as `DueDate`, o.HoldStatus from egprint.orders o, egprint.status s WHERE o.status=s.id  AND o.Customer='"+activeCustomer.get("insideId")+"'ORDER BY o.OrderDate DESC LIMIT "+limit+" OFFSET "+offset);
            if (recentOrders==null){recentOrders= new ArrayList<HashMap<String,String>> ();}
        %>
        <table class="ListTable">
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
        <%for(HashMap<String,String> order:recentOrders){
            String selectQuery = "SELECT  ord.*, hh.Description as `HoldType`, hh.FilesRequired, qq.description as `qtyDesc`, qq.TurnAround, qq.TurnAroundUnit, p.ID as `pId`, p.ProductName as `Product` , p.Description,  c.description as `Category`,  st.description as `Stock`, pr.description as `Press`, s.description as `Sides`, w.description as `Width`, h.description as `Height`, l.description as `Lamination`, u.description as  `UV`, score.description as `Score_Diecut`, f.description as `Fold`, o.description as `Other`  " +
                                "FROM  egprint.orders ord, egprint.quantities qq, egprint.product p,  egprint.category c,  egprint.stock st, egprint.press pr, egprint.orderonhold hh, egprint.sides s, egprint.width w, egprint.height h, egprint.lamination l, egprint.uv u, egprint.scorediecut score, egprint.fold f, egprint.other o   " +
                                "WHERE  p.category=c.id AND  p.stock=st.id AND p.press= pr.id AND p.sides= s.id AND p.width= w.id AND p.height= h.id AND p.lamination=l.id AND p.uv=u.id AND p.scorediecut=score.id AND p.fold=f.id AND ord.HoldStatus=hh.id AND p.other=o.id"+
                       " AND ord.Product=p.id AND ord.quantities = qq.id AND ord.id='"+order.get("id")+"'";

            HashMap<String,String> desc = Utilities.fetch3(selectQuery).get(0);


        %>
            <tr order="<%=order.get("id")%>" >
                <td></td>
                <td><%=order.get("id")%></td>
                <td>&nbsp;&nbsp;<%=order.get("JobName")%></td>
                <td><%=desc.get("Category")%><br><span style="font-weight:normal"><%=desc.get("Stock")%> + <%=desc.get("UV")%><br><%=desc.get("Width")%> <%=desc.get("Height")%>, <%=desc.get("Sides")%>,  <%=desc.get("qtyDesc")%> pcs </span></td>
                <td><%if(order.get("HoldStatus").equals("0")||order.get("HoldStatus").equals("1")){%><%=order.get("StatusDesc")%><%} else {%><span style="color:#F00;">On Hold</span><%}%></td>
                <td><%=Utilities.s2c(order.get("DueDate"))%><!--a class="Reorder" href="">Reorder</a--></td>
                <td></td>
            </tr>
        <%}%>
            </tbody>
        </table>
    </div>

</div>

        <%
        }
        %>
    </div>
    <%@include file="footer.jsp"%>


</div>
  <div class="MessageContainer" id="messageDisplay">
   <div class='MessageTitle'><span id="messageTitle"></span><div id="clickPrint"><img src="images/print.png">PRINT</div></div>
   <div id="MessageLdr">Loading <img src='images/ajax-loader.gif'></div>
   <div class="Close"><img src='images/Button_X.png'></div>
      <div class="Message" id="message">
   <div id="info">
      <div class="StatusBreadCrumb">
          <div id="breadCrumbs">
               <ul id="breadCrumbsOrd">
               <li class="OpenCap"></li>
               <%
               String steps[] = new String[]{"Received","Prepress","Printing","Finishing","Ready","Picked Up"};
               for (int i =  0; i<steps.length;i++)
                {%>
                  <li class="Step <%if(i==steps.length-1){%>LastBC<%}%>"><%=steps[i]%></li>
                  <%if(i==steps.length-1){continue;}//Skip the last divider%>
                  <li class="Divider"></li>
                <%}
               %>
               <li class="EndCap"></li>
               </ul>
           </div>
          <div class="DueDate">Due date: <span id="dueDate">05-02-2011</span></div>
      </div>
          <div class="Artwork">
              <div id="jobName" class="JobName"></div>
              <table class="ArtworkContainer">
                  <tr><td id="ifI"><div class="ArtworkFront"><img id="imageFront" src="<%=activeCompany.optString("UploadDomain","")%>/barcode/24142.jpg" alt=""></div></td></tr>
                  <tr><td id="ifT">Front</td></tr>
              </table>

          </div>
          <div class="PDBox">
              <div class="ProductDetails PD">
                  <div class="JobName">Product Details</div>
                  <table class="PDTable">
                      <tr>
                          <td class="TT">Category:</td>
                          <td id="pdCategory">Business Cards</td>
                          <td></td>
                      </tr>
                      <tr>
                          <td class="TT">Product:</td>
                          <td id="pdProduct">Standard Business Cards</td>
                          <td></td>
                      </tr>
                      <tr>
                          <td class="TT">Quantity:</td>
                          <td id="pdQty">1000</td>
                          <td></td>
                      </tr>
                      <tr>
                          <td class="TT">Size:</td>
                          <td id="pdSize">2" x 3.5"</td>
                          <td></td>
                      </tr>
                      <tr>
                          <td class="TT">Sides:</td>
                          <td id="pdSides">One Sided</td>
                          <td></td>
                      </tr>
                      <tr>
                          <td class="TT">Colors:</td>
                          <td id="pdColors">Full Color</td>
                          <td></td>
                      </tr>
                      <tr>
                          <td class="TT">Coating:</td>
                          <td id="pdCoating">UV 2 Sides</td>
                          <td></td>
                      </tr>
                  </table>
              </div>
              <div class="ProductDetails OD">
                  <div class="JobName">Order Details</div>
                  <table class="ODTable">
                      <tr>
                          <td class="TT">Invoice:</td>
                          <td id="odInvoice"></td>
                          <td></td>
                      </tr>
                      <tr>
                          <td class="TT">Order Date:</td>
                          <td id="odDate"></td>
                          <td></td>
                      </tr>

                      <tr>
                          <td class="TT">Turn Around:</td>
                          <td id="pdTA">5-7 Business days</td>
                          <!--td><img src="images/Synchronize-icon.png"><br><a class="cs" href="#">Modify</a> </td-->
                      </tr>
                      <tr>
                          <td class="TT">Due Date:</td>
                          <td id="odDueDate"></td>
                          <td></td>
                      </tr>
                      <tr>
                          <td class="TT">Shipping:</td>
                          <td id="odShip">Pick Up</td>
                          <!--td><img src="images/Synchronize-icon.png"><br><a class="ModShip" href="#">Modify</a></td-->
                      </tr>
                      <tr>
                          <td id="odShipTitle" class="TT">Picked Up By:</td>
                          <td id="odTracking"><a href="http://wwwapps.ups.com/WebTracking/track?trackNums=<%=""%>&track.x=Track"
                                                target="_blank" onclick="">1Z12345687895412</a></td>
                          <td></td>
                      </tr>
                  </table>
              </div>
          </div>    
          <div class="OrderStatus Red">
              <div class="JobName">Order Status</div>
              <span class="OneStatus" id="oneStatus"></span>
              <div class="UploadNew"><span>CLICK HERE TO UPLOAD NEW FILES</span> </div>
              <div class="FileSpace">
                 <div><iframe class="UpFrame" id="up_1" name="up_1" count='0' key='1'></iframe></div>
                       <form id="form_1" action="<%=activeCompany.optString("UploadDomain","")%>/FileUpload" method="POST" enctype="multipart/form-data" target="up_1" key="1" ticket="" onsubmit="return false;">
                        <input type="hidden" name="forceNotify" value="true">
                        <table class="FileUpload" id="fu_1">
                            <tr><td colspan="2" align="center"><div class="ProgressBar" id="pb_1" style="float:none;"></div></td></tr>
                            <tr><td class="UpTitle">Job Name:</td><td style="position:absolute;"><input  class="NiceInput"  name="jobName" value=""><input type="hidden" id="uploadTicket" name="uploadTicket" value=""></td></tr>

                            <tr class="FileArt FileFront"><td class="UpTitle">Artwork Front:</td><td style="position:absolute;"><input type="file" class="RealFile" name="file1" key="1f"></td></tr>
                            <tr class="FileArt  FileBack"><td class="UpTitle">Artwork Back: </td><td style="position:absolute;"><input type="file" class="RealFile" name="file2" key="1b" skip="true"></td></tr>

                            <tr class="FileGold FileFront"><td class="UpTitle">Gold Front:</td><td style="position:absolute;"><input type="file" class="RealFile" name="file3" key="2f"></td></tr>
                            <tr class="FileGold  FileBack"><td class="UpTitle">Gold Back: </td><td style="position:absolute;"><input type="file" class="RealFile" name="file4" key="2b" skip="true"></td></tr>

                            <tr class="FileSilver FileFront"><td class="UpTitle">Silver Front:</td><td style="position:absolute;"><input type="file" class="RealFile" name="file5" key="3f"></td></tr>
                            <tr class="FileSilver  FileBack"><td class="UpTitle">Silver Back: </td><td style="position:absolute;"><input type="file" class="RealFile" name="file6" key="3b" skip="true"></td></tr>

                            <tr class="FileSpot FileFront"><td class="UpTitle">Spot UV Front:</td><td style="position:absolute;"><input type="file" class="RealFile" name="file7" key="4f"></td></tr>
                            <tr class="FileSpot  FileBack"><td class="UpTitle">Spot UV Back: </td><td style="position:absolute;"><input type="file" class="RealFile" name="file8" key="4b" skip="true"></td></tr>


                            <tr><td class="UpTitle"></td><td><input  class="NiceInput"  name="comments" value="" type="hidden"></td></tr>
                            <tr><td colspan="2" align="center"><div style="text-decoration:underline;cursor:pointer;" id="sendForm">Upload Files Now<img src="images/Up-icon.png" style="border:none;"></div></td></tr>

                        </table>
                       </form>
              </div>                                
          </div>

      </div>

   </div>
</div>
<div class="Overall" id="mask"></div>
</body>
</html>