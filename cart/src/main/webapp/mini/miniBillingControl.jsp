<%@ page import="org.json.*,java.util.*,egprint.*" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="egprint.Utilities" %>
<%@ page import="egprint.cart.CartUtilities" %>
<%@ page import="egprint.mail.EmailMessage" %>
<%@ page import="egprint.mail.Mailman" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="egprint.quickbooks.QuickBooksUtils" %>
<%@ page import="java.math.BigInteger" %>
<%@ page import="javax.net.ssl.HttpsURLConnection" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONException" %>
<%
    HashMap<String, String> activeCustomer = (HashMap<String, String>) session.getAttribute("activeCustomer");
    String miniTotal = (String) session.getAttribute("miniTotal");
    response.setContentType("application/json");
    String callback = Utilities.get(request, "callback");
    JSONObject retVar = new JSONObject();

    JSONObject cart = (org.json.JSONObject) session.getAttribute("shoppingCart");
    System.out.println("Cart at upload: \n" + cart);
    if (cart == null) {
        Utilities.log("Session expired at checkout, or ilegal access. Probably expired.");
        retVar.put("status", "failed");
        retVar.put("error", "Unable to continue. Your session has expired.");
        session.setAttribute("result",retVar);
            response.sendRedirect("success.jsp");
        return;
    }

    boolean accepted = false;
    boolean paid = false;
    String terms = (Utilities.get(request, "terms", ""));
    String savedPk = (String) session.getAttribute("payKey");
    String incomingPk = Utilities.get(request, "payKey");
    String type = "Luna Paypal", method = "Paypal", note = "";

    if (incomingPk != null) {
        boolean valid = ((savedPk != null) && (incomingPk != null) && (savedPk.equalsIgnoreCase(incomingPk)));

        if (valid) {
        //Immediately remove saved paykey in order to avoid double dipping
            session.setAttribute("payKey", null);
             method = "Paypal";
        type = "Luna Paypal";
        accepted = true;
        paid = true;
        }
       } else if (terms.equals("terms")) //Terms customer.
    {
        if (activeCustomer.get("Terms").equals("3")) {
            method = "Terms";
            type = "Terms Account";
            accepted = true;
            paid = false;
        } else {
            session.setAttribute("message", "Your request was declined :-(<br>Reason:<br>You are not a terms customer<br><a href='checkout3.jsp'>Click here to try again</a>");
            Utilities.log("Customer tried to fake terms: " + activeCustomer.get("Customer") + "\n");
            retVar.put("status", "failed");
            retVar.put("error", "Your current terms are COD. Please choose another payment method or contact customer service");
            session.setAttribute("result",retVar);
            response.sendRedirect("success.jsp");
            return;
        }
    } else //CREDIT CARD TX!
    {
        JSONObject data = new JSONObject();
        data.put("ssl_amount", miniTotal);
        data.put("ssl_test_mode", "TRUE");
        data.put("ssl_merchant_id", "541844");
        data.put("ssl_user_id", "web");
        data.put("ssl_pin", "V1B8K5");
        data.put("ssl_show_form", "false");
        data.put("ssl_transaction_type", "ccsale");
        data.put("ssl_invoice_number", "123-ABC");
        data.put("ssl_email", activeCustomer.get("Login"));
        data.put("ssl_cvv2cvc2_indicator", "1");
        data.put("ssl_result_format", "ASCII");
        data.put("ssl_receipt_decl_method", "POST");
        data.put("ssl_receipt_decl_post_url", "http://upload.egprint.net/checkout3.jsp");
        data.put("ssl_receipt_apprvl_method", "GET");
        data.put("ssl_receipt_apprvl_get_url", "http://upload.egprint.net/checkout3.jsp");
        data.put("ssl_receipt_link_text", "Continue");
        Enumeration<String> e = request.getParameterNames();
        System.out.println("Parameters:");
        while (e.hasMoreElements()) {
            String param = e.nextElement();

            System.out.println(param + " = " + Utilities.get(request, param, "NULL"));
            data.put(param, Utilities.get(request, param, ""));
        }
        data.put("ssl_exp_date", data.getString("ssl_exp_date_M") + data.getString("ssl_exp_date_Y"));
        HashMap<String, String> ret = new HashMap<String, String>();
        if (!Utilities.get(request, "ssl_card_number").equals("skipskip")) {
            ret = novahttpcall(data);
        }
        if (!Utilities.get(request, "ssl_card_number").equals("skipskip")) {
            if (ret.containsKey("errorCode") || !ret.get("ssl_result").equals("0")) {

                session.setAttribute("message", "Your payment was declined :-(<br>Reason:<br>" + ret.get("errorMessage") + "<a href='#' onclick='document.location.reload(true)'>Click here to try again</a>");
                Utilities.log("Credit card declined for: " + activeCustomer.get("Customer") + "\n reason: " + ret.get("errorMessage"));
                retVar.put("status", "failed");
                retVar.put("error", "Your payment was declined :-(<br>Reason:<br>" + ret.get("errorMessage") + "<a href='checkout3.jsp'>Click here to try again</a>");
                response.getWriter().print(callback + "(" + retVar.toString() + ")");
                return;
            }
        }

        if (Utilities.get(request, "ssl_card_number").equals("skipskip")) {
            ret.put("ssl_card_number", "4SKIPPED!!!");
        }
        System.out.println(Utilities.h2j(ret));
        method = "CC";
        type = "Luna Amex";
        if (ret.get("ssl_card_number").startsWith("3")) {
            type = "Luna Amex";
        }
        if (ret.get("ssl_card_number").startsWith("4")) {
            type = "Luna Visa";
        }
        if (ret.get("ssl_card_number").startsWith("5")) {
            type = "Luna MC";
        }
        if (ret.get("ssl_card_number").startsWith("6")) {
            type = "LUNA DISCOVER";
        }
        paid = true;
        accepted = true;
        note = ret.get("ssl_card_number");
    }

    double totalPayment = Double.valueOf(miniTotal);

    //If we already have an invoice to apply this payment to, use it.
    JSONObject invoice = (JSONObject) session.getAttribute("miniInvoice");
    if(invoice==null){ //Otherwise create a new blank invoice.
    invoice = Utilities.createInvoiceNumber(activeCustomer.get("insideId"));
    }
    int pcode = -1;
    if (paid) {
        String ccQuery = "INSERT INTO egprint.Payments (`Method`,`Type`,`Amount`,`Date`,`ProcessedBy`,`Notes`) VALUES ('" + method + "','" + type + "','" + Utilities.money(totalPayment + "") + "',NOW(),'0','" + note + "')";
        pcode = Utilities.executeStatement(ccQuery);
        Utilities.log("Payment Query (" + pcode + ") \n" + ccQuery);

        ccQuery = "INSERT INTO egprint.PaymentApplied (`Payment`,`Invoice`,`Amount`) VALUES ('" + pcode + "','" + invoice.getString("id") + "','" + Utilities.money(totalPayment + "") + "')";
        Utilities.log("PaymentApplied insertion Query ->\n" + ccQuery);
        Utilities.executeStatement(ccQuery);
    }


    session.setAttribute("type",type);
    session.setAttribute("method",method);
    session.setAttribute("note",note);
    session.setAttribute("invoice",invoice);
    session.setAttribute("pcode",pcode);
    session.setAttribute("billed", true);
    session.setAttribute("totalPayment", totalPayment+"");
    Utilities.log("SHOPPING CART \n" + cart.toString());

    retVar.put("status", "success");
    retVar.put("redirect", session.getAttribute("redirectOnSuccess"));
    retVar.put("error", "<table style='margin:auto;'><tr><td><img src='images/Check-icon.png'></td><td style='font-size:14px;'>Payment Sucessful<br><a href='' onclick='closeMe()'>Go to the next step</a></td></tr></table>");
    session.setAttribute("result",retVar);
    response.sendRedirect("success.jsp");
    return;
