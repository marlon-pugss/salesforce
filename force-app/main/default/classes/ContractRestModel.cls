global class ContractRestModel {

    global String id				 {get;set;}
    global String status			 {get;set;}
    global String contractCode		 {get;set;}
    global Integer installmentNumber {get;set;}
    global String purchaseOrigin     {get;set;}
    global String ownerEmail		 {get;set;}
    global String externalId		 {get;set;}
    global String modality			 {get;set;}
    global String recordType		 {get;set;}
    global String contractType		 {get;set;}
    global String parentContract	 {get;set;}
    global String opportunityId		 {get;set;}
    global Boolean compliant		 {get;set;}
    global Account account			 {get;set;}
    global Order order				 {get;set;}
    global List<Product> products	 {get;set;}
    
    global class Account{
        global String id					{get;set;}
        global String email					{get;set;}
        global String name					{get;set;}
        global String document				{get;set;}
        global String documentType			{get;set;}
        global String phone					{get;set;}
        global String billingStreet			{get;set;}
        global String billingDistrict		{get;set;}
        global Integer billingNumber		{get;set;}
        global String billingCity			{get;set;}
        global String billingState			{get;set;}
        global String billingPostalCode		{get;set;}
        global String billingCountry		{get;set;}
        global String billingCountryIsoCode {get;set;}
        global String fluencyId				{get;set;}
    }
    
    global class Order{
        global String externalId					 {get;set;}
        global String status						 {get;set;}
        global Integer installment					 {get;set;}
        global String purchaseDate					 {get;set;}
        global PaymentTransaction paymentTransaction {get;set;}
    }
    
    global class PaymentTransaction{
        global String externalId			   {get;set;}
        global String recurrencyPeriod		   {get;set;}
        global String currencyIsoCode		   {get;set;}
        global String currencyFrom			   {get;set;}
        global String paymentMode			   {get;set;}
        global String paymentType			   {get;set;}
        global String gateway				   {get;set;}
        global String status				   {get;set;}
        global String confirmationPurchaseDate {get;set;}
        global Decimal price				   {get;set;}
        global Decimal fullPrice			   {get;set;}
        global String refusalReason			   {get;set;}
    }
    
    global class Product{
        global String code		  {get;set;}
        global String name		  {get;set;}
        global String description {get;set;}
        global String externalId  {get;set;}
        global String offerCode	  {get;set;}
        global String startDate	  {get;set;}
        global String endDate	  {get;set;}
        global String bundleCode  {get;set;}
    }
    
    global class ErrorMessage{
        global String message {get;set;}
    }
    
}