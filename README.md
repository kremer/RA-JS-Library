RA-JS-Framework
===============

This is the Red Argyle Javascript Framework that lives on top of the salesforce platform utilizing Marionette, Sublime Text, and Grunt to manage javascript applications on top of the salesforce platform. 

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

TODO: Share out the RA Dev Tools

TODO: document the new template features. See RA Dev Guide for more info on existing templating. 