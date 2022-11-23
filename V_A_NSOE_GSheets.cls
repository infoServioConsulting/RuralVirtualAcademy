global with sharing class V_A_NSOE_GSheets implements valence.NamedCredentialAdapter, valence.SchemaAdapter, valence.SourceAdapterForPull, valence.ChainFetchAdapter {
    
    @TestVisible
    private String namedCredentialName;
    
    private Scope nextScope;
    
    @TestVisible
    private Map<String, String> sheetIds = new Map<String, String>{
        'NSOE_Students' => '1_wNqrXOcVg7fJzGgw0fW_PiCTGNUNym5Pa7Y82WBVSE', 
        'NSOE_Guardians' => '1riCiL6h8TzkIHc60attFpZKnX5mUQV1jT_5kLwd9YmA'
    };
        
    // ----------------------------------
    // ----- NamedCredentialAdapter -----
	// ----------------------------------
    
    public void setNamedCredential(String namedCredential) {
        this.namedCredentialName = namedCredential;
    }	

    // -------------------------
    // ----- SchemaAdapter -----
	// -------------------------
    
    public List<valence.Table> getTables() {
        List<valence.Table> tables = new List<valence.Table>();
        
        for (String tbl : sheetIds.keySet()) {
            tables.add(valence.Table.create(tbl)
                       .withLabel(tbl)
                       .build());
        }
        
        return tables; 
    }
    
    public List<valence.Field> getFields(String tableApiName) {
        
      // only get the first row of cells for the headers
      List<valence.JSONParse> fieldNames = sheetRequest(tableApiName, '1:1')[0].asList();
        
        List<valence.Field> fields = new List<valence.Field>();
        
      	for (valence.JSONParse field : fieldNames) {
    		fields.add(valence.Field.create(field.getStringValue())
                           .withLabel(field.getStringValue())
                           .build());
		}

        return fields;
    }
    
    // --------------------------------
    // ----- SourceAdapterForPull -----
	// --------------------------------
    
    public valence.FetchStrategy planFetch(valence.LinkContext context) {
        return valence.FetchStrategy.immediate();
    }
    
    public Object getNextScope() {
        return nextScope;
    }
    
    public List<valence.RecordInFlight> fetchRecords(valence.LinkContext context, Object scope) { 
        
        Scope currentScope = (Scope)scope;
        
        // Create a list for the returned records
        List<valence.RecordInFlight> records = new List<valence.RecordInFlight>();
        
    	List<String> fields;
                
        // if scope is null (it's the first pull), grab the fields from the first row of the sheet
        if (currentScope == null) {
            // only get the first row of cells for the headers
            List<valence.JSONParse> fieldNames = sheetRequest(context.linkSourceName, '1:1')[0].asList();
        	fields = new List<String>();
        
        	for (valence.JSONParse field : fieldNames) {
           	 	fields.add(field.getStringValue());
        	}
        } else {
            fields = currentScope.fields;
        }

        // pull the JSON objects into a list to iterate thru
        // Range A2:AAA to get all cells from row 2 down to skip the headers. Grab through AAA in case they add more columns
        List<valence.JSONParse> returnedRecords = sheetRequest(context.linkSourceName, 'A2:AAA');
        
        // create a container for the raw data to be put into the record in flight
       	List<valence.JSONParse> jsonProperties; 
        Map<String, Object> recordMap;
            
        for (valence.JSONParse record : returnedRecords) {
            jsonProperties = record.asList();
            
          	recordMap = new Map<String, Object>();
            for (Integer i = 0; i < fields.size(); i++) {
                recordMap.put(fields[i], jsonProperties[i].getStringValue());
            }
                
            records.add(new valence.RecordInFlight(recordMap));
        }
        
        if (currentScope != null) {
        	nextScope = new Scope(currentScope.fields);
        }
        
        return records;
    }
    
    // ---------------------------
    // ------- Utility -----------
    // ---------------------------

    public class Scope {
        private List<String> fields;
        
    	public Scope(List<String> fields) {
            this.fields = fields;
        }
    }
    
    private List<valence.JSONParse> sheetRequest(String tableApiName, String cellRange) {
        HttpRequest req = new HttpRequest();
      	req.setEndpoint('callout:Google_Sheets/' + sheetIds.get(tableApiName) + '/values/' + cellRange);
      	req.setMethod('GET');
      	HttpResponse res = new Http().send(req);
        
        return new valence.JSONParse(res.getBody()).get('values').asList();
    }
}