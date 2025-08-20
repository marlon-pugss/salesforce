@isTest 
public with sharing class UserFixtureFactory extends FixtureFactory { 

    public UserFixtureFactory() {
        super ( new User() );
    }
    
    public UserFixtureFactory id (String recordId) {
        put ( 'Id', recordId );
        return this;
    }
    
    public UserFixtureFactory firstName (String firstName) {
        put ( 'FirstName', firstName );
        return this;
    }
    
    public UserFixtureFactory lastName (String lastName) {
        put ( 'LastName', lastName );
        return this;
    }
    
    public UserFixtureFactory userName (String userName) {
        put ( 'UserName', userName );
        return this;
    }
    
    public UserFixtureFactory email (String email) {
        put ( 'Email', email );
        return this;
    }
    
    public UserFixtureFactory alias (String alias) {
        put ( 'Alias', alias );
        return this;
    }
    
    public UserFixtureFactory timeZoneSidKey (String timeZoneSidKey) {
        put ( 'TimeZoneSidKey', timeZoneSidKey );
        return this;
    }
    
    public UserFixtureFactory localeSidKey (String localeSidKey) {
        put ( 'LocaleSidKey', localeSidKey );
        return this;
    }
    
    public UserFixtureFactory emailEncodingKey (String emailEncodingKey) {
        put ( 'EmailEncodingKey', emailEncodingKey );
        return this;
    }
    
    public UserFixtureFactory languageLocaleKey (String languageLocaleKey) {
        put ( 'LanguageLocaleKey', languageLocaleKey );
        return this;
    }
    
    public UserFixtureFactory profileId (String profileId) {
        put ( 'ProfileId', profileId );
        return this;
    }
    
    public UserFixtureFactory workSchedule (String workSchedule) {
        put ( 'WorkSchedule__c', workSchedule );
        return this;
    }
    
    public static User buildGeneric(){
        Profile profile	  = [SELECT Id FROM Profile WHERE Name LIKE '%Vendas%' limit 1];
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String millis	  = String.valueof(System.currentTimeMillis());
        String email	  = 'standarduser'+millis+randomInt+'@fluencyacademy.io';
        String test		  = 'test';
        
        return (User) new UserFixtureFactory().firstName('John')
            								  .lastName('Doe')
            								  .userName(email)
            								  .email(email)
            								  .alias(test)
            								  .timeZoneSidKey('America/Los_Angeles')
            								  .localeSidKey('pt_BR')
            								  .emailEncodingKey('UTF-8')
            								  .languageLocaleKey('pt_BR')
            								  .profileId(profile.Id)
            								  .workSchedule(Common.ALL_DAYS_WORK_SCHEDULE)
            								  .object();
    }
    
    public static User createGeneric(){
        User user = buildGeneric();
        insert user;
        return user;
    }
    
}