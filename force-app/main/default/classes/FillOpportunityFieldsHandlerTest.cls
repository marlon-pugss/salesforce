@isTest
public class FillOpportunityFieldsHandlerTest {

    public static final String LEAD_SOURCE	= 'LEAD_SOURCE';
    public static final String LEAD_SOURCE2 = 'LEAD_SOURCE_2';
    
    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
    }
    
    @isTest
    public static void givenAnOpportunityWithoutPricebook_WhenInsertIt_ThenFillPricebook(){
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName('Pendente')
                                                                       .recordTypeId(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId())
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .object();
        
        Map<String, String> pricebooksByOpportunitiesRecordTypes = Utils.getEnabledPricebooksToOpportunitiesMetadata();
            
        Test.startTest();
        	insert opp;
        Test.stopTest();
        
        Opportunity returnedOpp = [SELECT Id, RecordTypeId, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id];
        
        String expectedPricebook = pricebooksByOpportunitiesRecordTypes.get(String.valueOf(returnedOpp.RecordTypeId).left(15));
        String actualPricebook	 = String.valueof(returnedOpp.Pricebook2Id).left(15);
        
        Assert.areEqual(expectedPricebook, actualPricebook, 'Opportunity\'s pricebook was not updated');
    }
    
    @isTest
    public static void givenAnOpportunityWithOneRecordType_WhenUpdatingToAnotherRecordType_ThenUpdatePricebook(){
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                       .accountId(account.Id)
                                                                       .stageName('Pendente')
                                                                       .recordTypeId(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Paymentless').getRecordTypeId())
                                                                       .closeDate(Date.today().addDays(1))
                                                                       .persist();
        
        Map<String, String> pricebooksByOpportunitiesRecordTypes = Utils.getEnabledPricebooksToOpportunitiesMetadata();
            
        Test.startTest();
        	opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('InsideSales').getRecordTypeId();
        	update opp;
        Test.stopTest();
        
        Opportunity returnedOpp = [SELECT Id, RecordTypeId, Pricebook2Id FROM Opportunity WHERE Id = :opp.Id];
        Assert.isNull(returnedOpp.Pricebook2Id, 'Opportunity\'s pricebook was not updated');
    }
    
    @isTest
    public static void givenOpenOpportunityWithSameEmail_WhenInsertingOther_ThenCreateItWithDuplicateStageName(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                  .stageName('Pendente')
                                                                                  .leadSource(LEAD_SOURCE)
                                                                                  .accountId(account.Id)
                                                                                  .closeDate(Date.today().addDays(1))
                                                                                  .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            																	  .brand(LEAD_SOURCE)
                                                                                  .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE2)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
																		   .brand(LEAD_SOURCE2)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOpp.StageName);
    }
 
    @isTest
    public static void givenB2bLead_WhenConvertingIt_ThenGenerateB2bOpportunity(){
        
        Lead lead = (Lead) new LeadFixtureFactory().lastName('Test')
            									   .isConverted(false)
            									   .status(Common.LEAD_STATUS_QUALIFIED)
            									   .recordTypeId(Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId())
            									   .email('test@test.com')
            									   .brand('test')
            									   .persist();

        Test.startTest();
        	Database.executeBatch(new ConvertLeadAutomaticallyBatch(new Set<ID>{lead.Id}, true, false));
        Test.stopTest();

        Lead returnedLead = [SELECT Id, Status, IsConverted FROM Lead WHERE Id = :lead.Id];
        Opportunity opp	  = [SELECT Id, RecordTypeId, LeadRecordType__c FROM Opportunity LIMIT 1];
        
        System.assertEquals(true, returnedLead.IsConverted, 'Lead was not converted');
        System.assertEquals(Common.LEAD_STATUS_QUALIFIED, returnedLead.Status, 'Lead not returned properly');
        System.assertEquals(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId(), opp.RecordTypeId, 'Opportunity generated was not B2B');
        System.assertEquals('B2B', opp.LeadRecordType__c, 'Lead Record Type was not mapped from Lead'); 
    }
    
    /*@isTest
    public static void givenTwoOpportunitiesWithRecordTypeInsideSalesAndOpen_WhenUpdating_ThenChangeOwnerIdOfTheFirstOpp(){
        Account account = AccountFixtureFactory.createGeneric();
        User owner1     = UserFixtureFactory.createGeneric();
        User owner2     = UserFixtureFactory.createGeneric();
        
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .accountId(account.Id)
                                                                        .stageName('Pendente')
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .ownerId(owner1.Id)
                                                                        .persist(); 
        Opportunity returnedFirstOpp1 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp1.Id];
        Assert.areEqual(owner1.Id, returnedFirstOpp1.OwnerId, 'Opportunity ownerId incorrectly updated');
                                                                        
        Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .accountId(account.Id)
                                                                        .stageName('Pendente')
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();
            
        Test.startTest();
            opp2.ownerId = owner2.Id;
            update opp2;
        Test.stopTest();
        
        Opportunity returnedFirstOpp2 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp1.Id];
    
        Assert.areEqual(owner2.Id, returnedFirstOpp2.OwnerId, 'Opportunity ownerId incorrectly updated');
    } */
    
    @isTest
    public static void givenTwoOpportunitiesWithRecordTypePaymentlessAndOpen_WhenUpdating_ThenNotChangeOwnerIdOfTheFirstOpp(){
        Account account = AccountFixtureFactory.createGeneric();
        User owner1     = UserFixtureFactory.createGeneric();
        User owner2     = UserFixtureFactory.createGeneric();

        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .accountId(account.Id)
                                                                        .stageName('Pendente')
                                                                        .recordTypeId(Common.OPP_RT_ID_PAYMENTLESS)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .ownerId(owner1.Id)
                                                                        .persist(); 
        Opportunity returnedFirstOpp1 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp1.Id];
        Assert.areEqual(owner1.Id, returnedFirstOpp1.OwnerId, 'Opportunity ownerId incorrectly updated');
                                                                        
        Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .accountId(account.Id)
                                                                        .stageName('Pendente')
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .persist();

        Test.startTest();
            opp2.ownerId = owner2.Id;
            update opp2;
        Test.stopTest();
        
        Opportunity returnedFirstOpp2 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp1.Id];
    
        Assert.areEqual(owner1.Id, returnedFirstOpp2.OwnerId, 'Opportunity ownerId incorrectly updated');
    }
    
    @isTest
    public static void givenTwoOpportunitiesWithRecordTypeInsideSalesAndOpen_WhenInsertIt_ThenNotChangeOwnerIdOfTheFirstOpp(){
        Account account = AccountFixtureFactory.createGeneric();
        User owner1     = UserFixtureFactory.createGeneric();
        User owner2     = UserFixtureFactory.createGeneric();

        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .accountId(account.Id)
                                                                        .stageName('Pendente')
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .ownerId(owner1.Id)
                                                                        .persist(); 
        Opportunity returnedFirstOpp1 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp1.Id];
        Assert.areEqual(owner1.Id, returnedFirstOpp1.OwnerId, 'Opportunity ownerId incorrectly updated');

        Test.startTest();
            Opportunity opp2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                            .accountId(account.Id)
                                                                            .stageName('Pendente')
                                                                            .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                            .closeDate(Date.today().addDays(1))
                                                                            .ownerId(owner2.Id)
                                                                            .persist();
        Test.stopTest();
        
        Opportunity returnedFirstOpp2 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp1.Id];
    
        Assert.areEqual(owner1.Id, returnedFirstOpp2.OwnerId, 'Opportunity ownerId incorrectly updated');
    }
    
    @isTest
    public static void givenOpportunityLost_WhenInsertIt_ThenDontFillJourneyToLost(){
    	
        Account account = AccountFixtureFactory.createGeneric();

        Test.startTest();
            Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                            .stageName('Pendente')
                                                                            .leadSource(LEAD_SOURCE)
                                                                            .accountId(account.Id)
                                                                            .closeDate(Date.today().addDays(1))
                                                                            .stageName(Common.OPP_STAGENAME_DUPLICATED)
                                                                            .persist();
        Test.stopTest();

        Opportunity returnedOpp1 = [SELECT Id, StageName, Journey__c FROM Opportunity WHERE Id = :opp1.Id];
                
        Assert.areNotEqual(Common.OPP_JOURNEY_LOST, returnedOpp1.Journey__c, 'Opportunity journey incorrectly updated');
    }
    
    @isTest
    public static void givenOpportunityLost_WhenUpdatingWithExpiredLossReason_ThenFillJourneyToLost(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .stageName('Pendente')
                                                                        .leadSource(LEAD_SOURCE)
                                                                        .accountId(account.Id)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .lossReason(Common.OPP_LOSS_REASON_EXPIRED)
                                                                        .persist();
        
        Test.startTest();                                                   
        	opp1.StageName = Common.OPP_STAGENAME_CLOSED_LOST;
            update opp1;
        Test.stopTest();

        Opportunity returnedOpp1 = [SELECT Id, StageName, Journey__c FROM Opportunity WHERE Id = :opp1.Id];
                
        Assert.areEqual(Common.OPP_JOURNEY_LOST, returnedOpp1.Journey__c, 'Opportunity journey incorrectly updated');
    }
    
    @isTest
    public static void givenOpenOpportunityOfInsideSales_WhenInsertingOtheDifferentThanInsideSales_ThenDontCloseThis(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                  .stageName('Pendente')
                                                                                  .leadSource(LEAD_SOURCE)
                                                                                  .accountId(account.Id)
                                                                                  .closeDate(Date.today().addDays(1))
                                                                                  .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                  .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE2)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_B2B)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areNotEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOpp.StageName);
    }
    
    @isTest
    public static void givenOpenOpportunityWithLeadSourceAwari_WhenInsertingOtherLeadSource_ThenDontCloseThis(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                  .stageName('Pendente')
                                                                                  .leadSource('Test - aWarI')
            																	  .brand(Common.AWARI)
                                                                                  .accountId(account.Id)
                                                                                  .closeDate(Date.today().addDays(1))
                                                                                  .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                  .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areNotEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOpp.StageName);
    }
    
    @isTest
    public static void givenOpenOpportunityWithLeadSourceFluency_WhenInsertingLeadSourceAwari_ThenDontCloseThis(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                  .stageName('Pendente')
                                                                                  .leadSource('Test - aWarI')
            																	  .brand(Common.AWARI)
                                                                                  .accountId(account.Id)
                                                                                  .closeDate(Date.today().addDays(1))
                                                                                  .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                  .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areNotEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOpp.StageName);
    }
    
    @isTest
    public static void givenOpenOpportunityWithLeadSourceAwari_WhenInsertingLeadSourceAwari_ThenCloseThis(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                  .stageName('Pendente')
                                                                                  .leadSource('Test - aWarI')
                                                                                  .accountId(account.Id)
                                                                                  .closeDate(Date.today().addDays(1))
                                                                                  .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
																				  .brand(Common.AWARI)
                                                                                  .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource('aWarI - tEst')
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
																		   .brand(Common.AWARI)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOpp.StageName);
    }
    
    @isTest
    public static void givenOpenOpportunityWithLeadSourceIntensivo_WhenInsertingLeadSourceIntensivo_ThenCloseThis(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                  .stageName('Pendente')
                                                                                  .leadSource('Test - Intensivo')
                                                                                  .accountId(account.Id)
                                                                                  .closeDate(Date.today().addDays(1))
                                                                                  .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
																				  .brand(Common.INTENSIVO)
                                                                                  .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource('Intensivo - tEst')
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
																		   .brand(Common.INTENSIVO)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOpp.StageName);
    }
    
    @isTest
    public static void given2OpenOpportunitiesWithLeadSourceAwariAndFluency_WhenInsertingLeadSourceAwari_ThenCloseThis(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                   .stageName('Pendente')
                                                                                   .leadSource('Test - aWarI')
                                                                                   .accountId(account.Id)
                                                                                   .closeDate(Date.today().addDays(1))
                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   			   .brand(Common.AWARI)
                                                                                   .persist();
        
        Opportunity oppAlreadyOpen2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                   .stageName('Pendente')
                                                                                   .leadSource(LEAD_SOURCE)
                                                                                   .accountId(account.Id)
                                                                                   .closeDate(Date.today().addDays(1))
                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   			   .brand(LEAD_SOURCE)
                                                                                   .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource('aWarI - tEst')
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   	   .brand(Common.AWARI)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOpp.StageName);
    }
    
    @isTest
    public static void given2OpenOpportunitiesWithLeadSourceIntensivoAndFluency_WhenInsertingLeadSourceIntensivo_ThenCloseThis(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                   .stageName('Pendente')
                                                                                   .leadSource('Test - Intensivo')
                                                                                   .accountId(account.Id)
                                                                                   .closeDate(Date.today().addDays(1))
                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   			   .brand(Common.INTENSIVO)
                                                                                   .persist();
        
        Opportunity oppAlreadyOpen2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                   .stageName('Pendente')
                                                                                   .leadSource(LEAD_SOURCE)
                                                                                   .accountId(account.Id)
                                                                                   .closeDate(Date.today().addDays(1))
                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   			   .brand(LEAD_SOURCE)
                                                                                   .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource('Intensivo - tEst')
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   	   .brand(Common.INTENSIVO)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOpp.StageName);
    }
    
    @isTest
    public static void given2OpenOpportunitiesWithLeadSourceAwariAndFluency_WhenInsertingLeadSourceFluency_ThenCloseThis(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                   .stageName('Pendente')
                                                                                   .leadSource('Test - aWarI')
                                                                                   .accountId(account.Id)
                                                                                   .closeDate(Date.today().addDays(1))
                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   			   .brand(Common.AWARI)
                                                                                   .persist();
        
        Opportunity oppAlreadyOpen2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                   .stageName('Pendente')
                                                                                   .leadSource(LEAD_SOURCE)
                                                                                   .accountId(account.Id)
                                                                                   .closeDate(Date.today().addDays(1))
                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   			   .brand(LEAD_SOURCE)
                                                                                   .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   	   .brand(LEAD_SOURCE)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOpp.StageName);
    }
    
    @isTest
    public static void given2OpenOpportunitiesWithLeadSourceIntensivoAndFluency_WhenInsertingLeadSourceFluency_ThenCloseThis(){
    	
        Account account = AccountFixtureFactory.createGeneric();

		        
        Opportunity oppAlreadyOpen1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                   .stageName('Pendente')
                                                                                   .leadSource('Test - Intensivo')
                                                                                   .accountId(account.Id)
                                                                                   .closeDate(Date.today().addDays(1))
                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   			   .brand(Common.INTENSIVO)
                                                                                   .persist();
        
        Opportunity oppAlreadyOpen2 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                   .stageName('Pendente')
                                                                                   .leadSource(LEAD_SOURCE)
                                                                                   .accountId(account.Id)
                                                                                   .closeDate(Date.today().addDays(1))
                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   			   .brand(LEAD_SOURCE)
                                                                                   .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)                                                                                   .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
            														   	   .brand(LEAD_SOURCE)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOpp.StageName);
    }
    
    @isTest
    public static void givenOpportunityInsadeSalesAndOpen_WhenInsertIt_ThenFillSendWhatsappToTrue(){
    	
        Account account = (Account) new AccountFixtureFactory().name('Test')
                                                               .email('test@test.com')
                                                               .fullPhone('1144445555')
                                                               .persist();
        
        Test.startTest();                                                   
            Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                            .stageName(Common.OPP_STAGENAME_PENDING)
                                                                            .accountId(account.Id)
                                                                            .closeDate(Date.today().addDays(1))
                                                                            .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                            .persist();
        Test.stopTest();

        Opportunity returnedOpp1 = [SELECT Id, SendWhatsapp__c FROM Opportunity WHERE Id = :opp1.Id];
                
        Assert.isTrue(returnedOpp1.SendWhatsapp__c, 'Opportunity SendWhatsapp incorrectly updated');
    }
    
    @isTest
    public static void givenOpportunityInsadeSalesAndClosed_WhenInsertIt_ThenFillSendWhatsappToFalse(){
    	
        Account account = (Account) new AccountFixtureFactory().name('Test')
                                                               .email('test@test.com')
                                                               .fullPhone('1144445555')
                                                               .persist();

        Test.startTest();                                                   
            Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                            .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                                                            .accountId(account.Id)
                                                                            .closeDate(Date.today().addDays(1))
                                                                            .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                            .persist();
        Test.stopTest();

        Opportunity returnedOpp1 = [SELECT Id, SendWhatsapp__c FROM Opportunity WHERE Id = :opp1.Id];
                
        Assert.isFalse(returnedOpp1.SendWhatsapp__c, 'Opportunity SendWhatsapp incorrectly updated');
    }
    
    @isTest
    public static void givenOpportunityInsadeSalesAndOpen_WhenUpdatingToClosed_ThenNotUpdateSendWhatsapp(){
    	
        Account account = (Account) new AccountFixtureFactory().name('Test')
                                                               .email('test@test.com')
                                                               .fullPhone('1144445555')
                                                               .persist(); 

        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .stageName(Common.OPP_STAGENAME_PENDING)
                                                                        .accountId(account.Id)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .persist();
        Opportunity returnedOpp1 = [SELECT Id, SendWhatsapp__c FROM Opportunity WHERE Id = :opp1.Id];   
        Assert.isTrue(returnedOpp1.SendWhatsapp__c, 'Opportunity SendWhatsapp incorrectly updated');

        Test.startTest();
            opp1.StageName = Common.OPP_STAGENAME_CLOSED_LOST;
        	update opp1;
        Test.stopTest();

        Opportunity returnedOpp2 = [SELECT Id, SendWhatsapp__c FROM Opportunity WHERE Id = :opp1.Id];
                
        Assert.isTrue(returnedOpp2.SendWhatsapp__c, 'Opportunity SendWhatsapp incorrectly updated');
    }
    
    @isTest
    public static void givenOpportunityNotInsadeSalesAndOpen_WhenInsertIt_ThenFillSendWhatsappToFalse(){
    	
        Account account = (Account) new AccountFixtureFactory().name('Test')
                                                               .email('test@test.com')
                                                               .fullPhone('1144445555')
                                                               .persist();

        Test.startTest();                                                   
            Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                            .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                                                            .accountId(account.Id)
                                                                            .closeDate(Date.today().addDays(1))
                                                                            .recordTypeId(Common.OPP_RT_ID_PAYMENTLESS)
                                                                            .persist();
        Test.stopTest();

        Opportunity returnedOpp1 = [SELECT Id, SendWhatsapp__c FROM Opportunity WHERE Id = :opp1.Id];
                
        Assert.isFalse(returnedOpp1.SendWhatsapp__c, 'Opportunity SendWhatsapp incorrectly updated');
    }
    
    @isTest
    public static void givenOpportunityInsadeSalesAndOpenButAccountNotFilledFullPhone_WhenInsertIt_ThenFillSendWhatsappToFalse(){
    	
        Account account = (Account) new AccountFixtureFactory().name('Test')
                                                               .email('test@test.com')
                                                               .fullPhone(null)
                                                               .persist();
        
        Test.startTest();                                                   
            Opportunity oppWithFullPhoneNull = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                            .stageName(Common.OPP_STAGENAME_PENDING)
                                                                                            .accountId(account.Id)
                                                                                            .closeDate(Date.today().addDays(1))
                                                                                            .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                            .persist();      

            Opportunity oppWithoutLinkedAccount = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                               .stageName(Common.OPP_STAGENAME_PENDING)
                                                                                               .accountId(null)
                                                                                               .closeDate(Date.today().addDays(1))
                                                                                               .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                               .persist();
        Test.stopTest();

        Opportunity returnedOppWithFullPhoneNull    = [SELECT Id, SendWhatsapp__c FROM Opportunity WHERE Id = :oppWithFullPhoneNull.Id];
        Opportunity returnedOppWithoutLinkedAccount = [SELECT Id, SendWhatsapp__c FROM Opportunity WHERE Id = :oppWithoutLinkedAccount.Id];
                
        Assert.isFalse(returnedOppWithFullPhoneNull.SendWhatsapp__c, 'Opportunity SendWhatsapp incorrectly updated');
        Assert.isFalse(returnedOppWithoutLinkedAccount.SendWhatsapp__c, 'Opportunity SendWhatsapp incorrectly updated');
    }
    
    @isTest
    public static void givenOpportunityInsadeSalesAndOpenButFullPhoneNotFilled_WhenUpdatingFilledFullPhone_ThenFillSendWhatsappToTrue(){
    	
        Account account = (Account) new AccountFixtureFactory().name('Test')
                                                               .email('test@test.com')
                                                               .fullPhone(null)
                                                               .persist();
                                                           
        Opportunity opp1 = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                        .stageName(Common.OPP_STAGENAME_PENDING)
                                                                        .accountId(account.Id)
                                                                        .closeDate(Date.today().addDays(1))
                                                                        .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                        .persist();

        Opportunity returnedOpp1 = [SELECT Id, SendWhatsapp__c FROM Opportunity WHERE Id = :opp1.Id];
        Assert.isFalse(returnedOpp1.SendWhatsapp__c, 'Opportunity SendWhatsapp incorrectly updated');

        Test.startTest();
            opp1.FullPhone__c = '1144445555';
            update opp1;
        Test.stopTest();

        Opportunity returnedOpp2 = [SELECT Id, SendWhatsapp__c FROM Opportunity WHERE Id = :opp1.Id];
        Assert.isTrue(returnedOpp2.SendWhatsapp__c);
    }
    
    @isTest
    public static void givenOppRecordTypeInsideSalesAlreadyOpen_WhenInsertingRecordTypeRecycle_ThenNewOppWillBeNotAbleToDistribute(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        User user = UserFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                  .stageName('Pendente')
                                                                                  .leadSource(LEAD_SOURCE)
            																	  .brand(LEAD_SOURCE)
            																	  .ownerId(user.Id)
                                                                                  .accountId(account.Id)
                                                                                  .closeDate(Date.today().addDays(1))
                                                                                  .recordTypeId(Common.OPP_RT_ID_RECYCLE)
                                                                                  .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE)
            															   .brand(LEAD_SOURCE)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedNewOpp         = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];        
        Opportunity returnedOppAlreadyOpen = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppAlreadyOpen.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedNewOpp.StageName);
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedOppAlreadyOpen.StageName);
    }
    
    @isTest
    public static void givenOppRecordTypeRecycleAlreadyOpen_WhenInsertingRecordTypeInsideSales_ThenNewOppCloseAsDuplicated(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        User user = UserFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                  .stageName('Pendente')
                                                                                  .leadSource(LEAD_SOURCE)
            																	  .brand(LEAD_SOURCE)
            																	  .ownerId(user.Id)
                                                                                  .accountId(account.Id)
                                                                                  .closeDate(Date.today().addDays(1))
                                                                                  .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                  .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE)
            															   .brand(LEAD_SOURCE)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_RECYCLE)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedNewOpp         = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];        
        Opportunity returnedOppAlreadyOpen = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppAlreadyOpen.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedNewOpp.StageName);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOppAlreadyOpen.StageName);
    }
    
    @isTest
    public static void givenOppRecordTypeInsideSalesAlreadyOpen_WhenInsertingRecordTypeInsideSales_ThenNewOppWillBeNotAbleToDistribute(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        User user = UserFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                  .stageName('Pendente')
                                                                                  .leadSource(LEAD_SOURCE)
            																	  .brand(LEAD_SOURCE)
            																	  .ownerId(user.Id)
                                                                                  .accountId(account.Id)
                                                                                  .closeDate(Date.today().addDays(1))
                                                                                  .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                                  .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE)
            															   .brand(LEAD_SOURCE)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_INSIDESALES)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedNewOpp         = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];        
        Opportunity returnedOppAlreadyOpen = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppAlreadyOpen.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedNewOpp.StageName);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOppAlreadyOpen.StageName);
    }
    
    @isTest
    public static void givenOppRecordTypeRecycleAlreadyOpen_WhenInsertingRecordTypeRecycle_ThenNewOppWillBeNotAbleToDistribute(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        User user = UserFixtureFactory.createGeneric();
        
        Opportunity oppAlreadyOpen = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                                  .stageName('Pendente')
                                                                                  .leadSource(LEAD_SOURCE)
            																	  .brand(LEAD_SOURCE)
            																	  .ownerId(user.Id)
                                                                                  .accountId(account.Id)
                                                                                  .closeDate(Date.today().addDays(1))
                                                                                  .recordTypeId(Common.OPP_RT_ID_RECYCLE)
                                                                                  .persist();
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           .stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE)
            															   .brand(LEAD_SOURCE)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_RECYCLE)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedNewOpp         = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];        
        Opportunity returnedOppAlreadyOpen = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppAlreadyOpen.Id];
        
        Assert.areEqual(Common.OPP_STAGENAME_DUPLICATED, returnedNewOpp.StageName);
        Assert.areEqual(Common.OPP_STAGENAME_PENDING, returnedOppAlreadyOpen.StageName);
    }
    
    @isTest
    public static void givenOppRecordTypeB2B_WhenInsertingIt_ThenStageNameWillBeSetted(){
    	
        Account account = AccountFixtureFactory.createGeneric();
        
        Test.startTest();
        	Opportunity opp = (Opportunity) new OpportunityFixtureFactory().name('Test')
                                                                           //.stageName('Pendente')
                                                                           .leadSource(LEAD_SOURCE)
            															   .brand(LEAD_SOURCE)
                                                                           .accountId(account.Id)
                                                                           .closeDate(Date.today().addDays(2))
                                                                           .recordTypeId(Common.OPP_RT_ID_B2B)
                                                                           .persist();
        Test.stopTest();

        Opportunity returnedNewOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];        
        
        Assert.areEqual('StageName', returnedNewOpp.StageName);
    }
    
}