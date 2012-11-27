<%
    //Determine if we are in the staging environment
    boolean staging = request.getContextPath().toLowerCase().contains("stag");

    //Determine the company
    JSONObject activeCompany = Utilities.determineCompany(request);
        session.setAttribute("activeCompany",activeCompany);
        session.setAttribute("serviceCompany",activeCompany.optString("Alias","1"));
        System.out.println(activeCompany+" "+((String)session.getAttribute("serviceCompany")));

        //Redirect to http
    String URL=request.getRequestURL().toString();
    if(session.getAttribute("securePage")==null){
    if(URL.startsWith("https")){
           URL= "http"+URL.split("https")[1];
           response.sendRedirect(URL);
           return;
       }

            //Redirect to www
    if(!staging&&!URL.startsWith("http://www")){
           URL= "http://www."+URL.split("http://")[1];
           response.sendRedirect(URL);
           return;
       }
    }
    else{
           if(URL.startsWith("http:")){
               URL= "https"+URL.split("http")[1];
               response.sendRedirect(URL);
               return;
           }
    }

    //Determine the user
    HashMap<String,String> activeCustomer = (HashMap<String,String>) session.getAttribute("activeCustomer");
    String base = pageContext.getServletContext().getContextPath()+"/";
    String getURL=request.getRequestURL().toString();
    String catId = (String) session.getAttribute("categoryId");
    String catName = "default.jpg"; //Catchall
    HashMap<String,String> category =null;
    if (catId!=null) {
        category =  Utilities.fetch2("SELECT c.* FROM egprint.category c WHERE c.id='"+catId+"'").get(0);
        catName = category.get("Description").replaceAll(" ","");
    }
    JSONObject cart=( org.json.JSONObject)session.getAttribute("shoppingCart");

    //Page specifics
    String pageTitle = "";
%>