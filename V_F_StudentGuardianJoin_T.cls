@IsTest(SeeAllData=true)
private class V_F_StudentGuardianJoin_T {
	private static valence.LinkContext context;
    private static V_F_StudentGuardianJoin filter;
    
    static {
        context = new valence.LinkContext();
        context.linkSourceName = 'NSOE_Guardians';
     	filter = new V_F_StudentGuardianJoin();
    }
    
    @IsTest static void testValidFor() {
        system.AssertEquals(filter.validFor(context), true);
    }
    
    @IsTest static void testProcess() {
        
        
    Map<String, String> guardianIds = new Map<String, String>();
        
        String gId;
        
        for (Contact c : filter.nsoeStudents) {
            gId = c.REG_GUARDIAN_ID__c;
            break;
        }  
        
        
        List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
            new valence.RecordInFlight(new Map<String, String>{
				'ENR-GUARDIAN-ID' => gId
            })
        };
            
        context.linkSourceName = 'NSOE_Guardians';
        filter.process(context, records);
        
        for (valence.RecordInFlight record : records) {
            Object property = record.getPropertyValue('Active__c');
            
            System.assertEquals(null, null);
        }
        
    }
}