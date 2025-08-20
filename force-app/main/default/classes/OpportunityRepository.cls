public class OpportunityRepository extends AbstractRepository{

    public Opportunity findById ( String opportunityId ) {
        List<Opportunity> records = this.findById( new List<String> { opportunityId } );

        return records.isEmpty() ? null : records[0];
    }
    
    public List<Opportunity> findById ( List<String> opportunityIds ) {        
        return Database.query(getBaseQuery() + ', ' +
                              '(SELECT Id, OpportunityId, Quantity, UnitPrice, Product2Id, StartDate__c, EndDate__c, Duration__c, BundleCode__c, ' +
                              '		   Product2.Name, Product2.ProductCode, Product2.Family,  ' +
                              '		   Opportunity.AccountId, Opportunity.RecordTypeId  ' +
                              ' FROM   OpportunityLineItems),  ' +
                              '(SELECT Id, IsPrimary, Role, ContactId FROM OpportunityContactRoles)  ' +
                              'FROM	 Opportunity ' +
                              'WHERE Id IN :opportunityIds ');
    }
    
    public List<Opportunity> findByEmailAccount_ActiveOwner_NotStageNames(List<String> emails, Set<String> stageNames){
        return Database.query(getBaseQuery() + 
                              'FROM	 Opportunity ' +
                              'WHERE AccountEmail__c IN :emails ' +
                              'AND	 Owner.isActive = TRUE ' +
                              'AND	 StageName NOT IN :stageNames');
    }
    
    public List<Opportunity> findNotStageNames_Account_NotId_RecordType(Set<String> stageNames, Set<Id> accountIds, Set<Id> opportunityIds, Set<String> recordTypeIds){
        return Database.query(getBaseQuery() + 
                              'FROM	 Opportunity ' +
                              'WHERE StageName NOT IN :stageNames ' +
                              'AND	 AccountId IN :accountIds ' +
                              'AND	 ID NOT IN :opportunityIds ' +
                              'AND	 RecordTypeId IN :recordTypeIds');
    }
    
    public List<Opportunity> findNotStageNames_AccountEmail_RecordType(Set<String> stageNames, List<String> emails, Set<String> recordTypeIds){
        return Database.query(getBaseQuery() + 
                              'FROM	 Opportunity ' +
                              'WHERE StageName NOT IN :stageNames ' +
                              'AND	 AccountEmail__c IN :emails ' +
                              'AND	 RecordTypeId IN :recordTypeIds ' +
                              'ORDER BY CreatedDate');
    }
    
    public List<Opportunity> findById_AndLeadSources_WithoutContract (List<String> opportunityIds, Set<String> leadSources){
        return Database.query(getBaseQuery() + 'FROM  Opportunity ' +
                       						   'WHERE ID IN :opportunityIds ' +
                      						   'AND	  ContractId = NULL ' +
                      						   'AND	  LeadSource IN :leadSources');
    }
    
    public List<Opportunity> findBy_StageName_Journey_RecordTypeId_NotLeadSources_CreatedDateToday(String stageName, String stageNameOperator, String journey, String recordTypeId, Set<String> leadSources){        
        return Database.query(getBaseQuery() +
               'FROM Opportunity ' +
               'WHERE StageName ' + stageNameOperator +  '\'' + stageName + '\'' +
               'AND	  Journey__c = \'' + journey + '\'' +
               'AND   RecordTypeId = \'' + recordTypeId + '\'' +
			   'AND   LeadSource NOT IN :leadSources ' +
			   'AND   CreatedDate = TODAY ' + 
        	   'ORDER BY CreatedDate DESC');
    }
    
    public List<Opportunity> findByStageName_recordTypeId_BetweenCreatedDate_Brand_LeadSource_Vertical_RecycleQuantity(String stageName, String recordTypeId, Date startDate, Date endDate, String brand, List<String> leadSources, String vertical, Integer recycleQtt, Integer maxRecycleQtt) {
        String query = getBaseQuery() + 
                       'FROM  Opportunity ' + 
                       'WHERE StageName = :stageName ' + 
                       'AND	  RecordTypeId = :recordTypeId ' + 
                       'AND   CreatedDate >= ' + String.valueOf(startDate) + 'T00:00:00.000-03:00 ' +
                       'AND   CreatedDate <= ' + String.valueOf(endDate) + 'T23:59:59.999-03:00 ' +
                       'AND   Brand__c = :brand ' +
            		   'AND	  (RecycleQuantity__c = null OR RecycleQuantity__c < :maxRecycleQtt) ';
        
        if (leadSources != null && leadSources.size() > 0)
            query += ' AND LeadSource IN :leadSources';
        
        if (vertical != null && vertical != '')
            query += ' AND Vertical__c = :vertical';
        
        if (recycleQtt != null)
            query += ' AND (RecycleQuantity__c = null OR RecycleQuantity__c <= :recycleQtt )';
        
        return Database.query(query);
    }
    
    public List<Opportunity> findBy_NotStageName_RecordTypeId_FullPhone(Set<String> stageNames, Set<String> recordTypeIds, List<String> fullPhones){        
        return Database.query(getBaseQuery() +
               'FROM  Opportunity ' +
               'WHERE StageName NOT IN :stageNames ' +
               'AND   RecordTypeId  IN :recordTypeIds ' +
               'AND   FullPhone__c   = :fullPhones ' +
               'AND   FullPhone__c  != null ' +
               'ORDER BY CreatedDate');
    }
    
    public List<Opportunity> findBy_NotStageName_NotRecordTypeId_FullPhone(Set<String> stageNames, Set<String> recordTypeIds, List<String> fullPhones){        
        return Database.query(getBaseQuery() +
               'FROM  Opportunity ' +
               'WHERE StageName    NOT IN :stageNames ' +
               'AND   RecordTypeId NOT IN :recordTypeIds ' +
               'AND   FullPhone__c = :fullPhones ');
    }
    
    public List<Opportunity> findBy_StageName_AndLastModifiedDate(Set<String> stageNames, String lastModifiedDate ){
        return Database.query(getBaseQuery() + 'FROM  Opportunity ' +
                                               'WHERE StageName IN :stageNames ' +
                              				   'AND   LastModifiedDate >= ' + lastModifiedDate + 'T00:00:00.000-03:00 ' +
                              				   'AND   LastModifiedDate <= ' + lastModifiedDate + 'T23:59:59.999-03:00 ');
    }
    
    public List<AggregateResult> findOwnersBy_NotDuplicatedAnd_BetweenDates_Journey(Set<Id> users, Datetime startDateToCheck, Datetime endDateToCheck, String journey){
        String query = 'SELECT OwnerId, count(Id) FROM Opportunity ' +
                       'WHERE OwnerId IN :users ' +
                       'AND CreatedDate >= :startDateToCheck ' +
                       'AND CreatedDate < :endDateToCheck ' +
                       'AND	StageName NOT IN (\'' + Common.OPP_STAGENAME_DUPLICATED + '\')';
        
        query += journey == null ? '' : 'AND Journey__c = :journey ';
        
        query += 'GROUP BY OwnerId '+
                 'ORDER BY count(Id)';
        
        return Database.query(query);
    }
    
    public String findByIdReturningQuery(){
    	return getBaseQuery() + 'FROM Opportunity WHERE Id IN :opportunityIds';
    }

	public String findBy_OpenOpportunity_AndCreatedDate_AndNotRecordTypes_AndNotBrands(Integer daysToExpireOpportunity){
        return getBaseQuery() +
               'FROM Opportunity ' +
               'WHERE StageName NOT IN ( ' + Common.OPP_STAGENAMES_CLOSED_STRING + ' ) ' +
               'AND   CreatedDate != LAST_N_DAYS:' + daysToExpireOpportunity +
               'AND	  RecordTypeId NOT IN :notRecordTypes ' +
               'AND	  Brand__c NOT IN :notBrands';
    }
    
    public String findBy_OpenOpportunity_NotLossReasonExpireds_RecordTypeInsadeSales_NotFilledB2Bcontract_NotBrand_CreatedDateFromLead(Date oppReferenceDate){
        String referenceDate = String.valueOf(oppReferenceDate).left(10);
        
        return getBaseQuery() +
               'FROM Opportunity ' +
               'WHERE StageName NOT IN ( ' + Common.OPP_STAGENAMES_CLOSED_WIN_AND_DUPLICATED + ' ) ' +
               'AND   MotivoPerda__c NOT IN ( ' + Common.OPP_LOSS_REASON_EXPIREDS + ' ) ' +
               'AND   RecordTypeId = \'' + Common.OPP_RT_ID_INSIDESALES + '\'' +
               'AND   B2Bcontract__c = null ' +
               'AND   Brand__c NOT IN :notBrands ' +
               'AND   Lead__r.CreatedDate >= ' + referenceDate + 'T00:00:00.000-03:00 ' + 
               'AND   Lead__r.CreatedDate <= ' + referenceDate + 'T23:59:59.999-03:00';
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, CloseDate, StageName, isClosed, AccountId, LeadSource, OwnerId, RecordTypeId, CreatedDate, LastModifiedDate, Pricebook2Id, ' + 
               '	   FormaPagamento__c, ContractTerm__c, QuantidadeProdutos__c, TipoContrato__c, FullPhone__c, OmniChatLink__c, SendWhatsapp__c, '+
               ' 	   Brand__c, Vertical__c, Modality__c, RecycleQuantity__c, AccountEmail__c, ParentContract__c, Lead__c, '+
               '	   B2Bcontract__c, ReferredByAccount__c, Journey__c, PaymentLink__c, ' +
               '	   UTMsource__c, UTMmedium__c, UTMcampaign__c, UTMterm__c, UTMcontent__c, ' +
               ' 	   Account.Email__c, Account.Documento__c, Account.TipoDocumento__c, Account.NumberOfEmployees__c, Account.OperatingCountries__c, '+
               ' 	   Account.Name, Account.FluencyId__c, Account.OmnichatCustomerId__c, Account.FullPhone__c, '+
               '	   Account.BillingCity, Account.BillingCountry, Account.BirthDate__c, ' +
               ' 	   Owner.Email, RecordType.DeveloperName, Lead__r.CreatedDate ';
    }
    
}