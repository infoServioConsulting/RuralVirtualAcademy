@isTest
public class V_HelperClass_T {
    
    @isTest static void testGetRecordTypeIdsByDevName() {
        Map<String, String> results = V_HelperClass.getRecordTypeIdsByDevName('Account');
        
        System.assertEquals(false, results.isEmpty());
    }
    
    @isTest static void testGetTypesForObject() {
        List<RecordType> results2 = V_HelperClass.getTypesForObject('Account');
        
        System.assertEquals(false, results2.isEmpty());
    }
    
}