@isTest
public class RecycleLeadOppsTest {
    
    public static String LEAD_SOURCE1 = 'Source Test 1';
    public static String LEAD_SOURCE2 = 'Source Test 2';
    public static String BRAND_PAULA  = 'Paula';
    public static final String PHONE  = '551144445555';

    @testSetup
    public static void testSetup(){
		GeneralParametersFixtureFactory.createGeneric();
		FeatureFlagsFixtureFactory.createGeneric();
        
        List<Lead> leads	   = new List<Lead>();
        List<Opportunity> opps = new List<Opportunity>();
        
        QueueDistribution__c metadata = QueueDistributionFixtureFactory.create(LEAD_SOURCE1, 'Queue', 3, Common.QUEUE_DISTRIBUTION_RT_ID_LEAD, 0, false);
        Account account				  = AccountFixtureFactory.createGeneric();
        
        leads.add((Lead) new LeadFixtureFactory().lastName('Test')
                                                 .isConverted(false)
                                                 .email('test@fluencyacademy.io')
                  								 .phone(PHONE)
                                                 .leadSource(LEAD_SOURCE1)
                                                 .status(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE)
                                                 .brand(Common.Fluency)
                                                 .object());
        
        leads.add((Lead) new LeadFixtureFactory().lastName('Test')
                                                 .isConverted(false)
                                                 .email('test@fluencyacademy.io')
                  								 .phone(PHONE)
                                                 .leadSource(LEAD_SOURCE2)
                                                 .status(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE)
                                                 .brand(Common.Fluency)
                                                 .recycleQuantity(1)
                                                 .object());
        
        leads.add((Lead) new LeadFixtureFactory().lastName('Test')
                                                 .isConverted(false)
                                                 .email('test@fluencyacademy.io')
                  								 .phone(PHONE)
                                                 .leadSource(LEAD_SOURCE1)
                                                 .status(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE)
                                                 .brand(BRAND_PAULA)
                                                 .recycleQuantity(1)
                                                 .object());
        
        leads.add((Lead) new LeadFixtureFactory().lastName('Test')
                                                 .isConverted(false)
                                                 .email('test@fluencyacademy.io')
                  								 .phone(PHONE)
                                                 .leadSource(LEAD_SOURCE1)
                                                 .status(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE)
                                                 .brand(BRAND_PAULA)
                                                 .recycleQuantity(2)
                                                 .object());
        
        opps.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                              .accountId(account.Id)
                                                              .closeDate(Date.today().addDays(1))
                                                              .leadSource(LEAD_SOURCE1)
                                                              .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                                              .brand(Common.FLUENCY)
                                                              .object());
        
