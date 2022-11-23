global with sharing class V_F_ContactRecordType implements valence.SchemaAwareTransformationFilter {
    
	// --------------------------------
	// ----- TransformationFilter -----
	// --------------------------------

    // This link is only valid for Links feeding the Contact object with either the Student or Faculty tables from Skyward
    
    @TestVisible
	public Boolean validFor(valence.LinkContext context) {
        return (context.linkTargetName == 'Contact');
	}
    
    @TestVisible
    List<Contact> staffList = new List<Contact>();
    
    @TestVisible
    Map<String, String> staffMap = new Map<String, String>();

    @TestVisible
	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {
        
        String source = context.linkSourceName;
        
        if (source.contains('Guardian')) {
            if (staffList.isEmpty()) {
                staffList = [SELECT Name_Id__c from Contact WHERE Skyward_Staff__c = true];
                
                for (Contact c : staffList) {
                    staffMap.put(c.Name_Id__c, 'true');
                }
            }
        }
        
        // Gathers record type Ids by name based on the link target (Contact)
                
		Map<String, String> recordTypesByDevName = V_HelperClass.getRecordTypeIdsByDevName(context.linkTargetName);
        
        for(valence.RecordInFlight record : records) {
            
            // If coming from the Student table, set SF checkboxes Skyward_Student__c and Active__c = true (checked) on the record
            if (source.contains('Student')) {
                
                if (source == 'NSOE_Students' && (('' + record.getOriginalPropertyValue('STU-STATUS')) != '*Cancelled By District') && (('' + record.getOriginalPropertyValue('STU-STATUS')) != '*Denied')) {
                	record.setPropertyValue('Active__c', true);
                } else {
                    record.setPropertyValue('Active__c', false);
                }
                
                if (source == 'Student') {
                    record.setPropertyValue('Active__c', true);
                	record.setPropertyValue('Skyward_Student__c', true);
                }
                
                // if the GradYr is also not equal to 9999, this indicates they're NOT a Staff Contact, and so are updated to the Student record type
                
                if (source.contains('NSOE') || (source == 'Student' && record.getOriginalPropertyValue('GradYr') != 9999)) {
                    record.setPropertyValue('RecordTypeId', recordTypesByDevName.get('Student'));
                }
                
            } else if (source == 'Faculty') {
                
                String employeeId = '' + record.getOriginalPropertyValue('EmployeeId');
                
                // If coming from the Staff table, and the EmployeeId is not blank or 0, set SF checkboxes Skyward_Staff__c and Active__c = true (checked) on the record
                // Also assign the Faculty record type. This will take precedence over a Guardian record type.
                
                if (employeeId != '' && employeeId != '0') {
            		record.setPropertyValue('Active__c', true);
                    record.setPropertyValue('Skyward_Staff__c', true);
                    record.setPropertyValue('RecordTypeId', recordTypesByDevName.get('Faculty'));
                } else {
                    record.ignore('Invalid Employee ID');
                }
                
            } else if (source.contains('Guardian')) {
                
                record.setPropertyValue('Active__c', true);
                
                if (source == 'Guardian') {
                	record.setPropertyValue('Skyward_Guardian__c', true);
                }
                
                // If the Guardian Name Id is found in the staffMap, indicating they're already a Staff member,
                // the record is ignored and a warning is shown. Otherwise, the record is updated to the Guardian record type
                if ((source == 'NSOE_Guardians' && !staffMap.containsKey('' + record.getOriginalPropertyValue('NAME-ID'))) || (source == 'Guardian' && !staffMap.containsKey('' + record.getOriginalPropertyValue('GuardianNameId')))) {
                    record.setPropertyValue('RecordTypeId', recordTypesByDevName.get('Guardian'));
                }
            }
        }
    }

	// -------------------------------------------
	// ----- SchemaAwareTransformationFilter -----
	// -------------------------------------------
	
	// This creates the RecordTypeId source field and allows the writing of the other fields above

    @TestVisible
	public valence.FilterSchema describeSchema(valence.LinkContext context) {
		valence.FilterSchema schema = new valence.FilterSchema();
        
        schema.createsSourceField(valence.Field.create('RecordTypeId').build());
        
		schema.addTouch(valence.FilterSchema.buildTargetTouch('WRITE').onField(new List<String>{
			'RecordTypeId',
            'Active__c',
            'Skyward_Student__c',
            'Skyward_Staff__c',
            'Skyward_Guardian__c'
		}));
        
		return schema;
	}
}