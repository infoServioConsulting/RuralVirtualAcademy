@isTest
private class V_F_HouseholdAccounts_T {
	private static valence.LinkContext context;
    private static V_F_HouseholdAccounts filter;
    
    static {
        context = new valence.LinkContext();
        context.linkTargetName = 'Account';
     	filter = new V_F_HouseholdAccounts();
    }
    
    @IsTest static void testValidFor() {
        system.AssertEquals(filter.validFor(context), true);    
    }
    
    
    @IsTest static void testProcess() {
        Map<String, String> blankEmail = new Map<String, String> {
            'HomeEmail' => ''
        };
            
        Map<String, String> notBlankEmail = new Map<String, String> {
            'HomeEmail' => 'not_blank@email.com'
        };
        
        List<valence.RecordInFlight> accounts = new List<valence.RecordInFlight>{
            new valence.RecordInFlight(blankEmail),
            new valence.RecordInFlight(notBlankEmail)
        };
        
        context.linkSourceName = 'Student';
        filter.process(context, accounts);
        
        for (valence.RecordInFlight account : accounts) {
            
            if (account.getOriginalPropertyValue('HomeEmail') != '') {
            	System.assertNotEquals(account.getPropertyValue('RecordTypeId'), null);
            	System.assertNotEquals(account.getPropertyValue('Name'), null);
                System.assertEquals(account.isIgnored(), false);
            } else {
                System.assertEquals(account.isIgnored(), true);
            }
        }
        
        Map<String, List<Map<String, String>>> guardian1;
    	Map<String, String> emailMap = new Map<String, String>();
        
        for (Account a : filter.accountQuery) {
                    if (!a.Contacts.isEmpty()) {
                            for (Contact c : a.Contacts) {
                                guardian1 = new Map<String, List<Map<String, String>>>{
                                    'Students' => new List<Map<String, String>>{
                                        new Map<String, String>{
                                            'StudentNameId' => c.Name_ID__c,
                                                'GuardianOrderNumber' => '1'
                                        }
                                    }
                                };
                                emailMap.put(c.Name_Id__c, c.Parent_Email__c);
                                break;
                            }
                        }
                    }
        
        List<valence.RecordInFlight> guardians = new List<valence.RecordInFlight>{
            new valence.RecordInFlight(guardian1)
        };
            
        context.linkTargetName = 'Contact';
        context.linkSourceName = 'Guardian';
        filter.process(context, guardians);
        
        for (valence.RecordInFlight g : guardians) {
            if (emailMap.get('' + g.getOriginalPropertyValue('Students[0].StudentNameId')) != null) {
            	System.assertNotEquals(g.getOriginalPropertyValue('ParentEmail'), null);
            	System.assertNotEquals(g.getPropertyValue('AccountId'), null);
            	System.assertNotEquals(g.getPropertyValue('Guardian_Order_Number__c'), null);
                System.assertEquals(g.isIgnored(), false);
            } else {
                System.assertEquals(g.isIgnored(), true);
            }
        }
    }
    
    @IsTest static void testDescribeSchema() {
        valence.FilterSchema schema;
        
        schema = filter.describeSchema(context);
        
        System.assertNotEquals(schema, null);
    }
}