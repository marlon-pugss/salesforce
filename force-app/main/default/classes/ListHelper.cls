public with sharing class ListHelper { 
    
    public static Set<Id> convertStringListIntoSetIds (List<String> baseList) {
        Set<Id> filtered = new Set<Id>();

        for (String data : baseList)
            filtered.add( data );

        return filtered;
    }

    public static List<String> convertSetIdsToListString (Set<ID> baseSet) {
        List<String> filtered = new List<String>();

        for (ID data : baseSet) 
            filtered.add(data);

        return filtered;
    }

    public static List<Integer> convertIntegerSetToListInteger (Set<Integer> baseSet) {
        List<Integer> filtered = new List<Integer>();

        for (Integer data : baseSet) 
            filtered.add(data);

        return filtered;
    }

    public static Set<Id> convertObjectListIntoSetIds (String fieldNameForFilter, List<SObject> baseList) {
        Set<Id> filtered = new Set<Id>();

        if ( baseList == null  || baseList.isEmpty() ) return filtered;

        for ( SObject data : baseList  ) {
            if ( data.get(fieldNameForFilter ) == null ) continue;
            
            filtered.add( '' + data.get(fieldNameForFilter) );
        }

        return filtered;
    }

    public static List<String> convertObjectListIntoStringList (String fieldNameForFilter, List<SObject> baseList) {
        Set<String> filtered = new Set<String>();
        List<String> result  = new List<String>();
        
        if (baseList == null || baseList.isEmpty()) return result;

        for (SObject data : baseList){
            if ( data.get(fieldNameForFilter) == null ) continue;
            
            filtered.add('' + data.get(fieldNameForFilter) );
        }
        
        result.addAll (filtered);

        return result;
    }
    
    public static String convertStringListIntoString (List<String> baseList) {
        String result = NULL;
        
        if (baseList == null || baseList.isEmpty()) return result;

        for (Integer i = 0 ; i < baseList.size() ; i++){           
            if (result == NULL)
                result = '\'' + baseList[i] + '\', ';
            else if (i == baseList.size() - 1)       
                result += '\'' + baseList[i] + '\'';
            else
                result += '\'' + baseList[i] + '\', ';
        }
        
        return result;
    }
    
    public static String convertStringSetIntoString (Set<String> baseList) {
        String result = NULL;
        List<String> stringToIterate = convertStringSetIntoStringList(baseList);
        
        return convertStringListIntoString(stringToIterate);
    }
    
    public static List<String> convertStringSetIntoStringList(Set<String> setToConvert){
        List<String> listToReturn = new List<String>();
        
        if (setToConvert == null || setToConvert.size() == 0) return listToReturn;
        
        for (String value : setToConvert)
            listToReturn.add(value);
        
        return listToReturn;
    }
    
    public static Set<String> convertStringSplittedByCommasIntoStringSet(String stringToConvert){
        Set<String> setToReturn = new Set<String>();
        
        if (stringToConvert == null || stringToConvert == '') return setToReturn;
        
        List<String> stringSplitedByComma = stringToConvert.split(',');
        
        for (String value : stringSplitedByComma)
            setToReturn.add(value.trim());
        
        return setToReturn;
    }
    
    public static Set<String> convertAllToUpperCase(Set<String> setToConvert){
        Set<String> setToReturn = new Set<String>();
        
        if (!Utils.isFilled(setToConvert)) return setToReturn;
                
        for (String value : setToConvert)
            setToReturn.add(value.toUpperCase());
        
        return setToReturn;
    }
    
    public static Set<String> convertAllToNcharsLeft(Set<String> setToConvert, Integer numberOfChars){
        Set<String> setToReturn = new Set<String>();
        
        if (!Utils.isFilled(setToConvert)) return setToReturn;
                
        for (String value : setToConvert)
            setToReturn.add(value.left(numberOfChars));
        
        return setToReturn;
    }
    
    public static Boolean isListEmpty(List<sObject> baseList){
        return baseList == null || baseList.size() == 0;
    }

	public static String searchIntoList (String key , List<String> searchList) {
        for (String value : searchList)
            if ( value.indexOf (key) > 0 ) return value;

        return null;
    }    
    
    public static Map<String, SObject> indexListByField (String fieldNameForFilter, List<SObject> baseList) {

        Map<String, SObject> values = new Map<String, SObject>();

        if (baseList == null || baseList.isEmpty()) return values;

        for (SObject data : baseList) {
            String value = '' + data.get(fieldNameForFilter);

            if (value == null) continue;

            values.put(value, data);
        }

        return values;
    }    

    public static Map<String, List<SObject>> groupListByField ( String fieldNameForFilter, List<SObject> baseList) {
        Map<String, List<SObject>> values = new  Map<String, List<SObject>>();

        if (baseList == null || baseList.isEmpty()) return values;

        for ( SObject data : baseList) {
            String value = '' + data.get(fieldNameForFilter);

            if(value == null) continue;

            if(values.get(value) == null) 
                values.put(value, new List<SObject>());

            values.get(value).add (data);
        }

        return values; 
    }

}