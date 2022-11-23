global with sharing class V_F_GradeEnrollment implements valence.TransformationFilter {
 
	// --------------------------------
	// ----- TransformationFilter -----
	// --------------------------------

    // Valid only for updating Contact records
    
	public Boolean validFor(valence.LinkContext context) {
        return (context.linkTargetName == 'Contact' && (context.linkSourceName == null || context.linkSourceName.contains('Student')));
	}

	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {
    
        String gradeField;
        String ogGradeLevel;
        String newGradeLevel;
        
        // Update the k12kit__Grade_Level__c field in SF with the converted grade value coming from Skyward
        
        for(valence.RecordInFlight record : records) {
            
            // grade field to reference is determined based on the data source
            
            if (context.linkSourceName.contains('NSOE')) 
            {
                gradeField = 'MOD-STU-GRADE';
            } else {
                gradeField = 'GradeLevel';
            }
            
            // values are substituted for the numbers coming from Skyward to fit the grades in Salesforce
            
            ogGradeLevel = '' + record.getOriginalPropertyValue(gradeField);
            
            switch on ogGradeLevel {
                when '4K' {
                    newGradeLevel = 'Prekindergarten';
                }
                when 'PK' {
                    newGradeLevel = 'Prekindergarten';
                }
                when 'K4' {
                    newGradeLevel = 'Prekindergarten';
                }
                when 'KG' {
                    newGradeLevel = 'Kindergarten';
                }
                when '1' {
                    newGradeLevel = 'First Grade';
                }
                when '01' {
                    newGradeLevel = 'First Grade';
                }
                when '2' {
                    newGradeLevel = 'Second Grade';
                }
                when '02' {
                    newGradeLevel = 'Second Grade';
                }
                when '3' {
                    newGradeLevel = 'Third Grade';
                }
                when '03' {
                    newGradeLevel = 'Third Grade';
                }
                when '4' {
                    newGradeLevel = 'Fourth Grade';
                }
                when '04' {
                    newGradeLevel = 'Fourth Grade';
                }
                when '5' {
                    newGradeLevel = 'Fifth Grade';
                }
                when '05' {
                    newGradeLevel = 'Fifth Grade';
                }
                when '6' {
                    newGradeLevel = 'Sixth Grade';
                }
                when '06' {
                    newGradeLevel = 'Sixth Grade';
                }
                when '7' {
                    newGradeLevel = 'Seventh Grade';
                }
                when '07' {
                    newGradeLevel = 'Seventh Grade';
                }
                when '8' {
                    newGradeLevel = 'Eighth Grade';
                }
                when '08' {
                    newGradeLevel = 'Eighth Grade';
                }
                when '9' {
                    newGradeLevel = 'Ninth Grade';
                }
                when '09' {
                    newGradeLevel = 'Ninth Grade';
                }
                when '10' {
                    newGradeLevel = 'Tenth Grade';
                }
                when '11' {
                    newGradeLevel = 'Eleventh Grade';
                }
                when '12' {
                    newGradeLevel = 'Twelfth Grade';
                }
                when 'ST' {
                    newGradeLevel = 'Staff';
                }
                when 'GD' {
                    newGradeLevel = 'Graduated';
                }
                when else {
                    newGradeLevel = 'Not Applicable';
                }
            }
            
            record.setPropertyValue('k12kit__Current_Grade_Level__c', newGradeLevel);
        }
    }
}