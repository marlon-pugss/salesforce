public class RecordMatchingFilterQuery extends FilterQuery {

	private sObject record;
	private Map<String, Object> availableFields = new Map<String, Object>();

	public RecordMatchingFilterQuery(sObject record) {
		this.record = record;
		for (String field : record.getSObjectType().getDescribe().fields.getMap().keyset()) {
			if (record.get(field) != null) {
				availableFields.put(field, record.get(field));
			}
		}
	}

	public override Boolean isValid(sObject o) {
		Boolean isValid = true;
		for (String field : availableFields.keySet()) {
			if (record.get(field) != o.get(field)) {
				isValid = false;
				break;
			}
		}
		return isValid;
	}
}