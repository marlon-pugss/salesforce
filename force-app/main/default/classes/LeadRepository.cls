public class LeadRepository extends AbstractRepository{

    public Lead findById (String recordId) {
        List<Lead> records = this.findById(new List<String>{recordId});

        return records.isEmpty() ? null : records[0];
    }
    
    public List<Lead> findById (List<String> recordIds) {
        return Database.query(getBaseQuery() + 
                              'FROM	 Lead ' + 
                              'WHERE Id IN :recordIds');
    }
    
    public List<Lead> findByEmail_NotConverted_NotBrands (Set<String> emails, Set<String> notBrands) {
        return Database.query(getBaseQuery() + 
                              'FROM	 Lead ' + 
                              'WHERE Email__c IN :emails ' +
                              'AND	 isConverted = FALSE ' +
                              'AND	 Brand__c NOT IN :notBrands ');
    }
    
    public List<Lead> findByNotId_Email_NotConverted_ActiveOwner_NotOwner (List<Lead> recordIds, List<String> emails, Set<String> profiles) {
        return Database.query(getBaseQuery() + 
                              'FROM	 Lead ' + 
                              'WHERE Id NOT IN :recordIds ' + 
                              'AND	 Email__c IN :emails ' +
                              'AND	 isConverted = FALSE ' +
                              'AND	 Owner.isACTIVE = TRUE ' +
                              'AND	 Owner.Profile.Name NOT IN :profiles');
    }
    
    public List<Lead> findByNotConverted_Status_RecordTypeId_BetweenCreatedDate_Brand_LeadSource_Vertical_RecycleQuantity (String status, String recordTypeId, Date startDate, Date endDate, String brand, List<String> leadSources, String vertical, Integer recycleQtt, Integer maxRecycleQtt) {
        String query = getBaseQuery() + 
                       'FROM  Lead ' + 
            		   'WHERE isConverted = false ' +
            		   'AND	  Status = :status ' +  
            		   'AND	  RecordTypeId = :recordTypeId ' + 
                       'AND   CreatedDate >= ' + String.valueOf(startDate) + 'T00:00:00.000-03:00 ' +
                       'AND   CreatedDate <= ' + String.valueOf(endDate) + 'T23:59:59.999-03:00 ' +
                       'AND   Brand__c = :brand ' + 
            		   'AND	  (RecycleQuantity__c = null OR RecycleQuantity__c < :maxRecycleQtt) ';
        
        if (leadSources != null && leadSources.size() > 0)
            query += 'AND LeadSource IN :leadSources ';
        
        if (vertical != null && vertical != '')
            query += 'AND Vertical__c = :vertical ';
        
        if (recycleQtt != null)
            query += 'AND (RecycleQuantity__c = null OR RecycleQuantity__c <= :recycleQtt )';
                
        return Database.query(query);
    }
    
    public List<Lead> findByStatus_Substatus_notConverted_FullPhone_nullMS (String status, String substatus, List<String> fullPhones) {
        return Database.query(getBaseQuery() + 
                              'FROM	 Lead ' + 
                              'WHERE Status = :status ' + 
                              'AND	 Substatus__c = :substatus ' +
                              'AND	 isConverted = FALSE ' +
                              'AND	 FullPhone__c IN :fullPhones ' +
                              'AND	 MessagingSession__c = null');
    }
    
    public List<AggregateResult> findOwnersBy_NotConverted_Associated_Qualified_LeadSource(Set<Id> users, List<String> leadSources){
        return [SELECT	 OwnerId, count(id)
                FROM	 Lead
                WHERE	 IsConverted = FALSE
                AND		 AssociationToCampaign__c = :Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED
                AND      Status = :Common.LEAD_STATUS_QUALIFIED
                AND		 OwnerId IN :users
                AND		 LeadSource IN :leadSources
                GROUP BY OwnerId
                ORDER BY count(Id)];
    }
    
    public List<AggregateResult> findOwnersBy_NotConverted_AssocationToCampaign_Qualified_AndUsers(Set<Id> users, String associationToCampaign){
        return [SELECT	 OwnerId, count(id)
                FROM	 Lead
                WHERE	 IsConverted = FALSE
                AND		 AssociationToCampaign__c = :associationToCampaign
                AND      Status = :Common.LEAD_STATUS_QUALIFIED
                AND		 OwnerId IN :users
                GROUP BY OwnerId
                ORDER BY count(Id)];
    }
    
    public String findBy_NotConverted_StatusQualified_OwnerNotToRotate_AssociatedToCampaign_EmailNotNull_NotB2B(){
        return getBaseQuery() +
               'FROM  Lead ' +
               'WHERE isConverted = FALSE ' +
               'AND	  Status = \'' + Common.LEAD_STATUS_QUALIFIED + '\'' +
               'AND	  Owner.Profile.Name NOT IN (' + Common.PROFILES_TO_ROTATE_LEAD_STRING + ')' +
               'AND	  AssociationToCampaign__c = \'' + Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED + '\'' +
               'AND	  Email__c != NULL ' +
               'AND	  RecordTypeId NOT IN (\'' + Common.LEAD_RT_ID_B2B + '\')';
    }
    
    public String findById_NotConverted_EmailNotNull(){
        return getBaseQuery() +
               'FROM  Lead ' +
               'WHERE IsConverted = FALSE ' +
               'AND	  Email__c != NULL ' +
               'AND	  Id IN :leadIdsQuery';
    }
    
    public String findById_NotConverted_StatusNew_Owner_LeadSource(Set<Id> leadIdsQuery) {
        String query = getBaseQuery() +
                       'FROM  Lead ' +
                       'WHERE IsConverted = FALSE ' +
                       'AND   Status = \'Novo\'' +
                       'AND	  Owner.Profile.Name IN ( ' + Common.PROFILES_TO_ROTATE_LEAD_STRING + ' ) ' +
                       'AND	  CreatedDate >= 2023-04-11T03:00:00z ' +
                       'AND   LeadSource IN :leadSources ' +
                       'AND	  ((Email__c != NULL AND AssociationToCampaign__c = \'' + Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED + '\' )' +	
                       '		OR LeadSource = \'' + Common.LEAD_LEADSOURCE_REFERRAL_PROGRAM + '\' )';
        
                if (Utils.isFilled(leadIdsQuery))
                    query += 'AND Id IN :leadIdsQuery ';
        
        
        return query += 'ORDER BY CreatedDate';        
    }
    
    public String findBy_NotConverted_EmailNotNull_LeadSourceNotNull_WaitingAssociationToCampaign(){
        return getBaseQuery() + ', (SELECT Id, Campaign.Name FROM CampaignMembers) ' +
               'FROM   Lead ' +     
               'WHERE  IsConverted = FALSE ' +
               'AND	   Email__c != NULL ' +
               'AND	   LeadSource != NULL ' +
               'AND	   AssociationToCampaign__c = \'' + Common.LEAD_ASSOCIATION_TO_CAMPAIGN_WAITING + '\'' ;
    }
    
    public String findBy_NotConverted_Status_SubstatusNull_CreatedDate(String status, DateTime dateTimeToSetUnansweredLeads) {
        String referenceDate = String.valueOf(dateTimeToSetUnansweredLeads).left(10);
        
        return getBaseQuery() +
            'FROM	  Lead ' +
            'WHERE    IsConverted = FALSE ' +
            'AND 	  Status = \'' + status + '\' ' +
            'AND 	  Substatus__c = NULL ' +
            'AND   CreatedDate >= ' + referenceDate + 'T00:00:00.000-03:00 ' + 
            'AND   CreatedDate <= ' + referenceDate + 'T23:59:59.999-03:00' +
            'ORDER BY CreatedDate';
    }
    
    public String findBy_NotConverted_Status_LeadSource_CreatedDate_AndNotRecordType(Date leadReferenceDate) {
        String referenceDate = String.valueOf(leadReferenceDate).left(10);

        return getBaseQuery() +
                'FROM  Lead ' +
                'WHERE IsConverted = FALSE ' +
                'AND   Status NOT IN :statuses ' +
            	'AND   LeadSource IN :leadSources ' +
            	'AND   ((Email__c != NULL AND AssociationToCampaign__c = \'' + Common.LEAD_ASSOCIATION_TO_CAMPAIGN_ASSOCIATED + '\' )' +	
            	'		  OR LeadSource = \'' + Common.LEAD_LEADSOURCE_REFERRAL_PROGRAM + '\' ) '  +
                'AND   CreatedDate >= ' + referenceDate + 'T00:00:00.000-03:00 ' + 
                'AND   CreatedDate <= ' + referenceDate + 'T23:59:59.999-03:00 ' +
            	'AND   RecordTypeId NOT IN : notRecordTypes ' +
                'ORDER BY CreatedDate';
    }
    
    public String findBy_NotStatus_AndCreatedDate_AndRecordTypes_AndNotBrands(Integer daysToExpireLead){
        return getBaseQuery() +
               'FROM  Lead ' +
               'WHERE Status NOT IN :notStatuses ' +
               'AND   CreatedDate != LAST_N_DAYS: ' + daysToExpireLead + 
               'AND	  RecordTypeId IN :recordTypes ' +
               'AND	  Brand__c NOT IN :notBrands';
    }
    
    public String findByIdReturningQuery(){
        return getBaseQuery() + 'WHERE ID IN :leadIdsQuery';
    }
    
    private String getBaseQuery(){
        return 'SELECT Id, Name, FirstName, LastName, Phone, MobilePhone, Email, IsConverted, LeadSource, CreatedDate, Fax, Status, ' + 
               '	   RecordTypeId, ConvertedOpportunityId, ConvertedAccountId, ConvertedContactId, Owner.IsActive, ' +
               ' 	   Email__c, FullPhone__c, AssociationToCampaign__c, Brand__c, Vertical__c, RecycleQuantity__c, Substatus__c ';
    }
    
}