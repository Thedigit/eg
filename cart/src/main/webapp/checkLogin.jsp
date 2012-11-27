<%
    System.out.println("Checking Log In...");
    activeCustomer = (HashMap<String,String>) session.getAttribute("activeCustomer");
if (activeCustomer==null)
{
    System.out.println("Not LoggedIn!");
    System.out.println("url "+getURL);
    if(getURL.endsWith("/")){ session.setAttribute("categoryId",null);response.sendRedirect("home.jsp");return;}

    String user = Utilities.getCookie(request,"e","");
    String pass   = Utilities.getCookie(request,"p","");
    System.out.println("Saved Credentials :"+user+" "+pass);
    boolean remember = !user.equals("");

    response.sendRedirect("login.jsp");return;
    /*
    if(!remember){response.sendRedirect("login.jsp");return;}

    else{
       egprint.cart.LoginServlet.doLogin(request,response,user,pass,false);
    } */
}
 else{ //reload customer based on ID to get any refresh.
      activeCustomer = Utilities.fetch2("SELECT c.*,a.* FROM egprint.customer c,egprint.address a WHERE c.insideId=a.customerId AND a.Default=1 AND c.insideId='"+activeCustomer.get("insideId")+"'").get(0); 
}
     
%>