require([
    "dojo/parser",
    "dojo/on",
    "dojo/dom",
    "dojo/request",
		"dojo/json",
    "dijit/registry",
		"dojo/ready",
    "dojo/domReady!"
	], function(parser, on, dom, request, json, registry, ready ){

  parser.parse().then(function(instances) {
    login_dialog.show();

    on(registry.byId("login_button_ok"), "Click", function(evt) {
      var data = {};
      data['username'] = registry.byId("login_username").get("value");
      data['password'] = registry.byId("login_password").get("value");
      var _site = registry.byId("login_site").get("value");

      request.post("/admin/login", {
        "data": json.stringify(data),
        "timeout": 2000,
        "headers": {
          "Accept": "application/json",
          "Content-Type": "application/json"
        }
      }).then(function(data) {
      }, function() {
        login_dialog.show();
      }).then(function() {
        document.location.href = "/admin/" + _site + "/";
      });
    })
  });
});

