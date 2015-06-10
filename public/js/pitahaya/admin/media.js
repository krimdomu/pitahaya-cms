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

      on(registry.byId("file_new_folder"), "Click", function(evt) {
        if(dom.byId("media_edit")) {
          var current_media = $GLOBAL.mediaTree.jstree('get_selected', true)[0];
          console.log("create new media...");
          if( !current_media ) {
            alert("No parent media folder selected.");
            return;
          }

          var new_media = {
            "name": "New Folder",
            "type_name": "folder"
          };
          
          media_new(current_media, new_media);
        }
        else {
          alert("No parent media folder selected.");
        }
      });


      on(registry.byId("file_new_media_object"), "Click", function(evt) {
        if(dom.byId("media_edit")) {
          var current_media = $GLOBAL.mediaTree.jstree('get_selected', true)[0];
          console.log("upload new media...");
          if( !current_media ) {
            alert("No parent media folder selected.");
            return;
          }

          registry.byId("upload_media_object").show();
        }
        else {
          alert("No parent media folder selected.");
        }
      });


      on(registry.byId("file_delete"), "Click", function(evt) {
        if(dom.byId("media_edit")) {
          console.log("deleting media...");
          var current_media = mediaTree_get_selected();

          if( !current_media ) {
            alert("No media selected.");
            return;
          }
          
          media_delete(current_media);
        }
      });

      on(registry.byId("file_save"), "Click", function(evt) {
        // in media?
        if(dom.byId("media_edit")) {
          console.log("saving media...");
          var current_media = mediaTree_get_selected();

          media_set("name", registry.byId("media_name").get("value"));
          media_set("title", registry.byId("media_title").get("value"));
          media_set("description", registry.byId("media_description").get("value"));
          media_set("type_id", registry.byId("media_type").get("value"));
          media_set("hidden", registry.byId("media_hidden").get("value"), {is_bool: true});
          media_set("url", registry.byId("media_url").get("value") || registry.byId("media_name").get("value"));

          var data = $GLOBAL.media;

          if(typeof window["onmedia_data_save"] != "undefined") {
            onmedia_data_save();
          }

          var extra_data = $GLOBAL.media['data'] || {};
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
          
          if(registry.byId("media_rel_date").get("displayedValue")) {
            var rel_date;
            rel_date = registry.byId("media_rel_date").get("displayedValue");
            if(registry.byId("media_rel_time").get("displayedValue")) {
              rel_date += " " + registry.byId("media_rel_time").get("displayedValue");
            }
            else {
              rel_date += " 00:00";
            }
            data['rel_date'] = rel_date;
          }

          if(registry.byId("media_lock_date").get("displayedValue")) {
            var lock_date;
            lock_date = registry.byId("media_lock_date").get("displayedValue");
            if(registry.byId("media_lock_time").get("displayedValue")) {
              lock_date += " " + registry.byId("media_lock_time").get("displayedValue");
            }
            else {
              lock_date += " 00:00";
            }
            data['lock_date'] = lock_date;
          }
          
          console.log(data);

          if( !current_media ) {
            alert("No media object selected.");
            return;
          }

          media_save(current_media, data);
        }
      });
    });
  }
);
