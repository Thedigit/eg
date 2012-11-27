<%@page import="java.util.ArrayList"%>
<%@include file="common.jsp"%>
<%


 String templateId = (String) request.getAttribute("templateName");
    if(templateId==null){templateId="";}
 String title   = "Page not found";
 String content = "Sorry, we couldn't find the page you were looking for";
 String companyCode= (String) session.getAttribute("serviceCompany");
 ArrayList<HashMap<String,String>> templates = Utilities.fetch3("SELECT * FROM enterprise.templatePages t WHERE t.shortname='"+templateId+"' AND t.Active='1' AND t.HardLink='1' AND t.Company='"+companyCode+"'");

 if(!templateId.equals("-1")&&templates.size()==1){
   HashMap<String,String> template = templates.get(0);
   title = template.get("Name");
   content = template.get("Content");
 }
    else{
     //404
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
  <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/themes/smoothness/jquery-ui.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/ui.spinner.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/jquery.ui.selectmenu.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/topMenu.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/leftPanel.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/rightPanel.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/myAccount.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/register.css" />
  <link rel="stylesheet" type="text/css" href="<%=base%>css/templates.css" />
  <script type="text/javascript" src="<%=base%>js/spinner.js"></script>
  <script type="text/javascript" src="<%=base%>js/jquery.ui.selectmenu.js"></script>

  <style type="text/css">

  #ppAdd{
      margin:10px auto;
      width:120px;
      height:160px;
      background:url("images/home/EG-home_09.jpg");
  }

  #rotateBanner{
      /*background:url("http://d2c6jpv0fksi04.cloudfront.net/images/banner/banner.jpg");*/
      background:url("images/banner/banner.jpg");
      position:relative;
      height:226px;
      width:713px;
  }

      .BannerControls{
          position:absolute;
          bottom:5px;
          right:30px;
          height:20px;
          width:70px;
          background:url("images/50-black.png");
      }

      .BannerButton{
          cursor:pointer;
      }

  </style>
  <script>

      var currentPosition=0;
      var totalAds=3;
      var direction=0;
      var bannerWidth=713;
      var intervalTimer;
      function rotateBanner(){
      if (currentPosition<=0){currentPosition=0; direction=1;}
      if (currentPosition>=totalAds-1){currentPosition=totalAds-1;direction=-1;}
          currentPosition=currentPosition+direction;
          animateBanner();
      }

      function forcePosition(position)
      {
        currentPosition=position;
        clearInterval(intervalTimer);
        animateBanner()
        intervalTimer= setInterval("rotateBanner();",5000);

      }

      function animateBanner(){
          if($.browser.msie){
          $("#rotateBanner").stop().animate({backgroundPosition:currentPosition*bannerWidth+", 0"},1500);}

          else{$("#rotateBanner").stop().animate({backgroundPosition:currentPosition*bannerWidth+"px, 0px"},1500);}

              $(".BannerButton").attr('src',"images/banner/empty.png");
          $("#bannerButton"+currentPosition).attr('src',"images/banner/Full.png");
          $("#rotateBanner").unbind('click').click(function(){document.location=$("#bannerButton"+currentPosition).attr('page');});
      }

      function init()
      {
          //Equalize column width
          //equalize();
          $(".LeftPanel").height(Math.max($(".RightPanel").height(),600));
          $(".Categories ul li").hover(function(){$(this).addClass("ItemHover");},function(){$(this).removeClass("ItemHover");})

          //PreLoad Shopping Cart button Images
          $("<img id='loaderImg' src='images/addtocart-dark.jpg' onload=''/>");
          $("<img id='loaderImg' src='images/addtocart.jpg' onload=''/>");

          //BANNER CONTROLS
         // $(".LeftPanel,.RightPanel").css({height:"1000px"});


      }
      var noEqualize=false;
      $(document).ready(function(){init();});
  </script>
</head>
<body>

<div class="Body">
    <%@include file="topMenu.jsp"%>
    <%@include file="leftPanel.jsp"%>
    <div class="RightPanel" style="">


          <div style="margin:10px;text-align:center;">
          <h3><%=title%></h3>
          <div><%=content%></div>    
          </div>


    </div>
    <%@include file="footer.jsp"%>
</div>

</body>
</html>

<%!



     public String readURLConnection(java.net.URLConnection uc) throws Exception {
        StringBuffer buffer = new StringBuffer();
        java.io.BufferedReader reader = null;
        try {
            reader = new java.io.BufferedReader(new java.io.InputStreamReader(uc.getInputStream()));
            int letter = 0;
            while ((letter = reader.read()) != -1) {
                buffer.append((char) letter);
            }
            reader.close();
        } catch (Exception e) {
           // System.out.println("Could not read from UPS URL: " + e.toString());
            throw e;
        } finally {
            if (reader != null) {
                reader.close();
                reader = null;
            }
        }
        return buffer.toString();
    }

%>