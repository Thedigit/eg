function populateAll()
     {
         populate(mainTree,1);
         for (var j = 0; j <selections.length-1;j++)
         {
             var path="";
              for (var i = 0 ; i <= j; i++)
             {
                 if(i>0){path+=".";}
                 path+=selections[i].desc+"."+selections[i].val;
             }
         var sub = (jsonPath(mainTree,path))[0];
         populate(sub,j+2);
         }

        //Preselect Options...
        for (var j = 0; j <selections.length;j++)
         {
          $("#"+(j+1)+" option[value='"+selections[j].val+"']").attr("selected",true);

          updateBelow($("#"+(j+1)));
         }
         if (!firstLoad)try{ $(".BuilderOption").selectmenu('destroy');
           $(".BuilderOption").selectmenu();}catch(e){};
     }
     function updateBelow(menu){

         $(menu).removeClass("Highlight2");
         var id = parseInt(menu.attr("id"));
         var type = menu.attr("opt");
         var val = menu.val();

          $("#"+id+" option[value='-1']").remove();

         if (!firstLoad) try{ $(menu).selectmenu('destroy');
                   $(menu).selectmenu();}catch(e){alert(">>"+e)};
         if(val=="-1"){return;}

             selections[id-1].val=val;

         var path="";
         for (var i = 0 ; i < id; i++)
         {
             if(i>0){path+=".";}
             path+=selections[i].desc+"."+selections[i].val;

         }

         var sub = (jsonPath(mainTree,path))[0];
         if (sub["Price"])
         {
             loadedData=sub;
             $(".Blink").removeClass("Highlight2");
             discountPrice=parseFloat(sub["discountPrice"]).toFixed(2);
             regularPrice =parseFloat(sub["regularPrice"]).toFixed(2);
             price = parseFloat(sub["Price"]).toFixed(2);
             productId = sub["id"];
             refreshPrice();
             fetchFast();
             finalize();
             return;
         }
         populate(sub,id+1);
         $("#addToCartButton").removeClass("AddToCartActive AddToCartHover").unbind("click mouseenter mouseleave");

     }

     var it=0;
     function populate(treeA, menu)
     {
      menu = parseInt(menu);
       var sel = $("#"+menu).attr("opt");
       var tree=treeA[sel];
      // alert(sel);

       //$('#tree').html("");
       //$('#tree').html(it++ + "<br>"+JSON.stringify(treeA[sel]));

         //Disable all below.
         for( var i = 0 ; i < 11;i++){
         $("#"+(parseInt(menu)+i)).empty();
         var def = $(document.createElement('option')).val("-1").html("Select Options");
         $("#"+(parseInt(menu)+i)).append(def).attr("disabled",true);
        }


          $("#discountPrice").html("");
          $("#regularPrice").html("");
          $("#price").html("");
          price=-1;
         $("#"+menu).attr("disabled",false);
         $("#"+menu).addClass("Highlight2");


         var list = new Array();

         for(var key in tree){
             //alert(key + " "+tree[key].Description);
             var entry = new Object();
             entry.val=key;entry.desc=tree[key].Description;
             list.push(entry)
         }
         list.sort(
                 function(a,b)
                 {

                     var num = false;
                     try{num = parseInt(a.desc)==a.desc;}catch(e){}
                     if(num)
                     {return a.desc-b.desc;}
                     else
                     {
                         if (a.desc > b.desc)
                         {return 1;}
                         else
                         {
                          if(a.desc==b.desc)
                         {return 0}
                         else{return -1;}
                         }
                     }
                 });

         for (var i = 0 ; i < list.length;i++){
             var opt = $(document.createElement('option')).val(list[i].val).html(list[i].desc);
             $("#"+menu).append(opt);
         }
         $("#"+menu).attr("disabled",false);
           if (!firstLoad)try{ $(".BuilderOption").selectmenu('destroy');
                   $(".BuilderOption").selectmenu();}catch(e){};

     }

     function pulse(div,on){
         if (on) {div.animate({borderTopColor:"#99F",borderBottomColor:"#99F"},750,function(){pulse($(this),!on)});}
         else    {div.animate({borderTopColor:"#FFF",borderBottomColor:"#FFF"},750,function(){pulse($(this),!on)});}
     }

     var shipping;
     function finalize(data){
        // pointy.image.attr("src","/images/clear.gif");
         //price = data.finalSelection.Price;
         //sets=1;
         try{refreshPrice();}catch(e){}
        // try{refreshShipping();}catch(e){}
         $("#addToCartButton").unbind('mouseenter mouseleave');
         $("#addToCartButton").addClass("AddToCartActive");
         $("#addToCartButton").click(function(){$('#addToCartForm').submit()});
         $("#addToCartButton").hover(
                 function(){$("#addToCartButton").addClass("AddToCartHover");},
                 function(){$("#addToCartButton").removeClass("AddToCartHover");}
                 );

     }

     function refreshPrice(){
         if(price==-1){return;}
         $("#regularPrice").html("$"+(regularPrice*sets).toFixed(2)+"");
         $("#discountPrice").html("($"+(discountPrice*sets).toFixed(2)+")");
         $("#price").html("$"+(price*sets).toFixed(2)+"");
         $("#product").val(productId);
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

     function fetchFast(){
         $.getJSON("utils/?callback=?",{action:"getFast",q:loadedData.id},function(data){
             $("#fastDayImage").remove();
             if (data.q){
                 loadedData.ShipDateTA=24;
                 var qualify =$('<img id="fastDayImage" style="position:absolute;bottom:15px;right:15px;" src="images/Fast-icon.png">');
                 $(".ProductImage2").append(qualify);
             }

             fetchShipping();
         });
     }
     /**
      * Prefetch UPS data
      */
     var shippingLoaded=false;
     function fetchShipping(){
         //

        // alert(JSON.stringify(loadedData));
         var params = new Object();
         var shipment = new Object();
         shipment.products=new Object();

           var package  = new Object();
           var packageSpecs  = new Object();
           package.toZip   =  $('#shippingZip').val();
           package.sets    =  1;
           packageSpecs.weight  =  loadedData.Weight;
           packageSpecs.Price   =  loadedData.Price;
           packageSpecs.bundle  =  1.0;
           packageSpecs.boxes   =  loadedData.Boxes;
           package.product=packageSpecs;
          //package.jobReady   =  loadedData.ShipDate;
          // package.jobReadyTA   =  loadedData.ShipDateTA;
           package.TA   =  loadedData.ShipDateTA; //Turnaround

           shipment.products[0] = package;


         params.shipment= JSON.stringify(shipment);
         params.getTime= true;
         params.getRate= true;
         //alert(params.shipDate);

     var url= uploadDomain+'/_FTTO/upsCalc?jsoncallback=?';

              $("#shippingArrivalDate")[0].innerHTML='<img src="images/ajax-loader.gif" alt="Loading..."/>';
              //$("#shippingArrivalDate").html('LOADING!!!' );

              $.getJSON(url, params,function(data) {

                shipping=data;
                shippingLoaded=true;
               // $("#shippingArrivalDate").html('');
                refreshShipping();
              });
     }

     /**
      * Show shipping for selected turnaround time
      */

     function refreshShipping()
     {   try{

        $("#shippingArrivalDate").show();

       // if(!shippingLoaded||!loadedData.finalSelection){return;}
        var shipType = $('input:radio[name=shipOption]:checked').val();
        var shipDate = "0";//loadedData.finalSelection.jobReady.replace(/-/g,"");
        //alert(JSON.stringify(shipping)+shipType+shipDate);
        $("#shippingArrivalDate").html(shipping.products[shipDate][shipType].time+" $"+shipping.products[shipDate][shipType].rate.shipmentValue   );
       }catch(e){}

     }
     /**
      * Add a product to the shopping cart via AJAX call
      */
     function addToCart()
     {
         var params = new Object();
         params.action="addToCart";
         params.sets=$("#sets").val();
         $.getJSON("checkout?callback=?",params,function(data){

         });
     }
     var options = new Array();
     var pointy = new Object();
     var stopBounce=false;
     function init()
     {
         //Equalize column width

         equalize();
         $(".BuilderOption").selectmenu();
         //populateAll();
         getTree();
        // $(".BuilderOption").selectmenu();
         $("#optionsTable select").change(function(){updateBelow($(this)); $(this).parent().stop().css({borderColor:"#FFF"})});
         options[1] = $("#1");
         options[2] = $("#2");
         options[3] = $("#3");
         options[4] = $("#4");
         pointy.image = $(document.createElement('img')).addClass("Pointer").attr("src","images/Play-icon.png");
         var pos = $("#1").parent().prev().find("span:first-child").position();
        if(pos){
         pointy.image.css({left:pos.left-25,top:pos.top});
         pointy.x=pos.left;
         pointy.y=pos.top;
         //pointy.
        // $(document.body).append(pointy.image);

        // bounceOut();
        }
         $('#sets').spinner({ min: 1, max: 100 ,step:1});
         $("#sets").change(function(){sets=$(this).val();refreshPrice();});


         //$('#addToCartButton').click(function(){addToCart();});
         $('input:radio[name=shipOption]').change(function(){refreshShipping();})

         $(".ListTable tr").hover(
                 function(){$(this).find('td').addClass("HighlightRow");},
                 function(){$(this).find('td').removeClass("HighlightRow");}
                 );

         //PreLoad Shopping Cart button Images
         $("<img id='loaderImg' src='images/addtocart-dark.jpg' onload=''/>");
         $("<img id='loaderImg' src='images/addtocart.jpg' onload=''/>");

         //Highlight Option Fields
         $("div.ProductOption").hover(
                 function(){$(this).addClass("ProductOptionHover");},
                 function(){$(this).removeClass("ProductOptionHover");});

         //Update Selected Options
         $("input.ProductOption").change(function(){

             var opt = $(this).attr("opt");
             var selected = $(this).is(":checked");
             $("#hiddenOpt_"+opt).val(selected?1:"0");
         });


     }
     //getTree();
     $(document).ready(function(){init();});