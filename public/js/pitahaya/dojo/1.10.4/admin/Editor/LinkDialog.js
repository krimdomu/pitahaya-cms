define([
	"require",
	"dojo/_base/declare", // declare
	"dojo/dom-attr", // domAttr.get
	"dojo/keys", // keys.ENTER
	"dojo/_base/lang", // lang.delegate lang.hitch lang.trim
	"dojo/on",
	"dojo/sniff", // has("ie")
	"dojo/query", // query
	"dojo/string", // string.substitute
	"dijit/_editor/_Plugin",
  "dijit/_editor/plugins/LinkDialog"
], function(require, declare, domAttr, keys, lang, on, has, query, string,
	_Plugin, _LinkDialog){

  var LinkDialog = declare("js.admin.Editor.LinkDialog", [_LinkDialog], {

		htmlTemplate: "<a href=\"${urlInput}\" class=\"${classInput}\" _djrealurl=\"${urlInput}\"" +
			" target=\"${targetSelect}\"" +
			">${textInput}</a>",
  
		linkDialogTemplate: [
      '<div data-dojo-type="dijit/layout/ContentPane" title="Pages" style="height: 300px;">',
      '<div id="linkPageTree"></div>',
      '</div>',
			"<table role='presentation'><tr><td>",
			"<label for='${id}_urlInput'>${url}</label>",
			"</td><td>",
			"<input data-dojo-type='dijit.form.ValidationTextBox' required='true' " +
				"id='${id}_urlInput' name='urlInput' data-dojo-props='intermediateChanges:true'/>",
			"</td></tr><tr><td>",
			"<label for='${id}_classInput'>CSS Class:</label>",
			"</td><td>",
			"<input data-dojo-type='dijit.form.TextBox' id='${id}_classInput' " +
				"name='classInput' data-dojo-props='intermediateChanges:true'/>",
			"</td></tr><tr><td>",
			"<label for='${id}_textInput'>${text}</label>",
			"</td><td>",
			"<input data-dojo-type='dijit.form.ValidationTextBox' required='true' id='${id}_textInput' " +
				"name='textInput' data-dojo-props='intermediateChanges:true'/>",
			"</td></tr><tr><td>",
			"<label for='${id}_targetSelect'>${target}</label>",
			"</td><td>",
			"<select id='${id}_targetSelect' name='targetSelect' data-dojo-type='dijit.form.Select'>",
			"<option selected='selected' value='_self'>${currentWindow}</option>",
			"<option value='_blank'>${newWindow}</option>",
			"<option value='_top'>${topWindow}</option>",
			"<option value='_parent'>${parentWindow}</option>",
			"</select>",
			"</td></tr><tr><td colspan='2'>",
			"<button data-dojo-type='dijit.form.Button' type='submit' id='${id}_setButton'>${set}</button>",
			"<button data-dojo-type='dijit.form.Button' type='button' id='${id}_cancelButton'>${buttonCancel}</button>",
			"</td></tr></table>"
		].join(""),

    _isValid: function() {
      return true;
    },

		_getCurrentValues: function(a){
			// summary:
			//		Over-ride for getting the values to set in the dropdown.
			// a:
			//		The anchor/link to process for data for the dropdown.
			// tags:
			//		protected
			var url, text, target, class_name;
			if(a && a.tagName.toLowerCase() === this.tag){
				url = a.getAttribute('_djrealurl') || a.getAttribute('href');
				target = a.getAttribute('target') || "_self";
        class_name = a.getAttribute('class') || "";
				text = a.textContent || a.innerText;
				this.editor.selection.selectElement(a, true);
			}else{
				text = this.editor.selection.getSelectedText();
			}
			return {urlInput: url || '', textInput: text || '', targetSelect: target || '', classInput: class_name || ''}; //Object;
		},

		_loadDropDown: function(callback){
			// Called the first time the button is pressed.  Initialize TooltipDialog.
			require([
				"dojo/i18n", // i18n.getLocalization
				"dijit/TooltipDialog",
				"dijit/registry", // registry.byId, registry.getUniqueId
				"dijit/form/Button", // used by template
				"dijit/form/Select", // used by template
				"dijit/form/ValidationTextBox", // used by template
				"dojo/i18n!dijit/nls/common",
				"dojo/i18n!dijit/_editor/nls/LinkDialog"
			], lang.hitch(this, function(i18n, TooltipDialog, registry){
				var _this = this;
				this.tag = this.command == 'insertImage' ? 'img' : 'a';
				var messages = lang.delegate(i18n.getLocalization("dijit", "common", this.lang),
					i18n.getLocalization("dijit._editor", "LinkDialog", this.lang));
				var dropDown = (this.dropDown = this.button.dropDown = new TooltipDialog({
					title: messages[this.command + "Title"],
					ownerDocument: this.editor.ownerDocument,
					dir: this.editor.dir,
					execute: lang.hitch(this, "setValue"),
					onOpen: function(){
						_this._onOpenDialog();
						TooltipDialog.prototype.onOpen.apply(this, arguments);
					},
					onCancel: function(){
						setTimeout(lang.hitch(_this, "_onCloseDialog"), 0);
					}
				}));
				messages.urlRegExp = this.urlRegExp;
				messages.id = registry.getUniqueId(this.editor.id);

        messages['class'] = '';

        console.log(messages);
				this._uniqueId = messages.id;
				this._setContent(dropDown.title +
					"<div style='border-bottom: 1px black solid;padding-bottom:2pt;margin-bottom:4pt'></div>" +
					string.substitute(this.linkDialogTemplate, messages));
				dropDown.startup();
				this._urlInput = registry.byId(this._uniqueId + "_urlInput");
				this._textInput = registry.byId(this._uniqueId + "_textInput");
				this._setButton = registry.byId(this._uniqueId + "_setButton");
				this.own(registry.byId(this._uniqueId + "_cancelButton").on("click", lang.hitch(this.dropDown, "onCancel")));
				if(this._urlInput){
					this.own(this._urlInput.on("change", lang.hitch(this, "_checkAndFixInput")));
				}
				if(this._textInput){
					this.own(this._textInput.on("change", lang.hitch(this, "_checkAndFixInput")));
				}

				// Build up the dual check for http/https/file:, and mailto formats.
				this._urlRegExp = new RegExp("^" + this.urlRegExp + "$", "i");
				this._emailRegExp = new RegExp("^" + this.emailRegExp + "$", "i");
				this._urlInput.isValid = lang.hitch(this, function(){
					// Function over-ride of isValid to test if the input matches a url or a mailto style link.
					var value = this._urlInput.get("value");
					return this._urlRegExp.test(value) || this._emailRegExp.test(value);
				});

				// Listen for enter and execute if valid.
				this.own(on(dropDown.domNode, "keydown", lang.hitch(this, lang.hitch(this, function(e){
					if(e && e.keyCode == keys.ENTER && !e.shiftKey && !e.metaKey && !e.ctrlKey && !e.altKey){
						if(!this._setButton.get("disabled")){
							dropDown.onExecute();
							dropDown.execute(dropDown.get('value'));
						}
					}
				}))));

				callback();
			}));
		},

    _onOpenDialog: function() {
      var self = this;
			this.inherited(arguments);

      if(typeof $GLOBAL['linkPageTree'] == "undefined") {

        $GLOBAL['linkPageTree'] = $('#linkPageTree').jstree({
          core: {
            check_callback: true,
            data: {
              url: function(node) {
                if(node.id === '#') {
                  return "./page/tree";
                }
                else {
                  return "./page/tree/children/" + node.id;
                }
              }
            }
          }
        });

        $GLOBAL.linkPageTree.on("changed.jstree", function(e, data) {
          var item = data.instance.get_node(data.selected[0]);
          //var url_field = self._uniqueId + "_urlInput";
          var path = data.instance.get_path(item, "/").split("/");
          path.shift();

          self._urlInput.set("value", "/" + path.join("/") + ".html"); 
			    self._setButton.set("disabled", false);
        });

      }

    },

    _checkAndFixInput: function() {}
  });


	// Register these plugins
	_Plugin.registry["myCreateLink"] = function(){
		return new LinkDialog({command: "createLink"});
	};

	return LinkDialog;
});
