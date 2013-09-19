public class UploadController {
	//add upload as a function. 
	//pass token to this page
	//test the token and validate on the upload page
	public Attachment attachment { get; set; }
	public Blob file { get; set; }
	public String attachmentName { get; set; }
	public String attachmentOtherName { get; set; }
	public String message { get; set; }
	
	
	
	public Map<String, String> params {
		get {
			if(params == null) {
				if(ApexPages.currentPage() != null && ApexPages.currentPage().getParameters() != null) {
					params = ApexPages.currentPage().getParameters();
				}
				else params = new Map<String, String>();
			}
			return params;
		}
		set;
	}
	
	public String recordId { 
		get {
			if(recordId == null) {
				if(params.containsKey('recordId')) recordId = params.get('recordId');
			}
			return recordId;
		}
		set;
	}
	
	// options abound 
	
	// ?intro=<p>The HTML you want to see at the top.</p>
	public String intro { 
		get {
			if(intro == null) {
				intro = '<p>Upload a File</p>';
				if(params.containsKey('intro')) intro = params.get('intro');
			}
			return intro;
		}
		set;
	}
	
	// ?type=Attachment|Document|Content
	public String uploadType { 
		get {
			if(uploadType == null) {
				uploadType = 'Attachment';
				if(params.containsKey('uploadType')) uploadType = params.get('uploadType');
			}
			return uploadType;
		}
		set;
	}
	  
	// ?nameFormat=text|picklist
	// default = none
	public String nameFormat { 
		get {
			if(nameFormat == null) {
				nameFormat = '';
				if(params.containsKey('nameFormat')) nameFormat = params.get('nameFormat');
			}
			return nameFormat;
		}
		set;
	}
	
	// ?namePrefix=the text to place in front of this file
	public String namePrefix { 
		get {
			if(namePrefix == null) {
				namePrefix = '';
				if(params.containsKey('namePrefix')) namePrefix = params.get('namePrefix');
			}
			return namePrefix;
		}
		set;
	}
	
	// ?namePicklistOptions=csv
	public String namePicklistOptions { 
		get {
			if(namePicklistOptions == null) {
				namePicklistOptions = '';
				if(params.containsKey('namePicklistOptions')) namePicklistOptions = params.get('namePicklistOptions');
			}
			return namePicklistOptions;
		}
		set;
	}
	
	// ?parentCloseFunction= JS to call on window.opener
	public String parentCloseFunction { 
		get {
			system.debug('**enter get close');
			if(parentCloseFunction == null) {
				system.debug('**isnull');
				parentCloseFunction = '';
				if(params.containsKey('parentCloseFunction')) parentCloseFunction = params.get('parentCloseFunction');
				
			}
			system.debug('**ends at: '+ parentCloseFunction);
			return parentCloseFunction;
		}
		set;
	}
	
	public List<String> namePicklistOptionsList {
		get {
			if(namePicklistOptions == null) return null;
			return namePicklistOptions.split(',');
		}
	}
	
	public List<SelectOption> namePicklistSelectOptions {
		get {
			if(namePicklistSelectOptions == null) {
				if(namePicklistOptionsList == null) return null;
				namePicklistSelectOptions = new List<SelectOption>();
				for(String s : namePicklistOptionsList) namePicklistSelectOptions.add(new SelectOption(s, s));
			}
			return namePicklistSelectOptions;
		}
		set;
	}
	
	public UploadController() {
		attachmentName = '';
		attachmentOtherName = '';
		message = '';
		attachment = new Attachment();
	}
	
	public void upload() {
		
		message = '';
		if(attachment.Name == null || attachment.Name == '') {
			message = 'You must pick a file to upload.';
			return;
		}
		
		if(file != null)
		if(file.size() > 5242879) {
			file = null;
			attachment = new attachment();
			attachment.Body = null;
			message = 'The file is too large.';
			return;
		}
		if(attachmentName == '') attachmentName = attachment.Name.substring(0, attachment.Name.lastIndexOf('.') );
		String attachmentSuffix = attachment.Name.substring(attachment.Name.lastIndexOf('.') + 1);
		
		//attachment.Name = namePrefix + attachmentName + '.' + attachmentSuffix;
		attachment.Name = namePrefix + attachment.Name;
		
		
		attachment.ParentId = recordId;
		attachment.body = file;
		system.debug('********'+attachment+'*********');
		try {
			if(!Test.isRunningTest()) insert attachment;
			message = 'File upload "' + attachmentName + '" was successful. You may now upload another file or close this window.';
			//attachmentName = '';
			//attachmentOtherName = '';
			//attachment = new Attachment();
			attachment.Body = null;//reset the body because of view state limits
			file = null;
		}
		catch(Exception ex) {
			message = 'An unexpected error occurred. Please try again.' + ex.getMessage();
			file = null;
			attachment = new Attachment();
		}
	}
	
	public List<Attachment> attachments { get {
		return [select Id, Name from Attachment where ParentId = :recordId order by Name];	
	} set; }
	
	static testmethod void test() {
		
		Account a = new Account(Name = 'Test');
		insert a;
		
		PageReference pr = new PageReference('/foo');
		pr.getParameters().put('type', 'Attachment');
		pr.getParameters().put('nameFormat', 'picklist');
		pr.getParameters().put('namePicklistOptions', 'csv');
		pr.getParameters().put('parentCloseFunction', 'foo');
		pr.getParameters().put('recordId', a.Id);
		
		Test.setCurrentPageReference(pr);
		
		UploadController uc = new UploadController();
		system.assertEquals(uc.uploadType, 'Attachment');
		system.assertEquals(uc.nameFormat, 'picklist');
		system.assertEquals(uc.namePicklistOptions, 'csv');
		system.assertEquals(uc.parentCloseFunction, 'foo');
		system.assertNotEquals(uc.namePicklistOptionsList, null);
		system.assertNotEquals(uc.namePicklistSelectOptions, null);
		system.assertNotEquals(uc.params, null);
		
		uc.attachment.Name = 'foo.pdf';
		uc.attachmentName = 'foo';
		
		uc.upload();
		
	}
	
}