%><%!


    public HashMap
    novahttpcall(org.json.JSONObject nvpStr) {

        String version = "2.3";
        String agent = "Mozilla/4.0";
        String respText = "";
        HashMap<String, String> nvp = new HashMap<String, String>();

        //deformatNVP( nvpStr );
        StringBuffer data = new StringBuffer();
        Iterator<String> it = nvpStr.keys();
        while (it.hasNext()) {
            String key = it.next();
            try {
                data.append(key + "=" + nvpStr.getString(key));
                if (it.hasNext()) {
                    data.append("&");
                }
            } catch (org.json.JSONException e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
        }
        String encodedData = data.toString();

        try {
            URL postURL = new URL("https://www.myvirtualmerchant.com/VirtualMerchant/process.do");
            HttpsURLConnection conn = (HttpsURLConnection) postURL.openConnection();

            // Set connection parameters. We need to perform input and output,
            // so set both as true.
            conn.setDoInput(true);
            conn.setDoOutput(true);

            // Set the content type we are POSTing. We impersonate it as
            // encoded form data
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setRequestProperty("User-Agent", agent);

            //conn.setRequestProperty( "Content-Type", type );
            conn.setRequestProperty("Content-Length", String.valueOf(encodedData.length()));
            conn.setRequestMethod("POST");

            // get the output stream to POST to.
            DataOutputStream output = new DataOutputStream(conn.getOutputStream());
            output.writeBytes(encodedData);
            output.flush();
            output.close();

            // Read input from the input stream.
            DataInputStream in = new DataInputStream(conn.getInputStream());
            int rc = conn.getResponseCode();
            if (rc != -1) {
                BufferedReader is = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String _line = null;
                while (((_line = is.readLine()) != null)) {
                    String[] tk = _line.split("=");
                    if (tk.length == 1) {
                        nvp.put(tk[0], "");
                    } else {
                        nvp.put(tk[0], tk[1]);
                    }
                }

            }
            try {
                Utilities.executeStatement("INSERT INTO egprint.ccTransaction (`Amount`,`Result`,`Date`) values ('" + nvpStr.getString("ssl_amount") + "','" + nvp + "',NOW())");
            } catch (JSONException e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
            return nvp;
        }
        catch (IOException e) {
            // handle the error here
            return null;
        }
    }
%>