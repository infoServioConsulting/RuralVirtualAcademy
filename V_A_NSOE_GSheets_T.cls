@isTest
private class V_A_NSOE_GSheets_T implements HttpCalloutMock {
    
    private static valence.LinkContext context;
    
    static {
        context = new valence.LinkContext();
    }
    
    private static V_A_NSOE_GSheets adapter = new V_A_NSOE_GSheets();
        
    @isTest static void testNamedCredential() {
        adapter.setNamedCredential('callout:Google_Sheets');
       	System.assertEquals(adapter.namedCredentialName, 'callout:Google_Sheets');
    }

    // test that the Tables list is the same length as the tableNames list declared in the class
    @isTest static void testTables() {
        List<valence.Table> tables = adapter.getTables();
        System.assertEquals(adapter.sheetIds.size(), tables.size());
    }

    // confirm fields are returned from the Guardian table
    @isTest static void testGetFields() {
        Test.setMock(HttpCalloutMock.class, new V_A_NSOE_GSheets_T());
        List<valence.Field> fieldList = new List<valence.Field>();
        
        for (String key : adapter.sheetIds.keySet()) {
            fieldList = adapter.getFields(key);
            System.assertNotEquals(fieldList.size(), 0);
        }
    }
    
    // test that the returned value from planFetch is not null
    @isTest static void testFetchStrategy() {
        System.assertNotEquals(null, adapter.planFetch(context));
    }
    
    // test the record fetch
    @isTest static void testFetchRecords() {
        Test.setMock(HttpCalloutMock.class, new V_A_NSOE_GSheets_T());
        List<valence.RecordInFlight> testRecords = new List<valence.RecordInFlight>();
        
        for (String key : adapter.sheetIds.keySet()) {
            context.linkSourceName = key;
            testRecords = adapter.fetchRecords(context, null);
            System.assertNotEquals(testRecords.size(), 0);
        }
    }
    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
    	
        response.setBody('{"values":[["test"]]}');
        response.setStatusCode(200);
        
        return response;
    }
}