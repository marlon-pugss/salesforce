public class CaseRepository extends AbstractRepository{

    public Case findById (String recordId){
        List<Case> records = this.findById(new List<String>{recordId});

        return records.isEmpty() ? null : records[0];
    }
    
    public List<Case> findById (List<String> recordIds){
        return Database.query(getBaseQuery() + ' ,(SELECT OwnerId FROM LiveChatTranscripts) ' +
                              'FROM Case WHERE Id IN :recordIds ');
    }
        
    public List<Case> findById_WithChildCasesNotClosed (List<String> recordIds){
        return Database.query(getBaseQuery() + ' ,(SELECT Id FROM Cases WHERE Status NOT IN ( ' + Common.CASE_STATUSES_CLOSED_STRING + ' ) ) ' +
                              'FROM Case WHERE Id IN :recordIds ');
    }
    
    public List<Case> findByContractId_NotStatuses_RecordType (List<String> contractIds, List<String> statuses, String recordTypeId){
        return Database.query(getBaseQuery() + 
                              'FROM Case ' +
                              'WHERE Contract__c IN :contractIds ' +
                              'AND	 RecordTypeId = :recordTypeId ' +
                              'AND   Status NOT IN :statuses');
    }
    
    public List<Case> findByContractId_NotStatuses_RecordType_NonQueueForDistribution (List<Contract> contracts, List<String> statuses, String recordTypeId, String nonQueueForDistribution){
        return Database.query(getBaseQuery() + 
                              'FROM Case ' +
                              'WHERE Contract__c IN :contracts ' +
                              'AND   Status NOT IN :statuses ' +
                              'AND	 RecordTypeId = :recordTypeId ' +
                              'AND	 QueueForDistribution__c != :nonQueueForDistribution ');
    }
    
    public List<AggregateResult> findByOwnersAndOpen (Set<Id> users){
        return [SELECT   OwnerId, count(id) 
                FROM	 Case 
                WHERE    IsClosed = FALSE
                AND      OwnerId IN :users
                GROUP BY OwnerId
                ORDER BY count(Id)];
    }
    
    public List<Case> findByAccountPhone_NotClosed_PaymentOrderIsNotNull (List<String> phones){
        return Database.query(getBaseQuery() + 
                              'FROM  Case ' +
                              'WHERE Account.FullPhone__c IN :phones ' +
                              'AND   IsClosed = FALSE ' + 
                              'AND   PaymentOrder__c != null ' +
                              'ORDER BY createdDate ASC');
    }
    
    public List<Case> findById_Open_OwnerNotAdmin_Billing_ContactIdNotNull(List<String> recordIds) {
        return Database.query(getBaseQuery() +
                              'FROM	 Case ' +
                              'WHERE Id IN :recordIds ' +
                              'AND	 IsClosed = FALSE ' +
                              'AND	 Owner.Profile.Name NOT IN ( ' + Common.ADMIN_PROFILES_STRING + ' ) ' +
                              'AND	 RecordTypeId = \'' + Common.CASE_RT_ID_BILLING + '\'' +
               				  'AND	 ContactId != NULL ' +
                              'ORDER BY CreatedDate');
    }
    
    public String findByIdReturningQuery(){
        return getBaseQuery() + 'FROM Case WHERE ID IN :caseIdsQuery';
    }
    
    public String findBy_Open_QueueForDistribution_OwnerAdmin() {
        return getBaseQuery() +
               'FROM	 Case ' +
               'WHERE	 IsClosed = FALSE ' +
               'AND		 QueueForDistribution__c IN :queuesForDistribution ' +
               'AND		 Owner.Profile.Name IN ( ' + Common.ADMIN_PROFILES_STRING + ' ) ' +
               'ORDER BY CreatedDate';
    }

    public String findBy_Id_QueueForDistribution_OwnerAdmin() {
        return getBaseQuery() +
               'FROM	 Case ' +
               'WHERE	 QueueForDistribution__c IN :queuesForDistribution ' +
               'AND		 Owner.Profile.Name IN ( ' + Common.ADMIN_PROFILES_STRING + ' ) ' +
               'AND      ID IN :caseIdsQuery ' +
               'ORDER BY CreatedDate';
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, SuppliedName, SuppliedEmail, SuppliedPhone, OwnerId, Origin, Status, Subject, AccountId, ContactId, ContactPhone, ' + 
               '	   RecordTypeId, LastModifiedDate, CreatedDate, ParentId, ClosedDate, ' +
               '       QueueForDistribution__c, Contract__c, PaymentOrder__c, Tema_Theme__c, Product__c, Produto_Espec_fico__c, NumberOfDelayedOrders__c, ' + 
               '	   MotivoContato__c, MotivoFechamento__c, Sub_motivo_do_fechamento__c, ' +
               '	   PaymentOrder__r.Installment__c, Account.FullPhone__c, Owner.isActive ';
    }
    
}