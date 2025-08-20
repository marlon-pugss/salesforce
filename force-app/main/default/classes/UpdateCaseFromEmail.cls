public class UpdateCaseFromEmail {
    
    @TestVisible CaseRepository caseRepository;
    String typeFieldValidationRuleMessage = 'Preencha o campo &quot;Tipo&quot; para continuar';
    
    public UpdateCaseFromEmail(){
        caseRepository  = new CaseRepository();
    }

	public void updateCasesFromEmail(List<EmailMessage> newEmails){
        LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
        List<String> caseIds = ListHelper.convertObjectListIntoStringList('ParentId', newEmails);
        List<Case> casesToCheck = caseRepository.findById_WithChildCasesNotClosed(caseIds);
        List<Case> casesToUpsert = new List<Case>();
        Map<String, sObject> casesById = ListHelper.indexListByField('Id', casesToCheck);
        
        try{
            for (EmailMessage email : newEmails){

                Case caze = email.ParentId == null ? null : (Case) casesById.get(email.ParentId);

                if (caze == null || caze.RecordTypeId == Common.CASE_RT_ID_BILLING) continue;
                              
                if (isEmailFromAgent_AndCaseStatusDifferentThanWaitingStudent_AndClosingReasonDifferentThanSpamAndOpenedByEmail(email, caze)){
                    casesToUpsert.add(new CaseBuilder().id(caze.Id)
                                                        .status(Common.CASE_STATUS_WAITING_STUDENT)
                                                        .build());
                } 
				else if (isEmailFromClient(email)){
                    if (isCaseWaitingStudent_OrClosedIn24Hours(caze)){
                        casesToUpsert.add(new CaseBuilder().id(caze.Id)
                                                           .status(Common.CASE_STATUS_WAITING_AGENT)
                                                           .build());
                    } 
					else if (isCaseClosedMoreThan24Hours_AndDontHaveOpenChildCases(caze)){
                        logHelper.addMessage('Caso pai: ' + caze.Id, 'Criação de caso filho');
                        casesToUpsert.add(new CaseBuilder().parentId(caze.Id)
                                                           .origin(caze.Origin)
                                                           .ownerId(caze.Owner.isActive ? caze.OwnerId : Common.USER_ID_SERVICE_CX)
                                                           .accountId(caze.accountId)
                                                           .contactId(caze.contactId)
                                                           .suppliedEmail(caze.suppliedEmail)
                                                           .suppliedPhone(caze.suppliedPhone)
                                                           .subject('[RETORNO] - ' + caze.Subject)
                                                           .theme(caze.Tema_Theme__c)
                                                           .product(caze.Product__c)
                                                           .specificProduct(caze.Produto_Espec_fico__c)
                                                           .mainSituation(caze.MotivoContato__c)
                                                           .specificSituation(caze.MotivoFechamento__c)
                                                           .appliedSolution(caze.Sub_motivo_do_fechamento__c)
                                                           .build());
                    }
                }
            }
            
            if (casesToUpsert.size() > 0) caseRepository.save(casesToUpsert);
        } 
		catch(Exception ex){
            if (!ex.getMessage().contains(typeFieldValidationRuleMessage)) 
                logHelper.addError(ex);
        } 
		finally{
            if (logHelper.size() > 0)
                logHelper.createLog(String.valueOf(this).split(':')[0] + (logHelper.hasErrors() ? ' ERROR' : '') );
        }
    }
    
    private Boolean isEmailFromClient(EmailMessage email){
        return !email.FromAddress.contains(Common.FLUENCY_EMAIL_DOMAIN);
    }
    
    private Boolean isEmailFromAgent_AndCaseStatusDifferentThanWaitingStudent_AndClosingReasonDifferentThanSpamAndOpenedByEmail(EmailMessage email, Case caze){
        return caze.Status != Common.CASE_STATUS_WAITING_STUDENT && 
               email.FromAddress != Common.CX_SERVICE_EMAIL &&
               email.FromAddress.contains(Common.FLUENCY_EMAIL_DOMAIN) &&
               !Common.CASE_CLOSING_REASONS_SPAM_AND_OPENED_BY_EMAIL.contains(caze.MotivoFechamento__c);
    }

    private Boolean isCaseWaitingStudent_OrClosedIn24Hours(Case caze){
        return caze.Status == Common.CASE_STATUS_WAITING_STUDENT ||
              (caze.Status == Common.FECHADO && caze.ClosedDate >= System.now().addDays(-1) );
    }
    
    private Boolean isCaseClosedMoreThan24Hours_AndDontHaveOpenChildCases(Case caze){
        return caze.Status == Common.FECHADO && caze.ClosedDate < System.now().addDays(-1) && caze.Cases.size() == 0;
    }
    
}