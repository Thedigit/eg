/**
 * Shipping script
 */
var showShipping=false;
var shipOption=0;
$(document).ready(function(){
    //alert(JSON.stringify($("input:radio[name=MainShipOption]:checked")));
   //Change Shipping Speed
   $("input:radio[name=shipOption]").change(function(){
     cart.shipping.subtype = $(this).val();
     refreshShipping();
   });

   $("#shipOptionInsure").change(function(){
      if(!$(this).is(":checked")){
          alert("You have declined insurance for this package\n" +
                "We are not liable for any damage/loss than may ocurr during transit.")
      }
       refreshShipping();
    })
   $("#shipOptionSignature").change(function(){
      if(!$(this).is(":checked")){
          alert("You have declined delivery confirmation for this package\n" +
                "UPS may deliver or drop off package at its sole discretion.\n" +
                  "We are not liable for any damage/loss that may ocurr as a result.")
      }
       refreshShipping();
    })
   //Change Shipping type
    $("input:radio[name=MainShipOption]").bind('change click',function()
   {
       var option = $(this).val();
       displayShipping(parseInt(option));
   });

    //Check required fields
     $('.Required').each(function(){
              var req = $(document.createElement('span')).html("*").addClass("Required");
              $(this).parent().prev().append(req);

          });
    if(!$("#addressBook")[0]){return;}
    $("#addressBook").get(0).selectedIndex=1;
    loadShipping();
    $("#addressBook").change(function(){loadShipping();});
    //Must be after the above lines in order to prevent double tagging.
    $("#addressBook").selectmenu({width:420,format:addressFormatting,maxHeight:400});
    $("#stateSelect").selectmenu({width:270});
    $("#addressBook").trigger("change");
    $("#addressBook").get(0).selectedIndex=0;
    $("#addressBook").selectmenu('value',0);

    //create watcher for required fields
    $(".Required").change(function(){cart.shipping.address.id=-1;});

    //create watcher for zipcode
    //$("#shipZip").change(function(){
    $("#shipZip").change(function(){
        updatedZip();
    });
   // fetchShipping();
});

var addressFormatting = function(text){
			var newText = text;
			//array of find replaces
			var findreps = [
				{find:/^([^\-]+) \- /g, rep: '<span class="Selectmenu-item-header">$1</span>'},
				{find:/([^\|><]+) \| /g, rep: '<span class="ui-selectmenu-item-content">$1</span>'},
				{find:/([^\|><\(\)]+) (\()/g, rep: '<span class="ui-selectmenu-item-content">$1</span>$2'},
				{find:/([^\|><\(\)]+)$/g, rep: '<span class="ui-selectmenu-item-content">$1</span>'},
				{find:/(\([^\|><]+\))$/g, rep: '<span class="ui-selectmenu-item-footer">$1</span>'}
			];

			for(var i in findreps){
				newText = newText.replace(findreps[i].find, findreps[i].rep);
			}
			return newText;
		}


/**
 * Determine wha type of shipping to perform.
 * While it could bve done within the same function, additional functionality may be required latter.
 * @param option
 */
function displayShipping(option){

    showShipping=true;


    switch(option){
        case 1:{
            doPickup();
        }
        break;
        case 2:{
            doUPS();
        }
        break;
    }
    try{cart.shipping.type=option;}catch(e){document.location.reload(true);}
    refreshShipping();
    equalize();
    $("#nextStep").hover(hh,hh).removeClass("Shipping1 Shipping2 Shipping3").addClass("Payment2").click(nextStep);
}

function doPickup(){

    $(".ShipOption[option!=1]").fadeOut(function(){$(".ShipOption[option=1]").fadeIn();});
    $(".StaticShipping").html("Pickup");

}
function doUPS(){
   
    $(".ShipOption[option!=2]").fadeOut(function(){$(".ShipOption[option=2]").fadeIn();});
    $(".StaticShipping").html("UPS");
    //$("#nextStep").attr("disabled",true);


}

/*
Loads an address from the clients book.
* */
function loadShipping()
{
   var val = $('#addressBook').val();
   if(val==""){ad.id=-1;return;}
   var newShip = JSON.parse(val);

   $('input[name=Contact]').val(newShip.Contact);
   $('input[name=Company]').val(newShip.Business);
   $('input[name=Address]').val(newShip.Address1);
   $('input[name=City]').val(newShip.City);
   $('input[name=Zip]').val(newShip.Zip);
   $('input[name=Alias]').val(newShip.Alias);
   var opt = $('option[value='+newShip.State.toUpperCase()+']').attr('checked',true);
   var index = $('#stateSelect').children().index(opt);
   $('option[value='+newShip.State.toUpperCase()+']').parent().selectmenu('value',index);
   $("#zipVerify").html($("#shipZip").val());
   saveShipping();
    cart.shipping.address.id=newShip.id;
}

/**
 * Save shipping info in cart fields.
 */
function saveShipping(){
    var ad = cart.shipping.address;
    ad.contact=$('input[name=Contact]').val();
    ad.business=$('input[name=Company]').val();
    ad.address1=$('input[name=Address]').val();
    ad.city=$('input[name=City]').val();
    ad.state=$('#stateSelect').val();
    ad.zip=$('input[name=Zip]').val();
    ad.alias=$('input[name=Alias]').val();
    ad.save=$('input[name=saveAddress]').is(":checked")?1:0;
}

function validate(){
    //Quick autocheck

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
              }
              else{
                    if(!$(this).val().match(pattern))
                    {
                        var format = $(this).attr('format');
                        if(!format){format="";}
                        alert("A valid "+$(this).attr('name')+" is required \n"+format);
                        return false;
                    }
                  pass=true;
              }
          });
          if(!pass){return false;}
          //Specific fields

          if($("#stateSelect").val()==""){
              alert("A valid state must be selected");return false;
          }
    return pass;
}

