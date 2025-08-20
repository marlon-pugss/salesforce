public class ChangeCaseFieldsRelatedToChat {
    
    @TestVisible private CaseRepository caseRepository;
    @TestVisible private FindAccountHelper findAccountHelper;
    
    public ChangeCaseFieldsRelatedToChat(){
        caseRepository    = new CaseRepository();
        findAccountHelper = new FindAccountHelper();
    }
    
    public void changeCaseFieldsRelatedToChat(List<LiveChatTranscript> newChats){
        
        List<Case> casesToUpdate                  = new List<Case>();
        List<String> caseIds                      = ListHelper.convertObjectListIntoStringList('CaseId', newChats);
        List<Case> casesFromChat				  = caseRepository.findById(caseIds);
        Map<String, sObject> casesBySuppliedEmail = ListHelper.indexListByField('SuppliedEmail', casesFromChat);
        Map<String, String> accountsByEmail       = findAccountHelper.findAccountIdInAccountByEmailOrCreateAccount(casesBySuppliedEmail);
        
        for (Case caze : casesFromChat){
            if (caze.Status != 'Fechado' && caze.Origin != 'Chat')
                casesToUpdate.add(new CaseBuilder().id(caze.Id)
                                                   .ownerId((String) caze.LiveChatTranscripts[0].get('OwnerId'))
                                                   .origin(Common.CASE_ORIGIN_CHAT)
                                                   .status(Common.FECHADO)
                                                   .closingReason(Common.CASE_CLOSED_BY_CHAT)
                                                   .accountId(accountsByEmail.containsKey(caze.SuppliedEmail) ? ((String) accountsByEmail.get(caze.SuppliedEmail)) : null)
                                                   .type(Common.CASE_TYPE_CHAT)
                                                   .build());
        }
        
        if (casesToUpdate.size() > 0)
          caseRepository.save(casesToUpdate);
    }
}