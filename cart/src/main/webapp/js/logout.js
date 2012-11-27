/**
 * Created by IntelliJ IDEA.
 * User: Administrator
 * Date: Apr 2, 2011
 * Time: 7:07:05 PM
 * To change this template use File | Settings | File Templates.
 */
function redirectToExpired()
{
    document.location="result.jsp?msg=1";
}

if(typeof noLogout == "undefined" || !noLogout)
{
    setTimeout("alert('Your session will expire soon due to inactivity')",1200000);
    setTimeout("redirectToExpired()",1800000);
}