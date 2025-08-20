public virtual class Filter {
	
    public static RecordMatchingFilterQuery match(sObject prototype) {
        return new RecordMatchingFilterQuery(prototype);
    }

    public List<sObject> relevantChangeRecordsFilter (List<sObject> newRecords, Map<Id, sObject> oldRecords, String changedField, String expectedValue) {

        List<SObject> changedRecords = relevantChangeRecordsFilter ( newRecords, oldRecords, new List<String> { changedField } );

        List<SObject> changedRecordsWithValue = new List<SObject>();

        for (SObject record : changedRecords ) {

            String recordValue = '' + record.get(changedField);
            String receivedValue = '' + expectedValue;

            if ( recordValue != receivedValue ) { continue; }

            changedRecordsWithValue.add(record);

        }

        return changedRecordsWithValue;

    }

    public List<sObject> relevantChangeRecordsFilter (List<sObject> newRecords, Map<Id, sObject> oldRecords, String changedField, List<String> expectedValues) {

        List<SObject> changedRecords = relevantChangeRecordsFilter ( newRecords, oldRecords, new List<String> { changedField } );

        List<SObject> changedRecordsWithValue = new List<SObject>();

        for (SObject record : changedRecords) {

            String recordValue = '' + record.get(changedField);

            if ( !expectedValues.contains(recordValue) ) continue;

            changedRecordsWithValue.add(record);
        }

        return changedRecordsWithValue;
    }

    public List<sObject> relevantChangeRecordsFilterExceptValue ( List<sObject> newRecords, Map<Id, sObject> oldRecords, List<String> exceptValues, String changedField ) {

        List<SObject> changedRecords = relevantChangeRecordsFilter ( newRecords, oldRecords, new List<String> { changedField } );

        List<SObject> changedRecordsWithValue = new List<SObject>();

        for (SObject record : changedRecords ) {

            String recordValue = '' + record.get ( changedField );

            if ( exceptValues.contains ( recordValue ) ) { continue; }

            changedRecordsWithValue.add(record);

        }

        return changedRecordsWithValue;

    }

    virtual public List<sObject> relevantChangeRecordsFilter (List<sObject> newRecords, Map<Id, sObject> oldRecords, List<String> changedFiedls ) {

        List<SObject> relevantChanges = new List<SObject>();

        if ( newRecords == null || newRecords.isEmpty() ) { return relevantChanges; }

        if ( oldRecords == null || oldRecords.isEmpty() ) { return newRecords; }

        for ( SObject record : newRecords  ) {

            SObject oldRecord = oldRecords.get( (Id) record.get('Id') ) ;

            if ( !hasRelevantChanges (record, oldRecord, changedFiedls) ) { continue; }

            relevantChanges.add (record);

        }

        return relevantChanges;

    }

    virtual public List<sObject> relevantChangeRecordsFilter ( List<sObject> newRecords, Map<Id, sObject> oldContractsById, String fieldName, String fromValue, String toValue ) {

        List<SObject> relevantChanges = new List<SObject>();

        if ( newRecords == null || newRecords.isEmpty() ) { return relevantChanges; }

        if ( oldContractsById == null || oldContractsById.isEmpty() ) { return newRecords; }

        for ( SObject record : newRecords  ) {

            if ( record.get(fieldName) != toValue ) { continue; }

            SObject oldRecord = oldContractsById.get( (Id) record.get('Id') ) ;

            if ( oldRecord.get(fieldName) != fromValue ) { continue; }

            relevantChanges.add (record);

        }

        return relevantChanges;

    }

    virtual public List<sObject> relevantChangeRecordsByValueFilter ( List<sObject> newRecords, Map<Id, sObject> oldContractsById, String fieldName, String toValue ) {

        List<SObject> relevantChanges = new List<SObject>();

        if ( newRecords == null || newRecords.isEmpty() ) { return relevantChanges; }

        if ( oldContractsById == null || oldContractsById.isEmpty() ) { return newRecords; }

        for ( SObject record : newRecords  ) {
            SObject oldRecord = oldContractsById.get( (Id) record.get('Id') ) ;

            if ( !hasRelevantChanges (record, oldRecord, new  List<String>{fieldName}) ) { continue; }

            if ( record.get(fieldName) != toValue ) { continue; }

            relevantChanges.add (record);

        }

        return relevantChanges;

    }

    virtual public List<sObject> filterByInnerFieldNotIn ( List<sObject> records, String outerField, String innerField, String value ) {

        List<SObject> filteredRecords = new List<SObject>();

        if ( records == null || records.isEmpty() ) { return filteredRecords; }

        for ( SObject record : records ) {

            SObject innerRecord = record.getSObject ( outerField );

            String innerRecordField = String.valueOf ( innerRecord.get ( innerField ) );

            if ( innerRecordField == value ) { continue; }

            filteredRecords.add ( record );

        }

        return filteredRecords;

    }
    
    public static List<sObject> filterByFieldNotEmpty (List<sObject> records, String field){
        
        List<sObject> filteredRecords = new List<sObject>();

        if (records == null || records.isEmpty()) return filteredRecords;

        for (sObject record : records) {
            String fieldValue = String.valueOf( record.get(field) );
            
            if (fieldValue == null || fieldValue == '' || fieldValue == 'null') continue;

            filteredRecords.add(record);
        }

        return filteredRecords;
    }

    private Boolean hasRelevantChanges ( sObject changed , sObject old , List<String> changedFiedls ) {

        if ( old == null ) { return true; }

        for ( String field : changedFiedls ) {

            if ( changed.get(field)  !=  old.get(field) ) { return true; }

        }

        return false;

    }

}