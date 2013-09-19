global without sharing class CaseService {
	// SObject's used by the logic in this service, listed in dependency order
	private static List<Schema.SObjectType> SERVICE_SOBJECTS = 
		new Schema.SObjectType[] { 
			Contact.SObjectType,
			Case.SObjectType
		 };

	//create our static unit of work
	static private SObjectUnitOfWork uow = new SObjectUnitOfWork(SERVICE_SOBJECTS);
	static global void resetUOW() {
		uow = new SObjectUnitOfWork(SERVICE_SOBJECTS);
	}
	//lets create out static result
	static private Result result = new Result();
	
	@RemoteAction
	static global Result createCasesFromJavascriptErrors(List<Javascript_Error__c> javascriptErrors) {
		Contact contact = null;
		try {
			contact = [select Id, Name, Email from Contact where Related_User__c = :UserInfo.getUserId()];
		} catch(Exception except) {
			//do nothing let it be
		}
		try {
			
			if(contact == null) {
				User user = [select Id, Name, FirstName, LastName, Email, Phone, Agency__c from User where Id = :UserInfo.getUserId()];
				FFAgency_Assignment__c agencyAssignment = [select Agency__c from FFAgency_Assignment__c where Vendor_Supervisor__c = :user.Id or Care_Coordinator__c = :user.Id order by CreatedDate desc limit 1];
				contact = new Contact(
					FirstName = user.FirstName,
					LastName = user.LastName,
					Email = user.Email,
					Phone = user.Phone,
					Related_User__c = user.Id,
					AccountId = agencyAssignment.Agency__c 
				);
				uow.registerNew(contact);
			}
			List<Case> cases = new List<Case>();
			for(Javascript_Error__c javascriptError : javascriptErrors) {
				Case newCase = new Case(
					Subject = javascriptError.Title__c,
					Description = javascriptError.Description__c,
					Javascript_Error__c = javascriptError.Id,
					RecordTypeId = Case.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Family First Support').getRecordTypeId()
				);
				cases.add(newCase);
			}
			system.debug('***JSError' + javascriptErrors);
			system.debug('***Cases' + cases);
			uow.registerNew((List<SObject>)cases, Case.ContactId, contact);
			
			uow.commitWork();
			return result.setRecords(cases);
		} catch(Exception except) {
			return result.setException(except);
		}
	}
}