<%@page import="java.util.*"%>
<%@page import="egprint.*" %>
<%@include file="common.jsp"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>EGPRINT - Your Online Print Super Store</title>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/jquery-ui.min.js"></script>

  <script type="text/javascript" src="/JSON.js"></script>
  <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/themes/smoothness/jquery-ui.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/ui.spinner.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/jquery.ui.selectmenu.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/topMenu.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/leftPanel.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/rightPanel.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/myAccount.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/register.css" />
  <script type="text/javascript" src="<%=base%>js/spinner.js"></script>
  <script type="text/javascript" src="<%=base%>js/jquery.ui.selectmenu.js"></script>

  <style type="text/css">



  </style>
  <script>

      /**
       Read final product selection and display price & TA
       */
      var price;
      var sets;
      var shipping;
      function finalize(data){

          pointy.image.attr("src","");
          price = data.finalSelection.Price;
          sets=1;
          try{refreshPrice();}catch(e){alert(e);}
          try{refreshShipping();}catch(e){}
          /*$("#addToCart").show();
          $("#price").fadeIn("fast");
          $("#addToCart").fadeIn("fast");
          $("#pricingTable").fadeIn("fast"); */
          $("#addToCartButton").unbind('mouseenter mouseleave');
          $("#addToCartButton").addClass("AddToCartActive");
          $("#addToCartButton").click(function(){$('#addToCartForm').submit()});
          $("#addToCartButton").hover(
                  function(){$("#addToCartButton").addClass("AddToCartHover");},
                  function(){$("#addToCartButton").removeClass("AddToCartHover");}
                  );

      }

      function refreshPrice(){
          if(!loadedData||!loadedData.finalSelection){return;}//Nothing to update.
          $("#regularPrice").html("$"+(price*sets*1.15).toFixed(2)+"");
          $("#discountPrice").html("($"+(price*sets*.15).toFixed(2)+")");
          $("#price").html("$"+(price*sets).toFixed(2)+"");
      }
      /**
       Retrieve current state of product builder
       */
      var loadedData;
      function getBuilder()
      {
          var params = new Object();
          params.action="getBuilder";
          $.getJSON("/products/?callback=?",params,function (data){
             // alert(JSON.size(data.specs));
              loadedData=data;
              var nextStep = $("#"+data.nextStep);
              if (data.nextStep==-1){finalize(data);}
              for (var s in data.specs)
              {
                     var currentOpt = data.specs[s];
                      //var select = $("#"+JSON.size(data.specs));
                      var select = $("#"+s);
                       select.empty()
                       select.append($("<option></option>").attr("value","remove").text("Select "+currentOpt.name));
                      for (var opt in currentOpt.options)
                      {
                          var o = currentOpt.options[opt];

                          try{
                          var newOpt = $("<option></option>").attr("value",o.id).text(o.Description);
                         // alert("("+s+")"+o.id+" ? "+data.specs[s].selected)//{newOpt.attr("selected","yes");}
                          if(o.id==data.specs[s].selected){newOpt.attr("selected","yes");}

                          select.attr("disabled",'');

                          select.append(newOpt);

                          }catch (ex) {alert(ex);}
                      }
                  $(select).selectmenu('destroy');
                  $(select).selectmenu();
              }

              /**
               * If it's the Turnaround step, prefetch all the UPS shipping options.
               */
              if(data.nextStep==6||data.nextStep==-1)
              {  try{

                 fetchShipping();
                  }catch (E){alert(E)};
              }
              /**
               * Move Animate arrow to next option, Restart Animation.
               * */
              var pos = nextStep.parent().prev().find("span:first-child").position();
              if(!pos){return;}
              pointy.x=pos.left-25;
              pointy.y = pos.top;
              stopBounce=false;
              pointy.image.stop();
              pointy.image.attr("src","/images/Play-icon.png");
              pointy.image.animate({top:pointy.y+"px"});
              bounceOut();
          });
      }

      function sendBuildOption(select){

          var option = ($(select).attr("id"));
          $(select).find("option[value='remove']").remove();
          var params = new Object();
          params.action = "setOption";
          params.option = option;
          params.value =  $(select).val();
          /**
           * Stop Animation, Display progress icon.
           */
          stopBounce=true;
          pointy.image.attr("src","/images/progress.gif");
          $.getJSON("/products/?callback=?",params,function (data){
              getBuilder();
          });
          //Hide finalize fields to avoid confusion
          $("#regularPrice").html("");
          $("#discountPrice").html("");
          $("#price").html("");
          $("#addToCartButton").removeClass("AddToCartActive AddToCartHover").unbind("click mouseenter mouseleave");
           //$("#price").fadeOut("fast");
          // $("#addToCart").fadeOut("fast");
           $("#sets").val("1");

      }

      //Arrow Bounce Animation
      function bounceOut()
      {
          if(stopBounce){return;}
          $(pointy.image).animate({left:(pointy.x-10)+"px"},800,function(){bounceIn();});
      }
      function bounceIn()
      {

          $(pointy.image).animate({left:pointy.x+"px"},800,function(){if(stopBounce){return;} bounceOut();});
      }

      /**
       * Prefetch UPS data
       */
      var shippingLoaded=false;
      function fetchShipping(){
         // alert(JSON.stringify(loadedData));
          var params = new Object();
          var shipment = new Object();
          shipment.products=new Object();
          for(var i =0; i < loadedData.specs["6"].options.length;i++)
          {
            var package  = new Object();
            var packageSpecs  = new Object();
            package.toZip   =  $('#shippingZip').val();
            package.sets    =  1;
            packageSpecs.weight  =  10.0;
            packageSpecs.Price   =  1.0;
            packageSpecs.bundle  =  1.0;
            packageSpecs.boxes   =  1.0;
            package.product=packageSpecs;
            package.jobReady   =  loadedData.specs["6"].options[i].jobReady;

            shipment.products[loadedData.specs["6"].options[i].jobReady] = package;
          }

          params.shipment= JSON.stringify(shipment);
          params.getTime= true;
          //alert(params.shipDate);

      var url= 'http://upload.egprint.net/FTTO/upsCalc?jsoncallback=?';

               $("#shippingArrivalDate").html('<img src="/images/ajax-loader.gif" alt="Loading...">' );
               $.getJSON(url, params,function(data) {

                 shipping=data;
                 shippingLoaded=true;
                 $("#shippingArrivalDate").html('');
                 refreshShipping();
               });
      }

      /**
       * Show shipping for selected turnaround time
       */
      function refreshShipping()
      {   try{
         $("#shippingArrivalDate").show();
         if(!shippingLoaded||!loadedData.finalSelection){return;}
         var shipType = $('input:radio[name=shipOption]:checked').val();
         var shipDate = loadedData.finalSelection.jobReady;
         $("#shippingArrivalDate").html(shipping.products[shipDate][shipType].time);
      }catch(e){alert(e);}

      }
      /**
       * Add a product to the shopping cart via AJAX call
       */
      function addToCart()
      {
          var params = new Object();
          params.action="addToCart";
          params.sets=$("#sets").val();
          $.getJSON("/checkout?callback=?",params,function(data){

          });
      }
      var options = new Array();
      var pointy = new Object();
      var stopBounce=false;
      function init()
      {
          //Equalize column width

          $(".LeftPanel").height(Math.max($(".RightPanel").height(),600));
          $(".Categories ul li").hover(function(){$(this).addClass("ItemHover");},function(){$(this).removeClass("ItemHover");})
          $(".CartItem").hover(function(){$(this).addClass("ItemHover");},function(){$(this).removeClass("ItemHover");})
          $(".CartItem").click(function(){var specs = $(this).next(); if(specs.is(":visible")){specs.slideUp()}else{specs.slideDown()} });
          $("#optionsTable select").change(function(){sendBuildOption(this);});
          options[1] = $("#1");
          options[2] = $("#2");
          options[3] = $("#3");
          options[4] = $("#4");
          pointy.image = $(document.createElement('img')).addClass("Pointer").attr("src","/images/Play-icon.png");
          var pos = $("#1").parent().prev().find("span:first-child").position();
         if(pos){
          pointy.image.css({left:pos.left-25,top:pos.top});
          pointy.x=pos.left;
          pointy.y=pos.top;
          //pointy.
          $(document.body).append(pointy.image);

          bounceOut();
         }

          $('#sets').spinner({ min: 1, max: 100 ,step:1});
          $("#sets").change(function(){sets=$(this).val();refreshPrice();});

          $(".BuilderOption").selectmenu();
          //$('#addToCartButton').click(function(){addToCart();});
          $('input:radio[name=shipOption]').change(function(){refreshShipping();})

          $(".ListTable tr").hover(
                  function(){$(this).find('td').addClass("HighlightRow");},
                  function(){$(this).find('td').removeClass("HighlightRow");}
                  );

          //PreLoad Shopping Cart button Images
          $("<img id='loaderImg' src='/images/addtocart-dark.jpg' onload=''/>");
          $("<img id='loaderImg' src='/images/addtocart.jpg' onload=''/>");

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
          if(true){
           %>

           <%



%>
<div id="myAccount">
    <div class="BreadCrumb">
        <span class="BCDark">Home</span>
        <span class="BCDivider">&gt;</span>
        <span class="BCLight">Contact Us</span>

        <span class="Logout2"><span class="BCDivider"> &lt; </span><a href="/login?action=logout">Logout</a></span>

    </div>
    <table width="98%" cellspacing="0" cellpadding="2" border="0">
  <!--START: BODY_HEADER-->
    <tbody><tr>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr><td class="page_headers">Contact Us</td></tr>

 <!--END: BODY_HEADER-->
	<tr><td>
 <!--START: SUB_PAGES--><!--END: SUB_PAGES-->

    </td></tr>

	    <tr>
		<td class="data"><p><span style="font-weight: bold; font-family: Verdana;">Mailing Address:</span></p>
<p><span style="font-size: 8pt; font-family: Verdana;">www.egprint.net<br>7335 NW 35th ST<br><br>Miami, FL. 33122<br>US</span></p>
<p><span style="font-size: 8pt; font-family: Verdana;"><span style="font-weight: bold; font-size: 8pt; font-family: Verdana;">Phone:<br><br></span><span style="font-size: 8pt; font-family: Verdana;">305-470-0083</span></span></p>
<p><span style="font-size: 8pt; font-family: Verdana;">&nbsp;</span></p><span style="font-size: 8pt; font-style: italic; font-family: Verdana;">Thanks for shopping at www.egprint.net.</span></td>
	    </tr>
  </tbody></table>

</div>

        <%
        }
        %>
    </div>
    <%@include file="footer.jsp"%>

</div>

</body>
</html>