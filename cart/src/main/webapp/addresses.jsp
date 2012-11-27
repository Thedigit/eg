<%@page import="java.util.*"%>
<%@page import="egprint.*" %>
<%@include file="common.jsp"%>
<%@include file="checkLogin.jsp"%>
<%
// HashMap<String,String> activeCustomer = (HashMap<String,String>) session.getAttribute("activeCustomer");
 int orderCount = Integer.valueOf(Utilities.fetch2("SELECT COUNT(*) as `c` FROM egprint.address a WHERE a.customerId='"+activeCustomer.get("insideId")+"'").get(0).get("c"));
 session.setAttribute("orderCount",orderCount);

 String viewJobId = Utilities.get(request,"a");

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
  <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.0/themes/smoothness/jquery-ui.css" />
  <link rel="stylesheet" type="text/css" href="css/ui.spinner.css" />
  <link rel="stylesheet" type="text/css" href="css/jquery.ui.selectmenu.css" />
  <link rel="stylesheet" type="text/css" href="css/topMenu.css" />
  <link rel="stylesheet" type="text/css" href="css/leftPanel.css" />
  <link rel="stylesheet" type="text/css" href="css/rightPanel.css" />
  <link rel="stylesheet" type="text/css" href="css/addresses.css" />
  <link rel="stylesheet" type="text/css" href="css/checkout.css" />
  <link rel="stylesheet" type="text/css" href="css/register.css" />
  <script type="text/javascript" src="js/spinner.js"></script>
  <script type="text/javascript" src="js/jquery.ui.selectmenu.js"></script>

  <style type="text/css">



  </style>
  <script type="text/javascript">
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
                addObject.id=$("#id").val();
               var params = new Object();
               params.action = "updateAddress";
               params.addressObject=JSON.stringify(addObject);

               $.post("utils/",params,function(){document.location.reload(true);});

               }



      function close(){
              $("#messageDisplay").fadeOut();
              $("#mask").fadeOut(function(){$("#mask").fadeOut();});
      }

      /**
       * Load Mask
       * @param id
       */
      function details(id){

          $("#info").hide();
          $("#messageLdr").show();

          $(".Closer").unbind('click').click(function(){
              close();
          });

          $(".Overall").fadeIn();
          $("#messageDisplay").fadeIn();
          $("#messageDisplay").centerScreen();
        loadInfo(id);
      }

      function loadInfo(id){
         var params = new Object();
          params.action="loadAddress";
          params.id=id;
          var row = $("#address"+id);
          $("#companyField").val(row.find(".biz1").html());
          $("#contactField").val(row.find(".con1").html());
          $("#addressField").val(row.find(".add1").html());
          $("#cityField").val(row.find(".city1").html());
          $("#stateField").val(row.find(".state1").html());
          $("#zipField").val(row.find(".zip1").html());
          $("#id").val(id);
          $("#messageLdr").hide();
          $("#info").fadeIn();
      }

      $(document).ready(function() {
    jQuery.fn.centerScreen = function(loaded) {
        var obj = this;
        if(!loaded) {
            obj.css('top', $(window).height()/2-this.height()/2);
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
                  ).click(function(){details($(this).attr('address'));});

          $(".PDTable tr:even").find('td').addClass("OddRow");
          $(".ODTable tr:even").find('td').addClass("OddRow");
           $(".PDTable tr, .ODTable tr").hover(
                  function(){$(this).find('td').addClass("HighlightRow");},
                  function(){$(this).find('td').removeClass("HighlightRow");}
                  );


         
          $("#saveAddress").click(function(){submit();})
          $('.Required').each(function(){
              var req = $(document.createElement('span')).html("*").addClass("Required");
              $(this).parent().prev().append(req);

          });

          $(".cs").click(function(){alert("Coming Soon!");});
          //Disguise file upload button:
          $(".RealFile").fadeTo(0,'0');
          $(".RealFile").change(function(){
          $('#hideField_'+$(this).attr('key')).val($(this).val());});

          $(".UploadNew").click(function(){$(".FileSpace").slideDown();$(this).stop().css({backgroundColor:"#F00"})});
          $("#sendForm").click(function(){startUpload();})
          <%if (viewJobId!=null){%>
          details(<%=viewJobId%>);
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
        <span class="BCLight">Address Book</span>

        <span class="Logout2"><span class="BCDivider"> &lt; </span><a href="login?action=logout">Logout</a></span>

    </div>

    <div id="history" class="MAInfoDiv">
        <div class="Title2">
        <img src="images/MyAccount.png" alt=""> Address Book
        <span class="Pages">
            <%if(currentPage>1){%><a href="addresses.jsp?page=1"><img src="images/endArrow_L.gif" alt=""></a><%}else{%><img src="images/endArrow_L_disabled.gif" alt=""><%}%>
            <%if(currentPage>1){%><a href="addresses.jsp?page=<%=Math.max(1,currentPage-1)%>"><img src="images/singleArrow_L.gif" alt=""></a><%}else{%><img src="images/singleArrow_L_disabled.gif" alt=""><%}%>
            <%for(int i = Math.max(1,currentPage-displayable) ; i <= Math.min(totalPages,currentPage+displayable);i++){%> <a href="orders.jsp?page=<%=i%>" class="PageNumber <%if(i==currentPage){%>PageSelected<%}%>"><%=i%></a> <%}%>
            <%if(currentPage<totalPages){%><a href="addresses.jsp?page=<%=Math.min(totalPages,currentPage+1)%>"><img src="images/singleArrow_R.gif" alt=""></a><%}else{%><img src="images/singleArrow_R_disabled.gif" alt=""><%}%>
            <%if(currentPage<totalPages){%><a href="addresses.jsp?page=<%=totalPages%>"><a href="addresses.jsp?page=<%=totalPages%>"><img src="images/endArrow_R.gif" alt=""></a><%}else{%><img src="images/endArrow_R_disabled.gif" alt=""><%}%> </span>
        </div>

        <%
            String addQ = "SELECT a.* FROM egprint.address a WHERE a.customerId='"+activeCustomer.get("insideId")+"' ORDER BY a.Business LIMIT "+limit+" OFFSET "+offset;
            
            ArrayList<HashMap<String,String>> addresses = Utilities.fetch2(addQ);
            if (addresses==null){addresses= new ArrayList<HashMap<String,String>> ();}
        %>
        <table class="ListTable">
            <thead>
            <tr>
                <th></th>
                <th style="width:150px">Company</th>
                <th style="width:150px">Contact</th>
                <th>Address</th>
                <th></th>
            </tr>
            <tr><th class="Spacer"></th></tr>
            </thead>
            <tbody>
        <%for(HashMap<String,String> address:addresses){%>
            <tr id="address<%=address.get("id")%>" address="<%=address.get("id")%>">
                <td><img src="images/Search-icon-new.png" alt="" class="Details"></td>
                <td><span class="biz1"><%=address.get("Business")%></span></td>
                <td><span class="con1"><%=address.get("Contact")%></span></td>
                <td><span class="add1"><%=address.get("Address1")%></span>, <span class="city1"><%=address.get("City")%></span>, <span class="state1"><%=address.get("State")%></span><span class="zip1"><%=address.get("Zip")%></span></td>
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
   <div class='MessageTitle' id="messageTitle"></div>
   <div id="messageLdr">Loading <img src='images/ajax-loader.gif'></div>
   <div class="Close Closer"><img src='images/Button_X.png'></div>
      <div class="Message" id="message">
   <div id="info">
       <div id="updateAddress">
            <table align="left">
                <tr><td>Company: </td><td><input name="Business" id="companyField" class="NiceInput Required" value=""></td></tr>
                <tr><td>Contact: </td><td><input name="Contact" id="contactField" class="NiceInput Required" value=""></td></tr>
                <tr><td>Address: </td><td><input name="Address1" id="addressField" class="NiceInput Required" value=""></td></tr>
                <tr><td>City:    </td><td><input name="City"    id="cityField" class="NiceInput Required" value=""></td></tr>
                <tr><td>State:   </td><td><input name="State"   id="stateField" class="NiceInput Required" value="" fieldType="^[a-zA-Z]{2}$" format="2 Letter State: XX"></td></tr>
                <tr><td>Zip:     </td><td><input name="Zip"     id="zipField" class="NiceInput Required" value="" fieldType="^[0-9]{5}$" format="5 Digit Zip: xxxxx"></td></tr>
                <tr><td>Phone:   </td><td><input name="Phone"   id="phoneField" class="NiceInput Required" value="" fieldType="^[0-9]{3}-[0-9]{3}-[0-9]{4}$" format="10 Digit: xxx-xxx-xxxx"></td></tr>
                <tr><td>&nbsp;   </td><td></td></tr>
                <tr><td><span id="saveAddress" class="EditLink"><h2>Save</h2></span><input id="id" type="hidden" name="id" value="-1"></td><td><span id="cancelLink" class="EditLink Closer" ><h2>Cancel</h2></span></td></tr>

            </table>

            </div>
      </div>

   </div>
</div>
<div class="Overall" id="mask"></div>
</body>
</html>