        opps.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                              .accountId(account.Id)
                                                              .closeDate(Date.today().addDays(1))
                                                              .leadSource(LEAD_SOURCE2)
                                                              .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                                              .brand(Common.FLUENCY)
                                                              .recycleQuantity(1)
                                                              .object());
        
        opps.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                              .accountId(account.Id)
                                                              .closeDate(Date.today().addDays(1))
                                                              .leadSource(LEAD_SOURCE1)
                                                              .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                                              .brand(BRAND_PAULA)
                                                              .recycleQuantity(1)
                                                              .object());
        
        opps.add((Opportunity) new OpportunityFixtureFactory().name('Test')
                                                              .accountId(account.Id)
                                                              .closeDate(Date.today().addDays(1))
                                                              .leadSource(LEAD_SOURCE1)
                                                              .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                                              .brand(BRAND_PAULA)
                                                              .recycleQuantity(2)
                                                              .object());
        insert leads;
        insert opps;
    }
    
    @isTest
    public static void testGetters(){
        
        List<String> brands		 = RecycleLeadOpps.getValuesFromMetadata('Brand');
        List<String> verticals	 = RecycleLeadOpps.getValuesFromMetadata('Vertical');
        List<String> leadSources = RecycleLeadOpps.getLeadSources();
        Integer maxRecycleQtt	 = RecycleLeadOpps.getMaximumRecordsToRecycle();
        
        Assert.isTrue(brands.contains('Fluency'));
        Assert.isTrue(verticals.contains('Idiomas'));
        Assert.isTrue(leadSources.contains(LEAD_SOURCE1));
        Assert.areEqual(1, leadSources.size());
        Assert.areEqual(3, maxRecycleQtt);
        
    }
    
    @isTest
    public static void givenLeads_WhenInsertingSimpleFilter_ThenRecycle(){
        
        List<Lead> leadsToRecycle = RecycleLeadOpps.getLeads(Date.today(), Date.today(), Common.FLUENCY, null, null, null);
        Assert.areEqual(2, leadsToRecycle.size());
        
        Test.startTest();
        	RecycleLeadOpps.sendLeadsToRecycle(leadsToRecycle);
        Test.stopTest();
        
        List<Lead> recycledLeads = [SELECT Id FROM Lead WHERE RecordTypeId = :Common.LEAD_RT_ID_RECYCLE];
        Assert.areEqual(2, recycledLeads.size());
    }
    
    @isTest
    public static void given201Leads_WhenInsertingSimpleFilter_ThenRecycle(){
        
        List<Lead> leads = new List<Lead>();
        
        for (Integer i=0 ; i < 199; i++){
            leads.add((Lead) new LeadFixtureFactory().lastName('Test')
                                                     .isConverted(false)
                                                     .email('test' + i +'@fluencyacademy.io')
                      								 .phone(PHONE)
                                                     .leadSource(LEAD_SOURCE1)
                                                     .status(Common.LEAD_STATUS_NOT_ABLE_TO_DISTRIBUTE)
                                                     .brand(Common.Fluency)
                                                     .object());
        }
        insert leads;
        
        List<Lead> leadsToRecycle = RecycleLeadOpps.getLeads(Date.today(), Date.today(), Common.FLUENCY, null, null, null);
        Assert.areEqual(201, leadsToRecycle.size());
        List<String> leadIds = ListHelper.convertObjectListIntoStringList('Id', leadsToRecycle);
        
        Test.startTest();
        	RecycleLeadOpps.recycleLeads(leadIds);
        Test.stopTest();
        
        List<Lead> recycledLeads = [SELECT Id FROM Lead WHERE RecordTypeId = :Common.LEAD_RT_ID_RECYCLE];
        Assert.areEqual(201, recycledLeads.size());
    }
    
    @isTest
    public static void givenLeads_WhenInsertingRecycleQuantity_ThenRecycle(){
        
        List<Lead> leadsToRecycle = RecycleLeadOpps.getLeads(Date.today(), Date.today(), Common.FLUENCY, null, null, 0);
        Assert.areEqual(1, leadsToRecycle.size());
        
        Test.startTest();
        	RecycleLeadOpps.sendLeadsToRecycle(leadsToRecycle);
        Test.stopTest();
        
        List<Lead> recycledLeads = [SELECT Id, RecycledFromLead__c FROM Lead WHERE RecordTypeId = :Common.LEAD_RT_ID_RECYCLE];
        Assert.areEqual(1, recycledLeads.size());
        Assert.areEqual(recycledLeads[0].RecycledFromLead__c, leadsToRecycle[0].Id);
    }
    
    @isTest
    public static void givenLeads_WhenBrandIsPaulaAndRecycleQuantityZero_ThenDontRecycle(){
        List<Lead> leadsToRecycle = RecycleLeadOpps.getLeads(Date.today(), Date.today(), BRAND_PAULA, null, null, 0);
        Assert.areEqual(0, leadsToRecycle.size());
    }
    
    @isTest
    public static void givenOpportunities_WhenInsertingSimpleFilter_ThenRecycle(){
        
        List<Opportunity> oppsToRecycle = RecycleLeadOpps.getOpportunities(Date.today(), Date.today(), Common.FLUENCY, null, null, null);
        Assert.areEqual(2, oppsToRecycle.size());
        
        Test.startTest();
        	RecycleLeadOpps.sendOpportunitiesToRecycle(oppsToRecycle);
        Test.stopTest();
        
        List<Lead> recycledLeads = [SELECT Id FROM Lead WHERE RecordTypeId = :Common.LEAD_RT_ID_RECYCLE];
        Assert.areEqual(2, recycledLeads.size());
    }
    
    @isTest
    public static void givenOpportunities_WhenInsertingRecycleQuantity_ThenRecycle(){
        
        List<Opportunity> oppsToRecycle = RecycleLeadOpps.getOpportunities(Date.today(), Date.today(), Common.FLUENCY, null, null, 0);
        Assert.areEqual(1, oppsToRecycle.size());
        
        Test.startTest();
        	RecycleLeadOpps.sendOpportunitiesToRecycle(oppsToRecycle);
        Test.stopTest();
        
        List<Lead> recycledLeads = [SELECT Id, RecycledFromOpportunity__c FROM Lead WHERE RecordTypeId = :Common.LEAD_RT_ID_RECYCLE];
        Assert.areEqual(1, recycledLeads.size());
        Assert.areEqual(recycledLeads[0].RecycledFromOpportunity__c, oppsToRecycle[0].Id);
    }
    
    @isTest
    public static void givenOpportunities_WhenBrandIsPaulaAndRecycleQuantityZero_ThenDontRecycle(){
        List<Opportunity> oppsToRecycle = RecycleLeadOpps.getOpportunities(Date.today(), Date.today(), BRAND_PAULA, null, null, 0);
        Assert.areEqual(0, oppsToRecycle.size());
    }
    
    @isTest
    public static void given201Opps_WhenInsertingSimpleFilter_ThenRecycle(){
        
        List<Opportunity> opps = new List<Opportunity>();
        Account account		   = (Account) new AccountFixtureFactory().name('Test2')
                                                                      .email('test2@test.com')
                                                                      .persist();
        
        for (Integer i=0 ; i < 199; i++){
            opps.add((Opportunity) new OpportunityFixtureFactory().name('Test ' + i)
                                                                  .closeDate(Date.today().addDays(1))
                                                                  .accountId(account.Id)
                                                                  .leadSource(LEAD_SOURCE1)
                                                                  .stageName(Common.OPP_STAGENAME_CLOSED_LOST)
                                                                  .brand(Common.FLUENCY)
                                                                  .object());
        }
        insert opps;
        
        List<Opportunity> oppsToRecycle = RecycleLeadOpps.getOpportunities(Date.today(), Date.today(), Common.FLUENCY, null, null, null);
        Assert.areEqual(201, oppsToRecycle.size());
        List<String> oppIds = ListHelper.convertObjectListIntoStringList('Id', oppsToRecycle);
        
        Test.startTest();
        	RecycleLeadOpps.recycleOpportunities(oppIds);
        Test.stopTest();
        
        List<Lead> recycledLeads = [SELECT Id FROM Lead WHERE RecordTypeId = :Common.LEAD_RT_ID_RECYCLE];
        Assert.areEqual(201, recycledLeads.size());
    }
    
}