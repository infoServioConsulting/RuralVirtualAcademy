@IsTest(SeeAllData=true)
private class V_F_RelationshipUniqueId_T {
    
    private static valence.LinkContext context;
    private static V_F_RelationshipUniqueId filter;
    
    static {
        context = new valence.LinkContext();
        context.linkTargetName = 'hed__Relationship__c';
     	filter = new V_F_RelationshipUniqueId();
    }

    @IsTest static void testValidFor() {
        system.AssertEquals(filter.validFor(context), true);
    }
    
    @IsTest static void testProcess() {
        
    Map<String, Map<String, String>> guardianLookup = new Map<String, Map<String, String>>();
    Map<String, String> studentLookup = new Map<String, String>();
        
        String gId1;
        String sId1;
        
        for (Contact c : filter.contacts) {
            if (c.ENR_GUARDIAN_ID__c != null) {
                gId1 = c.ENR_GUARDIAN_ID__c;
            } 
            
            if (c.REG_STUDENT_ID__c != null) {
                sId1 = c.REG_STUDENT_ID__c;
            }
        }   
        
    
        List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
            new valence.RecordInFlight(new Map<String, String>{                
                'REG-STUDENT-ID' => sId1,
                    'REG-GUARDIAN-ID' => gId1
            })
        };
        
        context.linkSourceName = 'NSOE_Students';
        filter.process(context, records);
        
        for (valence.RecordInFlight record : records) {
            Object property = record.getOriginalPropertyValue('NSOERelationshipId');
            
            System.assertEquals(false, false);
        }
        
        records = new List<valence.RecordInFlight>{
            new valence.RecordInFlight(new Map<String, Object>{
                '$ParentSource' => new Map<String, Object>{
                    'GuardianNameId' => '12345'
                },
                'StudentNameId' => '23456'
            })
        };
            
        context.linkSourceName = null;
        filter.process(context, records);
        
        for (valence.RecordInFlight record : records) {
            Object property = record.getOriginalPropertyValue('RelationshipUniqueId');
            
            System.assertNotEquals(property, null);
            System.assertEquals(property, '1234523456');
        }
    
    }
    
    @IsTest static void testDescribeSchema() {
		valence.FilterSchema schema;
        
        schema = filter.describeSchema(context);
        
        System.assertNotEquals(schema, null);
    }
}