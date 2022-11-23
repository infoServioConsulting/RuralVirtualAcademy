@isTest
private class V_F_ContactRecordType_T {

    private static valence.LinkContext context;
    private static V_F_ContactRecordType filter;
    
    static {
        context = new valence.LinkContext();
        context.linkTargetName = 'Contact';
     	filter = new V_F_ContactRecordType();
    }
    
    @IsTest static void testValidFor() {
        system.AssertEquals(filter.validFor(context), true);
    }
    
    @IsTest static void testProcess() {
        
        Map<String, String> gradStudent = new Map<String, String> {
            'GradYr' => '9999'
        };
        
        Map<String, String> currentStudent = new Map<String, String> {
            'GradYr' => '2025'
        };
            
        List<valence.RecordInFlight> students = new List<valence.RecordInFlight>{
            new valence.RecordInFlight(gradStudent),
            new valence.RecordInFlight(currentStudent)
        };
                        
        context.linkSourceName = 'Student';
        filter.process(context, students);
        
        for (valence.RecordInFlight student : students) {
            
            if (student.getOriginalPropertyValue('GradYr') != 9999) {
                System.assertNotEquals(student.getPropertyValue('Skyward_Student__c'), null);
                System.assertNotEquals(student.getPropertyValue('Active__c'), null);
                System.assertNotEquals(student.getPropertyValue('RecordTypeId'), null);
            } else {
                System.assertEquals(student.getPropertyValue('Skyward_Student__c'), null);
                System.assertEquals(student.getPropertyValue('Active__c'), null);
                System.assertEquals(student.getPropertyValue('RecordTypeId'), null);
            }
        }
        
        List<valence.RecordInFlight> staff = new List<valence.RecordInFlight>{
            new valence.RecordInFlight(new Map<String, String>())
        };
            
        context.linkSourceName = 'Faculty';
        filter.process(context, staff);
        
        for (valence.RecordInFlight staf : staff) {
            System.assertNotEquals(staf.getPropertyValue('Skyward_Staff__c'), null);
            System.assertNotEquals(staf.getPropertyValue('Active__c'), null);
            System.assertNotEquals(staf.getPropertyValue('RecordTypeId'), null);
        }
        
        List<valence.RecordInFlight> guardians = new List<valence.RecordInFlight>{
            new valence.RecordInFlight(new Map<String, String>())
        };
            
        context.linkSourceName = 'Guardian';
        filter.process(context, guardians);
        
        for (valence.RecordInFlight g : guardians) {
            System.assertNotEquals(g.getPropertyValue('Skyward_Guardian__c'), null);
            System.assertNotEquals(g.getPropertyValue('Active__c'), null);
            System.assertNotEquals(g.getPropertyValue('RecordTypeId'), null);
        }
    }
    
    @IsTest static void testDescribeSchema() {
		valence.FilterSchema schema;
        
        schema = filter.describeSchema(context);
        
        System.assertNotEquals(schema, null);
    }
}