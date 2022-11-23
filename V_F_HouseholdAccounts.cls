global with sharing class V_F_HouseholdAccounts implements valence.SchemaAwareTransformationFilter {

	// --------------------------------
	// ----- TransformationFilter -----
	// --------------------------------
    
    // This filter is only valid for Links that update Account object records
    
	public Boolean validFor(valence.LinkContext context) {
        return ((context.linkTargetName == 'Account') || ((context.linkSourceName == 'Guardian') && (context.linkTargetName == 'Contact')));
	}
    
    // Gathers record type Ids for Accounts
    Map<String, String> recordTypesByDevName = V_HelperClass.getRecordTypeIdsByDevName('Account');
    String hhAccountRecordTypeId = recordTypesByDevName.get('HH_Account');
    
    @TestVisible
    List<Account> accountQuery = [SELECT Home_Email_Household_Key__c, (SELECT AccountId, Name_ID__c, Parent_Email__c FROM Contacts WHERE Skyward_Student__c = true) FROM Account WHERE RecordTypeId = :hhAccountRecordTypeId];      
 
    Map<String, Map<String, String>> studentMap = new Map<String, Map<String, String>>();
    
	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {
        
        if ((context.linkSourceName == 'Guardian') && (context.linkTargetName == 'Contact')) {
            
            if (studentMap.keySet().isEmpty()) {
                for (Account a : accountQuery) {
                    if (!a.Contacts.isEmpty()) {
                            for (Contact c : a.Contacts) {
                                studentMap.put(c.Name_ID__c, new Map<String, String> {
                                    'ParentEmail' => c.Parent_Email__c,
                                        'AccountId' => c.AccountId
                                        });
                            }
                        }
                    }
                }
            }

        
        for(valence.RecordInFlight record : records) {
        	
            if ((context.linkSourceName == 'Student') && (context.linkTargetName == 'Account')) {
                // If the HomeEmail property exists on the record (Student), and it's blank, ignore the Account creation because we don't have a Home Email (Household Key) to assign to the Account.
                if (record.getOriginalPropertyValue('HomeEmail') == '') {
                    record.ignore('Household Account ignored. Student Home Email is blank.');
                } else {
                // If the (Home)Email is not blank, create the Household as normal. Set the Name and Record Type of the account
                // The HomeEmail field gets mapped to Home Email (Household Key) through the Valence mapping, so it is not assigned here.
                // Assigns the Name based on LastName and assigns Record Type ID by finding the name of the record type ('HH_Account') in recordTypesByDevName 
                    record.setPropertyValue('Name', record.getOriginalPropertyValue('LastName') + ' Household');
                    record.setPropertyValue('RecordTypeId', hhAccountRecordTypeId);
                }
            } else if ((context.linkSourceName == 'Guardian') && (context.linkTargetName == 'Contact')) {
                
                String studentNameId = '' + record.getOriginalPropertyValue('Students[0].StudentNameId');
                String guardianOrderNumber = '' + record.getOriginalPropertyValue('Students[0].GuardianOrderNumber');
                
                if (studentMap.get(studentNameId) != null) {
                    record.setOriginalPropertyValue('ParentEmail', studentMap.get(studentNameId).get('ParentEmail'));
                    record.setPropertyValue('AccountId', studentMap.get(studentNameId).get('AccountId'));
                    record.setPropertyValue('Guardian_Order_Number__c', guardianOrderNumber);
                } else {
                    record.ignore('An Account was not found with this Home Email address: ' + studentMap.get(studentNameId));
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
        
        schema.createsSourceField(valence.Field.create('ParentEmail').build());
        
		schema.addTouch(valence.FilterSchema.buildTargetTouch('WRITE').onField(new List<String>{
            'Parent_Email__c'
		}));
        
		return schema;
	}
}