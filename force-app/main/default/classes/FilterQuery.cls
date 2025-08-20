public abstract class FilterQuery {

    public abstract Boolean isValid(sObject obj);

    public Boolean matches(SObject record) {
        return findFirst(new SObject[] { record }) == record;
    }
    
    public sObject findFirst(Iterable<sObject> records) {

        Iterator<sObject> iter = records.iterator();
        while (iter.hasNext()) {
            sObject obj = iter.next();
            if (isValid(obj)) {
                return obj;
            }
        }

        return null;
    }

}