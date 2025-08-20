public class AccountBuilder {
 
    private Account account;
    
    public AccountBuilder(){
        reset();
    }

    public void reset() {
        account = new Account();
    }
    
    public Account build() {
        return account;
    }

    public AccountBuilder id (String id){
        account.Id = id;
        return this;
    }

    public AccountBuilder recordTypeId (String recordTypeId){
        account.RecordTypeId = recordTypeId;
        return this;
    }

    public AccountBuilder name (String name){
        account.Name = name;
        return this;
    }

    public AccountBuilder firstName (String firstName){
        account.FirstName = firstName;
        return this;
    }

    public AccountBuilder lastName (String lastName){
        account.LastName = lastName;
        return this;
    }

    public AccountBuilder completeName (String completeName){
        account.NomeCompleto__c = completeName;
        return this;
    }

    public AccountBuilder email (String email){
        account.Email__c = email;
        return this;
    }

    public AccountBuilder fluencyId (String fluencyId){
        account.FluencyId__c = fluencyId;
        return this;
    }

    public AccountBuilder avatar (String avatar){
        account.Avatar__c = avatar;
        return this;
    }

    public AccountBuilder gender (String gender){
        account.Gender__c = gender;
        return this;
    }

    public AccountBuilder instagram (String instagram){
        account.Instagram__c = instagram;
        return this;
    }

    public AccountBuilder facebook (String facebook){
        account.Facebook__c = facebook;
        return this;
    }

    public AccountBuilder twitter (String twitter){
        account.Twitter__c = twitter;
        return this;
    }

    public AccountBuilder nativeLanguage (String nativeLanguage){
        account.NativeLanguage__c = nativeLanguage;
        return this;
    }

    public AccountBuilder document (String document){
        account.Documento__c = document;
        return this;
    }

    public AccountBuilder documentType (String documentType){
        account.TipoDocumento__c = documentType;
        return this;
    }

    public AccountBuilder phone (String phone){
        account.Telefone__c = phone;
        return this;
    }

    public AccountBuilder checkoutPhone (String checkoutPhone){
        account.TelefoneCheckout__c = checkoutPhone;
        return this;
    }

    public AccountBuilder billingStreet (String billingStreet){
        account.BillingStreet = billingStreet;
        return this;
    }

    public AccountBuilder billingDistrict (String billingDistrict){
        account.BillingDistrict__c = billingDistrict;
        return this;
    }

    public AccountBuilder billingNumber (Decimal billingNumber){
        account.BillingNumber__c = billingNumber;
        return this;
    }

    public AccountBuilder billingCity (String billingCity){
        account.BillingCity = billingCity;
        return this;
    }

    public AccountBuilder billingState (String billingState){
        account.BillingState = billingState;
        return this;
    }

    public AccountBuilder billingPostalCode (String billingPostalCode){
        account.BillingPostalCode = billingPostalCode;
        return this;
    }

    public AccountBuilder billingCountry (String billingCountry){
        account.BillingCountry = billingCountry;
        return this;
    }

    public AccountBuilder billingCountryIsoCode (String billingCountryIsoCode){
        account.BillingCountryIsoCode__c = billingCountryIsoCode;
        return this;
    }
    
    public AccountBuilder journey (String journey){
        account.Journey__c = journey;
        return this;
    }
    
    public AccountBuilder fullPhone (String fullPhone){
        account.FullPhone__c = fullPhone;
        return this;
    }
    
    public AccountBuilder numberOfActiveContracts (Decimal numberOfActiveContracts){
        account.NumberOfActiveContracts__c = numberOfActiveContracts;
        return this;
    }
    
}