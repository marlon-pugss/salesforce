public with sharing class AccountRepository extends AbstractRepository {
    
    public Account findById (String recordId) {
        List<Account> records = this.findById(new List<String>{recordId});
        
        return records.isEmpty() ? null : records[0];
    }
    
    public List<Account> findById(List<String> accountIds) {
        return Database.query(getBaseQuery() + ', ' +
                              '		(SELECT ' + getContractFields() +
                              '		 FROM Contracts ORDER BY LastModifiedDate DESC), ' +
                              '		(SELECT ' + getContactFields() + 
                              '		 FROM Contacts ORDER BY LastModifiedDate DESC), ' +
                              '		(SELECT ' + getOpportunityFields() +
                              ' 	 FROM Opportunities), ' +
                              '		(SELECT ' + getCaseFields() + 
                              ' 	 FROM Cases) ' +
                              'FROM	 Account ' +
                              'WHERE Id IN :accountIds');
    }
    
    public List<Account> findByEmail(List<String> emails) {
        return Database.query(getBaseQuery() + ', ' +
                              '		(SELECT ' + getContactFields() + 
                              ' 	 FROM Contacts), ' +
                              '		(SELECT ' + getOpportunityFields() +
                              ' 	 FROM Opportunities) ' +
                              'FROM	 Account ' +
                              'WHERE Email__c IN :emails ' +
                              'ORDER BY LastModifiedDate DESC');
    }
    
    public List<Account> findByPhone(List<String> phones) {
        return Database.query(getBaseQuery() + ', ' +
                              '		(SELECT ' + getContactFields() + 
                              '		 FROM Contacts), ' +
                              '		(SELECT ' + getOpportunityFields() +
                              '		 FROM Opportunities) ' +
                              'FROM	 Account ' +
                              'WHERE FullPhone__c IN :phones ' +
                              'ORDER BY LastModifiedDate DESC');
    }
    
    public List<Account> findById_ReturningActiveContracts(List<String> accountIds) {
        return Database.query(getBaseQuery() + ', ' +
                              '		(SELECT ' + getContractFields() +
                              ' 	 FROM Contracts WHERE Status = \'Ativo\') ' +
                              'FROM  Account ' +
                              'WHERE Id IN :accountIds');
    }
    
    public List<Account> findById_WithContactsWithoutFullPhone(Set<String> accountIds) {
        return Database.query(getBaseQuery() + ', ' +
                              '		(SELECT ' + getContactFields() + 
                              '		 FROM  Contacts ' +
                              ' 	 WHERE FullPhone__c = null) ' +
                              'FROM  Account ' +
                              'WHERE Id IN :accountIds ');
    }
    
    public List<Account> findById_WithLastModifiedContactsWithFullPhone(List<String> accountIds) {
        return Database.query(getBaseQuery() + ', ' +
                              '		(SELECT ' + getContactFields() + 
                              '		 FROM	  Contacts ' +
                              ' 	 WHERE	  FullPhone__c != null ' +
                              ' 	 ORDER BY LastModifiedDate DESC) ' +
                              'FROM  Account ' +
                              'WHERE Id IN :accountIds ');
    }
    
    public String findByIdWithoutFluencyId() {
        return getBaseQuery() + 'WHERE FluencyId__c = null AND Id IN :accountIds' +
            'FROM  Account';
    }
    
    public String findByContractsStatus_AndContractsStartDate(Integer lastNdays) {
        return getBaseQuery() + 
            ' FROM  Account ' +
            ' WHERE ID IN (SELECT AccountId ' + 
            '			   FROM	  Contract ' + 
            '			   WHERE  Status IN :statuses ' + 
            '			   AND	  StartDate != null AND StartDate != LAST_N_DAYS:' + lastNdays + ' )';
    }
    
    public String findByCaseType_AndCreatedDateThanNdays(Integer lastNdays) {
        return getBaseQuery() + 
            ' FROM  Account ' +
            ' WHERE ID IN (SELECT AccountId ' + 
            '			   FROM   Case ' + 
            '			   WHERE  Type = \'' + Common.CASE_TYPE_RETENTION + '\'' +
            '			   AND    CreatedDate != LAST_N_DAYS: '+ lastNdays + ')';
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, Phone, RecordTypeId, Email__c, NumberOfActiveContracts__c, FluencyID__c, FullPhone__c ';
    }
    
    private String getContactFields(){
        return 'Id, AccountId, Email__c, FullPhone__c, Account.Email__c ';
    }
    
    private String getContractFields(){
        return 'Id, Status, StartDate, Compliant__c ';
    }
    
    private String getOpportunityFields(){
        return 'Id, isClosed, StageName, RecordTypeId, OpportunitySource__c, B2BContract__c, ReferredByAccount__c, ParentContract__c ';
    }
    
    private String getCaseFields(){
        return 'Id, AccountId, Status, Type, CreatedDate, Contract__r.Status, isClosed ';
    }
    
}