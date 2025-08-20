public class Mock {
    
    public static SimpleMock.Answer when(String methodName) {
        return new SimpleMock().when(methodName);
    }

    public static Matcher anyType() {
        return new TypeMatcher();
    }

    public static Matcher anyOf(Type type) {
        return new TypeMatcher(type);
    }

    public static Matcher anyString() {
        return anyOf(String.class);
    }

    public static Matcher anyBoolean() {
        return anyOf(Boolean.class);
    }

    public static Matcher anyInteger() {
        return anyOf(Integer.class);
    }

    public static Matcher anyDecimal() {
        return anyOf(Decimal.class);
    }

    public static Matcher anyDate() {
        return anyOf(Date.class);
    }

    public static Matcher anyDateTime() {
        return anyOf(DateTime.class);
    }

    public static Matcher value(Object value) {
        return new ValueMatcher(value);
    }

    public static Matcher record(SObject record) {
        return new SObjectMatcher(record);
    }

    public static Matcher records(SObject[] records) {
        return new SObjectListMatcher(records);
    }

    public interface Matcher { 
        Boolean matches(Object value);
    }

    public class TypeMatcher implements Matcher { 
        private Type type;

        public TypeMatcher() { }

        public TypeMatcher(Type type) {
            this.type = type;
        }

        public Boolean matches(Object value) {
            Type type = (Type) value;
            return (this.type == null) || (this.type.isAssignableFrom(type));
        }
    }

    public virtual class ValueMatcher implements Matcher {
        private Object value;

        protected ValueMatcher() { }

        public ValueMatcher(Object value) {
            this.value = value;
        }

        public virtual Boolean matches(Object value) {
            return this.value == value;
        }
    }

    public class SObjectMatcher extends ValueMatcher {
        private SObject expectedRecord;

        public SObjectMatcher(SObject expectedRecord) {
            this.expectedRecord = expectedRecord;
        }

        public override Boolean matches(Object value) {
            SObject record = (SObject) value;
            return Filter.match(expectedRecord).matches(record);
        }
    }

    public class SObjectListMatcher extends ValueMatcher {
        private SObject[] expectedRecords;

        public SObjectListMatcher(SObject[] expectedRecords) {
            this.expectedRecords = expectedRecords;
        }

        public override Boolean matches(Object value) {
            SObject[] records = (SObject[]) value;

            if (expectedRecords.size() != records.size()) return false;

            for (Integer i = 0; i < expectedRecords.size(); i++) {
                SObject expectedRecord = expectedRecords[i];
                SObject record = records[i];
                if (!Filter.match(expectedRecord).matches(record)) return false;
            }
            return true;
        }
    }
}