<%@ page import="egprint.Utilities" %>
<%@include file="common.jsp"%>
<%


 String email = Utilities.getCookie(request,"e","");
 String pwd   = Utilities.getCookie(request,"p","");
 boolean remember = !email.equals("");

    /*
  if(session.getAttribute("autoLogin")!=null){
     session.removeAttribute("autoLogin");
     if(egprint.cart.LoginServlet.doLogin(request,response,email,pwd,false)){
         return;
     }
 }    */

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  <title>Sign in to your account - EGPRINT - Your Online Print Super Store</title>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/jquery-ui.min.js"></script>

  <script type="text/javascript" src="JSON.js"></script>
  <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/themes/smoothness/jquery-ui.css" />
  <link rel="stylesheet" type="text/css" href="css/ui.spinner.css" />
  <link rel="stylesheet" type="text/css" href="css/jquery.ui.selectmenu.css" />
  <link rel="stylesheet" type="text/css" href="css/register.css" />
  <link rel="stylesheet" type="text/css" href="css/leftPanel.css" />
  <link rel="stylesheet" type="text/css" href="css/topMenu.css" />
  <script type="text/javascript" src="js/spinner.js"></script>
  <script type="text/javascript" src="js/jquery.ui.selectmenu.js"></script>

  <style type="text/css">
     


      body,html{margin:0;padding:0;}
      body {font-size: 62.5%; font-family:"Verdana",sans-serif;}

      .LoginButtonActive{
          background:url("images/login02.png");
          width:60px;
          height:21px;
          cursor:pointer;
      }
      .LoginButton{
          background:url("images/login01.png");
          width:60px;
          height:21px;
      }
      .ForgotPasswordActive{
          background:url("images/retrieve02.png");
          width:149px;
          height:21px;
          cursor:pointer;
      }
      .ForgotPassword{
          background:url("images/retrieve01.png");
          width:149px;
          height:21px;
      }
      .RegisterButtonActive{
          background:url("images/create02.png");
          width:126px;
          height:21px;
          cursor:pointer;
      }
      .RegisterButton{
          background:url("images/create01.png");
          width:126px;
          height:21px;
      }
      .RegLeft{
          width:420px;
          height:600px;
          float:left;
      }
      .RegRight{
          margin:17px 0 0 0;
          width:294px;
          height:600px;
          float:right;
      }
  </style>


  <script>


      function init()
      {


         

          $('.Required').each(function(){
              var req = $(document.createElement('span')).html("*").addClass("Required");
              $(this).parent().prev().append(req);

          })
          $('.RegDiv').each(function(){
              var title = $(document.createElement('div')).html($(this).attr('title')).addClass("RegDivTitle");
              $(this).prepend(title);

          });

          $("#loginButton").hover(function(){$(this).removeClass("LoginButton");},function(){$(this).addClass("LoginButton");})
          $("#forgotPassword").hover(function(){$(this).removeClass("ForgotPassword");},function(){$(this).addClass("ForgotPassword");})
          $("#registerButton").hover(function(){$(this).removeClass("RegisterButton");},function(){$(this).addClass("RegisterButton");})


      }

      $(document).ready(function(){init();});
  </script>
</head><body>

<div class="Body">

    <%@include file="topMenu.jsp"%>
   
    <%@include file="leftPanel.jsp"%>
    <div class="RightPanel">
          

        <!--register.css controls this section-->
        <div class="RegLeft" >
            <div id="registration">
                <div id="breadCrumb">
                    Create New Account
                </div>
                <div class="Title">
                    Login to your account
                </div>
                <div class="RegDiv" title="">
                    <form action="login" method="POST" id="loginForm">
                        <input type="hidden" name="action" value="login">
                    <table>
                        <tr>
                            <td class="LeftField">Email</td>
                            <td><input class="Required NiceInput" name="Email" value="<%=email%>" fieldType="^[a-zA-Z0-9_.]+@[a-zA-Z0-9_.]+\.[a-zA-Z]{2,3}$"></td>
                        </tr>
                        <tr>
                            <td class="LeftField ">Password</td>
                            <td><input type="Password" class="Required NiceInput" name="pwd" value="<%=pwd%>"fieldType="[^ ]*." format="At least one char required"></td>
                        </tr>
                        <tr>
                            <td class="LeftField "><input type="checkbox" class="" name="rememberMe" id="rememberMe" <%=remember?"checked=''":""%> ><label for="rememberMe"> Remember Me</label></td>
                            <td></td>
                        </tr>

                    </table>
                    <div id="loginButton" class="LoginButton LoginButtonActive" onclick="$('#loginForm').submit();">

                    </div>
                    </form>
                </div>
                <div class="Title">
                    Forgot your password?
                </div>
                <div class="RegDiv" title="">
                    <form action="<%=base%>utils/" method="POST" id="retrieveForm">
                    <table>
                        <tr>
                            <td class="LeftField">Email</td>
                            <td><input class="Required NiceInput" name="email" fieldType="^[a-zA-Z0-9_.]+@[a-zA-Z0-9_.]+\.[a-zA-Z]{2,3}$"><input type="hidden" name="action" value="retrievePass"></td>
                        </tr>

                    </table>
                    <div id="forgotPassword" class="ForgotPassword ForgotPasswordActive " onclick="$('#retrieveForm')[0].submit();"></div>
                    </form>
                </div>

                <div class="Title">
                    Create New Account
                </div>
                <div class="RegDiv" title="">
                    <table>
                        <tr>
                            <td class="LeftField">Email</td>
                            <td><input class="Required NiceInput" name="Email" fieldType="^[a-zA-Z0-9_.]+@[a-zA-Z0-9_.]+\.[a-zA-Z]{2,3}$"> </td>
                        </tr>

                    </table>
                    <div id="registerButton" class="RegisterButton RegisterButtonActive" onclick="document.location='register.jsp'">

                    </div>
                </div>
            </div>
        </div>
        <div class="RegRight">
            <img src="http://d2c6jpv0fksi04.cloudfront.net/images/login_m.png" alt="">
        </div>
        
    </div>
    <%@include file="footer.jsp"%>

</div>

</body></html>