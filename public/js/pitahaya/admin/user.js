require([
    "dojo/on",
    "dojo/dom",
    "dojo/request",
		"dojo/json",
		"dojo/query",
    "dijit/registry",
		"dojo/ready",
    "dojo/dom-form"
	], function(on, dom, request, json, query, registry, ready, domForm){

    ready(function() {

      on(registry.byId("view_user"), "Click", function(evt) {
        user_load_view();
      });

      on(registry.byId("file_new_user"), "Click", function(evt) {
        var func = function() {
          new_user_dialog.show();
        }

        if($GLOBAL['view'] != "user") {
          user_load_view(func);
        }
        else {
          func();
        }
      });

      on(registry.byId("file_delete"), "Click", function(evt) {
        if(dom.byId("user_edit")) {
          console.log("deleting user...");
          var current_user = userTree_get_selected();

          if( !current_user ) {
            alert("No user selected.");
            return;
          }
          
          user_delete(current_user);
        }
      });


      on(registry.byId("file_save"), "Click", function(evt) {
        // in user?
        if(dom.byId("user_edit")) {
          console.log("saving user...");
          var current_user = userTree_get_selected();

          var data = {};
          data['username'] = $GLOBAL.registry.byId("user_username").get("value");
          data['email'] = $GLOBAL.registry.byId("user_email").get("value");
          if($GLOBAL.registry.byId("user_password").get("value")) {
            data['password'] = $GLOBAL.registry.byId("user_password").get("value");
          }

          user_save(current_user, data);
        }
      });

    });
  }
);
