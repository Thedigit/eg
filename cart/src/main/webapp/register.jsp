<%@ include file="common.jsp"%>
<%
session.setAttribute("tier","8");
session.setAttribute("serviceCompany","1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">






  <title>EGPRINT - Your Online Print Super Store</title>
<%@ include file="header.jsp"%>

<link rel="stylesheet" type="text/css" href="<%=base%>css/register.css" />
<link rel="stylesheet" type="text/css" href="<%=base%>css/jquery.ui.selectmenu.css" />
<link rel="stylesheet" type="text/css" href="<%=base%>css/jquery.qtip.css" />
<script type="text/javascript" src="<%=base%>js/spinner.js"></script>
  <script type="text/javascript" src="<%=base%>js/jquery.ui.selectmenu.js"></script>
  <script type="text/javascript" src="<%=base%>js/jquery.qtip.min.js"></script>

  <style type="text/css">
      html,body{margin:0;padding:0;}

      .Pointer{
          position:absolute;

      }

      .OrangeButton{
          height:18px;
          font: normal 11px sans-serif;
          border:solid 1px #FFF;
          background:#F63;
          color:#FFF;
      }
      .Body{
          margin:0 auto;
          width: 885px;
          border:1px solid;
      }

      .Top1,.BottomPanel{
          background:#666;
          color:#FFF;
          font: normal 14px sans-serif;
          width:885px;
          height:25px;
          line-height:22px;
      }

      a.TopMenuItem{
          margin:0 5px;
          color:#FFF;
          font: normal 11px sans-serif;
          text-decoration:none;
          line-height:22px;
      }
      a.TopMenuItem:hover{
          color:#F90;
      }

      div.TopMenuSearch{
          float:right;
          width:190px;
          height:25px;
          font: normal 11px sans-serif;
      }
      input.TopMenuSearch{
          border: 1px solid #E1E1E1;
          font: 11px sans-serif;
          height: 16px;
          margin: 0;
          padding: 0 0 0 5px;
          position: relative;
          top: -1px;
          width: 100px;
      }
      button.TopMenuSearch{
         margin:3px 0 0 0;
      }
      
      .RightPanel{
          width:715px;
          background:#FFF;
          float:right;
      }
          

      .BottomPanel{
          clear:both;
          text-align:center;
      }
      .BottomPanel2{
          background:#E1E1E1;
          color:#666;
          font: normal 10px sans-serif;
          width:885px;
          height:14px;
          line-height:14px;
          text-align:center;
      }


      body {font-size: 62.5%; font-family:"Verdana",sans-serif; }
  
  </style>
<link rel="stylesheet" href="register.css">

  <script>


      var pass;
      function submit(){
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
                        pass=false;
                        return false;
                    }
                  pass=true;
              }
          });
          if(!pass){return false;}
          //Specific fields
          //NO POBOXES allowed

          if($("input[name='Address']").val().match(/[pP][\.]{0,1}[oO][\.]{0,1}[ ]*[bB][oO][xX]/)){
              alert("P.O. Boxes Are Not Allowed");return false;
          }

          //Password check
          if($("#pwd1").val()!=$("#pwd2").val())
          {alert("Password verification failed. Passwords don't match");return false;}

          if($("#stateSelect").val()==""){
              alert("A valid state must be selected");return false;
          }

         $('#registrationForm').submit();

         }

      function init()
      {

          $(".Categories ul li").hover(function(){$(this).addClass("ItemHover");},function(){$(this).removeClass("ItemHover");})
          $(".CartItem").hover(function(){$(this).addClass("ItemHover");},function(){$(this).removeClass("ItemHover");})
          $(".CartItem").click(function(){var specs = $(this).next(); if(specs.is(":visible")){specs.slideUp()}else{specs.slideDown()} });
         
          $('.Required').each(function(){
              var req = $(document.createElement('span')).html("*").addClass("Required");
              $(this).parent().prev().append(req);

          });
          $('.RegDiv').each(function(){
              var title = $(document.createElement('div')).html($(this).attr('title')).addClass("RegDivTitle");
              $(this).prepend(title);

          })

          //Must be after the above lines in order to prevent double tagging.
          $(".MenuSelect").selectmenu();

          //Disguise taxId upload button:
          $("#taxId").fadeTo(0,'0');
          $("#taxId").change(function(){
              $('#taxIdField').val($(this).val());

          })
          $("#agree").change(function(){
              try{
              if($(this).is(":checked")){
                $("#proceedButton").removeClass("ProceedInactive");
                $("#proceedButton").addClass("ProceedActive");
                $("#proceedButton").unbind("click mouseenter mouseleave");
                $("#proceedButton").bind("click",function(){submit();});
                $("#proceedButton").hover(function(){$(this).toggleClass("ProceedHover");},function(){$(this).toggleClass("ProceedHover");});

              }else{
                $("#proceedButton").addClass("ProceedInactive");
                $("#proceedButton").removeClass("ProceedActive ProceedHover");
                $("#proceedButton").unbind("click mouseenter mouseleave");
              }
              }catch(e) {alert(e)}
          })

          $(".Qtip").qtip({
             position:{
                 my:"left center",
                 at:"right center",
                 target:$(".Qtip")
             } ,
              style: {
              		classes: 'ui-tooltip-blue ui-tooltip-shadow'
              	},
              hide:{
                  event:false
              }
          }).qtip('toggle',true);

      }

      $(document).ready(function(){init();});
  </script>
