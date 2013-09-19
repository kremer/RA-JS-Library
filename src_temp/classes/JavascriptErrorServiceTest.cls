@isTest
private class JavascriptErrorServiceTest {
	//Covers the CaseService as well as the JSError Service
	@isTest
	static public void test_createError() {
		FamilyFirstTestData fftd = new FamilyFirstTestData();
		String title = 'There was an issue';
		String description = 'Issue was x, y, z';
		Integer lineNumber = 55;
		String url = '#urfs/123123123123abc/review';

		fftd.createJavascriptError(title, description, lineNumber, url);

		system.assertEquals(null, fftd.testData.javascriptErrors[0].Id);
		system.assertEquals(0, [select Id from Javascript_Error__c].size());

		Result result = JavascriptErrorService.createError(fftd.testData.javascriptErrors[0]);
		system.assertEquals(true, result.success);
		system.assertNotEquals(null, result.records[0].Id);
		List<Javascript_Error__c> errors = [select Id, Title__c, Description__c, Line_Number__c, URL__c from Javascript_Error__c];
		system.assertEquals(1, errors.size());
		system.assertEquals(title, errors[0].Title__c);
		system.assertEquals(description, errors[0].Description__c);
		system.assertEquals(lineNumber, errors[0].Line_Number__c);
		system.assertEquals(url, errors[0].URL__c);
	}

	@isTest
	static public void testCreateSupportCase() {
		FamilyFirstTestData fftd = new FamilyFirstTestData();
		String title = 'There was an issue';
		String description = 'Issue was x, y, z';
		Integer lineNumber = 55;
		String url = '#urfs/123123123123abc/review';

		Id profileId = fftd.getProfileId('Care Coordinator');
		User testUser = fftd.createUser('Bob', 'Tester', 'bobt@familyFirsttest123.org', profileId);

		Integer casesToCreate = 100;//every other will be non case

		//Result result;
		Test.startTest();
		system.runAs(testUser) {
			fftd.createAgencyForCurrentUser();
			for(Integer i = 0; i < casesToCreate; i++) {
				if(Math.mod(i, 2) == 1)
					fftd.createJavascriptError(title + String.valueOf(i), description + String.valueOf(i), lineNumber + i, url + String.valueOf(i));
				else
					fftd.createJavascriptError(null, null, lineNumber, url);//no case for this

			}
			insert fftd.testData.javascriptErrors;

			system.assertEquals(casesToCreate, [select Id from Javascript_Error__c].size());

		}
		Test.stopTest();

		List<Case> cases = [select Id, Javascript_Error__c, Subject, Description from Case];
		system.assertEquals((casesToCreate/2), cases.size());
		Map<Id, Case> map_IdToCase = new Map<Id, Case>();
		for(Case caseToTest : cases) {
			map_IdToCase.put(caseToTest.Javascript_Error__c, caseToTest);
		}
		Integer errorsNotCases = 0;
		for(Javascript_Error__c jsError : fftd.testData.javascriptErrors) {
			Case caseToTest = map_IdToCase.get(jsError.Id);
			if(caseToTest != null) {
				system.assertEquals(jsError.Title__c, caseToTest.Subject);
				system.assertEquals(jsError.Description__c, caseToTest.Description);
			} else 
				errorsNotCases++;
		}
		system.assert(errorsNotCases < ((casesToCreate/2) + 1));

		JavascriptErrorService.resetUOW();
	}
	
}