module.exports = function(grunt) {
    var that = this;
    that.buildPropertiesPath = '../';//set to build properties Path
    that.getUsernameFromBuild = function(path) {
        if(isNothing(path))
            path = that.buildPropertiesPath;
        var file = grunt.file.read(path + 'build.properties');
        return file.split('sf.username=')[1].split('\n')[0];
    };
    that.getPasswordFromBuild = function(path) {
        if(isNothing(path))
            path = that.buildPropertiesPath;
        var file = grunt.file.read(path + 'build.properties');
        return file.split('sf.password=')[1].split('\n')[0];
    };
    that.getNameFromBuild = function(path) {
        if(isNothing(path))
            path = that.buildPropertiesPath;
        var file = grunt.file.read(path + 'build.properties');
        return file.split('creatorName=')[1].split('\n')[0];
    };
    that.getEmailFromBuild = function(path) {
        if(isNothing(path))
            path = that.buildPropertiesPath;
        var file = grunt.file.read(path + 'build.properties');
        return file.split('email=')[1].split('\n')[0];
    };
    that.getNamespaceFromBuild = function(path) {
        if(isNothing(path))
            path = that.buildPropertiesPath;
        var file = grunt.file.read(path + 'build.properties');
        return file.split('namespace=')[1].split('\n')[0];
    };

    // project configuration.
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        jshint: {
            options: {
                globals: {
                    jQuery: true,
                    console: true,
                    module: true,
                    document: true
                },
                newcap: false
            },
            build: ['gruntfile.js', 'js/*/*.js', 'js/*.js']
        },
        concat: {
            js: {
                src: ['js/_framework/*.js', 'js/packages/*/*/*.js', 'js/*/*.js', 'js/*.js', 'js/*/*/*.js', '!js/_framework/lib/*', '!js/_framework/templates/*'],
                dest: 'tmp/js/app_scripts.js'
            },
            jslib: {
                src: ['js/_framework/lib/js/jquery1.9.1.js', 'js/_framework/lib/js/underscore1.4.2.min.js', 'js/_framework/lib/js/*'],
                dest: 'tmp/js/lib_scripts.js'
            },
            csslib: {
                src: ['js/_framework/lib/css/*.css'],
                dest: 'tmp/css/lib_styles.css'
            },
            html: {
                src: ['js/*/templates/*.html', 'js/packages/*/templates/*.html'],
                dest: 'tmp/templates/app_templates.html'
            }
        },
        uglify: {
            options: {
                banner: '/*! '+ that.getNamespaceFromBuild('../') +' <%= grunt.template.today("dd-mm-yyyy") %> */\n'
            },
            build: {
                files: {
                    'tmp/js/app_scripts.min.js': ['<%= concat.js.dest %>']
                }
            }
        },
        htmlcompressor: {
            compile: {
                files: {
                    'templates/*.html': 'tmp/*.html'
                },
                options: {
                    type: 'html',
                    preserveServerScript: true
                }
            }
        },
        zip: {
            // example build target for static resources
            build: {
                options: {
                    base: 'tmp/'
                },
                src: ['tmp'],
                dest: 'build/staticresources/'+ that.getNamespaceFromBuild('../') +'.resource'
            }
        },
        copy: {
            css: {
                files: [{
                    expand: true,
                    cwd: 'css/',
                    src: ['*'],
                    dest: 'tmp/css'
                }]
            },
            cssLibImages: {
                files: [{
                    expand: true,
                    cwd: 'js/_framework/lib/css/',
                    src: ['*.png'],
                    dest: 'tmp/css'
                }]
            },
            cssLibImages2: {
                files: [{
                    expand: true,
                    cwd: 'js/_framework/lib/css/images/',
                    src: ['*'],
                    dest: 'tmp/css/images'
                }]
            },
            img: {
                files: [{
                    expand: true,
                    cwd: 'img/',
                    src: ['*'],
                    dest: 'tmp/img'
                }]
            },
            resource: {
                files: [{
                    expand: true,
                    cwd: 'build/staticresources/',
                    src: ['*'],
                    dest: '../src/staticresources'
                }]
            },
            itemview: {
                files: [{
                    expand: true,
                    cwd: 'js/_framework/templates/',
                    src: ['ra_js_view.js'],
                    dest: 'js/'
                }, {
                    expand: true,
                    cwd: 'js/_framework/templates/',
                    src: ['ra_js_template.html'],
                    dest: 'templates/'
                }]
            }
        },
        antdeploy: {
            // define global options for all deploys
            options: {
                root: 'build/',
                version: '27.0'
            },
            // create individual deploy targets. these can be 
            // individual orgs or even the same org with different packages
            application: {
                user: that.getUsernameFromBuild('../'), // pass path to location of build.properties
                pass: that.getPasswordFromBuild('../'), // pass path to location of build.properties
                serverurl: 'https://login.salesforce.com',
                pkg: {
                    staticresource: ['*']
                }
            }
        },
        clean: {
            build: ['tmp', 'build/package.xml']
        }

    });



    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-zipstream');
    grunt.loadNpmTasks('grunt-ant-sfdc');
    //grunt.loadNpmTasks('grunt-htmlcompressor');

    // custom task to write the -meta.xml file for the metadata deployment
    grunt.registerTask('write-meta', 'Write the required salesforce metadata', function() {
        grunt.log.writeln('Writing metadata...');
        var sr = [
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<StaticResource xmlns="http://soap.sforce.com/2006/04/metadata">',
            '  <cacheControl>Public</cacheControl>',
            '  <contentType>application/zip</contentType>',
            '  <description>MyTest Description</description>',
            '</StaticResource>'];
        var dest = grunt.template.process('<%= zip.build.dest %>') + '-meta.xml';
        grunt.file.write(dest, sr.join('\n'));
    });

    grunt.registerTask('testfile', 'test stuff', function() {
        //that.getUsernameFromBuild('../');
        grunt.log.writeln(that.getUsernameFromBuild('../'));
    });

    // default task (no deploy)
    grunt.registerTask('default', ['clean', 'jshint', 'concat', 'uglify', 'copy:css', 'copy:cssLibImages', 'copy:cssLibImages2', 'copy:img', 'zip', 'write-meta', 'copy:resource']);

    //basic local grunt
    grunt.registerTask('local', ['clean', 'concat', 'copy:css', 'copy:img']);

    //create new view
    grunt.registerTask('itemview', function(module, itemviewName) {
        //debugger;
        if (arguments.length === 0) {
            grunt.log.writeln(this.name + ", no args");
        } else {
            var timestamp = new Date().toDateString() + ' ' + new Date().toTimeString();
            var user = that.getNameFromBuild();
            var email = that.getEmailFromBuild();
            var namespace = that.getNamespaceFromBuild();

            replaces = [{
                i: '\\${name}',
                o: itemviewName
            }, {
                i: '\\${module}',
                o: module
            }, {
                i: '\\${namespace}',
                o: namespace
            }, {
                i: '\\${user}',
                o: user
            }, {
                i: '\\${email}',
                o: email
            }, {
                i: '\\${date}',
                o: timestamp
            }];
            createFileFromTemplate({
                path: 'js/' + module + '/views/',
                template: 'itemViewJS',
                fileName: itemviewName + 'View.js',
                replaces: replaces
            });
            createFileFromTemplate({
                path: 'js/' + module + '/templates/',
                template: 'itemViewHtml',
                fileName: itemviewName + 'View.html',
                replaces: replaces
            });
        }
    });

    //create new composite view
    grunt.registerTask('compositeview', function(module, compositeviewName) {
        //debugger;
        if (arguments.length === 0) {
            grunt.log.writeln(this.name + ", no args");
        } else {
            var timestamp = new Date().toDateString() + ' ' + new Date().toTimeString();
            var user = that.getNameFromBuild();
            var email = that.getEmailFromBuild();
            var namespace = that.getNamespaceFromBuild();

            replaces = [{
                i: '\\${name}',
                o: compositeviewName
            }, {
                i: '\\${module}',
                o: module
            }, {
                i: '\\${namespace}',
                o: namespace
            }, {
                i: '\\${user}',
                o: user
            }, {
                i: '\\${email}',
                o: email
            }, {
                i: '\\${date}',
                o: timestamp
            }];
            createFileFromTemplate({
                path: 'js/' + module + '/views/',
                template: 'compositeViewJS',
                fileName: compositeviewName + 'View.js',
                replaces: replaces
            });
            createFileFromTemplate({
                path: 'js/' + module + '/templates/',
                template: 'compositeItemViewHTML',
                fileName: compositeviewName + 'ItemView.html',
                replaces: replaces
            });
            createFileFromTemplate({
                path: 'js/' + module + '/templates/',
                template: 'compositeViewHTML',
                fileName: compositeviewName + 'CompositeView.html',
                replaces: replaces
            });
        }
    });

    //create module
    grunt.registerTask('module', function(moduleName) {
        //debugger;
        if (arguments.length === 0) {
            grunt.log.writeln(this.name + ", no args");
        } else {
            var timestamp = new Date().toDateString() + ' ' + new Date().toTimeString();
            var user = that.getNameFromBuild();
            var email = that.getEmailFromBuild();
            var namespace = that.getNamespaceFromBuild();
            replaces = [{
                i: '\\${name}',
                o: moduleName
            },{
                i: '\\${module}',
                o: moduleName
            }, {
                i: '\\${namespace}',
                o: namespace
            }, {
                i: '\\${user}',
                o: user
            }, {
                i: '\\${email}',
                o: email
            }, {
                i: '\\${date}',
                o: timestamp
            }];

            createFileFromTemplate({
                path: 'js/modules/' + moduleName + '/',
                template: 'moduleJS',
                fileName: moduleName + 'Module.js',
                replaces: replaces
            });

            createFileFromTemplate({
                path: 'js/modules/' + moduleName + '/layouts/',
                template: 'layoutJS',
                fileName: moduleName + 'Layout.js',
                replaces: replaces
            });

            createFileFromTemplate({
                path: 'js/modules/' + moduleName + '/templates/',
                template: 'layoutHTML',
                fileName: moduleName + 'Layout.html',
                replaces: replaces
            });

        }
    });

 //create module
    grunt.registerTask('app', function(appName) {
        //debugger;
        if (arguments.length === 0) {
            grunt.log.writeln(this.name + ", no name given for application. Ex: grunt app:Main");
        } else {
            var timestamp = new Date().toDateString() + ' ' + new Date().toTimeString();
            var user = that.getNameFromBuild();
            var email = that.getEmailFromBuild();
            var namespace = that.getNamespaceFromBuild();
            replaces = [{
                i: '\\${name}',
                o: appName + 'App'
            },{
                i: '\\${app}',
                o: appName + 'App'
            }, {
                i: '\\${namespace}',
                o: namespace
            }, {
                i: '\\${user}',
                o: user
            }, {
                i: '\\${email}',
                o: email
            }, {
                i: '\\${date}',
                o: timestamp
            }];

            createFileFromTemplate({
                path: 'js/' + appName + 'App/',
                template: 'applicationJS',
                fileName: appName + 'App.js',
                replaces: replaces
            });

            createFileFromTemplate({
                path: 'js/' + appName + 'App/layouts/',
                template: 'applicationLayoutJS',
                fileName: appName + 'AppLayout.js',
                replaces: replaces
            });

            createFileFromTemplate({
                path: 'js/' + appName + 'App/templates/',
                template: 'applicationLayoutHTML',
                fileName: appName + 'AppLayout.html',
                replaces: replaces
            });

        }
    });



    function createFileFromTemplate(options) {

        var template = loadTemplates({
            template: options.template
        });
        if (template === null || template === '') {
            grunt.log.writeln('TEMPLATE [' + options.template + ']: NOT DEFINED');
            return;
        }
        if (options.replaces !== null) {
            for (var k = 0; k < options.replaces.length; k++) {
                regExp = new RegExp(options.replaces[k].i, 'g');
                template = template.replace(regExp, options.replaces[k].o);
            }
        }
        grunt.file.write(options.path + '/' + options.fileName, template);
    }

    function loadTemplates(options) {
        templates = (grunt.file.readJSON('package.json')).templates;
        if (templates.templates[options.template] === undefined) {
            return null;
        }
        return grunt.file.read(templates.path + templates.templates[options.template]);
    }

    function isNothing(value) {
        if(value === undefined || value === null)
            return true;
        return false;
    }


    // 'all' task including deploy
    grunt.registerTask('all', ['default', 'antdeploy']);

};