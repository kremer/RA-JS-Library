global with sharing class JavascriptErrorService {
	// SObject's used by the logic in this service, listed in dependency order
	private static List<Schema.SObjectType> SERVICE_SOBJECTS = 
		new Schema.SObjectType[] { 
			Javascript_Error__c.SObjectType
		 };

	//create our static unit of work
	static private SObjectUnitOfWork uow = new SObjectUnitOfWork(SERVICE_SOBJECTS);
	static global void resetUOW() {
		uow = new SObjectUnitOfWork(SERVICE_SOBJECTS);
	}
	//lets create out static result
	static private Result result = new Result();
	static global Boolean firstPass = true;

	@RemoteAction
	static global Result createError(Javascript_Error__c newError) {
		try {
			uow.registerMixed(newError);
			uow.commitWork();
			return result.setRecord(newError);
		} catch(Exception except) {
			return result.setException(except);
		}
	}

	static global Result createSupportCase(List<Javascript_Error__c> javascriptErrors) {
		try {
			system.debug('***JSTrigger: ' + javascriptErrors);
			List<Javascript_Error__c> javascriptErrorsToMakeCases = new List<Javascript_Error__c>();
			for(Javascript_Error__c javascriptError: javascriptErrors) {
				if(javascriptError.Title__c != null && javascriptError.Description__c != null) {
					javascriptErrorsToMakeCases.add(javascriptError);
				}
			}
			return CaseService.createCasesFromJavascriptErrors(javascriptErrorsToMakeCases);

		} catch(Exception except) {
			return result.setException(except);
		}
	}
}