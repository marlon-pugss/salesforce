public class CreateCaseFromPaymentOrder{
    
    @TestVisible private CaseRepository caseRepository;
    @TestVisible private ContractRepository contractRepository;
    @TestVisible private PaymentOrderRepository paymentOrderRepository;
    @TestVisible private FindAccountHelper findAccountHelper;
    GeneralParameters__c parameters = GeneralParameters__c.getInstance();
    DateTime createdDateToCaseRetentionDelayDays;
        
    public CreateCaseFromPaymentOrder(){
        caseRepository		                = new CaseRepository();
        contractRepository                  = new ContractRepository();
        paymentOrderRepository              = new PaymentOrderRepository();
        findAccountHelper					= new FindAccountHelper();
        createdDateToCaseRetentionDelayDays = Date.today().addDays(-1 * Integer.valueOf(parameters.CaseRetentionDelayDays__c));
    }
    
    public void createCases(Map<Id, sObject> newPaymentOrders, Map<Id, sObject> oldPaymentOrders){
        
        List<Case> casesToUpsert					 = new List<Case>();
        List<PaymentOrder__c> paymentOrdersToCheck	 = paymentOrderRepository.findById(ListHelper.convertSetIdsToListString(newPaymentOrders.keySet()));
        List<String> contractIds					 = ListHelper.convertObjectListIntoStringList('Contract__c', newPaymentOrders.values());
        List<Case> openCasesFromContracts			 = caseRepository.findByContractId_NotStatuses_RecordType(contractIds, Common.CASE_STATUSES_CLOSED, Common.CASE_RT_ID_BILLING);
        Map<String, sObject> openCasesByPaymentOrder = ListHelper.indexListByField('PaymentOrder__c', openCasesFromContracts);         
        Map<String, List<Case>> openCasesByContract	 = getCasesByContract(openCasesFromContracts);    
        
        try{
            for (PaymentOrder__c paymentOrder : paymentOrdersToCheck){
                                
                PaymentOrder__c oldPaymentOrder = (oldPaymentOrders != null && oldPaymentOrders.containsKey(paymentOrder.Id)) ? (PaymentOrder__c) oldPaymentOrders.get(paymentOrder.Id) : null;
                Case caseFromPaymentOrder       = openCasesByPaymentOrder.containsKey(paymentOrder.Id) ? (Case) openCasesByPaymentOrder.get(paymentOrder.Id) : null;
                
                if (orderHasStatusAnd_IsInsertTriggerOrStatusHasChanged(paymentOrder, oldPaymentOrder)){
                    if (paymentOrder.Status__c.containsIgnoreCase(Common.ORDER_STATUS_PAID))
                        casesToUpsert.addAll(closeCaseFromPaidOrders(paymentOrder, openCasesByContract));
                    
                    else if (orderHasPaymentDateAnd_isDisputeStatus(paymentOrder))
                        casesToUpsert.add(manageCaseForDisputeOrders(paymentOrder, caseFromPaymentOrder));
                }
            }
        }
        catch(Exception ex){
            LogInterfaceHelper.getInstance().addError(ex);
            LogInterfaceHelper.getInstance().createLog('CreateCaseFromPaymentOrder ERROR');
        }
        
        if (Utils.isFilled(casesToUpsert))
            caseRepository.save(casesToUpsert);
    }
    
    private Boolean orderHasStatusAnd_IsInsertTriggerOrStatusHasChanged(PaymentOrder__c paymentOrder, PaymentOrder__c oldPaymentOrder){
        return paymentOrder.Status__c != null && (Trigger.isInsert || oldPaymentOrder.Status__c != paymentOrder.Status__c);
    }
    
    private Boolean orderHasPaymentDateAnd_isDisputeStatus(PaymentOrder__c paymentOrder){
        return paymentOrder.PaymentDate__c != null && Common.ORDER_STATUSES_DISPUTE.contains(paymentOrder.Status__c.toUpperCase());
    }

    private Case createNewCase (PaymentOrder__c paymentOrder, String queueForDistribution, String ownerId, String type){
        
        String priority	 = Common.ORDER_STATUS_WITH_HIGH_PRIORITY.contains(paymentOrder.Status__c.toUpperCase()) ? Common.HIGH : Common.MEDIUM;
        String subject 	 = paymentOrder.Name + ' - ' + String.valueOf(paymentOrder.PaymentDate__c.format()).left(10) + ' - ' + paymentOrder.Status__c;
        String accountId = paymentOrder.Contract__r.AccountId;
                
        return new CaseBuilder().origin(Common.CASE_ORIGIN_SALES)
                                .status(Common.NOVO)
                                .contract(paymentOrder.Contract__r.Id)
                                .paymentOrder(paymentOrder.Id)
                                .ownerId(ownerId)
                                .queueForDistribution(queueForDistribution)
            					.priority(priority)
                                .subject(subject)
            					.accountId(accountId)
                                .type(type)
                                .suppliedEmail(paymentOrder.Contract__r.Account.Email__c)
                                .recordTypeId(type == Common.CASE_TYPE_CHARGE ? Common.CASE_RT_ID_BILLING : Common.CASE_RT_ID_DEFAULT)
                                .build();
    }
    
    private Case closeCase (String caseId, String closingReason) {    
        return new CaseBuilder().id(caseId)
                                .status(Common.FECHADO)
                                .closingReason(closingReason)
                                .build();   
    }

    private Case updateCase (String orderId, PaymentOrder__c paymentOrder){
        
        String priority	   = Common.ORDER_STATUS_WITH_HIGH_PRIORITY.contains(paymentOrder.Status__c.toUpperCase()) ? Common.HIGH : Common.MEDIUM;
        String dateSubject = String.valueOf(paymentOrder.PurchaseDate__c != null ? paymentOrder.PurchaseDate__c.format() : paymentOrder.CreatedDate.format()).left(10);
        String subject	   = paymentOrder.Name + ' - ' + dateSubject + ' - ' + paymentOrder.Status__c.toUpperCase();
                
        return new CaseBuilder().Id(orderId)
            					.priority(priority)
                                .subject(subject)
                                .build();   
    }
    
    private Map<String, List<Case>> getCasesByContract(List<Case> openCasesFromContracts){
        
        Map<String, List<Case>> casesByContract = new Map<String, List<Case>>();
        
        for (Case caze : openCasesFromContracts){
            if (casesByContract.get(caze.Contract__c) != null)
                casesByContract.get(caze.Contract__c).add(caze);
            else
                casesByContract.put(caze.Contract__c, new List<Case>{caze});
        }
        
        return casesByContract;
    }
    
    private List<Case> closeCaseFromPaidOrders(PaymentOrder__c paymentOrder, Map<String, List<Case>> openCasesByContract){
        List<Case> casesFromContract = openCasesByContract.containsKey(paymentOrder.Contract__c) ? openCasesByContract.get(paymentOrder.Contract__c) : null;
        List<Case> casesToClose		 = new List<Case>();
        
        if (Utils.isFilled(casesFromContract)){
            
            for (Case caze : casesFromContract){
                if (paymentOrder.Installment__c > 1 && caze.Contract__c == paymentOrder.Contract__c && caze.PaymentOrder__c == paymentOrder.Id)
                    casesToClose.add(closeCase(caze.Id, Common.CASE_COMPLETED_PAYMENT));
            }
        }
        
        return casesToClose;
    }
    
    private Case manageCaseForDisputeOrders(PaymentOrder__c paymentOrder, Case caseFromPaymentOrder){
        if (caseFromPaymentOrder != null && !caseFromPaymentOrder.Subject.contains(paymentOrder.Status__c)){
            return updateCase(caseFromPaymentOrder.Id, paymentOrder);                       
        }                        
        else {
            String queueForDistribution = paymentOrder.Contract__r.CreatedDate > createdDateToCaseRetentionDelayDays ? Common.CASE_QUEUE_FOR_DISTRIBUTION_SALES_RETENTION : Common.CASE_QUEUE_FOR_DISTRIBUTION_FINANCIAL_RETENTION_BRASIL;
            return createNewCase(paymentOrder, queueForDistribution, Common.USER_ID_SERVICE_CX, Common.CASE_TYPE_RETENTION);
        } 
    }
    
}