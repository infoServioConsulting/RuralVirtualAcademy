@isTest
private class V_A_Skyward_T implements HttpCalloutMock {
    
    private static valence.LinkContext context;
    
    static {
        context = new valence.LinkContext();
    }
    
    private static V_A_Skyward adapter = new V_A_Skyward();
        
    @isTest static void testNamedCredential() {
        adapter.setNamedCredential('callout:RVA_Skyward');
       	System.assertEquals(adapter.namedCredentialName, 'callout:RVA_Skyward');
    }
    
    // test that the AUTH_TOKEN variable is populated after obtaining the token from the <callout:Skyward>/token path
    @isTest static void testAuthToken() {
        Test.setMock(HttpCalloutMock.class, new V_A_Skyward_T());
        adapter.setAuthToken();
       	System.assertNotEquals(adapter.AUTH_TOKEN, null);
    }
    
    // test that the Tables list is the same length as the tableNames list declared in the class
    @isTest static void testTables() {
        List<valence.Table> tables = adapter.getTables();
        System.assertEquals(adapter.tableMap.size(), tables.size());
    }

    // confirm fields are returned from the Guardian table
    @isTest static void testGetFields() {
        Test.setMock(HttpCalloutMock.class, new V_A_Skyward_T());
        List<valence.Field> fieldList = new List<valence.Field>();
        
        for (String key : adapter.tableMap.keySet()) {
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
        Test.setMock(HttpCalloutMock.class, new V_A_Skyward_T());
        List<valence.RecordInFlight> testRecords = new List<valence.RecordInFlight>();
        
        for (String key : adapter.tableMap.keySet()) {
            context.linkSourceName = key;
            testRecords = adapter.fetchRecords(context, null);
            System.assertNotEquals(testRecords.size(), 0);
        }
    }
    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        
        // simulates a response from the API providing the auth token
        if (request.getEndpoint().endsWith('/token') && 
            request.getBody().contains('{!$Credential.UserName}') && 
            request.getBody().contains('{!$Credential.Password}')) 
        {
            response.setBody('{"access_token":"token"}');
        	response.setStatusCode(200);
        }
        
        // simulates requests to each endpoint
        if (request.getEndpoint().contains('/guardians')) 
        {
            response.setBody('[{"GuardianNameId":0}]');
        	response.setStatusCode(200);
        } else if (request.getEndpoint().contains('/staffmembers')) {
            response.setBody('[{"EmployeeId":0}]');
        	response.setStatusCode(200);
        } else if (request.getEndpoint().contains('/students')) {
            response.setBody('[{"NameId":0}]');
        	response.setStatusCode(200);
        }
        
        return response;
    }
}