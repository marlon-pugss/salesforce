public with sharing class CaseOrderTableController {
    private static final Integer MAX_RECORDS           = 20000;
    private static Set<Id> contractIds                 = new Set<Id>();
    private static Map<Id, List<Case>> contractToCases = new Map<Id, List<Case>>();
    private static List<CaseOrderRow> rows 			   = new List<CaseOrderRow>();

    @AuraEnabled(cacheable=true)
    public static DataWrapper getCaseOrderRows(Date startDate, Date endDate, List<String> statusList) {
        try {
            
            statusList = Utils.isFilled(statusList) ? statusList : Common.ORDER_STATUSES_DELAYED;
            
            List<PaymentOrder__c> orders = [SELECT Id, Name, Status__c, Contract__c, OrderDate__c, CreatedDate, PaymentLink__c,
                                            	   Contract__r.Account.Name, Contract__r.AccountEmail__c, Contract__r.NumberOfDelayedOrders__c
                                            FROM  PaymentOrder__c
                                            WHERE OrderDate__c >= :startDate
                                            AND   OrderDate__c <= :endDate
                                            AND   Status__c IN :statusList
                                            AND   Contract__r.NumberOfDelayedOrders__c IN (1,2,3)
                                            ORDER BY OrderDate__c DESC];
            
            if (orders.size() > MAX_RECORDS) {
                DataWrapper limitExceeded = new DataWrapper();
                limitExceeded.totalRecords = orders.size();
                limitExceeded.exceedsLimit = true;
                return limitExceeded;
            }
            
            for (PaymentOrder__c order : orders) {
                if (order.Contract__c != null)
                    contractIds.add(order.Contract__c);
            }
            
            List<Case> casesToTable = [SELECT Id, Owner.Name, Owner.Email, Account.Name, Account.Email__c, FullPhone__c, 
                                       		  Contact.Phone, Contract__c, Contract__r.NumberOfDelayedOrders__c
                                       FROM  Case
                                       WHERE Contract__c IN :contractIds
                                       AND   RecordTypeId = :Common.CASE_RT_ID_BILLING
                                       AND   Contract__r.NumberOfDelayedOrders__c IN (1,2,3)
                                       AND   IsClosed = false];
            
            for (Case caze : casesToTable) {
                if (!contractToCases.containsKey(caze.Contract__c)) 
                    contractToCases.put(caze.Contract__c, new List<Case>());
                
                contractToCases.get(caze.Contract__c).add(caze);
            }
            
            for (PaymentOrder__c order : orders) {
                if (order.Contract__c != null) {
                    List<Case> cases = contractToCases?.get(order.Contract__c);
                    if (Utils.isFilled(cases)) {
                        for (Case caze : cases) {
                            rows.add(new CaseOrderRow(
                                caze.Owner.Name,
                                caze.Owner.Email,
                                caze.Account.Name,
                                caze.Account.Email__c,
                                caze.FullPhone__c,
                                caze.Contact.Phone,
                                caze.Id,
                                order.Id,
                                order.OrderDate__c,
                                order.Contract__c,
                                caze.Contract__r.NumberOfDelayedOrders__c,
                                order.PaymentLink__c
                            ));
                            break;
                        }
                    } else {
                        rows.add(new CaseOrderRow(
                            null,   
                            null,   
                            order.Contract__r.Account.Name,   
                            order.Contract__r.AccountEmail__c,  
                            null,   
                            null,   
                            null,   
                            order.Id,
                            order.OrderDate__c,
                            order.Contract__c,
                            order.Contract__r.NumberOfDelayedOrders__c,
                            order.PaymentLink__c
                        ));
                    }
                }
            }

            DataWrapper wrapper  = new DataWrapper();
            wrapper.records      = rows;
            wrapper.totalRecords = rows.size();
            wrapper.exceedsLimit = false;
            wrapper.startDate    = startDate;
            wrapper.endDate      = endDate;
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao buscar dados: ' + e.getMessage());
        }
    }

    public class DataWrapper {
        @AuraEnabled public List<CaseOrderRow> records;
        @AuraEnabled public Integer totalRecords;
        @AuraEnabled public Boolean exceedsLimit;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
    }

    public class CaseOrderRow {
        @AuraEnabled public String ownerName;
        @AuraEnabled public String ownerEmail;
        @AuraEnabled public String accountName;
        @AuraEnabled public String accountEmail;
        @AuraEnabled public String fullPhone;
        @AuraEnabled public String contactPhone;
        @AuraEnabled public String caseId;
        @AuraEnabled public String paymentOrderId;
        @AuraEnabled public Date orderDate;
        @AuraEnabled public String contractId;
        @AuraEnabled public Decimal delayedOrders;
        @AuraEnabled public String paymentLink;

        public CaseOrderRow(
            String ownerName,
            String ownerEmail,
            String accountName,
            String accountEmail,
            String fullPhone,
            String contactPhone,
            String caseId,
            String paymentOrderId,
            Date orderDate,
            String contractId,
            Decimal delayedOrders,
            String paymentLink
        ) {
            this.ownerName = ownerName;
            this.ownerEmail = ownerEmail;
            this.accountName = accountName;
            this.accountEmail = accountEmail;
            this.fullPhone = fullPhone;
            this.contactPhone = contactPhone;
            this.caseId = caseId;
            this.paymentOrderId = paymentOrderId;
            this.orderDate = orderDate;
            this.contractId = contractId;
            this.delayedOrders = delayedOrders;
            this.paymentLink = paymentLink;
        }
    }
}