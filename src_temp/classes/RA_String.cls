public with sharing class RA_String {
	public static Set<String> usedUniques {
		get {
			if(usedUniques == null) usedUniques = new Set<String>();
			return usedUniques;
		}
		set;
	}
	
	/**
	* @author 			Tom Patros
	* @date 			3/23/2012
	* @description		generates a unique numeric string via SF's Crypto.getRandomInteger()
	* @params				
	* @returns			String, unique numeric string
	* @notes			stores generated uniques in usedUniques and tests to avoid duplicates (unlikely, but you never know)
	*/
	public static String unique() {
		String output = null;
		while(output == null || usedUniques.contains(output)) {
			output = String.valueOf(Math.abs(Crypto.getRandomInteger()));
		}
		usedUniques.add(output);
		return output;
	}

	/**
	* @author 			Tom Patros
	* @date 			3/23/2012
	* @description		splits a string by comma, then trims all the resulting strings
	* @params			String value - string to split and trim	
	* @returns			List<String>
	* @notes			
	*/	
	public static List<String> splitAndTrim(String value) {
		if(value == null) return null;
		List<String> result = value.split(',');
		for(Integer x = 0; x < result.size(); x++) result[x] = result[x].trim();
		return result;
	}
	
	/**
	* @author 			Tom Patros
	* @date 			3/23/2012
	* @description		returns the key prefix (first three characters from an SFID)
	* @params			String sfid - Salesforce ID
	* @returns			String
	* @notes			
	*/	
	public static String keyPrefix(String sfid) { 
		if(sfid != null && sfid != '')
			return sfid.substring(0, 3);
		return null;
	}
	
	/**
	* @author 			Tom Patros
	* @date 			3/23/2012
	* @description		returns the key prefix (first three characters from an SFID)
	* @params			SObject record - Salesforce record
	* @returns			String
	* @notes			relies on keyPrefix(String)
	*/	
	public static String keyPrefix(sObject record) {
		return keyPrefix(record.Id);
	}
	
	/**
	* @author 			Tom Patros
	* @date 			4/3/2012
	* @description		checks if an SFID matches a prefix
	* @params			sfid - string, the sfid to test
	*					prefixOrSObjectName - string, the prefix or SObject Name to test
	* @returns			Boolean, true if there is a match
	* @notes			relies on keyPrefix function
	*/
	public static Boolean hasKeyPrefix(String sfid, String prefixOrSObjectName) {
		if(keyPrefix(sfid).equals(prefixOrSObjectName)) return true;
		prefixOrSObjectName = RA_Schema.getPrefix(prefixOrSObjectName);
		return keyPrefix(sfid).equals(prefixOrSObjectName);
	}
	
	/**
	* @author 			Tom Patros
	* @date 			3/23/2012
	* @description		finds and replaces multiple values in a string
	* @params			String value - string to do find and replace on
	*					List<String> finds - strings to find
	*					List<String> replaces - strings to replace						
	* @returns			String
	* @notes			finds and replaces must have the same indexes
	*					delegates to replaceMultiple(value, pairs)
	*/		
	public static String replaceMultiple(String value, List<String> finds, List<String> replaces) {
		
		if(finds == null || finds.size() == 0 || replaces == null || replaces.size() == 0) return value;
		
		Map<String, String> pairs = new Map<String, String>();
		
		for(Integer x = 0; x < finds.size(); x++) pairs.put(finds[x], replaces[x]);
		
		return replaceMultiple(value, pairs);

	}
	
	/**
	* @author 			Tom Patros
	* @date 			3/23/2012
	* @description		finds and replaces multiple values in a string
	* @params			String value - string to do find and replace on
	*					List<String> finds - strings to find		
	* @returns			String
	* @notes			
	*/		
	public static String replaceMultiple(String value, Map<String, String> pairs) {
		
		for(String s : pairs.keySet()) value = value.replace(s, pairs.get(s));
		return value;

	}
	
	public static String concat(List<String> strings, String delimiter, String prepend, String append) {
		String output = '';
		for(Integer x = 0; x < strings.size(); x++) {
			output += prepend + strings[x] + append;
			if(x < strings.size() - 1) output += delimiter;
		}
		return output;
	}
	
	public static String concat(List<String> strings, String delimiter, String prepend) {
		return concat(strings, delimiter, prepend, '');
	}
	
	public static String concat(List<String> strings, String delimiter) {
		return concat(strings, delimiter, '', '');
	}
	
	public static String concat(List<String> strings) {
		return concat(strings, '', '', '');
	}
	
	public static String queryString(Map<String, String> params) {
		
		List<String> paramPairs = new List<String>();
		for(String s : params.keySet()) {
			paramPairs.add(concat(new String[] { s, params.get(s) }, '='));
		}
		return '?' + concat(paramPairs, '&');
		
	}
	
	public static Boolean empty(String s) {
		if(s == null) return true;
		if(s.trim() == '') return true;
		return false;
	}
	
	public static Boolean empty(Object o) {
		try {
			String s = String.valueOf(o);
			return empty(s);
		}
		catch(Exception ex) {
			return false;
		}
	}
	
	// keeps the first X characters of a string, or the whole string if it is shorter than lengthLimit
	public static String chop(String s, Integer lengthLimit) {
		if(s == null) return null;
		if(s.length() > lengthLimit) return s.substring(0, lengthLimit);
		return s;
	}
	
	public static Map<String, Integer> uniqueCharacterCount(String input) {
		Map<String, Integer> output = new Map<String, Integer>();
		List<String> splitString = input.split('');
		splitString.remove(0);
		for(String s : splitString) {
			if(!output.containsKey(s)) output.put(s, 1);
			else output.put(s, output.get(s) + 1);
		}
		return output;
	}
	
	// returns the file extension of a file name, treating the last "." as the delimiter before the extension
	public static String fileExtension(String fileName) {
		if(fileName == null || !fileName.contains('.')) return null;
		return fileName.substring(fileName.lastIndexOf('.') + 1);
	}
	
	// returns contents of str before first instance of s - s is excluded
	public static String before(String str, String s) {
		return str.substring(0, str.indexOf(s));
	}
	
	// returns remainder of str after first instance of s - s is excluded
	public static String after(String str, String s) {
		return str.substring(str.indexOf(s) + s.length());
	}
	
	public static testmethod void test() {
		String s = null;
		system.assertEquals(null, RA_String.splitAndTrim(s));
		s = '   foo   ,   bar   ';
		List<String> result = RA_String.splitAndTrim(s);
		system.assertEquals(2, result.size());
		system.assertEquals('foo', result[0]);
		system.assertEquals('bar', result[1]);
		
		Account a = new Account(Name = 'Test');
		insert a;
		
		// test replaceMultiple
		String haystack = 'AXYBXYCXY';
		String[] finds = new String[] {'X','Y'};
		String[] replaces = new String[] {'1','2'};
		RA_String.replaceMultiple(haystack, finds, replaces);
		
		// test keyprefix
		String accountPrefix = RA_String.keyPrefix(a);

		// test keyprefix fail
		String nullstring;
		system.assertEquals(null,RA_String.keyPrefix(nullstring));
		system.assertEquals(null,RA_String.keyPrefix(''));
		
		// test concat
		String concatTest = RA_String.concat(new String[] {'A','B','C'},'=','*','*');
		concatTest = RA_String.concat(new String[] {'A','B','C'},'=','*');
		concatTest = RA_String.concat(new String[] {'A','B','C'},'=');
		concatTest = RA_String.concat(new String[] {'A','B','C'});
		
		// test empty
		Object emptyMe = null;
		system.assertEquals(true, RA_String.empty(emptyMe));
		system.assertEquals(false, RA_String.empty(new Account()));
		system.assertEquals(true, RA_String.empty(''));
		system.assertEquals(false, RA_String.empty('foo'));
		
		// test fileExtension
		system.assertEquals('txt', RA_String.fileExtension('file.txt'));
		system.assertEquals('txt', RA_String.fileExtension('file.foo.txt'));
		
		// test queryString
		Map<String, String> params = new Map<String, String>();
		params.put('A','1');
		params.put('B','2');
		params.put('C','3');
		RA_String.queryString(params);
		
		// test chop
		String chopMe = 'ABCDEFGHIJ';
		system.assertEquals('ABC', RA_String.chop(chopMe, 3));
		system.assertEquals('ABCDE', RA_String.chop(chopMe, 5));
		system.assertEquals('ABCDEFGHIJ', RA_String.chop(chopMe, 20));
		
		// test uniqueCharacterCount
		String uniqueMe = 'AAA 111 222 333 456 DEF XYZ';
		Map<String, Integer> uniques = RA_String.uniqueCharacterCount(uniqueMe);
		system.assertEquals(3, uniques.get('A'));
		system.assertEquals(1, uniques.get('Z'));
		system.assertEquals(6, uniques.get(' '));
		
		// test before
		String beforeMe = 'foo.bar.test';
		system.assertEquals('foo', RA_String.before(beforeMe, '.'));
		system.assertEquals('foo.', RA_String.before(beforeMe, 'bar'));
		system.assertEquals('foo', RA_String.before(beforeMe, '.bar.'));
		system.assertEquals('foo.bar.', RA_String.before(beforeMe, 'test'));
		
		// test after
		String afterMe = 'foo.bar.test';
		system.assertEquals('bar.test', RA_String.after(afterMe, '.'));
		system.assertEquals('.test', RA_String.after(afterMe, 'bar'));
		system.assertEquals('test', RA_String.after(afterMe, '.bar.'));
		system.assertEquals('', RA_String.after(afterMe, 'test'));
		
	}

	@isTest
	static public void testUniques() {
		String u;
		//test base getter
		system.assertNotEquals(null, usedUniques);

		//batch test
		for(Integer i =0; i<100; i++) {
			u = unique();
			system.assert(u.length() > 0);
			system.assert(usedUniques.contains(u));
		}
	}

	@isTest 
	static public void testHasKeyPrefix(){
		//lets test the key prefix function
		Account a = new Account( Name = 'Test' );
		insert a;

		system.assertEquals(true,RA_String.hasKeyPrefix(a.Id,'Account'));

		//this time it already exists, so lets try with the prefix itself
		String prefix = RA_String.KeyPrefix(a.Id);
		system.assertEquals(true,RA_String.hasKeyPrefix(a.Id,prefix));

		//this one is bad
		system.assertEquals(false,RA_String.hasKeyPrefix(a.Id,'Contact'));
	}

}