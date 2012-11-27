<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="egprint.Utilities" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.URLDecoder" %>
<%@include file="../common.jsp"%>
<%--
    //COMENTED CREDENTIALS ARE FOR TEST MODE _LENSAM69 Sandbox account.
	if(bSandbox){
    gv_APIUserName	= "lensam_1292364038_biz_api1.gmail.com";
	gv_APIPassword	= "1292364047";
	gv_APISignature = "AOg3.zs3avWdPA4NnXidS10zGKZjAWfA9VdD1KPKRfVmQ7AmZQTt8RN0";
    }
         --%>
<%
boolean sb=true;
//set PayPal Endpoint to sandbox
String url = "https://svcs.paypal.com/AdaptivePayments/Pay";
if(sb){ url = "https://svcs.sandbox.paypal.com/AdaptivePayments/Pay";}

/*
*******************************************************************
PayPal API Credentials
Replace API_USERNAME with your API Username
Replace API_PASSWORD with your API Password
Replace API_SIGNATURE with your Signature
*******************************************************************
*/

//PayPal API Credentials
    String API_UserName		    = "orders_api1.egprint.net";                       //TODO
    String API_Password		    = "2CF2JYHV8L9ASQAW";                                                 //TODO
    String API_Signature		= "AkGV2axXZhSuB0E5e7uZTYsivRrJAmyNoRm-yFCs84A6pd-NrmM.184f";   //TODO

    if (sb){
        API_UserName		    = "lensam_1292364038_biz_api1.gmail.com";
        API_Password		    = "1292364047";                                                       //TODO
        API_Signature		    = "AOg3.zs3avWdPA4NnXidS10zGKZjAWfA9VdD1KPKRfVmQ7AmZQTt8RN0";   //TODO
    }

//Default App ID for Sandbox
    String API_AppID			= "APP-8WM21116A3559234K";
    if (sb){ API_AppID			= "APP-80W284485P519543T"; }

//Request/Response Format
    String API_RequestFormat	= "NV";
    String API_ResponseFormat	= "NV";

//Transaction Parameters
    String receiver			    = "orders@egprint.net";                              //TODO
    if (sb){ receiver			= "rec1_1303245987_biz@yahoo.com";}                              //TODO
    String returnUrl			= activeCompany.optString("FullDomain","")+"/mini/success.jsp";                            //TODO
    if (sb){ returnUrl			= activeCompany.optString("UploadDomain","")+"/staging/mini/miniBillingControl.jsp?payKey=${payKey}";}                              //TODO
    String cancelUrl			= activeCompany.optString("FullDomain","")+"/mini/miniBilling.jsp";                            //TODO
    if (sb){ cancelUrl			= activeCompany.optString("UploadDomain","")+"/staging/mini/miniBilling.jsp";}                              //TODO
    String amount				= (String) session.getAttribute("miniTotal");                            //TODO
                           //TODO

//Create request payload with minimum required parameters
    String requestBody          =
                                "actionType" 						+"="+ "PAY" +
                                "&currencyCode" 					+"="+ "USD" +
                                "&receiverList.receiver(0).email" 	+"="+ receiver +
                                "&receiverList.receiver(0).amount" 	+"="+ amount +
                                "&returnUrl" 						+"="+ returnUrl +
                                "&cancelUrl" 						+"="+ cancelUrl +
                                "&requestEnvelope.errorLanguage" 	+"="+ "en_US";


//************************************
//**  Set up HTTP request to PayPal **
//************************************

    URL postURL = new URL( url );
	HttpURLConnection conn = (HttpURLConnection)postURL.openConnection();

	// Set connection parameters. We need to perform input and output,
	// so set both as true.
	conn.setDoInput (true);
	conn.setDoOutput (true);

    // Set Request type
    conn.setRequestMethod("POST");

    // Set request headers
    conn.setRequestProperty("X-PAYPAL-SECURITY-USERID"	    , API_UserName		 );
    conn.setRequestProperty("X-PAYPAL-SECURITY-SIGNATURE"	, API_Signature	     );
    conn.setRequestProperty("X-PAYPAL-SECURITY-PASSWORD"    , API_Password		 );
    conn.setRequestProperty("X-PAYPAL-APPLICATION-ID"		, API_AppID		     );
    conn.setRequestProperty("X-PAYPAL-REQUEST-DATA-FORMAT"	, API_RequestFormat  );
    conn.setRequestProperty("X-PAYPAL-RESPONSE-DATA-FORMAT"	, API_ResponseFormat );


    // Send data to PayPal.
    DataOutputStream output = new DataOutputStream( conn.getOutputStream());
    output.write(requestBody.getBytes("UTF-8"));
    output.flush();
    output.close ();

    // Read input from the input stream.
    String payPalresponse = "";
    DataInputStream in = new DataInputStream (conn.getInputStream());
    int rc = conn.getResponseCode();
    if ( rc != -1)
    {
        BufferedReader is = new BufferedReader(new InputStreamReader( conn.getInputStream()));
        String _line = null;
        while(((_line = is.readLine()) !=null))
        {
            payPalresponse += _line;
        }
    }

    //Parse the ap key from the response
    //Display the Paypal response
    Utilities.log("Response from PayPal: \n\n");
    HashMap<String,String> responseParameters = new HashMap<String, String>();
	String[] responseParts = payPalresponse.split("&");
    for(String part: responseParts){
        String[] nameValue = part.split("=");
        responseParameters.put(nameValue[0],URLDecoder.decode(nameValue[1],"UTF-8"));
        Utilities.log(nameValue[0]+" = "+URLDecoder.decode(nameValue[1],"UTF-8"));
    }


//************************************
//**  Analyze response and redirect **
//**        user to PayPal          **
//************************************

    //Check to see if the request was sucessful.
    if (responseParameters.get("responseEnvelope.ack").equalsIgnoreCase("Success")){

        String payKey = responseParameters.get("payKey");

        session.setAttribute("payKey",payKey);
        Utilities.log("Transaction Created."+responseParameters.get("payKey"));
		Utilities.log("CorrId:   " +  responseParameters.get("responseEnvelope.correlationId") );
		Utilities.log("Timestamp:   " +  responseParameters.get("responseEnvelope.timestamp") );
        //Set url to approve the transaction


        String payPalURL = "https://www.paypal.com/webapps/adaptivepayment/flow/pay?paykey=" + payKey;
        if (sb){ payPalURL = "https://www.sandbox.paypal.com/webapps/adaptivepayment/flow/pay?paykey=" + payKey;}

	    response.sendRedirect(payPalURL);
	    return;


	}
	else {
		Utilities.log("CorrId:   " +  responseParameters.get("responseEnvelope.correlationId") );
		Utilities.log("Timestamp:   " +  responseParameters.get("responseEnvelope.timestamp") );
		Utilities.log("ERROR Code:   " +  responseParameters.get("error(0).errorId") );
		Utilities.log("ERROR Message:" +  responseParameters.get("error(0).message") );
	}
%>
<html>
<head>
    <style type="text/css">
        body,html{
            background:#fff;
        }
    </style>
</head>
<body>
<h2>
    An error has occurred
</h2>
<div>
    You <strong>HAVE NOT</strong> been billed. Your order has not been placed. Please reload this page to try again. If this problem persists, please contact customer service.
</div>
</body>
</html>