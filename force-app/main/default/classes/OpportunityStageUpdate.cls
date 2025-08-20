public with sharing class OpportunityStageUpdate {
    @AuraEnabled
    public static void updateOpportunityStage(Id opportunityId, String stageName) {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        opp.StageName = stageName;
        update opp; // Atualiza a oportunidade no Salesforce
    }
}
