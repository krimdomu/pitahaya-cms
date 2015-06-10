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

  var ImgLinkDialog = declare("js.admin.Editor.LinkDialog", [_LinkDialog.ImgLinkDialog], {
  
		linkDialogTemplate: [
      '<div data-dojo-type="dijit/layout/ContentPane" title="Pages" style="height: 300px; width: 338px;">',
      '<div id="imgMediaTree"></div>',
      '</div>',
			"<table role='presentation'><tr><td>",
			"<label for='${id}_urlInput'>${url}</label>",
			"</td><td>",
			"<input dojoType='dijit.form.ValidationTextBox' regExp='${urlRegExp}' " +
				"required='true' id='${id}_urlInput' name='urlInput' data-dojo-props='intermediateChanges:true'/>",
			"</td></tr><tr><td>",
			"<label for='${id}_textInput'>${text}</label>",
			"</td><td>",
			"<input data-dojo-type='dijit.form.ValidationTextBox' required='false' id='${id}_textInput' " +
				"name='textInput' data-dojo-props='intermediateChanges:true'/>",
			"</td></tr><tr><td>",
			"</td><td>",
			"</td></tr><tr><td colspan='2'>",
			"<button data-dojo-type='dijit.form.Button' type='submit' id='${id}_setButton'>${set}</button>",
			"<button data-dojo-type='dijit.form.Button' type='button' id='${id}_cancelButton'>${buttonCancel}</button>",
			"</td></tr></table>"
		].join(""),

    _isValid: function() {
      return true;
    },

    _onOpenDialog: function() {
      var self = this;
			this.inherited(arguments);

      if(typeof $GLOBAL['imgMediaTree'] == "undefined") {

        $GLOBAL['imgMediaTree'] = $('#imgMediaTree').jstree({
          core: {
            check_callback: true,
            data: {
              url: function(node) {
                if(node.id === '#') {
                  return "./media/tree";
                }
                else {
                  return "./media/tree/children/" + node.id;
                }
              }
            }
          }
        });

        $GLOBAL.imgMediaTree.on("changed.jstree", function(e, data) {
          var item = data.instance.get_node(data.selected[0]);
          //var url_field = self._uniqueId + "_urlInput";
          var path = data.instance.get_path(item, "/").split("/");
          path.shift();

          self._urlInput.set("value", "/media/" + path.join("/")); 
			    self._setButton.set("disabled", false);
        });

      }
    },

    _checkAndFixInput: function() {}
  });

	// Register these plugins
	_Plugin.registry["myInsertImage"] = function(){
		return new ImgLinkDialog({command: "insertImage"});
	};

	return ImgLinkDialog;
});
