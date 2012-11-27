<%@page import="java.util.*" %>

<title><%=pageTitle%>EGPRINT - Your Online Print Super Store</title>

<%
    /**
     * Include this file in the HEAD of the products pages. It will load all meta-tags for the specified category
     */
%>
<!--Default Tags-->
<%
    if (catId != null) {
%>
<!--Facebook Speficic Tag-->
<meta property="og:type" content="website"/>
<meta property="og:url" content="<%=request.getScheme() + "://" + request.getServerName()+request.getAttribute("javax.servlet.forward.request_uri")%>"/>

<!--Google+ Open Graph data-->
<meta property="og:title" content="<%=pageTitle%>EGPRINT - Your Online Print Super Store" />
<meta property="og:image" content="<%=request.getScheme() + "://" + request.getServerName()%>/static/products/<%=catName%>.jpg" />
<meta property="og:description" content="<%=pageTitle%> Products - By EGPrint.net. Your online print superstore. Printing specialists since 1978. No project too big, no project too small; we can handle all your printing needs with our state of the art equipment." />
<!--Generic default image for this page-->
<link rel="image_src" href="/static/products/<%=catName%>.jpg"/>

<!--Custom Tags-->
<%
    ArrayList<HashMap<String, String>> metaTags = Utilities.fetch3("SELECT * FROM enterprise.category_meta_tags c WHERE c.category='" + catId + "' ORDER BY c.id");
    for (HashMap<String, String> tag : metaTags) {
%>
<meta name="<%=tag.get("name")%>" content="<%=tag.get("content")%>"/>
<%
        }
    }
%>

<!--FAVICON-->
<link rel="shortcut icon" href="<%=base%>images/egprint.ico">

<!--JQUERY and related scripts-->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.19/jquery-ui.min.js"></script>
<script type="text/javascript" src="<%=base%>js/JSON.js"></script>
<link rel="stylesheet" type="text/css" href="<%=base%>css/topMenu.css"/>
<link rel="stylesheet" type="text/css" href="<%=base%>css/leftPanel.css"/>
<link rel="stylesheet" type="text/css" href="<%=base%>css/rightPanel.css"/>
<link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.19/themes/smoothness/jquery-ui.css"/>

<!--Domain hints-->
<script type="text/javascript">
    var uploadDomain="<%=activeCompany.optString("UploadDomain","")%>";
    var fullDomain="<%=activeCompany.optString("FullDomain","")%>";
</script>