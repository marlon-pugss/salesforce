@RestResource(urlMapping='/contractRest/*')
global class ContractRest{
    
    @httpPost
    global static void createContract(ContractRestModel contractModel){
        
        LogInterfaceHelper logHelper							= LogInterfaceHelper.getInstance();
        ProductRepository productRepository						= new ProductRepository();
        AccountRepository accountRepository						= new AccountRepository();
        ContactRepository contactRepository						= new ContactRepository();
        ContractRepository contractRepository					= new ContractRepository();
        OpportunityRepository oppRepository						= new OpportunityRepository();
        LeadRepository leadRepository							= new LeadRepository();
        UserRepository userRepository							= new UserRepository();
        ContractedProductRepository contractedProductRepository = new ContractedProductRepository();
        
        Savepoint sp;
        if(!Test.isRunningTest()) sp = Database.setSavepoint();
        
        try{
            logHelper.addMessage(JSON.serialize(contractModel, true), 'Request Body');
                                 
            validateFields(contractModel);
            
            Map<String, ContractRestModel.Product> productsByExternalId = getProductByExternalId(contractModel);            
            List<Product2> products                                     = productRepository.findByProductCodeOrOfferCodeOrExternalCode(productsByExternalId.keySet());
            Map<String, sObject> productsByCode                         = ListHelper.indexListByField('ProductCode', products);
            
            validateProducts(productsByExternalId, productsByCode);
            
            if (Utils.isFilled(products)){
                
                String accountEmail				= contractModel.account.email.toLowerCase();
                Contact contactFromOtherAccount = null;
                Contact primaryContact			= null;
                List<Account> accounts			= accountRepository.findByEmail(new List<String>{accountEmail});
                Account account 	   			= Utils.isFilled(accounts)									? accounts[0]			: null;
                List<Contact> contacts 			= account  != null && Utils.isFilled(account.Contacts)		? account.Contacts		: null;
                List<Opportunity> opps 			= account  != null && Utils.isFilled(account.Opportunities) ? account.Opportunities : null;
                
                if (account == null)
                    contactFromOtherAccount = contactRepository.findByEmail(contractModel.account.email);
                
                if (contractModel.purchaseOrigin == 'voomp' && contractModel.contractCode != null){
                    List<Contract> contracts = contractRepository.findByContractCode(contractModel.contractCode);
                    if (Utils.isFilled(contracts))
                        throw new CustomException('A contract already exist with this contract code');
                }
                else if (account != null){
                    List<ProdutoContratado__c> contractedProducts = contractedProductRepository.findByAccount_AndProductCode_AndContractCode(account.Id, productsByExternalId.keySet(), contractModel.contractCode);
                    if (Utils.isFilled(contractedProducts))
                        throw new CustomException('A contract already exist with this contracted product');
                }
                
                if(contractModel.modality != null && contractModel.modality.toUpperCase() != Common.PAYMENTLESS.toUpperCase() && !Common.ORDER_STATUSES_CREATE_TRANSACTION.contains(contractModel.order.paymentTransaction.status) )
                    throw new CustomException('Create contract not allowed: transaction status not in ' + Common.ORDER_STATUSES_CREATE_TRANSACTION);
                
                String fullPhone = FormatFullPhoneHelper.processPhoneNumber(null, contractModel.account.Phone, null);
                
                if (account == null)
                    account = createAccount(account, accountRepository, contractModel.account, fullPhone);
                else if (account.FluencyId__c == null)
                    account = updateAccount(account, accountRepository, contractModel.account);
                
                if (contactFromOtherAccount != null)
                    primaryContact = associateContact(contactFromOtherAccount, account);
                else
                    primaryContact = createContact(contacts, account, contractModel.account, fullPhone, contactRepository);
                
                String ownerId	  = getUserIdByEmail(contractModel.ownerEmail, userRepository);
                Contract contract = createContract(contractModel, account.Id, contractRepository, ownerId, primaryContact);
                
                Opportunity opportunity = closeFirstOpenOpportunityAndActivateContract(contract, accountEmail, fullPhone, contractRepository, oppRepository, contractModel);
                                
                createContractedProduct(contract, products, opportunity, productsByExternalId, contractedProductRepository, productsByCode);                        
                
                if (contractModel.modality == null || contractModel.modality.toUpperCase() != Common.PAYMENTLESS.toUpperCase()){
                    PaymentOrder__c paymentOrder = upsertPaymentOrder(contractModel.order, contract);
                    
                    upsertTransaction(contractModel.order.paymentTransaction, paymentOrder);
                    
                    convertOpenLeads(contractModel.account.email, leadRepository);
                }
                
                ContractRestModel responseModel = createResponseModel(contract, products, account);
                String responseBody				= JSON.serialize(responseModel, true);
                
                restResponse(201, responseBody, logHelper);
            }
            else{
                throw new CustomException('No product was found');
            }
        }
        catch(Exception ex){
            logHelper.addError(ex);
            
            if(!Test.isRunningTest()) Database.rollback(sp);
            
            ContractRestModel.ErrorMessage error = new ContractRestModel.ErrorMessage();
            error.message						 = ex.getMessage();
            
            restResponse(400, JSON.serialize(error), logHelper);
        }
        finally{
            if (logHelper.size() > 0)
                logHelper.createLog('ContractRest/createContract');
        }
    
    }
    
    private static Account createAccount(Account account, AccountRepository accountRepository, ContractRestModel.Account model, String fullPhoneProcessed){
        AccountBuilder builder = new AccountBuilder().name(model.name)
                                      				 .email(model.email)
            										 .completeName(model.name)
            										 .document(model.document)
                                      				 .phone(fullPhoneProcessed)
            										 .fullPhone(fullPhoneProcessed)
                        							 .documentType(model.documentType)
                                      				 .billingCity(model.billingCity)
                                      				 .billingState(model.billingState)
                                      				 .billingNumber(model.billingNumber)
                                      				 .billingDistrict(model.billingDistrict)
                                      				 .billingPostalCode(model.billingPostalCode)
                                      				 .billingCountry(model.billingCountry)
                                      				 .billingCountryIsoCode(model.billingCountryIsoCode)
            										 .billingStreet(model.billingStreet)
            										 .recordTypeId(Common.ACCOUNT_RT_ID_BUSINESS)
            										 .fluencyId(model.fluencyId);
        
        return (Account) accountRepository.save(builder.build());
    }
    
    private static Account updateAccount(Account account, AccountRepository accountRepository, ContractRestModel.Account model){
        account.FluencyID__c = model.fluencyId;
        
        return (Account) accountRepository.save(account);
    }
    
    private static Contact createContact(List<Contact> contacts, Account account, ContractRestModel.Account model, String fullPhoneProcessed, ContactRepository contactRepository){
        
        if (account.RecordTypeId == Common.ACCOUNT_RT_ID_PERSON_ACCOUNT) return null;
        
        Contact contactWithSameEmail = null;
         
        if (contacts != null){
            for (Contact contact : contacts){
                if (contact.Email__c == model.email){
                    contactWithSameEmail = contact;
                    break;
                }
            }
        }
        
        if (contactWithSameEmail == null){
            
            Map<String, String> nameByFirstNameAndLastName = convertNameIntoFirstNameAndLastName(model.name.trim());
            
            return (Contact) contactRepository.save(new ContactBuilder().accountId(account.Id)
                                                                        .customEmail(model.email)
                                                                        .phone(fullPhoneProcessed)
                                                                        .fullPhone(fullPhoneProcessed)
                                                                        .firstName(nameByFirstNameAndLastName.get('FirstName'))
                                                                        .lastName(nameByFirstNameAndLastName.get('LastName'))
                                                                        .build());        
        }
        else return contactWithSameEmail;
    }
    
    private static Contact associateContact(Contact contact, Account account){
        insert new AccountContactRelationBuilder().accountId(account.Id)
            									  .contactId(contact.Id)
            									  .build();
        return contact;
    }
    
    private static Contract createContract(ContractRestModel model, String accountId, ContractRepository contractRepository, String ownerId, Contact primaryContact){
        
        Date startDate = model.products[0].startDate != null ? Date.valueOf(model.products[0].startDate) : null;
                
        ContractBuilder builder = new ContractBuilder().ownerId(ownerId)
            										   .accountId(accountId)
            										   .startDate(startDate)
            										   .createdByIntegration(true)
            										   .externalId(model.externalId)
            										   .sellerEmail(model.ownerEmail)
            										   .opportunity(model.opportunityId)
            										   .contractCode(model.contractCode)
            										   .primaryContact(primaryContact.Id)
            										   .status(Common.CONTRACT_STATUS_DRAFT)
            										   .parentContract(model.parentContract)
            										   .purchaseOrigin(model.purchaseOrigin)
            										   .numberOfInstallments(model.installmentNumber);
        
        if (model.modality == null || model.modality.toUpperCase() != Common.PAYMENTLESS.toUpperCase())
            builder.renewalPeriod(model.order.paymentTransaction.recurrencyPeriod)
            	   .currencyIsoCode(model.order.paymentTransaction.currencyIsoCode);
        else if (model.modality != null)
            builder.modality(Common.PAYMENTLESS.toUpperCase());
        
        Contract contractToReturn = (Contract) contractRepository.save(builder.build());
        contractToReturn		  = (Contract) contractRepository.save(new ContractBuilder().id(contractToReturn.Id)
                                                                      						.status(Common.CONTRACT_STATUS_ACTIVE)
                                                                      						.build());
        return contractToReturn;
    }
    
    private static Opportunity closeFirstOpenOpportunityAndActivateContract(Contract contract, String email, String fullPhone, ContractRepository contractRepository, OpportunityRepository oppRepository, ContractRestModel model){
        Opportunity opportunityToClose	   = new Opportunity();
        Opportunity openOpportunity		   = model.modality != null && model.modality.toUpperCase() == Common.PAYMENTLESS.toUpperCase() ? null : getFirstOpenOpportunity(email, fullPhone, oppRepository, model);
        ContractBuilder contractToActivate = new ContractBuilder().id(contract.Id)
            													  .status(Common.CONTRACT_STATUS_ACTIVE);
        
        if (openOpportunity != null){
            opportunityToClose = new OpportunityBuilder().id(openOpportunity.Id)
                                                         .contractId(contract.Id)
                                                         .stageName(Common.OPP_STAGENAME_CLOSED_WIN)
                                                         .closedByIntegration(true)
                                                         .build();
            if (openOpportunity.B2BContract__c != null)
                contractToActivate.b2bContract(openOpportunity.B2BContract__c);
            
            if (openOpportunity.ReferredByAccount__c != null)
                contractToActivate.referredByAccount(openOpportunity.ReferredByAccount__c);
            
            if (openOpportunity.ParentContract__c != null)
                contractToActivate.parentContract(openOpportunity.ParentContract__c);
            
            contractToActivate.opportunity(openOpportunity.Id);
            
            if (opportunityToClose.Id != null)
                oppRepository.save(opportunityToClose);
        }
        
        contractRepository.save(contractToActivate.build());
        
        return opportunityToClose;
    }
    
    private static Opportunity getFirstOpenOpportunity(String email, String fullPhone, OpportunityRepository oppRepository, ContractRestModel model){
        Opportunity openOpportunity = new Opportunity();
        
        if (model.opportunityId != null)
            return new OpportunityBuilder().id(model.opportunityId)	
            							   .build();
        
        List<Opportunity> openOpps = oppRepository.findNotStageNames_AccountEmail_RecordType(Common.OPP_STAGENAMES_CLOSED, new List<String>{email}, Common.OPP_RT_ID_INSIDESALES_AND_RECYCLE);
        
        if (!Utils.isFilled(openOpps))
            openOpps = oppRepository.findBy_NotStageName_RecordTypeId_FullPhone(Common.OPP_STAGENAMES_CLOSED,
                                                                                Common.OPP_RT_ID_INSIDESALES_AND_RECYCLE,
                                                                                new List<String>{fullPhone}) ;
        
        if (Utils.isFilled(openOpps))
            return openOpps[0];
        else
            return null;
    }
    
    private static List<ProdutoContratado__c> createContractedProduct(Contract contract, List<Product2> products, Opportunity opportunity, Map<String, ContractRestModel.Product> productsByExternalId, ContractedProductRepository contractedProductRepository, Map<String, sObject> productsByCode ){
        
        List<ProdutoContratado__c> contractedProductsToInsert = new List<ProdutoContratado__c>();
        
        for (ContractRestModel.Product product : productsByExternalId.values()){
            Product2 productSF = (Product2) productsByCode.get(product.externalId);
            
            Date startDate    = product.startDate  != null ? Date.valueOf(product.startDate) : null;
            Date endDate      = product.endDate    != null ? Date.valueOf(product.endDate)   : null;
            String bundleCode = product.bundleCode != null ? product.bundleCode              : null;
                        
            ContractedProductBuilder builder = new ContractedProductBuilder().productId(productSF.Id)
                                                                             .offerCode(product.offerCode)
                                                                             .name(productSF.Name)
                                                                             .contractId(contract.Id)
                                                                             .productCode(productSF.ProductCode)
                                                                             .startDate(startDate)
                                                                             .endDate(endDate)
                                                                             .bundleCode(bundleCode);
            if (opportunity.Id != null)
                builder.opportunityId(opportunity.Id);
            
            contractedProductsToInsert.add(builder.build());
        }
        
        contractedProductsToInsert = (List<ProdutoContratado__c>) contractedProductRepository.save(contractedProductsToInsert);
        return contractedProductsToInsert;
    }
    
    private static PaymentOrder__c upsertPaymentOrder(ContractRestModel.Order model, Contract contract){
        
        PaymentOrder__c paymentOrder = new PaymentOrderBuilder().externalId(model.externalId)
                                                                .contract(contract.Id)
                                                                .purchaseDate(Date.valueOf(model.purchaseDate))
                                                                .installment(model.installment)
            													.status(model.paymentTransaction.status)
                                                                .build();
        upsert paymentOrder ExternalId__c;
        return paymentOrder;
    }
    
    private static Transaction__c upsertTransaction(ContractRestModel.PaymentTransaction model, PaymentOrder__c paymentOrder){
        Transaction__c tranzaction = new TransactionBuilder().externalId(model.externalId)
            												 .paymentOrder(paymentOrder.Id)
            												 .installment(paymentOrder.Installment__c)
                                                             .paymentType(model.paymentType)
                                                             .paymentGateway(model.gateway)
                                                             .status(model.status)
                                                             .confirmationPurchaseDate((Datetime) JSON.deserialize('"' + model.confirmationPurchaseDate + '"', DateTime.class))
                                                             .sourceCurrency(model.currencyFrom)
                                                             .currencyIsoCode(model.CurrencyIsoCode)
                                                             .salePrice(model.price)
                                                             .fullPrice(model.fullPrice)
                                                             .orderDate(paymentOrder.PurchaseDate__c)
                                                             .refusalReason(model.refusalReason)
                                                             .build();
        upsert tranzaction ExternalId__c;
        return tranzaction;
    }
    
    private static void convertOpenLeads(String email, LeadRepository leadRepository){
        List<Lead> leadsToConvert = leadRepository.findByEmail_NotConverted_NotBrands(new Set<String>{email}, Common.LEAD_BRANDS_TO_NOT_CONVERT_FROM_CONTRACT);
        
        if (Utils.isFilled(leadsToConvert)){
            Set<Id> leadIdsToConvert = ListHelper.convertObjectListIntoSetIds('Id', leadsToConvert);
            Database.executeBatch(new ConvertLeadAutomaticallyBatch(leadIdsToConvert, false, false), 15);
        }
    }
    
    private static ContractRestModel createResponseModel(Contract contract, List<Product2> products, Account account){
        ContractRestModel responseModel = new ContractRestModel();
        responseModel.id				= contract.Id;
        responseModel.status			= contract.Status;
        responseModel.modality			= contract.Modality__c;
        responseModel.recordType		= contract.RecordType.DeveloperName;
        responseModel.contractType		= contract.TipoContrato__c;
        responseModel.compliant			= contract.Compliant__c;
        
        ContractRestModel.Account responseAccount = new ContractRestModel.Account();
        responseAccount.id 						  = account.Id;
        responseAccount.email 					  = account.Email__c;
        responseAccount.fluencyId				  = account.FluencyID__c;
        responseModel.account					  = responseAccount;
        
        responseModel.products = new List<ContractRestModel.Product>();
        for (Product2 product : products){
            ContractRestModel.Product responseProduct = new ContractRestModel.Product();
            responseProduct.code 					  = product.ProductCode;
            responseProduct.name 					  = product.Name;
            responseProduct.description				  = product.ProductCode;
            responseModel.products.add(responseProduct);
        }
        
        return responseModel;
    }
    
    private static void restResponse(Integer statusCode, String responseBody, LogInterfaceHelper logHelper){
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statuscode	  = statusCode;
        RestContext.response.responseBody = Blob.valueOf(responseBody);
        logHelper.addMessage('Status Code: '  + statusCode + '\n\n' + responseBody, 'Response Body');
    }
    
    private static String getUserIdByEmail(String email, UserRepository userRepository){  
        
        String userToReturn = Common.USER_ID_SF_EA;
        
        if (email == null) return userToReturn;
        
        List<User> contractOwner = userRepository.findByPartOfEmail(email);
        
        if (Utils.isFilled(contractOwner)){           
            userToReturn = contractOwner[0].Id;             
        } 
        else {
            Integer index = email.indexOf('@');
            
            if (index != -1){
                contractOwner = userRepository.findByPartOfEmail(email.substring(0, index) + '%');
                
                if (contractOwner != null && !contractOwner.isEmpty())
                    userToReturn = contractOwner[0].Id;
            }	            
        }
             
        return userToReturn;            
    }
    
    private static void validateFields(ContractRestModel contractModel){
        if (contractModel.products == null || contractModel.products.isEmpty()) throw new CustomException('There are no products in this request');
        if (contractModel.purchaseOrigin == 'voomp' && contractModel.externalId == null) throw new CustomException('The contract externalId is empty');
        if (contractModel.account == null)						   throw new CustomException('The account is empty');
        if (contractModel.account.email == null)				   throw new CustomException('The account has no email');
        if (contractModel.modality != null && contractModel.modality.toUpperCase() != Common.PAYMENTLESS.toUpperCase()){
            if (contractModel.order == null)						   throw new CustomException('The order is empty');
            if (contractModel.order.paymentTransaction == null)		   throw new CustomException('The transaction is empty');
            if (contractModel.order.paymentTransaction.status == null) throw new CustomException('The status of transaction is empty');
        }
        
        for (ContractRestModel.Product product : contractModel.products){
            if (product.externalId == null || product.externalId == '')
                throw new CustomException('There are products without external Id');
        }
    }
    
    private static void validateProducts(Map<String, ContractRestModel.Product> productsByExternalId, Map<String, sObject> productsByCode){
                    
        String productsNotSF = '';
        
        for(ContractRestModel.Product product : productsByExternalId.values()){
            Product2 productSF = (Product2) productsByCode.get(product.externalId);
            
            if(productSF == null)
               productsNotSF += product.externalID;
        }
        
        if(productsNotSF != '')
            throw new CustomException('These products does not exist in salesforce: ' + productsNotSF);
    }
    
    private static Map<String, ContractRestModel.Product> getProductByExternalId(ContractRestModel contractModel){
        
        Map<String, ContractRestModel.Product> productsByExternalIdToReturn = new Map<String, ContractRestModel.Product>();
        
        for (ContractRestModel.Product product : contractModel.products)
            productsByExternalIdToReturn.put(product.externalId, product);  
        
        return productsByExternalIdToReturn;
    }
    
    private static Map<String, String> convertNameIntoFirstNameAndLastName(String name){
        
        Map<String, String> firstNameAndLastNameToReturn = new Map<String, String>();      
            
        Integer indexOfFirstName = name.indexOf(' ');
        
        if (indexOfFirstName == -1){
            firstNameAndLastNameToReturn.put('LastName', name.substring(0, name.length() <= 80 ? name.length() : 80 ));
        }
        else{
            String firstPartName  = name.substring(0, indexOfFirstName);
            String secondPartName = name.substring(indexOfFirstName);
            
            if (secondPartName.length() <= 80 && firstPartName.length() <= 40){
                firstNameAndLastNameToReturn.put('FirstName', firstPartName);
                firstNameAndLastNameToReturn.put('LastName', secondPartName);
            }
            else if (secondPartName.length() <= 80 && firstPartName.length() > 40){
                firstNameAndLastNameToReturn.put('FirstName', name.substring(0, 40));
                firstNameAndLastNameToReturn.put('LastName', secondPartName);
            }
            else if (secondPartName.length() > 80 && firstPartName.length() <= 40){
                Integer indexOfSecondName = secondPartName.indexOf(' ');
                firstNameAndLastNameToReturn.put('FirstName', firstPartName);
                
                if (indexOfSecondName == -1){
                    firstNameAndLastNameToReturn.put('LastName', secondPartName.substring(0, secondPartName.length() <= 80 ? secondPartName.length() : 80));
                }
                else{
                    String firstPartOfSecondName = secondPartName.substring(0, indexOfSecondName);
                    String firstNameAux 		 = firstPartName + ' ' + firstPartOfSecondName;
                    
                    if (firstNameAux.length() <= 40){
                        firstNameAndLastNameToReturn.put('FirstName', firstNameAux);
                        firstNameAndLastNameToReturn.put('LastName', secondPartName.remove(firstPartOfSecondName).trim().substring(0,80));
                    }
                    else{
                        firstNameAndLastNameToReturn.put('LastName', secondPartName.substring(0, secondPartName.length() <= 80 ? secondPartName.length() : 80));
                    }
                }
            }
            else{
                firstNameAndLastNameToReturn.put('LastName', name.substring(0, secondPartName.length() <= 80 ? secondPartName.length() : 80));
            }
        }	
        
        return firstNameAndLastNameToReturn;
    }
    
    global class CustomException extends Exception {}
    
}