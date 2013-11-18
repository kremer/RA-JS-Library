RA-JS-Library
===============

This is the Red Argyle Javascript Library that lives on top of the salesforce platform utilizing Marionette, Sublime Text, and Grunt to manage javascript applications on top of the salesforce platform. 

1.  Make sure you get Sublime Text 3 and the Latest Mavens Mate:

[http://mavensmate.com/Plugins/Sublime_Text/Installation](http://mavensmate.com/Plugins/Sublime_Text/Installation) 

2. Install Node JS, as of writing we are using v0.10.12 and the latest is v0.10.20

[http://nodejs.org/](http://nodejs.org/) 

3. Install Grunt.js - Our Grunt file is based off the work of Kevin O’hara

[http://gruntjs.com/](http://gruntjs.com/) 

[http://kevinmohara.com/2013/02/25/building-and-deploying-force-com-static-resources-using-grunt-js-video/](http://kevinmohara.com/2013/02/25/building-and-deploying-force-com-static-resources-using-grunt-js-video/) 

Steps to set up the project:

1. Pull down / fork the RA JS Framework

2. Drag the project into the sublime text app. This will open a workspace with all the files in it. 

3. Pick MavensMate in the menu -> Project -> New Project and enter your credentials. This will create a new project with existing src and the config, move both those folders into the project we created in the last step, mavens will know that it can use that project with your org. You can now code on the force.com platform.

4. Drop the src_temp files into your source and compile. These are deploy ready and will give you the base service and Financial Forces Enterprise Library. Delete the src_temp when your done.

5. Now for the JS on top of the platform. There are 2 files to note:

* build.properties

    * Located in the base of the project, this is to not be synced in git. It holds you credentials and creator information for the template automation

* package.json

    * located in the js_src folder, this is to be synced in git. This defines the namespace of your project and holds some of the templating information. 

Set your Credentials in the build.properties, and the namespace of the project in the build.properties. 

6. run command in js_src: "sudo npm install"

sObject / sObjects
------
**sObject** - This is an extention of a Backbone Model that contains some unique features for salesforce. The Salesforce fields are set on the objects attributes. Fields that preceed with an underscore are ignored when formatting to salesforce SObjects ex: “\_i\_wont_save_into_salesforce”. 

**sObjects** - this is an extention of a Backbone Collection that contains a collection of sObjects. This extends the functionality for DML into bulkification.

###absorb

Absorb will replace the attributes of an object with the object being passed in. This is pretty much a wrapper of the models set functionality. However the collection will absorb by the Id attribute keeping the collection consistent. 

```javascript
   var model = sObject({
      Name : '',
      Id : '123456'
   }); 
   model.absorb({
      Name : 'Test Account',
      AccountNumber : '123'
   });
   /*
      Model Attributes is now 
      {
         Name : 'Test Account',
         Account : '123',
         Id : '123456
      }
   */
   
   var collection.absorb(); //resets the model, need better absorb management. 
```

Simple Access Calls are defined as simple object interactions that would either run a query or service that returns sObjects or saving an sObject/sObjects directly into Salesforce. 



###Save

```javascript
var model = new sObject();    //    var collection = new sObjects();
//... add fields or gather from form
model.save({ //collection.save({
	objectType: 'Custom_Object__c'  //or ‘Account’ just the 
}); 
```

This will save (upsert) the model or collection into salesforce (removing fields that preceed with an underscore ) and return the model or collection with the Id’s from salesforce. You can also pass in a successHandle function or an errorHandle function to override the defaults.

**defaultSuccessSaveHandle** - 
	Absorbs the salesforce record into the model - (recalculate formula fields if present / sets the ID) throws events on save / error
TRIGGERS: ‘save:success’ - save was successful and object was absorbed into model

**defaultErrorSaveHandle** - 
failed to save the record
TRIGGERS: ‘save:error’  - issues could be:
   * Make sure you update the standard Service.cls for your org, see below
   * Make sure there is an Id, or sobjectType present on the object
   * Make sure all fields on the object exist in sf and are the right type

####Example

```javascript
	var model = new sObject();
	model.set({Name: 'Test Account'});
	this.listenToOnce(model, 'save:success', function(){
		flashMessage({message: 'SAVED!'});
	});
	this.listenToOnce(model, 'save:error', function(){
		flashMessage({message: 'ERROR!'});
	});
	model.save({ objectType: 'Account' });
```

###Load
```javascript
var model = new sObject();      //    var collection = new sObjects();
model.load({
	queryOrService: 'select Id, Name from Account' //'AccountService.getAllAccounts'
});
```
This function will load from a query or a service (service must return records in the result.records property unless you override the default handlers). This will be absorbed by the model, and reset the collection(collection for now loses the _ properties besides the defaults of the sObject). successHandler and errorHandle can be passed in to handle the remoteAction returns. 

**defaultSuccessLoadHandle** - 
Model - absorbs the result.record[0] object
Collection - resets the collection to result.records 
TRIGGERS: ‘load:success’

**defaultErrorLoadHandle** - 
	TRIGGERS: ‘load:error’ - issues could be:
   *You messed up the query, spelling!
   *The query is just invalid or not accepted by salesforce (access?)
   *The Field / Object does not exist in your org
   *The Service Does not exist
   *You made the service but did not expose it to the page, set a component controller to the class with the remoteAction and add the component to the page

####Example
```javascript
	var collection = new sObjects();
	this.listenToOnce(collection, 'load:success', function(){
		flashMessage({ message: 'LOADED' });
	});
	this.listenToOnce(collection, 'load:error', function(){
		flashMessage({ message: 'FAILED!' });
	});
	collection.load({
		queryOrService: ‘select Id, Name from Account’
	});
```

TODO: Share out the RA Dev Tools

TODO: document the new template features. See RA Dev Guide for more info on existing templating. 
