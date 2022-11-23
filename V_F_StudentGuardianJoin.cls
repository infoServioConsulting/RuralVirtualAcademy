global with sharing class V_F_StudentGuardianJoin implements valence.TransformationFilter {
    
	// --------------------------------
	// ----- TransformationFilter -----
	// --------------------------------

    // This link is only valid for Links feeding the Contact object with either the Student or Faculty tables from Skyward
    
    @TestVisible
	public Boolean validFor(valence.LinkContext context) {
        return (context.linkSourceName == 'NSOE_Guardians');
	}
    
    @TestVisible
    List<Contact> nsoeStudents = [SELECT REG_GUARDIAN_ID__c from Contact WHERE REG_GUARDIAN_ID__c != null AND Active__c = true];
    Map<String, String> guardianIds = new Map<String, String>();
	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {
        
        if (guardianIds.isEmpty()) {
            for (Contact c : nsoeStudents) {
                guardianIds.put(c.REG_GUARDIAN_ID__c, '');
        	}  
        }
        
        for(valence.RecordInFlight record : records) {
            if (guardianIds.get('' + record.getOriginalPropertyValue('ENR-GUARDIAN-ID')) == null) {
                record.setPropertyValue('Active__c', false);
                record.ignore('This Guardian is not tied to an NSOE Student record.');
            }
        }
    }
}