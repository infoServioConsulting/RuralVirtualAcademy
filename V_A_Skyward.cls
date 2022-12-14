global with sharing class V_A_Skyward implements valence.NamedCredentialAdapter, valence.SchemaAdapter, valence.SourceAdapterForPull, valence.ChainFetchAdapter {
  
    private final String SCHOOL_ID = '800';
    private final String tokenEndpoint = 'callout:RVA_Skyward/token';
    
    @TestVisible
    private String AUTH_TOKEN;
    
    @TestVisible
    private String namedCredentialName;
    
    private Scope nextScope;
    
    // I've created this hardcoded table map because Skyward does not have a table directory, nor a field list for each table
    // This associates the table name with the endpoint for easy access

    @TestVisible
    private Map<String, String> tableMap = new Map<String, String>{
        	'Guardian' => 			'callout:RVA_Skyward/v1/schools/' + SCHOOL_ID + '/guardians',
            'Faculty' => 			'callout:RVA_Skyward/v1/schools/' + SCHOOL_ID + '/staffmembers',
            'Student' => 			'callout:RVA_Skyward/v1/schools/' + SCHOOL_ID + '/students'
             };
                
    // ----------------------------------
    // ----- NamedCredentialAdapter -----
	// ----------------------------------
    
    /**
    * Gives you the NamedCredential name that you will need in order to do an Apex callout or get information about
    * the endpoint the User would like to talk to using your adapter.
    *
    * @param namedCredentialName The API name of a NamedCredential defined in this Salesforce org
    *
    * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_callouts_named_credentials.htm
    */
                 
    public void setNamedCredential(String namedCredential) {
        this.namedCredentialName = namedCredential;
    }	

    // -------------------------
    // ----- SchemaAdapter -----
	// -------------------------
    
    /**
    * We will interrogate your adapter and ask it what tables can be interacted with.
    *
    * @return A List of Table definitions that will be provided to Users.
    */
    
    public List<valence.Table> getTables() {
        List<valence.Table> tables = new List<valence.Table>();
        
        for (String tbl : tableMap.keySet()) {
            tables.add(valence.Table.create(tbl)
                       .withLabel(tbl)
                       .build());
        }
        
        return tables; 
    }
    
    /**
    * A natural follow-on from getTables, we will interrogate your adapter to
    * find out which fields can be interacted with on a table.
    *
    * @param tableApiName The specific table a User is interested in, comes from your list returned by getTables()
    *
    * @return A List of Field definitions that will be provided to Users for consideration.
    */
    
    public List<valence.Field> getFields(String tableApiName) {
        
        List<valence.JSONParse> sampleData;
        Map<String, valence.JSONParse> sampleRecord;
        List<String> fieldNames;
        List<valence.Field> fields = new List<valence.Field>();
        
        sampleData = new valence.JSONParse(authorizedRequest(tableMap.get(tableApiName) + '?limit=1').getBody()).asList();
        sampleRecord = sampleData[0].asMap();
        fieldNames = new List<String>(sampleRecord.keySet());
        
        for (String field : fieldNames) {
            
            if (sampleRecord.get(field).isArray()) {                
                fields.add(valence.Field.create(field)
                           .withLabel(field)
                           .setList(true, false)
                           .build());
            } else {    
                fields.add(valence.Field.create(field)
                           .withLabel(field)
                           .build());
            }
        }

        return fields;
    }
    
    // --------------------------------
    // ----- SourceAdapterForPull -----
	// --------------------------------
    
    /**
    * This method helps you to scale seamlessly to fetch large numbers of records. We do this by splitting requests
    * out into separate execution contexts, if need be.
    *
    * Valence will call planFetch() on your Adapter first, and then start calling fetchRecords(). The number of times
    * fetchRecords() is called depends on what you return from planFetch(). Every call to fetchRecords() will be in
    * its own execution context with a new instance of your Adapter, so you'll lose any state you have in your class.
    *
    * @param context Information about this Link and the current execution of it.
    *
    * @return An instance FetchStrategy that will tell the Valence engine what should happen next
    */
    
    public valence.FetchStrategy planFetch(valence.LinkContext context) {
        return valence.FetchStrategy.immediate();
    }
    
    /**
	* @return A scope object that will be passed back to you on the next call to FetchRecords.
	*/
    public Object getNextScope() {
        return nextScope;
    }
    
    /**
    * Second, we will call this method sequentially with scopes you gave us in response to planPush(). We give you your
    * scope back so you can use it as needed.
    *
    * If you need to mark errors as failed or warning, use the addError() and addWarning() methods on RecordInFlight.
    *
    * @param context Information about this Link and the current execution of it.
    * @param scope A single scope instance from the List of scopes returned by planFetch()
    *
    * @return All of the records that have been updated since the timestamp passed inside LinkContext.
    */
    
    public List<valence.RecordInFlight> fetchRecords(valence.LinkContext context, Object scope) {
        
        Integer recordLimit;
        
        if (context.batchSizeLimit > 0) {
            recordLimit = context.batchSizeLimit;
        } else {
            recordLimit = 200;
        }
        
        Scope currentScope = (Scope)scope;
        HttpResponse callResponse;
        String rootEndpoint = tableMap.get(context.linkSourceName) + '?limit=' + recordLimit;
        
        if (scope == null) {
            callResponse = authorizedRequest(rootEndpoint);
        } else {
            AUTH_TOKEN = currentScope.authToken;
        	callResponse = authorizedRequest(currentScope.nextPageLink);
        }
        
        List<valence.JSONParse> dataJson = new valence.JSONParse(callResponse.getBody()).asList();
        List<valence.RecordInFlight> records = new List<valence.RecordInFlight>();
        Map<String, Object> recordMap;
            
        for (valence.JSONParse record : dataJson) {
            recordMap = new Map<String, Object>();
            for (String field : record.asMap().keySet()) {
                recordMap.put(field, record.get(field).getValue());
            }
            records.add(new valence.RecordInFlight(recordMap));
        }

        if (callResponse.getHeader('Link') != null) {
        	String cursor = 'cursor=' + callResponse.getHeader('Link').substringBetween('cursor=', '>');
	    	nextScope = new Scope(rootEndpoint + '&' + cursor, AUTH_TOKEN);
        } else {
            nextScope = null;
        }
        
        return records;
    }
    
    // ---------------------------
    // ------- Utility -----------
    // ---------------------------

    @TestVisible
    private void setAuthToken() {
        
        // retrieve an Authorization token after submitting the username and password to the token endpoint
        
        String uName = '{!$Credential.UserName}';
        String pWord = '{!$Credential.Password}';
        String reqBody = 'grant_type=password&username=' + uName + '&password=' + pWord;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(tokenEndpoint);
        req.setBody(reqBody);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        HttpResponse res = new Http().send(req);
        valence.JSONParse root = new valence.JSONParse(res.getBody());

		AUTH_TOKEN = root.get('access_token').getStringValue();
    }
    
    @TestVisible
    private HttpResponse authorizedRequest(String endpoint) {
        
        if (AUTH_TOKEN == null) {
            setAuthToken();
        }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer ' + AUTH_TOKEN);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        return new Http().send(req);
    }
    
    public class Scope {
        private String nextPageLink;
        private String authToken;

    	public Scope(String nextPageLink, String authToken) {
            this.nextPageLink = nextPageLink;
            this.authToken = authToken;
        }
        
    }
}