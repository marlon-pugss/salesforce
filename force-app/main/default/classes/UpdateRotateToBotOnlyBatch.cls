public class UpdateRotateToBotOnlyBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.StateFul {
    @TestVisible GeneralParametersRepository repository;
    
    public UpdateRotateToBotOnlyBatch(){
        repository  = new GeneralParametersRepository();
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id FROM Lead LIMIT 1');        
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
                
        GeneralParameters__c parameters = repository.findAllParameters(); 
        
        repository.save(new GeneralParametersBuilder().id(parameters.Id)
                                                      .rotateToBotOnly(parameters.rotateToBotOnly__c ? false : true)
                                                      .build());
    }

    public void finish(Database.BatchableContext context) {}
}