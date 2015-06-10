define([
	"dojo",
	"dijit",
	"dojox",
	"dojo/string",
	"dijit/_editor/_Plugin",
	"dijit/_base/manager",
	"dijit/form/Button",
	"dijit/Dialog",
	"dojox/html/format",
	"dojo/_base/connect",
	"dojo/_base/declare",
	"dojo/i18n"
], function(dojo, dijit, dojox, string, _Plugin) { 

var Snippets = dojo.declare("js.admin.Editor.Snippets", _Plugin, {

	// width: [public] String
	//		The width to use for the rich text area in the copy/pate dialog, in px.  Default is 400px.
	width: "400px",

	// height: [public] String
	//		The height to use for the rich text area in the copy/pate dialog, in px.  Default is 300px.
	height: "300px",

  template: [
    '<div id="pnl_insert_snippet_${uId}" class="edgePanel" data-dojo-type="dijit/layout/ContentPane">',
    '</div>',
    '<div id="pnl_insert_snippet_btn_${uId}" class="edgePanel" data-dojo-type="dijit/layout/ContentPane">',
    '<button id="btn_insert_snippet_${uId}" type="button" data-dojo-type="dijit/form/Button">Paste</button>',
    '</div>'
  ].join("\n"),

	_initButton: function(){

		this.button = new dijit.form.Button({
			label: "Paste Snippets",
			showLabel: false,
			iconClass: "editSnippets",
			tabIndex: "-1",
			onClick: dojo.hitch(this, "_openDialog")
		});

		this._uId = dijit.getUniqueId(this.editor.id);

    var strings = {};
		strings.uId = this._uId;
		strings.width = this.width || "400px";
		strings.height = this.height || "300px";

		this._dialog = new dijit.Dialog({title: "Paste Snippets"}).placeAt(dojo.body());
		this._dialog.set("content", string.substitute(this.template, strings));
    this._panel = dijit.byId("pnl_insert_snippet_" + this._uId);
    this._panel.set("href", "./editor/snippets?uid=" + this._uId);

		// Link up the action buttons to perform the insert or cleanup.
		this.connect(dijit.byId("btn_insert_snippet_" + this._uId), "onClick", "_paste");

	},

  _paste: function(evt) {
    var self = this;
    var snippet_id = $GLOBAL.registry.byId("html_snippet_" + this._uId).get("value");

    $GLOBAL.request.get("./editor/snippet/" + snippet_id).then(function(data) {
      self._dialog.hide();
      self.editor.execCommand("inserthtml", data);
    });
  },

	setEditor: function(editor){
		// summary:
		//		Over-ride for the setting of the editor.
		// editor: Object
		//		The editor to configure for this plugin to use.
		this.editor = editor;
		this._initButton();
	},

/*
	updateState: function(){
		// summary:
		//		Over-ride for button state control for disabled to work.
		this.button.set("disabled", this.get("disabled"));
	},
  */
	
	_openDialog: function(){
		// summary:
		//		Function to trigger opening the copy dialog.
		// tags:
		//		private
		this._dialog.show();
	},

	_cancel: function(){
		// summary:
		//		Function to handle cancelling setting the contents of the
		//		copy from dialog into the editor.
		// tags:
		//		private
		this._dialog.hide();
	},

	_clearDialog: function(){
		// summary:
		//		simple function to cleat the contents when hide is calledon dialog
		//		copy from dialog into the editor.
		// tags:
		//		private
	},

	destroy: function(){
		// sunnary:
		//		Cleanup function
		// tags:
		//		public
		if(this._dialog){
			this._dialog.destroyRecursive();
		}
		delete this._dialog;
		this.inherited(arguments);
	}

});

	// Register these plugins
	_Plugin.registry["snippets"] = function(){
		return new Snippets({
			width: "400px",
			height: "300px"
    });
	};

return Snippets;
});
