public without sharing class CustomObjectAccessDomain extends SObjectDomain {
	public CustomObjectAccessDomain(List<Custom_Object_Access__c> sObjectList) {
		super(sObjectList);
	}
	public override void beforeInsert() {
		//we can call multiple services if needed
		system.debug('###beforeInsert');
		Result result = HouseholdNoSharingService.changeOwners(this);
		system.debug('***' + result);
	}

	public class Constructor implements SObjectDomain.IConstructable {
		public SObjectDomain construct(List<SObject> records){
			return new CustomObjectAccessDomain(records);
		}
	}

}