</head><body>

<div class="Body">

    <%@include file="topMenu.jsp"%>

    <%@include file="leftPanel.jsp"%>
    <div class="RightPanel">
          

        <!--register.css controls this section-->
        <div id="registration">
            <div id="breadCrumb">
                Create New Account
            </div>
            <div class="Title">
                Create New Account
            </div>
            <form method="POST" action="register/" id="registrationForm" onsubmit="" enctype="multipart/form-data" target="_self">
            <div class="RegDiv" title="Choose Login">
                <table>
                    <tr>
                        <td class="LeftField">Email</td>
                        <td><input class="Required NiceInput" name="Email" fieldType="^[a-zA-Z0-9_.]+@[a-zA-Z0-9_.]+\.[a-zA-Z]{2,3}$"></td>
                    </tr>
                    <tr>
                        <td class="LeftField">Password</td>
                        <td><input id="pwd1" type="Password" class="Required NiceInput" name="Password" fieldType="[^ ]*." format="At least one char required"></td>
                    </tr>
                    <tr>
                        <td class="LeftField">Confirm Password</td>
                        <td><input id="pwd2" type="Password" class="Required NiceInput" name="Password Confirmation" fieldType="[^ ]*." format="At least one char required"></td>
                    </tr>
                    <tr>
                        <td class="LeftField"><strong>Invitation Code</strong></td>
                        <td><input id="inv" type="text" class="NiceInput Qtip" name="invitationCode" fieldType="[^ ]*." format="At least one char required" title="If you were mailed an invitation code, you must enter it now to receive the advertised prices"></td>
                    </tr>
                </table>
            </div>

            <div class="RegDiv" title="Company Information">
                <table>
                    <tr>
                        <td class="LeftField">First Name</td>
                        <td><input class="Required NiceInput" name="First"></td>
                    </tr>
                    <tr>
                        <td class="LeftField">Last Name</td>
                        <td><input class="Required NiceInput" name="Last"></td>
                    </tr>
                    <tr>
                        <td class="LeftField">Company</td>
                        <td><input class="Required NiceInput" name="Company"></td>
                    </tr>
                    <tr>
                        <td class="LeftField">Phone</td>
                        <td>
                            <input class="Required NiceInput" name="Phone1" maxlength="3" style="width:30px" fieldType="^[0-9]{3}$" format="10 Digit: xxx-xxx-xxxx">
                            <input class="Required NiceInput" name="Phone2" maxlength="3" style="width:30px" fieldType="^[0-9]{3}$" format="10 Digit: xxx-xxx-xxxx">
                            <input class="Required NiceInput" name="Phone3" maxlength="4" style="width:40px" fieldType="^[0-9]{4}$" format="10 Digit: xxx-xxx-xxxx">

                            </td>
                    </tr>
                    <tr>
                        <td class="LeftField">Address</td>
                        <td><input class="Required NiceInput" name="Address"></td>
                    </tr>
                    <tr>
                    <tr>
                        <td class="LeftField">City</td>
                        <td><input class="Required NiceInput" name="City"></td>
                    </tr>
                    <tr>
                        <td class="LeftField">State</td>
                        <td>
                            <select class="Required MenuSelect" id="stateSelect" name="State" size="1">
                                <option selected value="">State...</option>
                                <option value="AL">Alabama</option>
                                <option value="AK">Alaska</option>
                                <option value="AZ">Arizona</option>
                                <option value="AR">Arkansas</option>
                                <option value="CA">California</option>
                                <option value="CO">Colorado</option>
                                <option value="CT">Connecticut</option>
                                <option value="DE">Delaware</option>
                                <option value="FL">Florida</option>
                                <option value="GA">Georgia</option>
                                <option value="HI">Hawaii</option>
                                <option value="ID">Idaho</option>
                                <option value="IL">Illinois</option>
                                <option value="IN">Indiana</option>
                                <option value="IA">Iowa</option>
                                <option value="KS">Kansas</option>
                                <option value="KY">Kentucky</option>
                                <option value="LA">Louisiana</option>
                                <option value="ME">Maine</option>
                                <option value="MD">Maryland</option>
                                <option value="MA">Massachusetts</option>
                                <option value="MI">Michigan</option>
                                <option value="MN">Minnesota</option>
                                <option value="MS">Mississippi</option>
                                <option value="MO">Missouri</option>
                                <option value="MT">Montana</option>
                                <option value="NE">Nebraska</option>
                                <option value="NV">Nevada</option>
                                <option value="NH">New Hampshire</option>
                                <option value="NJ">New Jersey</option>
                                <option value="NM">New Mexico</option>
                                <option value="NY">New York</option>
                                <option value="NC">North Carolina</option>
                                <option value="ND">North Dakota</option>
                                <option value="OH">Ohio</option>
                                <option value="OK">Oklahoma</option>
                                <option value="OR">Oregon</option>
                                <option value="PA">Pennsylvania</option>
                                <option value="RI">Rhode Island</option>
                                <option value="SC">South Carolina</option>
                                <option value="SD">South Dakota</option>
                                <option value="TN">Tennessee</option>
                                <option value="TX">Texas</option>
                                <option value="UT">Utah</option>
                                <option value="VT">Vermont</option>
                                <option value="VA">Virginia</option>
                                <option value="WA">Washington</option>
                                <option value="WV">West Virginia</option>
                                <option value="WI">Wisconsin</option>
                                <option value="WY">Wyoming</option>
                                </select>
                                </td>
                    </tr>
                    <tr>
                        <td class="LeftField">Zip Code</td>
                        <td><input class="Required NiceInput" name="Zip" fieldType="^[0-9]{5}$" format="5 Digit Zip: xxxxx"></td>
                    </tr>
                    <tr>
                        <td class="LeftField">How did you find us?</td>
                        <td>

                            <select class="MenuSelect" id="originSelect" name="Origin" size="1">
                                <option selected value="">Select Origin</option>
                                <option value="11000">Magazine</option>
                                <option value="21000">Google</option>
                                <option value="22000">Bing</option>
                                <option value="23000">Yahoo</option>
                                <option value="3">Direct Mailer</option>
                                <option value="1">Customer Referral</option>
                                <option value="0">Other</option>
                                </select>
                                </td>
                    </tr>
                    <!--
                    <tr>
                        <td class="LeftField">Tax ID</td>
                        <td style="position:absolute;"><input class="" readonly="" id='taxIdField' value="...Click Here To Upload...">
                            <span class="Tiny">Required for tax exempt customers</span>
                            <input type="file" id="taxId" name="taxId">
                        </td>
                    </tr>
                    -->
                    <input type="file" id="taxId" name="taxId" style="display:none">
                </table>
            </div>

            <div class="RegDiv" title="Agree to Terms & Conditions">
                By creating an account I acknowledge that I am an authorized representative for the above stated company, and hereby agree to the <a href="#">Terms & Conditions</a> for usage of this website.<br>
                <div id="proceedButton" class="ProceedInactive" onclick="submit()" >
                   &gt; AGREE
                </div>
            </div>
          </form>
        </div>

        
    </div>
    <%@include file="footer.jsp"%>

</div>

</body></html>