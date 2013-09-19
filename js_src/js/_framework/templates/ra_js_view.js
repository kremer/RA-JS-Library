/*
 * @class ${name}View
 * @author ${user} - ${email}
 * @created ${date}
 *
 */
${namespace}.module("${module}Module", function(${module}Module, App, Backbone, Marionette, $, _) {

	${module}Module.${name}View = Backbone.Marionette.ItemView.extend({
		template: '${module}${name}View',

		events: {},

		onShow: function() {}

	});

});