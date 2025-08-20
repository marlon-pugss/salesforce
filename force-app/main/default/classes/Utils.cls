public class Utils {
    
    static Integer serialNumber = 1;
  
    public static String getFakeId(Schema.SObjectType sObjectType){
        String result = String.valueOf(serialNumber++);
        return sObjectType.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
    }

    public static String generatePwd(Integer len){
        Blob blobKey = crypto.generateAesKey(128);
        String key	 = EncodingUtil.convertToHex(blobKey);
        String pwd	 = key.substring(0,len);
        
        return pwd;
    }
    
    public static Datetime getLocalDateTime(Datetime z){    
        Datetime l = z.Date();
        l 		   = l.addHours(z.hour());
        l		   = l.addMinutes(z.minute());
        l		   = l.addSeconds(z.second());
        return l;
    }
    
    public static Datetime dateToDatetime(Date dat){
        return dat == null ? null : Datetime.newInstance(dat.year(), dat.month(), dat.day());
    }
    
    public static String formatLocalTime(Datetime l){ 
        String strOffset		= l.format('Z');
        strOffset				= strOffset.substring(0,3) + ':' + strOffset.substring(3,5);
        String strDateFormatted = json.serialize(l);
        strDateFormatted 		= strDateFormatted.substring(1, strDateFormatted.lastIndexOf('.'));
        strDateFormatted		= strDateFormatted;
        return strDateFormatted;
    }
    
    public static Date getLastWorkingDayFromDateAndNumber (Date dataAtual, Integer businessDays, BusinessHours bh){
        
        DateTime auxDate = DateTime.newInstance(dataAtual.Year(), dataAtual.Month(), dataAtual.Day(), 12, 00 ,00);
        Date auxDate2	 = dataAtual;
        
        for(Integer i = 1; i <= businessDays; i++ ){
            auxDate = auxDate - 1;
            auxDate2 = auxDate2 - 1;
            
            if(!BusinessHours.isWithin(bh.id, auxDate)) i--;
        }
        
        return auxDate2;
    }
    
    public static Date getNextWorkingDayFromDateAndNumber (Date dataAtual, Integer businessDays, BusinessHours bh){
        
        DateTime auxDate = DateTime.newInstance(dataAtual.Year(), dataAtual.Month(), dataAtual.Day(), 12, 00 ,00);
        Date auxDate2	 = dataAtual;
        
        for(Integer i = 1; i <= businessDays; i++ ){
            auxDate = auxDate + 1;
            auxDate2 = auxDate2 + 1;
            if(!BusinessHours.isWithin(bh.id, auxDate)) i--;
        }
        
        return auxDate2;
    }
    
    public static Integer randomiza(Integer n){
        Integer ranNum = (Integer) (Math.random() * n);
        return ranNum;
    }
    
    public static Integer mod(Integer dividendo, Integer divisor) {
        return (Integer) Math.round(dividendo - (Math.floor(dividendo / divisor) * divisor));
    }
    
    public static String cpf(Boolean comPontos) {
        Integer n  = 9;
        Integer n1 = randomiza(n);
        Integer n2 = randomiza(n);
        Integer n3 = randomiza(n);
        Integer n4 = randomiza(n);
        Integer n5 = randomiza(n);
        Integer n6 = randomiza(n);
        Integer n7 = randomiza(n);
        Integer n8 = randomiza(n);
        Integer n9 = randomiza(n);
        Integer d1 = n9 * 2 + n8 * 3 + n7 * 4 + n6 * 5 + n5 * 6 + n4 * 7 + n3 * 8 + n2 * 9 + n1 * 10;
        
        d1 = 11 - (mod(d1, 11));
        
        if (d1 >= 10) d1 = 0;
        
        Integer d2 = d1 * 2 + n9 * 3 + n8 * 4 + n7 * 5 + n6 * 6 + n5 * 7 + n4 * 8 + n3 * 9 + n2 * 10 + n1 * 11;
        
        d2 = 11 - (mod(d2, 11));
        
        String retorno = '';
        
        if (d2 >= 10) d2 = 0;
        
        if (comPontos)
            retorno = '' + n1 + n2 + n3 + '.' + n4 + n5 + n6 + '.' + n7 + n8 + n9 + '-' + d1 + d2;
        else
            retorno = '' + n1 + n2 + n3 + n4 + n5 + n6 + n7 + n8 + n9 + d1 + d2;
        
        return retorno;
    }
    
    public static String cnpj(Boolean comPontos) {
        Integer n	= 9;
        Integer n1	= randomiza(n);
        Integer n2	= randomiza(n);
        Integer n3	= randomiza(n);
        Integer n4	= randomiza(n);
        Integer n5	= randomiza(n);
        Integer n6	= randomiza(n);
        Integer n7	= randomiza(n);
        Integer n8	= randomiza(n);
        Integer n9	= 0; //randomiza(n);
        Integer n10 = 0; //randomiza(n);
        Integer n11 = 0; //randomiza(n);
        Integer n12 = 1; //randomiza(n);
        Integer d1	= n12 * 2 + n11 * 3 + n10 * 4 + n9 * 5 + n8 * 6 + n7 * 7 + n6 * 8 + n5 * 9 + n4 * 2 + n3 * 3 + n2 * 4 + n1 * 5;
        
        d1 = 11 - (mod(d1, 11));
        
        if (d1 >= 10) d1 = 0;
        
        Integer d2 = d1 * 2 + n12 * 3 + n11 * 4 + n10 * 5 + n9 * 6 + n8 * 7 + n7 * 8 + n6 * 9 + n5 * 2 + n4 * 3 + n3 * 4 + n2 * 5 + n1 * 6;
        
        d2 = 11 - (mod(d2, 11));
        
        if (d2 >= 10) d2 = 0;
        
        String retorno = null;
        
        if (comPontos)
            retorno = '' + n1 + n2 + '.' + n3 + n4 + n5 + '.' + n6 + n7 + n8 + '/' + n9 + n10 + n11 + n12 + '-' + d1 + d2;
        else
            retorno = '' + n1 + n2 + n3 + n4 + n5 + n6 + n7 + n8 + n9 + n10 + n11 + n12 + d1 + d2;
        
        return retorno;
    }
    
    public static string removeSpecialCharacters (String texto) {
        if(texto == null) return null;
        
        return texto.deleteWhitespace()
            		.replaceAll('[áàâã]', 'a')
            		.replaceAll('[éèê&]', 'e')
            		.replaceAll('[íìî]', 'i')
            		.replaceAll('[õòóô]', 'o')
            		.replaceAll('[ùûúü]', 'u')
            		.replaceAll('[ç]', 'c')
            		.replaceAll('[ñ]', 'n')
            		.replaceAll('[ÁÀÂÃ]', 'a')
            		.replaceAll('[ÉÈÊ]', 'e')
            		.replaceAll('[ÎÍÌÏ]', 'i')
            		.replaceAll('[ÕÔÓÒÖ]', 'o')
            		.replaceAll('[ÙÛÚÜ]', 'u')
            		.replaceAll('[Ñ]', 'N')
            		.replaceAll('[Ç]', 'C')
            		.replaceAll('\\+', '')
            		.replaceAll('\\D','')
            		.replaceAll('[!@#$%*-+?\',()-]', '');
            	  //.replaceAll('[^a-zA-Z0-9\\s]','');
    }
    
    public static string removeLetters (String texto) {
        if(texto == null) return null;
        
        return texto.deleteWhitespace().replaceAll('a','').replaceAll('b','').replaceAll('c','').replaceAll('d','')
            		.replaceAll('e','').replaceAll('f','').replaceAll('g','').replaceAll('h','').replaceAll('i','')
            		.replaceAll('j','').replaceAll('k','').replaceAll('l','').replaceAll('m','').replaceAll('n','')
            		.replaceAll('o','').replaceAll('p','').replaceAll('q','').replaceAll('r','').replaceAll('s','')
            		.replaceAll('t','').replaceAll('u','').replaceAll('v','').replaceAll('w','').replaceAll('x','')
            		.replaceAll('y','').replaceAll('z','');
    }
    
    public static Boolean isFilled(List<sObject> objectList){
        return objectList != null && !objectList.isEmpty();
    }
    
    public static Boolean isFilled(List<Object> objectList){
        return objectList != null && !objectList.isEmpty();
    }
    
    public static Boolean isFilled(Set<String> stringSet){
        return stringSet != null && !stringSet.isEmpty();
    }
    
    public static Boolean isFilled(List<String> stringList){
        return stringList != null && !stringList.isEmpty();
    }
    
    public static Boolean isFilled(Set<Id> IdSet){
        return idSet != null && !idSet.isEmpty();
    }
    
    public static Boolean isFilled(Set<Date> setDate){
        return setDate != null && !setDate.isEmpty();
    }
    
    public static Boolean isFilled(Map<String, String> mapListString){
        return mapListString != null && !mapListString.isEmpty();
    }
    
    public static Boolean isFilled(Map<Integer, List<Object>> mapIntegerByObjectList){
        return mapIntegerByObjectList != null || !mapIntegerByObjectList.values().isEmpty();
    }
    
    public static Boolean isFilled(Map<String, List<Object>> mapIntegerByObjectList){
        return mapIntegerByObjectList != null || !mapIntegerByObjectList.values().isEmpty();
    }
    
    public static Boolean isFilled(Map<Id, sObject> mapIdByObject){
        return mapIdByObject != null || !mapIdByObject.values().isEmpty();
    }

    public static Map<String, String> getEnabledPricebooksToOpportunitiesMetadata(){
        
        List<PricebookToOpportunity__mdt> values 				 = PricebookToOpportunity__mdt.getAll().values();
        Map<String, String> pricebooksByOpportunitiesRecordTypes = new Map<String, String>();
        
        if ( !isFilled(values) ) return pricebooksByOpportunitiesRecordTypes;
        
        for (PricebookToOpportunity__mdt metadata : values){
            if (metadata.Enabled__c)
                pricebooksByOpportunitiesRecordTypes.put(metadata.OpportunityRecordType__c , metadata.PricebookId__c);
        }
        
        return pricebooksByOpportunitiesRecordTypes;
    }
    
    public static Map<String, String> getAllCaseSubjectToPriorityMetadata(){
        
        List<CaseSubjectToPriority__mdt> values = CaseSubjectToPriority__mdt.getAll().values();
        Map<String, String> priorityBySubjects	= new Map<String, String>();
        
        if ( !isFilled(values) ) return priorityBySubjects;
        
        for (CaseSubjectToPriority__mdt metadata : values)
            priorityBySubjects.put(metadata.Subject__c, metadata.Priority__c);
        
        return priorityBySubjects;
    }
    
    public static Map<String, String> getAllLocaleToDDIMetadata(){
        
        List<LocaleToDDI__mdt> values    = LocaleToDDI__mdt.getAll().values();
        Map<String, String> LocaleByDDIs = new Map<String, String>();
        
        if ( !isFilled(values) ) return LocaleByDDIs;
        
        for (LocaleToDDI__mdt metadata : values)
            LocaleByDDIs.put(metadata.DDI__c, metadata.Locale__c);
        
        return LocaleByDDIs;
    }
    
    public static Map<String, String> getAllLocaleToRegionMetadata(){
        
        List<LocaleToDDI__mdt> values    = LocaleToDDI__mdt.getAll().values();
        Map<String, String> regionByLocales = new Map<String, String>();
        
        if ( !isFilled(values) ) return regionByLocales;
        
        for (LocaleToDDI__mdt metadata : values)
            regionByLocales.put(metadata.Locale__c, metadata.Region__c);
        
        return regionByLocales;
    }
    
    public static Map<String, String> getAllLeadSourceToProduct(){
        
        List<LeadSourceToProduct__mdt> values    = LeadSourceToProduct__mdt.getAll().values();
        Map<String, String> LeadSourceToProducts = new Map<String, String>();
        
        if ( !isFilled(values) ) return LeadSourceToProducts;
        
        for (LeadSourceToProduct__mdt metadata : values)
            LeadSourceToProducts.put(metadata.LeadSource__c, metadata.Product__c);
        
        return LeadSourceToProducts;
    }
    
    public static Map<String, List<String>> getAllRecycleLeadOppMetadata(){
        
        List<RecycleLeadOpp__mdt> values	  = RecycleLeadOpp__mdt.getAll().values();
        Map<String, List<String>> mapToReturn = new Map<String, List<String>>();
        
        if ( !isFilled(values) ) return mapToReturn;
        
        for (RecycleLeadOpp__mdt metadata : values){
            if (mapToReturn.get(metadata.Field__c) != null)
                mapToReturn.get(metadata.Field__c).add(metadata.Value__c);
            else
                mapToReturn.put(metadata.Field__c, new List<String>{metadata.Value__c});
        }
        
        return mapToReturn;
    }
    
    public static List<SObject> filterRecordsByBrandsFromHSMmetadata(List<SObject> recordsList, Boolean brandsInMetadata) {
        
        if(!isFilled(recordsList)) return recordsList;
        
        GeneralParameters__c parameters = GeneralParameters__c.getInstance();        
        if(String.isBlank( (String) parameters.BrandsToSendHSMViaLead__c) ) return recordsList;
        
        Set<String> uniqueBrands = ListHelper.convertStringSplittedByCommasIntoStringSet((String) parameters.BrandsToSendHSMViaLead__c);
        uniqueBrands			 = ListHelper.convertAllToUpperCase(uniqueBrands);
        
        List<SObject> filteredRecordsList = new List<SObject>();
        
        for (SObject record : recordsList) {
            String brand = (String) record?.get('Brand__c');
            
            if (String.isBlank(brand)) continue; //String.isBlank returns true if the specified String is white space, empty (''), or null;
            
            if (brandsInMetadata && uniqueBrands.contains(brand.toUpperCase()) )
                filteredRecordsList.add(record);
            else if (!brandsInMetadata && !uniqueBrands.contains(brand.toUpperCase()) )
                filteredRecordsList.add(record);
        }
        
        return filteredRecordsList;
    }     
    
    public static Map<String, List<QueueDistribution__c>> getEnabledQueueDistributionForRecordTypeId(String recordTypeId){
        
        QueueDistributionRepository repository = new QueueDistributionRepository();
        
        List<QueueDistribution__c> values = repository.findBy_RecordTypeId_Enabled(recordTypeId);
        
        Map<String, List<QueueDistribution__c>> queuesByReferenceField = new Map<String, List<QueueDistribution__c>>();
        
        if ( !isFilled(values) ) return queuesByReferenceField;
        
        for (QueueDistribution__c metadata : values){            
            
            if (queuesByReferenceField.get(metadata.Origin__c.toUpperCase()) == null)
                queuesByReferenceField.put(metadata.Origin__c.toUpperCase(), new List<QueueDistribution__c>{metadata});
            else
                queuesByReferenceField.get(metadata.Origin__c.toUpperCase()).add(metadata);
        }
        
        return queuesByReferenceField;
    }
    
    public static Map<Integer, List<QueueDistribution__c>> getEnabledQueueDistributionByRotationDays(String recordTypeId){
        
        QueueDistributionRepository repository = new QueueDistributionRepository();
        
        List<QueueDistribution__c> values = repository.findBy_RecordTypeId_Enabled(recordTypeId);
        
        Map<Integer, List<QueueDistribution__c>> queuesByRotationDays = new Map<Integer, List<QueueDistribution__c>>();
        
        if ( !isFilled(values) ) return queuesByRotationDays;
        
        for (QueueDistribution__c metadata : values){
            
            if (metadata.AgeOfOpportunity__c == null) continue;

            if (metadata.AgeOfOpportunity__c == null) continue;

            Integer daysToOpportunityRotationDate = Integer.valueOf(metadata.AgeOfOpportunity__c);
            Integer rotationDay                   = Date.today().addDays(-1 * daysToOpportunityRotationDate).day();
            
            if (queuesByRotationDays.get(rotationDay) == null)
                queuesByRotationDays.put(rotationDay, new List<QueueDistribution__c>{metadata});
            else
                queuesByRotationDays.get(rotationDay).add(metadata);
        }
        
        return queuesByRotationDays;
    }
    
    public static Map<String, Opportunity> convertOppListIntoMapOfOppsByEmail(List<Opportunity> opps){
        
        Map<String, Opportunity> oppsByEmailAndLeadSource = new Map<String, Opportunity>();
        
        if ( !isFilled(opps) ) return oppsByEmailAndLeadSource;
        
        for (Opportunity opp : opps)
            oppsByEmailAndLeadSource.put(opp.Account.Email__c, opp);
        
        return oppsByEmailAndLeadSource;
    }
    
    public static Boolean checkHorizontalDistributionStatus(List<QueueDistribution__c> queueDistributions){
        return queueDistributions[0].HorizontalDistribution__c;
    }
    
    public static Boolean isSameBrand(String newBrand, String otherBrand){
        
        GeneralParameters__c parameters = GeneralParameters__c.getInstance();
        
        if( String.isBlank(newBrand) || String.isBlank(otherBrand) || String.isBlank((String) parameters.UniqueBrands__c) ) return false;
        
        Set<String> uniqueBrands = ListHelper.convertStringSplittedByCommasIntoStringSet((String) parameters.UniqueBrands__c);
        uniqueBrands			 = ListHelper.convertAllToUpperCase(uniqueBrands);
        
        String newBrandUpperCase   = newBrand.toUpperCase();
		String otherBrandUpperCase = otherBrand.toUpperCase();
        
        for (String brand : uniqueBrands){
            if (newBrandUpperCase == brand && otherBrandUpperCase == brand)
                return true;
        }
        
        return !uniqueBrands.contains(newBrandUpperCase) && !uniqueBrands.contains(otherBrandUpperCase);
    }    
    
    public static String getAccountIdFromMessagingSession(MessagingSession messagingSession, Map<String, String> accountsByEmail, Map<String, String> accountsByphone){
                
        if(accountsByEmail?.get(messagingSession.Email__c) != null)
            return accountsByEmail.get(messagingSession.Email__c);
        
        else if(accountsByphone?.get(messagingSession.FullPhone__c) != null)
            return accountsByPhone.get(messagingSession.FullPhone__c);
        
        return null;
    }
    
    public static Map<String, String> findEmailFromAccountOrContactByPhone(List<String> phones){
        
        Map<String, String> emailsByPhoneToReturn = new Map<String, String>();
        
        if ( !isFilled(phones) ) return emailsByPhoneToReturn;
        
        List<Account> accountsWithSamePhone = new accountRepository().findByPhone(phones);
        List<Contact> contactsWithSamePhone = new contactRepository().findByPhone(phones);

        if ( !isFilled(accountsWithSamePhone) && !isFilled(contactsWithSamePhone) ) return emailsByPhoneToReturn;
        
        Map<String, sObject> accountsByPhone = ListHelper.indexListByField('FullPhone__c', accountsWithSamePhone);
        Map<String, sObject> contactsByPhone = ListHelper.indexListByField('FullPhone__c', contactsWithSamePhone);
        
        for (String phone : phones){
            Account account = (Account) accountsByPhone?.get(phone);
            Contact contact = (Contact) contactsByPhone?.get(phone);
            
            if (account != null)
                emailsByPhoneToReturn.put(phone, account.Email__c);
            else if (contact != null && contact.AccountId != null)
                emailsByPhoneToReturn.put(phone, contact.Email__c);            
        }
        
        return emailsByPhoneToReturn;
    }
    
    public static MessagingSession setMSLastMessage(String body){
        MessagingSessionModel model = MessagingSessionModel.parse(body)?.get(0);
        if(model == null) return null;       
        
        Datetime msDatetime = Datetime.newinstance(long.valueOf(model.serverReceivedTimestamp));
        String datetimeToMS = '' + msDatetime.month() + '-' + msDatetime.day() + ' ' + String.valueOf(msDatetime.time()).left(8);
        String messageText  = model.messageText != null ? model.messageText.left(25) + ' ...' : 'Arquivo';
        
        return new MessagingSessionBuilder().id(model.relatedRecords[0])
                                            .lastMessage(messageText)
                                            .lastMessageDate(datetimeToMS)
                                            .build();
    }
    
    public static Set<Date> getOpportunityCreatedDates(List<QueueDistribution__c> enabledQueueDistributions){

        Set<Date> returnOpportunityCreatedDatess = new Set<Date>();

        if ( !isFilled(enabledQueueDistributions) ) return returnOpportunityCreatedDatess;    

        for(QueueDistribution__c queueDistribution : enabledQueueDistributions){
            if(queueDistribution.AgeOfOpportunity__c != null){
                Integer daysToOpportunityRotationDate = Integer.valueOf(queueDistribution.AgeOfOpportunity__c);
                returnOpportunityCreatedDatess.add(Date.today().addDays(-1 * daysToOpportunityRotationDate));
            }
        }  
        return returnOpportunityCreatedDatess;
    }
    
    public static String generateKeyFromTwoParts(String keyPart1, String keyPart2) {
        return keyPart1 + keyPart2;
    }
    
    public static String generateKeyFromThreeParts(String keyPart1, String keyPart2, String keyPart3) {
        return keyPart1 + keyPart2 + keyPart3;
    }
    
}