<%@page import="java.util.*"%>
<%@page import="egprint.Utilities"%>
<%   session.setAttribute("Payment_Amount","19.00");
	/*==================================================================
	 PayPal Express Checkout Call
	 ===================================================================
	*/
/*
	This step indicates whether the user was sent here by PayPal
	if this value is null then it is part of the regular checkout flow in the cart
*/

String token = egprint.Utilities.get(request,"token");
    String resp="";
    HashMap<String,String> nvp=null;
if ( token != null)
{
    session.setAttribute("TOKEN",token);
%>
<%@include file="paypalfunctions.jsp" %>
<%
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
		String ErrorSeverityCode = nvp.get("L_SEVERITYCODE0");

        
	}
        String finalPaymentAmount =  session.getAttribute("Payment_Amount").toString();
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
		String exchangeRate		= nvp.get("EXCHANGERATE");  //' Exchange rate if a currency conversion occurred. Relevant only if your are billing in their non-primary currency. If the customer chooses to pay with a currency other than the non-primary currency, the conversion occurs in the customer’s account.

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
	}
	else
	{
		// Display a user friendly Error on the page using any of the following error information returned by PayPal

		String ErrorCode = nvp.get("L_ERRORCODE0");
		String ErrorShortMsg = nvp.get("L_SHORTMESSAGE0");
		String ErrorLongMsg = nvp.get("L_LONGMESSAGE0");
		String ErrorSeverityCode = nvp.get("L_SEVERITYCODE0");
	}
}

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>Success?</title>
  <script>
  </script>
</head>
<body>
PAYMENT ACCEPTED!
You'll be redirected to the file upload screen automatically.(Or not...)
<table>
 <%Set<String> it = nvp.keySet();
  for(String k:it)
  {

    %>
    <tr><td><%=k%></td><td><%=nvp.get(k)%></td></tr>

 <%

  }
 %>
    <tr><td>token</td><td><%=session.getAttribute("TOKEN")%></td></tr>
    </table>
</body>
</html>