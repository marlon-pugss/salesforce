public class FillStudyPlatformFields {

    @TestVisible private AccountRepository accountRepository;
    @TestVisible private ContactRepository contactRepository;
    @TestVisible private FindAccountHelper findAccountHelper;
    
    public FillStudyPlatformFields(){
        accountRepository = new AccountRepository();
        contactRepository = new ContactRepository();
        findAccountHelper = new FindAccountHelper();
    }
    
    public void fillAccountIdFields(List<StudyPlatform__c> newStudyPlatform ){  
        
        List<String> studyPlatformEmails    = ListHelper.convertObjectListIntoStringList('Email__c', newStudyPlatform);   
        Map<String, String> accountsByEmail = findAccountHelper.findAccountIdInAccountOrContactByEmail(studyPlatformEmails);
        LogInterfaceHelper logHelper 		= LogInterfaceHelper.getInstance();        
        
        for(StudyPlatform__c sp : newStudyPlatform){ 
            if(sp.Email__c != null && accountsByEmail.get(sp.Email__c) != null )
                sp.Account__c = accountsByEmail.get(sp.Email__c); 
            else 
                logHelper.addError('Conta não encontrada para este email: ' + sp.Email__c, 'ERRO');
        }
    } 
}