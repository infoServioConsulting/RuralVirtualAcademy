@isTest
private class V_F_GradeEnrollment_T {
    
    private static valence.LinkContext context;
    private static V_F_GradeEnrollment filter;
    
    static {
        context = new valence.LinkContext();
        context.linkTargetName = 'Contact';
     	filter = new V_F_GradeEnrollment();
    }
    
    @IsTest static void testValidFor() {
        system.AssertEquals(filter.validFor(context), true);   
    }

    @IsTest static void testProcess() {
        
        List<String> grades = new List<String>{
            'PK',
            '4K',
            'K4',
            'KG',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '01',
            '02',
            '03',
            '04',
            '05',
            '06',
            '07',
            '08',
            '09',
            '10',
            '11',
            '12',
            'ST',
            'GD'
        };
            
        List<valence.RecordInFlight> records = new List<valence.RecordInFlight>();
        
        for (String grade : grades) {
            records.add(new valence.RecordInFlight(new Map<String, String>{
                'GradeLevel' => grade
            }));
        }        
                        
        context.linkSourceName = 'Student';
        filter.process(context, records);
        
        for (valence.RecordInFlight record : records) {
            System.assertNotEquals(record.getPropertyValue('k12kit__Current_Grade_Level__c'), null);
        }
        
    }
}