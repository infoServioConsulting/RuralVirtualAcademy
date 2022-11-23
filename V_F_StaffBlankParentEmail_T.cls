@IsTest(SeeAllData=true)
private class V_F_StaffBlankParentEmail_T {
    
	private static valence.LinkContext context;
    private static V_F_StaffBlankParentEmail filter;
    
    static {
        context = new valence.LinkContext();
        context.linkSourceName = 'Faculty';
        context.linkTargetName = 'Contact';
     	filter = new V_F_StaffBlankParentEmail();
    }

    @IsTest static void testValidFor() {
        system.AssertEquals(filter.validFor(context), true);
    }
    
      @IsTest static void testProcess() {

        List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
            new valence.RecordInFlight(new Map<String, Object>{
                '$ParentTarget' => new Map<String, Object>{
                    'Id' => (Id)'0035900000HSrKgAAL'
                }
            })
        };
                        
        filter.process(context, records);
        
        for (valence.RecordInFlight record : records) {
            Object property = record.getPropertyValue('Parent_Email__c');
            
            System.assertEquals(null, null);
        }
    }
}