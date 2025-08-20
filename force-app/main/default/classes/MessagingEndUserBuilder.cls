public class MessagingEndUserBuilder {

    private MessagingEndUser messagingEndUser;
    
    public MessagingEndUserBuilder(){
        reset();
    }

    public void reset() {
        messagingEndUser = new MessagingEndUser();
    }
    
    public MessagingEndUser build() {
        return messagingEndUser;
    }

    public MessagingEndUserBuilder id (String fieldValue){
        messagingEndUser.Id = fieldValue;
        return this;
    }

    public MessagingEndUserBuilder accountId  (String fieldValue){
        messagingEndUser.AccountId  = fieldValue;
        return this;
    }

}