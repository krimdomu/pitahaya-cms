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

      on(registry.byId("view_page"), "Click", function(evt) {
        page_load_view();
      });

      on(registry.byId("file_new_page"), "Click", function(evt) {
        if(dom.byId("page_edit")) {
          var current_page = $GLOBAL.pageTree.jstree('get_selected', true)[0];
          console.log("create new page...");
          if( !current_page ) {
            alert("No parent page selected.");
            return;
          }

          var type_name = "page";

          if(typeof page_get("child_type") != "undefined" && page_get("child_type") != null) {
            type_name = page_get("child_type");
          }

          var new_page = {
            "name": "New Page",
            "active": 0,
            "type_name": type_name
          };
          
          page_new(current_page, new_page);
        }
        else {
          alert("No parent page selected.");
        }
      });


      on(registry.byId("file_delete"), "Click", function(evt) {
        if(dom.byId("page_edit")) {
          console.log("deleting page...");
          var current_page = pageTree_get_selected();

          if( !current_page ) {
            alert("No page selected.");
            return;
          }
          
          page_delete(current_page);
        }
      });

      on(registry.byId("file_save"), "Click", function(evt) {
        // in page?
        if(dom.byId("page_edit")) {
          console.log("saving page...");
          var current_page = pageTree_get_selected();
          //var data = domForm.toObject("page_edit");

          page_set("name", registry.byId("page_name").get("value"));
          page_set("title", registry.byId("page_title").get("value"));
          page_set("description", registry.byId("page_description").get("value"));
          page_set("type_id", registry.byId("page_type").get("value"));
          page_set("content_type_id", registry.byId("content_type").get("value"));
          page_set("navigation", registry.byId("page_navigation").get("value"), {is_bool: true});
          page_set("active", registry.byId("page_active").get("value"), {is_bool: true});
          page_set("hidden", registry.byId("page_hidden").get("value"), {is_bool: true});
          page_set("url", registry.byId("page_url").get("value") || registry.byId("page_name").get("value"));


          if(typeof window["onpage_save"] != "undefined" && window["onpage_save"]) {
            onpage_save();
          }

          if(typeof window["onpage_data_save"] != "undefined" && window["onpage_data_save"]) {
            onpage_data_save();
          }

          var data = $GLOBAL.page;
          // we need to remove this, because if this is set, this has 
          // precedence over content_type_id.
          // change of content type would not work
          delete data['content_type_name'];

          var extra_data = $GLOBAL.page['data'] || {};
          for (var key in data) {
            if(data.hasOwnProperty(key)) {
              if(key.contains("data.")) {
                var k = key.split(/\./);
                extra_data[k[1]] = data[key];
                delete data[key];
              }
            }
          }
          
          data['data'] = extra_data;
          
          if(registry.byId("page_rel_date").get("displayedValue")) {
            var rel_date;
            rel_date = registry.byId("page_rel_date").get("displayedValue");
            if(registry.byId("page_rel_time").get("displayedValue")) {
              rel_date += " " + registry.byId("page_rel_time").get("displayedValue");
            }
            else {
              rel_date += " 00:00";
            }
            data['rel_date'] = rel_date;
          }

          if(registry.byId("page_lock_date").get("displayedValue")) {
            var lock_date;
            lock_date = registry.byId("page_lock_date").get("displayedValue");
            if(registry.byId("page_lock_time").get("displayedValue")) {
              lock_date += " " + registry.byId("page_lock_time").get("displayedValue");
            }
            else {
              lock_date += " 00:00";
            }
            data['lock_date'] = lock_date;
          }
          
          console.log(data);

          if( !current_page ) {
            alert("No page selected.");
            return;
          }

          page_save(current_page, data);
        }
      });
    });
  }
);
