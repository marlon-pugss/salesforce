global without sharing class DW_FormularioContratacao {
    global OpportunityContactRole oppCr {get;set;}
    global Opportunity opportunity {get;set;}
    global String recordTypeId {get;set;}

    global DW_FormularioContratacao(ApexPages.StandardController controller){
        String recordId = ApexPages.currentPage().getParameters().get('recordId');
        opportunity = [SELECT AccountId FROM Opportunity WHERE Id = :recordId];
        List<OpportunityContactRole> oppCRList = [SELECT Id, ContactId
                             FROM OpportunityContactRole 
                             WHERE OpportunityId = :recordId
                             AND Role = 'Decisor'];
        if (oppCRList.size() > 0) {
            oppCr = oppCRList.get(0);
        }                     
        recordTypeId = Schema.SObjectType.FormularioPersonalizado__c.getRecordTypeInfosByName().get('Formulário de contratação Yowza').getRecordTypeId();
    }

    @RemoteAction
    global static String createRecord(String form){
        try{
            insert (FormularioPersonalizado__c)JSON.deserialize(form,FormularioPersonalizado__c.class);
            return 'success';
        }catch(Exception e){
            System.debug(e.getMessage());
            return e.getMessage();
        }
    }
}