<%@ page import="java.util.*"%>
<%@ page import="egprint.Utilities" %>
<%@ page import="java.net.URL" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.net.URLConnection" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.io.IOException" %>
<%@ include file="common.jsp"%>
<%

 if(!getURL.startsWith("http:"))
 {response.sendRedirect("http://"+getURL.split("//")[1]);return;}

if(activeCustomer==null){
      log(request,response); //Log Visitor
 }

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>EGPRINT - Your Online Print Super Store</title>
    <%@ include file="header.jsp"%>

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
        
          $(".ListTable tr").hover(
                  function(){$(this).find('td').addClass("HighlightRow");},
                  function(){$(this).find('td').removeClass("HighlightRow");}
                  );

          //PreLoad Shopping Cart button Images
          $("<img id='loaderImg' src='images/addtocart-dark.jpg' onload=''/>");
          $("<img id='loaderImg' src='images/addtocart.jpg' onload=''/>");

          //BANNER CONTROLS
          $("<img id='loadBanner' src='http://d2c6jpv0fksi04.cloudfront.net/images/banner/banner.jpg'/>").load(function(){
             intervalTimer= setInterval("rotateBanner();",5000);
          });
          $(".BannerButton").click(function(event){forcePosition($(this).attr("current"));event.stopPropagation();});
          $(".LeftPanel,.RightPanel").css({height:"1000px"});


      }
      var noEqualize=true;
      $(document).ready(function(){init();});
  </script>

</head>
<body>

<div class="Body">
    <%@include file="topMenu.jsp"%>

    <%@include file="leftPanel.jsp"%>
    <div class="RightPanel" style="height:1000px;">


          <div style="text-align:center;">
        <a href="login.jsp"><img src="images/home/EG-home_03.jpg" alt="" style="border:none;"></a><br>
        <a href="products/BusinessCards"><img src="images/home/EG-home_05.jpg" alt="" style="border:none;"></a><br>
        <div id="rotateBanner">
            <%
            Properties bannerProps = new Properties();
                try {
                    bannerProps.load(application.getResourceAsStream("/images/banner/bannerLinks.txt"));
                } catch (IOException e) {
                    e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                }
            %>
            <div class="BannerControls">
                <img id="bannerButton0" current="0" class="BannerButton" src="images/banner/Full.png" alt="" page=" products/<%=bannerProps.getProperty("link0","BusinessCards")%>" >
                <img id="bannerButton1" current="1" class="BannerButton" src="images/banner/empty.png" alt="" page="products/<%=bannerProps.getProperty("link1","BusinessCards")%>" >
                <img id="bannerButton2" current="2" class="BannerButton" src="images/banner/empty.png" alt="" page="products/<%=bannerProps.getProperty("link2","BusinessCards")%>" >

            </div>
        </div>
       
        <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
                <td><a href="register.jsp"><img src="images/home/EG-home_12.jpg" alt="" style="border:none;"></a></td>
                <td><a href="<%=base%>pages/templates"><img src="images/home/EG-home_13.jpg" alt="" style="border:none;"></a></td>
                <td><a href="http://www.egprint.net/Sample-Request_ep_30.html"><img src="images/home/EG-home_14.jpg" alt="" style="border:none;"></a></td>
            </tr>
        </table>
        <a href="products/Banners"><img src="images/home/EG-home_16.jpg" alt="" style="border:none;"></a><br>
        <a ><img src="images/home/EG-home_20.jpg" alt="" style="border:none;"></a><br>

        </div>

    </div>
     <%@include file="footer.jsp"%>

</div>

</body>
</html>

<%!

    public void log(HttpServletRequest request, HttpServletResponse response){
         try {
            final String ip = request.getRemoteAddr();
            Thread t = new Thread(){
                public void run(){ try{
                    String city = "Unknown";
                    String state ="Unknown";
                    String latitude = "Unknown";
                    String longitude ="Unknown";
                    try{
                    //Get City and State, based on IP
                    java.net.URL getAddr = new java.net.URL("http://www.geoplugin.net/json.gp?ip="+ip);
                   String l = readURLConnection(getAddr.openConnection());
                   l=l.substring(10,l.length()-1);
                  //  System.out.println(ip+"\n"+l);
                    org.json.JSONObject info = new org.json.JSONObject(l);
                    city = info.getString("geoplugin_city");
                    state = info.getString("geoplugin_region");


                    } catch (Exception eee){}

                   //Get Latitude, and Longitude for usage with Google maps.
                    try{
                     java.net.URL getAddr = new java.net.URL("http://maps.googleapis.com/maps/api/geocode/json?address="+city.replaceAll(" ","+")+","+state+"&sensor=false");
                    String l = readURLConnection(getAddr.openConnection());
                    //l=l.substring(10,l.length()-1);
                    //System.out.println(ip+"\n"+l);
                    org.json.JSONObject info = new org.json.JSONObject(l);
                    org.json.JSONObject loc = info.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location");
                    latitude  = loc.getString("lat");
                    longitude = loc.getString("lng");


                   }
                   catch(Exception eee) {eee.printStackTrace();}
                Utilities.executeStatement("INSERT INTO egdeal.log (`time`,`ip`,`city`,`state`,`Latitude`,`Longitude`) values (NOW(),'"+ip+"','"+city+"','"+state+"','"+latitude+"','"+longitude+"')");
                }
                catch(Exception ee){ee.printStackTrace();}
                }
            };
            t.start();
        }
        catch (Exception e){e.printStackTrace();}
    }

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