public class CreateCaseHelper {

    public CreateCaseHelper(){}

    public Case createNewCase(String subject, String type, String status, String contractId){

        return new CaseBuilder().subject(subject)
                                .type(type)
                                .status(status)
                                .contract(contractId)
                                .build();
    }
}