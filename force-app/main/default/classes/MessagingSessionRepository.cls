public class MessagingSessionRepository extends AbstractRepository{

    public MessagingSession findById (String recordId){
        List<MessagingSession> records = this.findById(new List<String>{recordId});

        return records.isEmpty() ? null : records[0];
    }

    public List<MessagingSession> findById (List<String> recordIds){
        return Database.query(getBaseQuery() + 
                              'FROM MessagingSession ' +
                              'WHERE Id IN :recordIds ');
    }

    public List<MessagingSession> findById_OpportunityIdINull(Set<String> recordIds){
        return Database.query(getBaseQuery() + 
                              'FROM MessagingSession ' +
                              'WHERE Id IN :recordIds ' +
                              'AND   OpportunityId = null ');
    }
    
    public List<MessagingSession> findByLeadId_OpportunityIdINull (Set<String> leadIds) {
        return Database.query(getBaseQuery() + 
                              'FROM	 MessagingSession ' + 
                              'WHERE LeadId IN :leadIds ' +
                              'AND   OpportunityId = null ');
    }
    
    public List<MessagingSession> findByOpportunityId_NotStatus (Set<Id> oppIds, Set<String> statuses) {
        return Database.query(getBaseQuery() + 
                              'FROM	 MessagingSession ' + 
                              'WHERE OpportunityId IN :oppIds ' + 
                              'AND	 Status NOT IN :statuses');
    }

    public List<MessagingSession> findByOwnerId_StatusNotEnded (List<String> userIds){
        return Database.query(getBaseQuery() + 
                              'FROM MessagingSession ' +
                              'WHERE OwnerId = :userIds ' +
                              'AND Status != \'' + Common.ENDED + '\'');
    }

    public List<MessagingSession> findByWhatsappPhone_StatusNotEnded (Set<String> whatsappPhones){
        return Database.query(getBaseQuery() + 
                              'FROM MessagingSession ' +
                              'WHERE WhatsappPhone__c = :whatsappPhones ' +
                              'AND Status != \'' + Common.ENDED + '\'');
    }

    private String getBaseQuery(){
        return 'SELECT Id, Status, CaseId, LeadId, OwnerId, ChannelType, OpportunityId, CreatedDate,' +
               '       Email__c, FullPhone__c, WhatsappPhone__c, PaymentOrder__c, LastMessage__c, LastMessageDate__c, ' +
               '	   EndUserAccount.Name, Conversation.ConversationIdentifier,  ' +
               '       Opportunity.Name, Opportunity.StageName, Opportunity.LeadSource ';
    }
}