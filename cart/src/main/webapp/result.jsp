<%@ page import="egprint.Utilities" %>
<%@ include file="common.jsp"%>
<%
String msg = (String) session.getAttribute("message");
    if (msg==null){msg="";}
String msgCode = Utilities.get(request,"msg","0");
    if (msgCode.equals("0"))
    {}
    else if (msgCode.equals("1"))
    {
        msg+= " Your session has ended due to inactivity. Please log in again<br><a href='login.jsp'>Account Login</a>";
    }
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">






  <title>EGPRINT - Your Online Print Super Store</title>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/jquery-ui.min.js"></script>

  <script type="text/javascript" src="JSON.js"></script>
  <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/themes/smoothness/jquery-ui.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/ui.spinner.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/jquery.ui.selectmenu.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/register.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/leftPanel.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/topMenu.css" />
  <script type="text/javascript" src="<%=base%>js/spinner.js"></script>
  <script type="text/javascript" src="<%=base%>js/jquery.ui.selectmenu.js"></script>

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

      noLogout=true;
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
                        return false;
                    }
                  pass=true;
              }
          });
          if(!pass){return false;}
          //Specific fields
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

          })
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
           
            <div class="RegDiv" title="Message:">
               <%=msg%>
            </div>

        </div>
    </div>
    <%@include file="footer.jsp"%>

</div>

</body></html>