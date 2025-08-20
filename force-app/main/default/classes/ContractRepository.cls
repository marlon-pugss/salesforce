public class ContractRepository extends AbstractRepository{

    public Contract findById (String recordId) {
        List<Contract> records = this.findById( new List<String>{recordId} );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<Contract> findById (List<String> recordIds) {
        return Database.query(getBaseQuery() + 
                              ', (SELECT Id, ProductCode__c, BundleCode__c, DataInicio__c, DataFim__c FROM Cursos__r), ' +
                              '  (SELECT Id FROM Opportunities) ' + 
                              'FROM	 Contract ' +
                              'WHERE Id IN :recordIds');
    }
    
    public List<Contract> findById_OpportunityNotNull (Set<String> recordIds) {
        return Database.query(getBaseQuery() + 
                              'FROM	 Contract '  +
                              'WHERE Id IN :recordIds ' +
                              'AND   Opportunity__c != null');
    }
    
    public Contract findByContractCode(String contractCode, String accountId){
        List<Contract> contracts = Database.query(getBaseQuery() +
                                                  'FROM	 Contract ' +
                                                  'WHERE AccountId = :accountId ' + 
                                                  'AND   CodigoContrato__c = :contractCode');
        
        return (contracts == null || contracts.isEmpty()) ? null : contracts[0];
    }
    
    public List<Contract> findByContractCode (String contractCode) {
        return Database.query(getBaseQuery() +
                              'FROM	 Contract ' +
                              'WHERE CodigoContrato__c = :contractCode ');
    }
    
    public List<Contract> findByAccountEmail_AndStatus (List<String> emails, String status) {
        return Database.query(getBaseQuery() +
                              'FROM		Contract ' +
                              'WHERE	Account.Email__c IN :emails ' + 
                              'AND		Status = :status ' + 
                           	  'ORDER BY CreatedDate DESC');
    }
    
    public List<Contract> findById_AndCompliant_AndHasOrderInStatusLessThanDays (Set<Id> contractIds, Boolean compliancy, List<String> orderStatuses, Date dateToCheck) {
        return Database.query(getBaseQuery() + 
                              'FROM	 Contract ' +
                              'WHERE Id IN :contractIds ' + 
                              'AND	 Compliant__c = :compliancy ' + 
                              'AND	 ID IN (SELECT Contract__c FROM PaymentOrder__c WHERE Status__c IN :orderStatuses AND OrderDate__c < :dateToCheck)');
    }

    public List<Contract> findById_WithProducts (List<String> recordIds) {
        return Database.query(getBaseQuery() + 
                              ', (SELECT Id, ProductCode__c, BundleCode__c, DataInicio__c, DataFim__c FROM Cursos__r), ' +
                              '  (SELECT Id FROM Opportunities) ' + 
                              'FROM	 Contract ' +
                              'WHERE Id IN :recordIds ' +
                              'AND	 Id IN (SELECT Contrato__c FROM ProdutoContratado__c)');
    }

    public List<Contract> findById_WithOnePaymentOrder_AndStatusNotCanceledAndInactive(List<String> recordIds) {
        List<String> statusToNotCancel = Common.CONTRACT_STATUSES_CANCELED_AND_FINISHED_AND_INACTIVE;
        return Database.query(getBaseQuery() + 
                              ', (SELECT Id, ProductCode__c, BundleCode__c, DataInicio__c, DataFim__c FROM Cursos__r), ' +
                              '  (SELECT Id FROM Opportunities) ' + 
                              'FROM	 Contract ' +
                              'WHERE Id IN :recordIds ' + 
                              'AND	 PaymentOrderQuantity__c = 1 ' + 
                           	  'AND	 Status NOT IN :statusToNotCancel');
    }
    
    public List<Contract> findBy_ParentContract_AndNotStatus (Set<Id> recordIds, List<String> statuses) {
        return Database.query(getBaseQuery() + 
                              'FROM	 Contract ' +
                              'WHERE ParentContract__c IN :recordIds ' +
                              'AND	 Status NOT IN :statuses');
    }
    
    public String findById_ReturningQuery(){
        return getBaseQuery() + ', (SELECT Id, ProductCode__c, BundleCode__c, DataInicio__c, DataFim__c FROM Cursos__r) ' +
            					' FROM	Contract ' +
        						' WHERE Id IN :contractIdsQuery';
    }
    
    public String findByDateBiggerThanLastModifiedDate(){
        return getBaseQuery() + ', (SELECT Id, ProductCode__c, BundleCode__c, DataInicio__c, DataFim__c FROM Cursos__r) ' +
            					' FROM	Contract ' +
        						' WHERE LastModifiedDate >= :comparisionDate';
    }
    
    public String findByCompliant_AndHasOrderInStatusLessThanDays(Boolean compliancy, String orderStatuses, Integer daysToCheckCompliancy){
        return getBaseQuery() + ', (SELECT Id, ProductCode__c, BundleCode__c, DataInicio__c, DataFim__c FROM Cursos__r) ' +
            					' FROM	Contract ' +
        						' WHERE Compliant__c =  ' + compliancy +
            					' AND   ID IN (SELECT Contract__c FROM PaymentOrder__c ' +
            					'              WHERE Status__c IN ( ' + orderStatuses + ' ) ' +
            					'              AND OrderDate__c != LAST_N_DAYS:' + daysToCheckCompliancy + ' ) ';
            								
    }
    
    public String findByEndDateLessThanToday_AndNotStatus() {
        return getBaseQuery() + ', (SELECT Id, ProductCode__c, BundleCode__c, DataInicio__c, DataFim__c FROM Cursos__r) ' +
            					' FROM	Contract ' +
            					' WHERE EndDate < TODAY '+
            					' AND   Status NOT IN :statusToNotConsider';
    }
    
    public String findByOrderStatuses_OrderDate_RenewalFrequency_OverdueInstallments (String orderStatuses, Date dateToCheck, String renewalFrequency, Decimal overdueInstallments) {
        return getBaseQuery()  + ' FROM  Contract ' +
                                 ' WHERE LastPaymentOrder__r.Status__c IN ( ' + orderStatuses + ' ) '  +
                                 ' AND   LastPaymentOrder__r.OrderDate__c <= ' + String.valueOf(dateToCheck).left(10) +
                                 ' AND   PeriodoRenovacao__c = \'' + renewalFrequency + '\' ' +
                                 ' AND   NumberOfDelayedOrders__c >= ' + overdueInstallments;
    }
 
    public String findByStatus_CancellationReason_CancellationDate(String status, String cancellationReason, String cancellationDate){
        return getBaseQuery() + ' FROM	Contract ' +
        						' WHERE	Status = \'' + status + '\' ' +
            					' AND   CancellationReason__c = \'' + cancellationReason + '\' ' +
                                ' AND   CancellationDate__c >= ' + cancellationDate + 'T00:00:00.000-03:00 ' +
                                ' AND   CancellationDate__c <= ' + cancellationDate + 'T23:59:59.999-03:00 ';
    }
    
    public String findByStatus_CreatedDate_HasOpp_HasOppWithLead_LeadSourceFromOpp (Date dateToCheck, String leadSource) {
        return getBaseQuery()  + ' FROM  Contract ' +
                                 ' WHERE Status IN :statusToConsider ' +
                                 ' AND   CreatedDate >= ' + String.valueOf(dateToCheck) + 'T00:00:00.000-03:00 ' + 
                                 ' AND   CreatedDate <= ' + String.valueOf(dateToCheck) + 'T23:59:59.999-03:00 ' + 
                                 ' AND   Opportunity__c != null ' +
                                 ' AND   Opportunity__r.Lead__c != null ' +
                                 ' AND   Opportunity__r.LeadSource = \'' + leadSource + '\' ';
    }
 
    private String getBaseQuery(){
        return 'SELECT Id, Status, StartDate, EndDate, AccountId, ContractTerm, CreatedDate, LastModifiedDate, ContractNumber, ' + 
               '	   DataProximaCobranca__c, NumberOfDelayedOrders__c, ExternalId__c, Compliant__c, TipoContrato__c, Modality__c, ParentContract__c, Opportunity__c, ' + 
               '	   PurchaseOrigin__c, CancellationReason__c, OfferContractValue__c, ' +
               '	   Account.Name, Account.Email__c, Account.FluencyId__c, Account.Id, Account.FullPhone__c, ' + 
               '	   Opportunity__r.Brand__c, Opportunity__r.Lead__c, Opportunity__r.Vertical__c, ' +
               '	   LastPaymentOrder__r.Status__c, RecordType.DeveloperName ';
    }
    
}