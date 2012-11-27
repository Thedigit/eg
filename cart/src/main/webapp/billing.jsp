<%@ page import="org.json.*,java.util.*,egprint.*" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="egprint.Utilities" %>
<%@ page import="egprint.cart.CartUtilities" %>
<%@ page import="egprint.mail.EmailMessage" %>
<%@ page import="egprint.mail.Mailman" %>
<%@ page import="egprint.communications.sms.SMSMessage" %>
<%@ page import="static egprint.communications.sms.SMSUtils.getFrom" %>
<%
    session.setAttribute("securePage",true);
%>
<%@ include file="common.jsp" %>
<%
    session.removeAttribute("securePage");
%>
<%@include file="checkLogin.jsp"%>
<%@ include file="paypalfunctions.jsp" %>
<%
    response.setContentType("application/json");
    String callback = Utilities.get(request, "callback");
    JSONObject retVar = new JSONObject();

    System.out.println("Cart at upload: \n" + cart);
    if (cart == null) {
         Utilities.log("Session expired at checkout, or ilegal access. Probably expired.");
                retVar.put("status", "failed");
                retVar.put("error", "Unable to continue. Your session has expired.");
                response.getWriter().print(callback + "(" + retVar.toString() + ")");
                return;
    }

    String token = egprint.Utilities.get(request, "token");
    boolean paypal = (token != null);
    boolean accepted = false;
    boolean paid = false;
    boolean terms = (Utilities.get(request, "terms") != null);
    System.out.println("pp:" + paypal + " terms:" + terms);
    String type = "Luna Paypal", method = "Paypal", note = "";
    if (paypal){

    String resp="";
    HashMap<String,String> nvp=null;
    if ( token != null) //PAYPAL Checkout
{
    session.setAttribute("TOKEN",token);

	/*
	'------------------------------------
	' Calls the GetExpressCheckoutDetails API call
	'
	' The GetShippingDetails function is defined in PayPalFunctions.jsp
	' included at the top of this file.
	'-------------------------------------------------
	*/

	 nvp = GetShippingDetails(token, session);
	String strAck = nvp.get("ACK").toString();

	if(strAck != null && (strAck.equalsIgnoreCase("Success") || strAck.equalsIgnoreCase("SuccessWithWarning")))
	{
		String email 			= nvp.get("EMAIL"); // ' Email address of payer.
		String payerId 			= nvp.get("PAYERID"); // ' Unique PayPal customer account identification number.
		String payerStatus		= nvp.get("PAYERSTATUS"); // ' Status of payer. Character length and limitations: 10 single-byte alphabetic characters.
		String salutation		= nvp.get("SALUTATION"); // ' Payer's salutation.
		String firstName		= nvp.get("FIRSTNAME"); // ' Payer's first name.
		String middleName		= nvp.get("MIDDLENAME"); // ' Payer's middle name.
		String lastName			= nvp.get("LASTNAME"); // ' Payer's last name.
		String suffix			= nvp.get("SUFFIX"); // ' Payer's suffix.
		String cntryCode		= nvp.get("COUNTRYCODE"); // ' Payer's country of residence in the form of ISO standard 3166 two-character country codes.
		String business			= nvp.get("BUSINESS"); // ' Payer's business name.
		String shipToName		= nvp.get("SHIPTONAME"); // ' Person's name associated with this address.
		String shipToStreet		= nvp.get("SHIPTOSTREET"); // ' First street address.
		String shipToStreet2	= nvp.get("SHIPTOSTREET2"); // ' Second street address.
		String shipToCity		= nvp.get("SHIPTOCITY"); // ' Name of city.
		String shipToState		= nvp.get("SHIPTOSTATE"); // ' State or province
		String shipToCntryCode	= nvp.get("SHIPTOCOUNTRYCODE"); // ' Country code.
		String shipToZip		= nvp.get("SHIPTOZIP"); // ' U.S. Zip code or other country-specific postal code.
		String addressStatus 	= nvp.get("ADDRESSSTATUS"); // ' Status of street address on file with PayPal
		String invoiceNumber	= nvp.get("INVNUM"); // ' Your own invoice or tracking number, as set by you in the element of the same name in SetExpressCheckout request .
		String phonNumber		= nvp.get("PHONENUM"); // ' Payer's contact telephone number. Note:  PayPal returns a contact telephone number only if your Merchant account profile settings require that the buyer enter one.

        resp+=
                email		     +"\n"+
               payerId 		 +"\n"+
               payerStatus		 +"\n"+
               salutation		 +"\n"+
               firstName		 +"\n"+
               middleName		 +"\n"+
               lastName		 +"\n"+
               suffix			 +"\n"+
               cntryCode		 +"\n"+
               business		 +"\n"+
               shipToName		 +"\n"+
               shipToStreet	 +"\n"+
               shipToStreet2	 +"\n"+
               shipToCity		 +"\n"+
               shipToState		 +"\n"+
               shipToCntryCode	 +"\n"+
               shipToZip		 +"\n"+
               addressStatus 	 +"\n"+
               invoiceNumber	 +"\n"+
               phonNumber       ;

		/*
		' The information that is returned by the GetExpressCheckoutDetails call should be integrated by the partner into his Order Review
		' page
		*/
	}
	else
	{
		// Display a user friendly Error on the page using any of the following error information returned by PayPal

		String ErrorCode = nvp.get("L_ERRORCODE0");
		String ErrorShortMsg = nvp.get("L_SHORTMESSAGE0");
		String ErrorLongMsg = nvp.get("L_LONGMESSAGE0");
		//String ErrorSeverityCode = nvp.get("L_SEVERITYCODE0");
        Utilities.log("PAYPAL ERROR "+ErrorCode+" > "+ErrorShortMsg+" > "+ErrorLongMsg);
          Utilities.log("PAYPAL ERROR payment was declined :-(<br>Reason:<br>"+ErrorLongMsg+"<a href='checkout3.jsp'>Click here to try again</a>");
                retVar.put("status", "failed");
                retVar.put("error", "Your payment was declined by PayPal :-(<br>Reason:<br>"+ErrorLongMsg+"<br><a href='checkout3.jsp'>Click here to try again</a>");
                response.getWriter().print(callback + "(" + retVar.toString() + ")");
                return;
	}
        String finalPaymentAmount =  Utilities.money(CartUtilities.getCartTotal(activeCustomer.get("Taxable").equals("1"),cart)+"");
	/*
	'------------------------------------
	' Calls the DoExpressCheckoutPayment API call
	'
	' The ConfirmPayment function is defined in the file PayPalFunctions.jsp,
	' that is included at the top of this file.
	'-------------------------------------------------
	*/

	 nvp = ConfirmPayment(finalPaymentAmount, session, request);
	 strAck = nvp.get("ACK");
	if(strAck !=null && (strAck.equalsIgnoreCase("Success") || strAck.equalsIgnoreCase("SuccessWithWarning")))
	{
		/*
		'********************************************************************************************************************
		'
		' THE PARTNER SHOULD SAVE THE KEY TRANSACTION RELATED INFORMATION LIKE
		'                    transactionId & orderTime
		'  IN THEIR OWN  DATABASE
		' AND THE REST OF THE INFORMATION CAN BE USED TO UNDERSTAND THE STATUS OF THE PAYMENT
		'
		'********************************************************************************************************************
		*/

		String transactionId	= nvp.get("TRANSACTIONID"); // ' Unique transaction ID of the payment. Note:  If the PaymentAction of the request was Authorization or Order, this value is your AuthorizationID for use with the Authorization & Capture APIs.
		String transactionType 	= nvp.get("TRANSACTIONTYPE"); //' The type of transaction Possible values: l  cart l  express-checkout
		String paymentType		= nvp.get("PAYMENTTYPE");  //' Indicates whether the payment is instant or delayed. Possible values: l  none l  echeck l  instant
		String orderTime 		= nvp.get("ORDERTIME");  //' Time/date stamp of payment
		String amt				= nvp.get("AMT");  //' The final amount charged, including any shipping and taxes from your Merchant Profile.
		String currencyCode		= nvp.get("CURRENCYCODE");  //' A three-character currency code for one of the currencies listed in PayPay-Supported Transactional Currencies. Default: USD.
		String feeAmt			= nvp.get("FEEAMT");  //' PayPal fee amount charged for the transaction
		String settleAmt		= nvp.get("SETTLEAMT");  //' Amount deposited in your PayPal account after a currency conversion.
		String taxAmt			= nvp.get("TAXAMT");  //' Tax charged on the transaction.
		String exchangeRate		= nvp.get("EXCHANGERATE");  //' Exchange rate if a currency conversion occurred. Relevant only if your are billing in their non-primary currency. If the customer chooses to pay with a currency other than the non-primary currency, the conversion occurs in the customer�s account.

		/*
		' Status of the payment:
				'Completed: The payment has been completed, and the funds have been added successfully to your account balance.
				'Pending: The payment is pending. See the PendingReason element for more information.
		*/

		String paymentStatus	= nvp.get("PAYMENTSTATUS");

		/*
		'The reason the payment is pending:
		'  none: No pending reason
		'  address: The payment is pending because your customer did not include a confirmed shipping address and your Payment Receiving Preferences is set such that you want to manually accept or deny each of these payments. To change your preference, go to the Preferences section of your Profile.
		'  echeck: The payment is pending because it was made by an eCheck that has not yet cleared.
		'  intl: The payment is pending because you hold a non-U.S. account and do not have a withdrawal mechanism. You must manually accept or deny this payment from your Account Overview.
		'  multi-currency: You do not have a balance in the currency sent, and you do not have your Payment Receiving Preferences set to automatically convert and accept this payment. You must manually accept or deny this payment.
		'  verify: The payment is pending because you are not yet verified. You must verify your account before you can accept this payment.
		'  other: The payment is pending for a reason other than those listed above. For more information, contact PayPal customer service.
		*/

		String pendingReason	= nvp.get("PENDINGREASON");

		/*
		'The reason for a reversal if TransactionType is reversal:
		'  none: No reason code
		'  chargeback: A reversal has occurred on this transaction due to a chargeback by your customer.
		'  guarantee: A reversal has occurred on this transaction due to your customer triggering a money-back guarantee.
		'  buyer-complaint: A reversal has occurred on this transaction due to a complaint about the transaction from your customer.
		'  refund: A reversal has occurred on this transaction because you have given the customer a refund.
		'  other: A reversal has occurred on this transaction due to a reason not listed above.
		*/

		String reasonCode		= nvp.get("REASONCODE");
        accepted=true;
        paid=true;
        Utilities.log("PAYPAL SUCCESS "+ transactionId + " $"+amt+" ("+orderTime+")");
	}
	else
	{
		// Display a user friendly Error on the page using any of the following error information returned by PayPal

		String ErrorCode = nvp.get("L_ERRORCODE0");
		String ErrorShortMsg = nvp.get("L_SHORTMESSAGE0");
		String ErrorLongMsg = nvp.get("L_LONGMESSAGE0");
		//String ErrorSeverityCode = nvp.get("L_SEVERITYCODE0");
        session.setAttribute("message","Your payment was declined :-(<br>Reason:<br>"+ErrorLongMsg+"<a href='checkout3.jsp'>Click here to try again</a>");
       Utilities.log("PAYPAL ERROR payment was declined :-(<br>Reason:<br>"+ErrorLongMsg+"<a href='checkout3.jsp'>Click here to try again</a>");
                retVar.put("status", "failed");
                retVar.put("error", "Your payment was declined :-(<br>Reason:<br>"+ErrorLongMsg+"<a href='checkout3.jsp'>Click here to try again</a>");
                response.getWriter().print(callback + "(" + retVar.toString() + ")");
                return;
	}
}
}
    else if (terms) //Terms customer.
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
                response.getWriter().print(callback + "(" + retVar.toString() + ")");
                return;
        }
    } else //CREDIT CARD TX!
    {
        JSONObject data = new JSONObject();
        data.put("ssl_amount", Utilities.money(CartUtilities.getCartTotal(activeCustomer.get("Taxable").equals("1"), cart) + ""));
        data.put("ssl_test_mode", "FALSE");
        data.put("ssl_merchant_id", "${NOVA.MERCHANTID}");
        data.put("ssl_user_id", "web");
        data.put("ssl_pin", "${NOVA.PIN}");
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

            System.out.println(param +" = "+ Utilities.get(request, param, "NULL"));
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
                Utilities.log("Credit card declined for: " + activeCustomer.get("Customer") + "\n reason: "+ ret.get("errorMessage") );
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

    double totalPayment = CartUtilities.getCartTotal(activeCustomer.get("Taxable").equals("1"), cart);

    JSONObject invoice = Utilities.createInvoiceNumber(activeCustomer.get("insideId"));
    int pcode = -1;
    if (paid) {
        String ccQuery = "INSERT INTO egprint.Payments (`Method`,`Type`,`Amount`,`Date`,`ProcessedBy`,`Notes`) VALUES ('" + method + "','" + type + "','" + Utilities.money(totalPayment + "") + "',NOW(),'0','" + note + "')";
        pcode = Utilities.executeStatement(ccQuery);
        Utilities.log("Payment Query (" + pcode + ") \n" + ccQuery);

         ccQuery="INSERT INTO egprint.PaymentApplied (`Payment`,`Invoice`,`Amount`) VALUES ('"+pcode+"','"+invoice.getString("id")+"','"+Utilities.money(totalPayment+"")+"')";
           Utilities.log("PaymentApplied insertion Query ->\n"+ccQuery);
           Utilities.executeStatement(ccQuery);
    }

    //AFTER PAYMENT APPROVAL, We Clear the cart to avoid double billing.
    session.setAttribute("billed", true);
    Utilities.log("SHOPPING CART \n" + cart.toString());


    //Save or update address.
    JSONObject add = cart.getJSONObject("shipping").getJSONObject("address");
    System.out.println("Adddress>>"+add);
    if(!add.has("id")){add.put("id","-1");}
    if (add.getInt("id") != -1) //Update an existing address
    {
        Utilities.updateAddress(add);
    } else {
        add.put("CustomerId", activeCustomer.get("insideId"));
        add.put("Default", "0");
        int id = Utilities.insertAddress(add);
        add.put("id", id);//This is where we're shipping to.
    }

    /**Determine how many order this customer has placed**/
        int orderCount= 0;
        try {
            orderCount = Integer.parseInt(Utilities.fetch3("SELECT COUNT(*) as `total` FROM egprint.orders o WHERE o.customer='" + activeCustomer.get("insideId") + "'").get(0).get("total"));
        } catch (NumberFormatException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

    ArrayList<String> invoices = new ArrayList<String>();
    HashMap<String, String> emailConfirmation = new HashMap<String, String>();
    ArrayList<JSONObject> newOrders = new ArrayList<JSONObject>();
    try {

        java.util.Iterator<String> keys = cart.getJSONObject("products").keys();
        int i = 0;
        while (keys.hasNext()) {
            i++;
            String key = keys.next();
            JSONObject qty = cart.getJSONObject("products").getJSONObject(key);
            JSONObject product = qty.getJSONObject("product");
            JSONObject productOptions = qty.getJSONObject("options");
            int sets = qty.getInt("sets");
            int round = java.math.BigDecimal.ROUND_HALF_UP;
            java.math.BigDecimal itemShipping = new java.math.BigDecimal(CartUtilities.getCartItemShipping(cart, key)).setScale(2, round);
            java.math.BigDecimal partialItemShipping = itemShipping.divide(new java.math.BigDecimal(sets), 2, round);


            for (int j = 1; j <= sets; j++) {
                double shipPrice = 0;
                int stype = cart.getJSONObject("shipping").getInt("type");

                if (stype != 1) {
                    shipPrice = CartUtilities.getCartShipping(cart);
                }
                double itemPrice = product.getDouble("Price");
                double itemTax = itemPrice * ((activeCustomer.get("Taxable").equals("1") ? 0.07 : 0.0));
                java.math.BigDecimal thisItemShipping = itemShipping.subtract(partialItemShipping.multiply(new java.math.BigDecimal((sets - j) + "")));
                itemShipping = itemShipping.subtract(thisItemShipping);
                double itemTotal = itemPrice + itemTax + thisItemShipping.doubleValue();

                JSONObject newOrder = Utilities.createOrder(qty.getString("qty"), activeCustomer.get("insideId"), add.getString("id"), cart.getJSONObject("shipping").getString("type"), cart.getJSONObject("shipping").getString("subtype"), "EG", activeCustomer.get("Taxable"),null, thisItemShipping.setScale(2, round).toString(), pcode, type,invoice,productOptions);
                try{
                    final String msg = "Dear customer,\r\n This is an automatic message to notify you that files for order #"+newOrder.getString("order")+" have not beed uploaded. You can upload the files from your order status page: "+activeCompany.optString("FullDomain","")+"/orders.jsp?j="+newOrder.getString("order")+"\r\nIn order to serve you in a timely fashion these files must be uploaded as soon as possible. If you have already emailed / uploaded the files, please disregard this message.";
                    final String ordNum = newOrder.getString("order");
                    final EmailMessage em = new EmailMessage(activeCustomer.get("Login"),"orders@egprint.net","Files not received",msg,activeCustomer.get("insideId"),activeCustomer.get("Customer"));
                    Thread t = new Thread(){
                        public void run(){
                            try{

                                Thread.sleep(5*60*60*1000);
                                ArrayList<HashMap<String,String>> missing= Utilities.fetch3("SELECT * FROM egprint.orders o WHERE o.currentfolder is NULL AND o.id='"+ordNum+"'");
                                if(missing.size()>0){
                                Mailman.send(em);
                                }
                            }   catch(Exception e3){e3.printStackTrace();}
                        }
                    };

                    t.start();

                }catch(Exception ee){ee.printStackTrace();}
                newOrder.put("set",j);
                newOrder.put("totalSets",sets);
                newOrders.add(newOrder);
                try {

                    emailConfirmation.put(newOrder.getString("order"),
                            "\nINVOICE: " +invoice.getString("number") +
                                    "\n\nSET: " + j + " of " + sets + " \n" +
                                    CartUtilities.getCartItemString(cart, key, activeCustomer.get("Taxable").equals("1")) +
                                    "\n\nTransaction:\n 	Type: " + type + "\n   Method: " + method + "\n   Notes: " + note
                    );
                   // invoices.add(Utilities.getInvoiceHeader() + "-" + newOrder.get("order"));
                    invoices.add(invoice.getString("number"));

                } catch (Exception e) {
                    e.printStackTrace();
                    Utilities.log("Error Creating Orders for " + activeCustomer.get("Customer") + "\n" + e.getMessage());
                    retVar.put("status", "failed");
                    retVar.put("error", "Unable to create orders. Your credit card has been billed. Please contact customer service");
                    response.getWriter().print(callback + "(" + retVar.toString() + ")");
                    return;
                }
            }
        }
        StringBuffer emailBody = new StringBuffer("MONEY TIME:\n TOTAL AMOUNT CHARGED: " + Utilities.money(totalPayment + "") + "\nType: " + type + "\n   Method: " + method + "\n   Notes: " + note + "\n SYSTEM TIME: " + (new Date()) + "\n");
        emailBody.append("CUSTOMER:\n" + activeCustomer.get("insideId") + " - " + activeCustomer.get("Customer") +
                activeCustomer.get("Contact") + "\n" +
                activeCustomer.get("Address1") + "\n" +
                activeCustomer.get("City") + ", " +
                activeCustomer.get("State") + " " +
                activeCustomer.get("Zip") + "\n"
        );
        Iterator<String> emailOrders = emailConfirmation.keySet().iterator();
        while (emailOrders.hasNext()) {
            String emailOrder = emailOrders.next();
            emailBody.append((String) emailConfirmation.get(emailOrder) + "\n\n+++++++++++++++++++\n");
        }

        egprint.mail.EmailMessage em = new egprint.mail.EmailMessage("mailbyluna@gmail.com", "orders@egprint.net", "New Order " + activeCustomer.get("insideId") + " - " + activeCustomer.get("Customer"),
                emailBody.toString()
                , "3141", "LennyLand");
        egprint.mail.Mailman.queue.size();
        egprint.mail.Mailman.send(em);

        //SEND SMS MESSAGE FOR FIRST TIME CUSTOMERS
                try {
                    System.out.println("orderCount = " + orderCount);
                    if(orderCount<1){
                        SMSMessage smsMessage = new SMSMessage();
                        smsMessage.setBody("New Customer! "+activeCustomer.get("Contact")+" from "+activeCustomer.get("Customer")+". Phone: "+activeCustomer.get("Phone"));
                        smsMessage.setFrom(getFrom());
                        smsMessage.setTo(Utilities.property("newCustomerNumber"));
                        smsMessage.send();
                    }
                } catch (Exception e) {
                    e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                }

    } catch (Exception e) {
        e.printStackTrace();
        retVar.put("status", "failed");
        retVar.put("error", "Unknown Error. Please contact customer service");
        response.getWriter().print(callback + "(" + retVar.toString() + ")");
        return;
    }

    session.setAttribute("type",type);
    session.setAttribute("method",method);
    session.setAttribute("note",note);
    session.setAttribute("newOrders",newOrders);
    retVar.put("status", "success");
    retVar.put("redirect", "upload2.jsp");
    retVar.put("error", "<table style='margin:auto;'><tr><td><img src='images/Check-icon.png'></td><td style='font-size:14px;'>Payment Sucessful<br><a href='upload2.jsp' onclick=''>Proceed to upload</a></td></tr></table>");
    response.getWriter().print(callback + "(" + retVar.toString() + ")");
    return;
%>