/**
 * Watch zipcode field for changes.
 * A 5 Digit entry that remains after 1 second triggers a fetch of UPS data.
 */
var updateCode="";
function updatedZip(){
    if(!$("#shipZip").val().match(/[0-9]{5}/)){return;}
    clearTimeout(updateCode);
    $("#zipVerify").html($("#shipZip").val());
    cart.shipping.toZip=$("#shipZip").val();
    updateCode = setTimeout("syncCart()",1000);
}

/**
 * Fetch UPS Rate Data
 */
shippingLoaded=false;
var shippingRequest="";
var shipping;
function fetchShipping1(){
        shipping=new Object();
        shipping.ground=0.0;
        shipping.expedited2=0.0;
        shipping.nextDay=0.0;
         // alert(JSON.stringify(loadedData));
          var params = new Object();
          var shipment = new Object();
          var products= cart.products;
          for(var i in products)
          {
            products[i].toZip=$('#shipZip').val();
            //alert(JSON.stringify($('#shipZip').val()+products[i].product));//=$('#shippingZip').val();
           } /**/

          params.shipment= JSON.stringify(cart);
          //alert(params.shipment);//= JSON.stringify(cart);
          params.getRate= true;
          //alert(params.shipDate);

      var url= uploadDomain+'/FTTO/upsCalc?jsoncallback=?';

              $("#nda, #ex2, #gnd").html('<img src="/images/ajax-loader.gif" alt="Loading...">' );
              if(shippingRequest.hasOwnProperty('abort')){shippingRequest.abort();}
              shippingRequest=$.getJSON(url, params,function(data) {

                 shipping=data;
                 shippingLoaded=true;
                // alert(JSON.stringify(data));

                // $("#shippingArrivalDate").html('');
                  if(showShipping){refreshShipping();}
               
               });
      }

/**
 * Update all shipping fields based on selection
 */
function refreshShipping()
{      try{
      if(cart.shipping.type==1){
         $(".staticShipTotal").html("$0.00");
         $(".StaticShipPrice").html("$0.00");
          totalShip=0;
      }
      else {
        
      var products = cart.shipping.rates.products;
      var shipType = $("input:radio[name=shipOption]:checked").val();
      var shipName = $("input:radio[name=shipOption]:checked").attr('stype');
      cart.shipping.subtype =shipType;
     $('.StaticShipping').html(shipName);
    if(shipType=="self"){
        selfShipping();
        return;
    }
    //Update individual items in order.
    if(!cart.shipping.rates.totals){return;}
    for(var item in products){

          var value = parseFloat(products[item][shipType].rate.shipmentValue);

           cart.shipping.insure="0";
           cart.shipping.dconf ="0";
           if(insured()) {value += parseFloat(products[item][shipType].rate.insuranceValue);cart.shipping.insure="1";}
           if(dconf())   {value += parseFloat(products[item][shipType].rate.confirmationValue);cart.shipping.dconf="1";}
           $(".sShipPrice_"+item).html('$'+value.toFixed(2));
        }
    //Display Options
    $("#nda").html("$"+cart.shipping.rates.totals.nextDay);
    $("#ex2").html("$"+cart.shipping.rates.totals.expedited2);
    $("#gnd").html("$"+cart.shipping.rates.totals.ground);
    if(cart.shipping.rates.totals.insurance==0.0){$("#insuranceTotal").html("FREE !");}
    else{$("#insuranceTotal").html("+ $"+cart.shipping.rates.totals.insurance);}
    $("#confirmationTotal").html("+ $"+cart.shipping.rates.totals.confirmation);
     var value = parseFloat(cart.shipping.rates.totals[shipType]);
     if(insured()) {value += parseFloat(cart.shipping.rates.totals.insurance);}
     if(dconf())   {value += parseFloat(cart.shipping.rates.totals.confirmation);}
     //Display Static Total/
      totalShip=value;    
     $(".staticShipTotal").html("$"+value.toFixed(2));
      }
    refreshTotal();
}catch(e){}
}

function insured()
{return $("#shipOptionInsure").is(":checked");}
function dconf()
{return $("#shipOptionSignature").is(":checked");}

function selfShipping(){
     $('.StaticShipping').html("3rd Party UPS");
}
