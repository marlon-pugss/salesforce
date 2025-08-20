public with sharing class OpportunityStageUpdateController {
    @AuraEnabled
    public static String getOpportunityId(Id messagingSessionId) {
        MessagingSession session = [SELECT OpportunityId FROM MessagingSession WHERE Id = :messagingSessionId LIMIT 1];
        return session.OpportunityId;
    }

    @AuraEnabled
    public static void updateStage(String stageName, Id recordId, String closingReason) {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :recordId LIMIT 1];
        opp.StageName = stageName;
        // Adicione a lógica para lidar com o motivo de fechamento, se necessário
        update opp;
    }
}