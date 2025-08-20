@isTest
public class EmailMessageFixtureFactory extends FixtureFactory{
    
    public EmailMessageFixtureFactory() {
        super (new EmailMessage());
    }
    
    public EmailMessageFixtureFactory id (String fieldValue) {
        put ('Id', fieldValue);
        return this;
    }
    
    public EmailMessageFixtureFactory parentId (String fieldValue) {
        put ('ParentId', fieldValue);
        return this;
    }
    
    public EmailMessageFixtureFactory subject (String fieldValue) {
        put ('Subject', fieldValue);
        return this;
    }
    
    public EmailMessageFixtureFactory fromAddress (String fieldValue) {
        put ('FromAddress', fieldValue);
        return this;
    }
    
    public static EmailMessage buildGeneric(String subject, String fromAddress, String parentId){
        return (EmailMessage) new EmailMessageFixtureFactory().subject(subject)
            												  .fromAddress(fromAddress)
            												  .parentId(parentId)
            												  .object();
    }
    
    public static EmailMessage createGeneric(String subject, String fromAddress, String parentId){
        EmailMessage email = buildGeneric(subject, fromAddress, parentId);
        insert email;
        return email;
    }
    
}