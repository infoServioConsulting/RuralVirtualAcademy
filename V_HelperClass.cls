global with sharing class V_HelperClass {
    
    @TestVisible
	public static Map<String, String> getRecordTypeIdsByDevName(String objectName) {
		Map<String, String> recordTypesByDevName = new Map<String, Id>();
		for(RecordType recordType : getTypesForObject(objectName)) {
			recordTypesByDevName.put(recordType.DeveloperName, recordType.Id);
		}

		return recordTypesByDevName;
	}
    
	@TestVisible
	private static List<RecordType> getTypesForObject(String objectName) {
		return [SELECT Id, DeveloperName, Name FROM RecordType WHERE SobjectType = :objectName];
	}

}