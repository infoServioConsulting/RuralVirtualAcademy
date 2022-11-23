global with sharing class V_F_StaffBlankParentEmail implements valence.TransformationFilter {
    
    // assign the ID from the first (only) element in the Account list
    List<Contact> guardians = [SELECT Name_ID__c FROM Contact WHERE Skyward_Guardian__c = true];
    
    // get the ID of the account with the Home Email (Household Key) equal to "skyward_staff@email.com". This is the RVA Staff account
    Account acct = [SELECT Id FROM Account WHERE Home_Email_Household_Key__c = 'skyward_staff@email.com' LIMIT 1];
    
    Map<String, String> guardianNameIds;
    Id staffAccount = acct.Id;
    
	// --------------------------------
	// ----- TransformationFilter -----
	// --------------------------------

    // valid for Links feeding the Contact object 
    
	public Boolean validFor(valence.LinkContext context) {
        return (context.linkSourceName == 'Faculty' && context.linkTargetName == 'Contact');
	}
        
	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {
    
        // get all Staff that have blank Parent Email (Household Key) fields
        guardianNameIds = new Map<String, String>();
        
        for (Contact c : guardians) {
            guardianNameIds.put(c.Name_ID__c, 'true');
        }
        
        for(valence.RecordInFlight record : records) {
            
            if (!guardianNameIds.containsKey('' + record.getOriginalPropertyValue('NameId'))) {
                
                // if the list of Staff contacts with blank emails contains the parent record ID (the upserted Staff),
                // assign the staff to the RVA Staff account
                
                record.setPropertyValue('AccountId', staffAccount);
                record.setPropertyValue('Parent_Email__c', 'skyward_staff@email.com');
                record.addWarning('Parent_Email__c has been updated to skyward_staff@email.com and the record has been associated to the Staff Account.');
            }
        }
    }
}