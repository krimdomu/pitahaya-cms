function fill_form_elements(ref, cb) {
  for(var key in ref) {
    cb(key, ref[key]);
  }
}

Array.prototype.contains = function(obj) {
    var i = this.length;
    while (i--) {
        if (this[i] === obj) {
            return true;
        }
    }
    return false;
}

if (typeof String.prototype.contains === 'undefined') {
  String.prototype.contains = function(it) {
    return this.indexOf(it) != -1;
  };
}


require([
    "dojo/on",
    "dojo/dom",
    "dojo/request",
		"dojo/json",
    "dijit/registry",
    "dojo/request/script",
    "dojo/cookie",
    "dijit/_editor/plugins/EnterKeyHandling",
		"dojo/ready",
		"dojo/domReady!"
	], function(on, dom, request, json, registry, script, cookie, EnterKeyHandling, ready ){

  $GLOBAL['on'] = on;
  $GLOBAL['dom'] = dom;
  $GLOBAL['request'] = request;
  $GLOBAL['registry'] = registry;
  $GLOBAL['json'] = json;
  $GLOBAL['script'] = script;
  $GLOBAL['cookie'] = cookie;
  $GLOBAL['EnterKeyHandling'] = EnterKeyHandling;

  script.get("/js/pitahaya/admin/admin_init.js");

  ready(function() {
    on(registry.byId("file_exit"), "Click", function(evt) {
      logout();
    });

    on(registry.byId("admin_export"), "Click", function(evt) {
      request.get("./export").then(function() {
        $.notify("Site exported.", "success");
      });
    });
  });

});

