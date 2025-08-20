@isTest
public class PreventDeleteOpportunityLineItemTest {
    
    @testSetup
    private static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    private static void givenOpportunityWithOpportunityLineItem_WhenDeletedByAdmin_ThenDeleteOppLineItems(){
        
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                       .persist();
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        Product2 product			  = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry = PricebookEntryFixtureFactory.createGeneric(product.Id);
        OpportunityLineItem lineItem  = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, product.Id, pricebookEntry.Id);
        
        Test.startTest();
            System.runAs(new User(Id = Common.USER_ID_SF_EA)) {
                delete lineItem;
            }
        Test.stopTest();
        
        List<OpportunityLineItem> lineItemsReturned = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.areEqual(0, lineItemsReturned.size());
    }
    
    @isTest
    private static void givenOpportunityWithOpportunityLineItem_WhenDeletedByNonAdmin_ThenDontDeleteOppLineItems(){
        
        User user		= UserFixtureFactory.createGeneric();
        Account account = AccountFixtureFactory.createGeneric();
                
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .ownerId(user.Id)
                                                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                       .persist();
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        Product2 product			  = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry = PricebookEntryFixtureFactory.createGeneric(product.Id);
        OpportunityLineItem lineItem  = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, product.Id, pricebookEntry.Id);
                
        Test.startTest();
            try{
                System.runAs(new User(Id = user.Id)) {
                    delete lineItem;
                }
            }
            catch(Exception ex){
                Assert.isTrue(ex.getMessage().contains(Label.CantDeleteTheseRecords));
            }
        Test.stopTest();
        
        List<OpportunityLineItem> lineItemsReturned = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.areEqual(1, lineItemsReturned.size());
        
    }
    
    @isTest
    private static void givenOpportunityWithTwoOpportunityLineItem_WhenDeletedByAdmin_ThenDeleteOppLineItems(){
        
        Account account = AccountFixtureFactory.createGeneric();
                
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                       .persist();
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        Product2 product			   = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry  = PricebookEntryFixtureFactory.createGeneric(product.Id);
        
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        lineItems.add( OpportunityLineItemFixtureFactory.buildGeneric(opp.Id, product.Id, pricebookEntry.Id) );
        lineItems.add( OpportunityLineItemFixtureFactory.buildGeneric(opp.Id, product.Id, pricebookEntry.Id) );
        insert lineItems;
        
        Test.startTest();
            System.runAs(new User(Id = Common.USER_ID_SF_EA)) {
                delete lineItems;
            }
        Test.stopTest();
        
        List<OpportunityLineItem> lineItemsReturned = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.areEqual(0, lineItemsReturned.size());
    }
    
    @isTest
    private static void givenOpportunityWithTwoOpportunityLineItem_WhenDeletedByNonAdmin_ThenDontDeleteOppLineItems(){
        
        User user		= UserFixtureFactory.createGeneric();
        Account account = AccountFixtureFactory.createGeneric();
                
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .ownerId(user.Id)
                                                                       .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                       .persist();
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        Product2 product			   = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry  = PricebookEntryFixtureFactory.createGeneric(product.Id);
        
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        lineItems.add( OpportunityLineItemFixtureFactory.buildGeneric(opp.Id, product.Id, pricebookEntry.Id) );
        lineItems.add( OpportunityLineItemFixtureFactory.buildGeneric(opp.Id, product.Id, pricebookEntry.Id) );
        insert lineItems;
        
        Test.startTest();
            try{
                System.runAs(new User(Id = user.Id)) {
                    delete lineItems;
                }
            }
            catch(Exception ex){
                Assert.isTrue(ex.getMessage().contains(Label.CantDeleteTheseRecords));
            }
        Test.stopTest();
        
        List<OpportunityLineItem> lineItemsReturned = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.areEqual(2, lineItemsReturned.size());
    }
    
    @isTest
    private static void givenB2BopportunityWithOpportunityLineItem_WhenDeletedByNonAdmin_ThenDeleteOppLineItems(){
        
        User user		= UserFixtureFactory.createGeneric();
        Account account = AccountFixtureFactory.createGeneric();
                
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .stageName('Pendente')
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .accountId(account.Id)
                                                                       .contractType('Parceria')
                                                                       .modality('Charged')
                                                                       .ownerId(user.Id)
                                                                       .recordTypeId(Common.OPP_RT_ID_B2B)
                                                                       .persist();
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        Product2 product			  = ProductFixtureFactory.createGeneric();
        PricebookEntry pricebookEntry = PricebookEntryFixtureFactory.createGeneric(product.Id);
        OpportunityLineItem lineItem  = OpportunityLineItemFixtureFactory.createGeneric(opp.Id, product.Id, pricebookEntry.Id);
        
        Test.startTest();
            System.runAs(new User(Id = user.Id)) {
                delete lineItem;
            }
        Test.stopTest();
        
        List<OpportunityLineItem> lineItemsReturned = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        Assert.areEqual(0, lineItemsReturned.size());
    }
    
}