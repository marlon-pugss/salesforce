public abstract with sharing class AbstractRepository {

    public SObject save (sObject record) {
        if (record == null) return record;
        
        return this.save(new List<SObject>{record}).get(0);
    }
    
    public List<SObject> save (List<sObject> records) {
        if (records.isEmpty()) return records; 

        upsert records;
        return records;
    }

    public SObject remove (sObject record) {
        if (record == null) return record;
        
        return this.remove(new List<SObject>{record}).get(0);
    }
    
    public List<SObject> remove (List<SObject> records) {
        if (records.isEmpty()) return records; 

        delete records;
        return records;
    }

}