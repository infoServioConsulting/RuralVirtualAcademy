global with sharing class V_F_RelationshipUniqueId implements valence.SchemaAwareTransformationFilter {

	// --------------------------------
	// ----- TransformationFilter -----
	// --------------------------------

    // Valid only when the Relationship object is a target
    
	public Boolean validFor(valence.LinkContext context) {
        return context.linkTargetName == 'hed__Relationship__c';
	}
    
    // for each Relationship record, create a unique ID comprised of both Student and Guardian NameIds concatenated together
    // This ensures that each relationship can be upserted and duplicate records will not get created
    
    @TestVisible
    List<Contact> contacts = [SELECT ENR_GUARDIAN_ID__c, REG_STUDENT_ID__c, Name_ID__c, Id, hed__Gender__c from Contact];
    Map<String, Map<String, String>> guardianLookup = new Map<String, Map<String, String>>();
    Map<String, String> studentLookup = new Map<String, String>();
    
	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {
            
        String guardianRegId;
        String studentRegId;
        String nsoeId;
        
        String guardianNameId;
        String studentNameId;
        String skywardId;
        
        if (guardianLookup.isEmpty()) {
            for (Contact c : contacts) {
                if (c.ENR_GUARDIAN_ID__c != null) {
                    guardianLookup.put(c.ENR_GUARDIAN_ID__c, new Map<String, String>{'Id' => c.Id, 'NameId' => c.Name_ID__c,'Gender' => c.hed__Gender__c});
                } 
                
                if (c.REG_STUDENT_ID__c != null) {
                	studentLookup.put(c.REG_STUDENT_ID__c, c.Id);
                }
            }   
        }
    
        for(valence.RecordInFlight record : records) {
            if (context.linkSourceName == 'NSOE_Students'){
                
                guardianRegId = '' + record.getOriginalPropertyValue('REG-GUARDIAN-ID');
                studentRegId = '' + record.getOriginalPropertyValue('REG-STUDENT-ID');
               
                if ((guardianLookup.get(guardianRegId) != null) && (studentLookup.get(studentRegId) != null)) {
                    
                    nsoeId = guardianRegId + studentRegId;
                    record.setOriginalPropertyValue('NSOERelationshipId', nsoeId);
                    
                    guardianNameId = guardianLookup.get(guardianRegId).get('NameId');
                    studentNameId = '' + record.getOriginalPropertyValue('NAME-ID');
                    
                    record.setPropertyValue('hed__Contact__c', '' + studentLookup.get(studentRegId));
                    record.setPropertyValue('hed__RelatedContact__c', '' + guardianLookup.get(guardianRegId).get('Id'));
                    
                    if (guardianLookup.get(guardianRegId).get('Gender') == 'Male') {
                        record.setPropertyValue('hed__Type__c', 'Father');
                    } else {
                        record.setPropertyValue('hed__Type__c', 'Mother');
                    }
                } else {
                    record.ignore('REG-GUARDIAN-ID is not found in the ENR-GUARDIAN-ID on Contacts in Salesforce.');
                }
                
            } else if (record.getOriginalPropertyValue('StudentNameId') != null) {
                
                guardianNameId = '' + record.getOriginalPropertyValue('$ParentSource.GuardianNameId');
                studentNameId = '' + record.getOriginalPropertyValue('StudentNameId');
            }

            skywardId = guardianNameId + studentNameId;
            record.setOriginalPropertyValue('RelationshipUniqueId', skywardId);
        }
    }

	// -------------------------------------------
	// ----- SchemaAwareTransformationFilter -----
	// -------------------------------------------

	// This creates the RelationshipUniqueId source field and allows the writing of the other fields above
	
	public valence.FilterSchema describeSchema(valence.LinkContext context) {
		valence.FilterSchema schema = new valence.FilterSchema();

        schema.createsSourceField(valence.Field.create('NSOERelationshipId').build());
        schema.createsSourceField(valence.Field.create('RelationshipUniqueId').build());
        
		schema.addTouch(valence.FilterSchema.buildTargetTouch('WRITE').onField(new List<String>{
			'NSOE_Relationship_ID__c',
			'Relationship_Unique_ID__c'
		}));
		return schema;
	}
}