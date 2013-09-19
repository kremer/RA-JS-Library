/*
 * @class ${name}Layout
 * @author ${user} - ${email}
 * @created ${date}
 *
 */
${namespace}.module("${module}Module", function(${module}Module, App, Backbone, Marionette, $, _) {

	${module}Module.${name}Layout = Backbone.Marionette.Layout.extend({
		template: '${name}Layout',

		events: {},

		regions: {
			content : '.content'
		},

		onRender: function() {}

	});

});