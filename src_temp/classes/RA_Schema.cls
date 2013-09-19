public with sharing class RA_Schema {

	private static Map<String, String> namePrefixMapCache {
		get {
			if(namePrefixMapCache == null) namePrefixMapCache = new Map<String, String>();
			return namePrefixMapCache;
		}
		set;
	}
	private static Map<String, String> prefixNameMapCache { 
		get {
			if(prefixNameMapCache == null) prefixNameMapCache = new Map<String, String>();
			return prefixNameMapCache;
		}
		set;
	}

	private static Map<String, Map<String, Schema.sObjectField>> sObjectTypeFieldsCache { 
		get {
			if(sObjectTypeFieldsCache == null) sObjectTypeFieldsCache = new Map<String, Map<String, Schema.sObjectField>>();
			return sObjectTypeFieldsCache;
		}
		set;
	}

	public static Map<String, Schema.SObjectType> globalDescribe {
		get {
			if(globalDescribe == null) globalDescribe = Schema.getGlobalDescribe();
			return globalDescribe;
		}
		set;
	}
	
	public static String getPrefix(String SObjectTypeName) {
		if(namePrefixMapCache.containsKey(SObjectTypeName)) return namePrefixMapCache.get(SObjectTypeName);
		String prefix = globalDescribe.get(SObjectTypeName).getDescribe().getKeyPrefix();
		namePrefixMapCache.put(SObjectTypeName, prefix);
		prefixNameMapCache.put(prefix, SObjectTypeName);
		return prefix;
	}
	
	public static String getNameByPrefix(String prefix) {
		if(prefixNameMapCache.containsKey(prefix)) return prefixNameMapCache.get(prefix);
		
		for(Schema.sObjectType sot : globalDescribe.values()) {
			Schema.DescribeSObjectResult D = sot.getDescribe();
			String keyPrefix = sot.getDescribe().getKeyPrefix();
			String name = sot.getDescribe().getName();
			
			// build as we go
			if(!prefixNameMapCache.containsKey(keyPrefix)) prefixNameMapCache.put(keyPrefix, name);
			if(!namePrefixMapCache.containsKey(name)) namePrefixMapCache.put(name, keyPrefix);
			if(keyPrefix != null)
				if(keyPrefix.equals(prefix)) return name;//JK - this needs to be .equals to be case sensitive. or kabloom
			
		}
		
		return null;
		
	}
	
	public static Schema.SObjectType getSObjectTypeByPrefix(String prefix) {
		String name = getNameByPrefix(prefix);
		if(name == null) return null;
		return globalDescribe.get(name);
	}
	
	public static Schema.SObjectType getSObjectTypeByName(String name) {
		return globalDescribe.get(name);
	}
	
	public static Map<String, Schema.sObjectField> getFields(String sObjectTypeName) {
		if(sObjectTypeFieldsCache.containsKey(sObjectTypeName)) return sObjectTypeFieldsCache.get(sObjectTypeName);
		Map<String, Schema.sObjectField> fieldsMap = getSObjectTypeByName(sObjectTypeName).getDescribe().fields.getMap();
		sObjectTypeFieldsCache.put(sObjectTypeName, fieldsMap);
		return fieldsMap;
	}
	
	public static sObject newSObject(String sObjectTypeNameOrSFID) {
		system.debug(sObjectTypeNameOrSFID);
		String prefix = RA_String.keyPrefix(sObjectTypeNameOrSFID);
		system.debug(prefix);
		String name = getNameByPrefix(prefix);
		system.debug(name);
		if(name == null) return getSObjectTypeByName(sObjectTypeNameOrSFID).newSObject();
		else return newSObject(name, sObjectTypeNameOrSFID);
	}
	
	public static sObject newSObject(String sObjectTypeName, String sfid) {
		return getSObjectTypeByName(sObjectTypeName).newSObject(sfid);
	}
	
	public static Schema.sObjectField getField(String sObjectTypeName, String fieldNameOrPath) {

		if(fieldNameOrPath.indexOf('.') == -1) {
			// easy case, just find the field
			return getFields(sObjectTypeName).get(fieldNameOrPath);
		}
		else {
			// trickier, need to traverse path
			String firstPathStep = RA_String.before(fieldNameOrPath, '.');
			system.debug(firstPathStep);
			// need to test for the relationship name in the context of the object  
			
			// TODO: create a cache map for this...
			for(Schema.sObjectField sof : getFields(sObjectTypeName).values()) {
				Schema.DescribeFieldResult d = sof.getDescribe();
				system.debug(d.getType().name().toLowerCase());
				system.debug(d.getRelationshipName()); 
				if(d.getType().name().toLowerCase() == 'reference' && d.getRelationshipName() != null && d.getRelationshipName().toLowerCase() == firstPathStep.toLowerCase()) {
					sObjectTypeName = d.getReferenceTo()[0].getDescribe().getName();
					break;
				}
			}
			
			return RA_Schema.getField(sObjectTypeName, RA_String.after(fieldNameOrPath, '.'));
		}
		  
	}
	
	public static Map<String, String> fieldDataTypeMap(String sObjectTypeName, List<String> fieldNamesOrPaths) {
		Map<String, String> m = new Map<String, String>();
		Schema.sObjectField f;
		for(String s : fieldNamesOrPaths) {
			f = getField(sObjectTypeName, s);
			if(f == null) continue;
			m.put(s, f.getDescribe().getType().name().toLowerCase());
		}
		return m;
	}
	
	//http://sfdc.arrowpointe.com/2011/03/28/cloning-records-in-apex/ courtesy of community post from Scott Hemmeter
	// Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
 
        String selects = '';
 
        if (whereClause == null || whereClause == ''){ return null; }
 
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
 
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
 
        }
 
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
 
    }
	
	public static testmethod void test() {
		
		String accountPrefix = RA_Schema.getPrefix('Account');
		Schema.SObjectType accountType = RA_Schema.getSObjectTypeByPrefix(accountPrefix);
		
		Account a = new Account(Name = 'Test');
		insert a;
		Contact c = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = a.Id);
		insert c;  
		
		String contactPrefix = RA_String.keyPrefix(c);
		Schema.SObjectType contactType = RA_Schema.getSObjectTypeByPrefix(contactPrefix);
		
		system.assertEquals(null, RA_Schema.getSObjectTypeByPrefix('ZZZ'));
		
	}
	
	public static testmethod void testGetField() {
		
		Schema.sObjectField f;
		String sObjectType = 'Contact';
		String fieldPath = 'AccountId';
		
		// simple test, one level
		f = getField(sObjectType, fieldPath);
		system.assertEquals('AccountId', f.getDescribe().getName());
		
		// now test a path
		fieldPath = 'Account.OwnerId';
		f = getField(sObjectType, fieldPath);
		system.assertNotEquals(null, f);
		system.assertEquals('OwnerId', f.getDescribe().getName());
		
		// now test a harder path
		fieldPath = 'Account.Owner.Contact.FirstName';
		f = getField(sObjectType, fieldPath);
		system.assertNotEquals(null, f);
		system.assertEquals('FirstName', f.getDescribe().getName());
		
	}
	
	public static testmethod void testFieldDataTypeMap() {
		
		String sObjectType = 'Contact';
		List<String> fieldPaths = new List<String>();
		fieldPaths.add('AccountId');
		fieldPaths.add('Account.OwnerId');
		fieldPaths.add('Account.Owner.Contact.FirstName');
		
		Map<String, String> m = fieldDataTypeMap(sObjectType, fieldPaths);
		
		system.assertEquals('reference', m.get('AccountId'));
		system.assertEquals('reference', m.get('Account.OwnerId'));
		system.assertEquals('string', m.get('Account.Owner.Contact.FirstName'));
		
	}

	@isTest 
	static public void testGetsObject(){
		Account a = new Account(Name = 'Test');
		insert a;
		sObject o = newSObject(a.Id);
		system.assertEquals(Account.sObjectType, o.getSObjectType());


		Contact c = new Contact(LastName = 'Test');
		insert c;
		o = newSObject(c.Id);
		system.assertEquals(Contact.sObjectType, o.getSObjectType());
	}

	@isTest
	static public void testgetCreatableFieldsSOQL(){

		//lets test the fail cases
		system.assertEquals(null, getCreatableFieldsSOQL('Account', null));
		system.assertEquals(null, getCreatableFieldsSOQL('Account', ''));

		//lets insert an account and then query for it
		Account a = new Account(
			Name = 'Test',
			AccountNumber = '12345',
			Type = 'Prospect'
		);

		insert a;
		String soql = getCreatableFieldsSOQL('Account', 'Id = \'' + a.Id + '\'');
		system.assertNotEquals(null, soql);

		List<Account> accounts = Database.query(soql);

		system.assertEquals(1, accounts.size());
		system.assertEquals('Test', accounts[0].Name);
		system.assertEquals('Prospect', accounts[0].Type);

		try {
			system.assertEquals('12345', accounts[0].AccountNumber);
			//system.assert(false); //lets force break validation if we succeed
		} catch(Exception ex) {
			//this fails because we didnt query for it, not createable
			system.assert(true);
		}
	}
	
}