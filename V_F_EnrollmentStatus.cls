global with sharing class V_F_EnrollmentStatus implements valence.TransformationFilter {

	// --------------------------------
	// ----- TransformationFilter -----
	// --------------------------------

    // Valid only for updating Grade Enrollment records
    
	public Boolean validFor(valence.LinkContext context) {
        return (context.linkTargetName == 'Enrollment_Status__c');
	}

	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {
        
        // get record types by object name
        Map<String, String> recordTypesByDevName = V_HelperClass.getRecordTypeIdsByDevName(context.linkTargetName);
        
        for(valence.RecordInFlight record : records) {
            
            String recordTypeName;
            Boolean rejected;
            
            // pull in the student's grade to determine the record type for the enrollment status record
            String grade = '' + record.getOriginalPropertyValue('MOD-STU-GRADE');
            
            if (grade.isAlpha() || (grade.isNumeric() && Integer.valueOf(grade) <= 8)) {
                recordTypeName = 'Elementary_and_Middle_School';
            } else if (grade.isNumeric() && Integer.valueOf(grade) >= 9) {
                recordTypeName = 'High_School';
            }
            
            if (recordTypeName != null) {
                record.setPropertyValue('RecordTypeId', recordTypesByDevName.get(recordTypeName));
            }
            
            String ogStatus = '' + record.getOriginalPropertyValue('STU-STATUS');
            String wipStatus;
            String newStatus;
            
            switch on ogStatus {
                when 'New' {
                    newStatus = 'Application Received';
                    rejected = false;
                }
                when '*Approved' {
                    newStatus = 'You are Accepted';
                    wipStatus = '';
                    rejected = false;
                }
                when 'WIP' {
                    newStatus = 'Application Received';
                    wipStatus = '' + record.getOriginalPropertyValue('UNUSED-CHAR-1');
                    rejected = false;
                }
                when '*Cancelled By District', '*Denied' {
                    newStatus = 'Application Received';
                    rejected = true;
                }
            }
            
            switch on wipStatus {
                when 'APP' {
                    newStatus = 'You are Accepted';
                    rejected = false;
                }
                when 'ADM' {
                    newStatus = 'Records Received';
                    rejected = false;
                }
                when 'DEN' {
                    rejected = true;
                }
            }
            
            if (newStatus != null) {
            	record.setPropertyValue('Enrollment_Stage__c', newStatus);
            }
            
            record.setPropertyValue('WIP_Status__c', wipStatus);
            record.setPropertyValue('Application_Denied__c', rejected);
        }
    }
}