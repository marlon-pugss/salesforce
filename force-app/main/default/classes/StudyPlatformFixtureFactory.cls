@isTest
public class StudyPlatformFixtureFactory extends FixtureFactory{
    
    public StudyPlatformFixtureFactory() {
        super (new StudyPlatform__c());
    }
    
    public StudyPlatformFixtureFactory id (String recordId) {
        put ('Id', recordId);
        return this;
    }
    
    public StudyPlatformFixtureFactory name (String name) {
        put ('Name', name);
        return this;
    }
    
    public StudyPlatformFixtureFactory ownerId (String ownerId) {
        put ('OwnerId', ownerId);
        return this;
    }
    
    public StudyPlatformFixtureFactory email (String email) {
        put ('Email__c', email);
        return this;
    }
    
    public StudyPlatformFixtureFactory source (String source) {
        put ('Source__c', source);
        return this;
    }
    
    public StudyPlatformFixtureFactory courseId (String courseId) {
        put ('CourseId__c', courseId);
        return this;
    }
    
    public StudyPlatformFixtureFactory courseName (String courseName) {
        put ('CourseName__c', courseName);
        return this;
    }
    
    public StudyPlatformFixtureFactory progress (Integer progress) {
        put ('Progress__c', progress);
        return this;
    }
    
    public StudyPlatformFixtureFactory startedCourseDate (Date startedCourseDate) {
        put ('StartedCourseDate__c', startedCourseDate);
        return this;
    }
    
    public StudyPlatformFixtureFactory lastActivityDate (Date lastActivityDate) {
        put ('LastActivityDate__c', lastActivityDate);
        return this;
    }
    
    public StudyPlatformFixtureFactory loginsToDate (Integer loginsToDate) {
        put ('LoginsToDate__c', loginsToDate);
        return this;
    }
    
    public static StudyPlatform__c buildGeneric(){
        return (StudyPlatform__c) new StudyPlatformFixtureFactory().name('Teste')
                                              .email('Teste@gmail.com')
                                              .source('Teste1')
                                              .courseId('Teste1')
                                              .courseName('Teste1')
                                              .object();
    }
    
    public static StudyPlatform__c createGeneric(){
        StudyPlatform__c record = buildGeneric();
        insert record;
        return record;
    }
}