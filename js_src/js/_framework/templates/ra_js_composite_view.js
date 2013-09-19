/*
 * @class ${name}View
 * @author ${user} - ${email}
 * @created ${date}
 *
 */
${namespace}.module("${module}Module", function(${module}Module, App, Backbone, Marionette, $, _) {

	${module}Module.${name}ItemView = Backbone.Marionette.ItemView.extend({
		template: '${module}${name}ItemView',
		tagName: 'tr', //'div' or what you want this view to render under
		className: '', //class name to the wrapper of this, span3? well?
		events: {},

		onRender: function() {}

	});

	${module}Module.${name}CompositeView = Backbone.Marionette.CompositeView.extend({
		template: '${module}${name}CompositeView',

		events: {},

		onShow: function() {},

		itemViewContainer: 'tbody',//where do you wish to render this within the composite template
		itemView: ${module}Module.${name}ItemView

	});

});