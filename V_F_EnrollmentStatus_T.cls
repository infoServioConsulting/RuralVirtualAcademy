@isTest
private class V_F_EnrollmentStatus_T {
    
	private static valence.LinkContext context;
    private static V_F_EnrollmentStatus filter;
    
    static {
        context = new valence.LinkContext();
        context.linkTargetName = 'Enrollment_Status__c';
     	filter = new V_F_EnrollmentStatus();
    }
    
    @IsTest static void testValidFor() {
        system.AssertEquals(filter.validFor(context), true);
    }
    
    @IsTest static void testProcess() {
        
        Map<String, String> recordTypesByDevName = V_HelperClass.getRecordTypeIdsByDevName(context.linkTargetName);
        
        Map<String, String> testData = new Map<String, String>{
            'PK' => 'New',
            '4K' => '*Approved',
            'K4' => 'WIP',
            'KG' => '*Cancelled By District',
            '1' => '*Denied',
            '2' => 'New',
            '3' => '*Approved',
            '4' => 'WIP',
            '5' => '*Cancelled By District',
            '6' => '*Denied',
            '7' => 'New',
            '8' => '*Approved',
            '9' => 'WIP',
            '01' => '*Cancelled By District',
            '02' => '*Denied',
            '03' => 'New',
            '04' => '*Approved',
            '05' => 'WIP',
            '06' => '*Cancelled By District',
            '07' => '*Denied',
            '08' => 'New',
            '09' => '*Approved',
            '10' => 'WIP',
            '11' => '*Cancelled By District',
            '12' => '*Denied',
            'ST' => 'New',
            'GD' => '*Approved' 
        };
            
            Map<String, String> typeMap = new Map<String, String>{
            'PK' => 'Elementary_and_Middle_School',
            '4K' => 'Elementary_and_Middle_School',
            'K4' => 'Elementary_and_Middle_School',
            'KG' => 'Elementary_and_Middle_School',
            '1' => 'Elementary_and_Middle_School',
            '2' => 'Elementary_and_Middle_School',
            '3' => 'Elementary_and_Middle_School',
            '4' => 'Elementary_and_Middle_School',
            '5' => 'Elementary_and_Middle_School',
            '6' => 'Elementary_and_Middle_School',
            '7' => 'Elementary_and_Middle_School',
            '8' => 'Elementary_and_Middle_School',
            '9' => 'High_School',
            '01' => 'Elementary_and_Middle_School',
            '02' => 'Elementary_and_Middle_School',
            '03' => 'Elementary_and_Middle_School',
            '04' => 'Elementary_and_Middle_School',
            '05' => 'Elementary_and_Middle_School',
            '06' => 'Elementary_and_Middle_School',
            '07' => 'Elementary_and_Middle_School',
            '08' => 'Elementary_and_Middle_School',
            '09' => 'Elementary_and_Middle_School',
            '10' => 'High_School',
            '11' => 'High_School',
            '12' => 'High_School',
            'ST' => 'Elementary_and_Middle_School',
            'GD' => 'Elementary_and_Middle_School' 
        };
            
            Map<String, String> statusChanges = new Map<String, String>{
                'New' => 'Application Received',
                    '*Approved' => 'You are Accepted',
                    'WIP' => 'Application Received',
                    '*Cancelled By District' => 'Application Received',
                    '*Denied' => 'Application Received'
                    };
                        
            Map<String, Boolean> rejects = new Map<String, Boolean>{
                	'New' => false,
                    '*Approved' => false,
                    'WIP' => false,
                    '*Cancelled By District' => true,
                    '*Denied' => true
            };
                        
        List<valence.RecordInFlight> records = new List<valence.RecordInFlight>();
        
        for (String grade : testData.keySet()) {
            
 
            records.add(new valence.RecordInFlight(new Map<String, String>{
                'MOD-STU-GRADE' => grade,
                    'STU-STATUS' => testData.get(grade)
                    }));
        	}
        
        filter.process(context, records);
        
        for (valence.RecordInFlight record : records) {
            if (record.getOriginalPropertyValue('STU-STATUS') != 'WIP') {
              System.assertEquals(record.getPropertyValue('Application_Denied__c'), rejects.get('' + record.getOriginalPropertyValue('STU-STATUS')));
            }
            System.assertEquals('' + record.getPropertyValue('Enrollment_Stage__c'), statusChanges.get('' + record.getOriginalPropertyValue('STU-STATUS')));
            System.assertNotEquals('' + record.getPropertyValue('RecordTypeId'), null);
        }
    }     
}