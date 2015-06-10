/******************************************************************************/
// Media functions
/******************************************************************************/

/**
 * FUNCTION: media_set(key, value, options)
 *
 * RETURNS: void
 *
 * Set a field for the current loaded media object.
 */
function media_set(key, value, opts) {
  console.log("setting media info: " + key + " -> " + value);

  if(typeof $GLOBAL['media'] == "object" && $GLOBAL['media'] != null) {
    if(typeof opts == "object" && typeof opts['is_bool'] != "undefined" && opts['is_bool']) {
      $GLOBAL['media'][key] = value === 'on' ? 1 : 0;
    }
    else {
      $GLOBAL['media'][key] = value;
    }
  }
  else {
    console.log("No media selected...");
  }
}

/**
 * FUNCTION: media_get(key)
 *
 * RETURNS: mixed
 *
 * Get a field of the current loaded media object.
 */
function media_get(key) {
  if(typeof $GLOBAL['media'] == "object" && typeof $GLOBAL['media'][key] != "undefined") {
    return $GLOBAL['media'][key];
  }
  else {
    return null;
  }
}

/**
 * FUNCTION: media_data_set(key, value, options)
 *
 * RETURNS: void
 *
 * Set a `data` value for current loaded media.
 */
function media_data_set(key, value, opts) {
  console.log("setting media data: " + key + " -> " + value);
  if(typeof $GLOBAL['media']['data'] == "object" && $GLOBAL['media']['data'] != null) {
    if(typeof opts == "object" && typeof opts['is_bool'] != "undefined" && opts['is_bool']) {
      $GLOBAL['media']['data'][key] = value === 'on' ? 1 : 0;
    }
    else {
      $GLOBAL['media']['data'][key] = value;
    }
  }
  else {
    $GLOBAL['media']['data'] = {};
    if(typeof opts == "object" && typeof opts['is_bool'] != "undefined" && opts['is_bool']) {
      $GLOBAL['media']['data'][key] = value === 'on' ? 1 : 0;
    }
    else {
      $GLOBAL['media']['data'][key] = value;
    }
  }
}

/**
 * FUNCTION: media_data_get(key)
 *
 * RETURNS: mixed
 *
 * Get a `data` value of the current loaded media.
 */
function media_data_get(key) {
  if(typeof $GLOBAL.media['data'] == "object" && typeof $GLOBAL.media['data'][key] != "undefined") {
    return $GLOBAL.media['data'][key];
  }
  else {
    return null;
  }
}

/**
 * FUNCTION: media_load(id)
 *
 * RETURNS: void
 *
 * Load a media into the main admin area. Populates the formular elements after
 * this.
 */
function media_load(id) {

  mainAdminArea_load_page("./media/" + id, function() {
  
    $("#upload_media_object_elem").fileupload({
      dataType: "json",
      done: function(e, data) {
        console.log("Done uploading files...");
        console.log(data);
        $GLOBAL.registry.byId("upload_media_object").hide();

        var parent_page = mediaTree_get_selected();
        var new_id = $GLOBAL.mediaTree.jstree("create_node", parent_page.id, data.result[0], "last");
        console.log("new id:" + new_id);
        //$GLOBAL.mediaTree.jstree("deselect_all", true);
        //$GLOBAL.mediaTree.jstree("select_node", new_id);
      },
      progressall: function(e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        console.log("progress: " + progress + "%");
      }
    });

    $GLOBAL.request.get("media/" + id, 
          {
            "headers": {
              "Accept": "application/json"
            },
            "handleAs": "json"
          }
        ).then(function(data) {
          $GLOBAL['media'] = data;

          $GLOBAL.dom.byId("media_url").value = decodeURIComponent(data['url']);

          fill_form_elements(data, function(elem, value) {

            var skip_itm = new Array("content", "site_id", "keywords", "id", "m_date", "c_date", "active", "data", "navigation",
              "level", "lft", "type", "hidden", "rgt", "rel_date", "lock_date");

            var form_itms = new Array("name", "description", "title");

            var dropdown_itms = new Array("type");

            var editor_itms = new Array("content");
            
            var checkbox_itms = new Array("hidden", "navigation");
            
            var date_itms = new Array("rel_date", "lock_date");

            if(form_itms.contains(elem)) {
              $GLOBAL.dom.byId("media_" + elem).value = value;
            }

            if(dropdown_itms.contains(elem)) {
              $GLOBAL.dom.byId("media_" + elem).value = value;
            }

            if(editor_itms.contains(elem)) {
              console.log("value: " + value);
              if($GLOBAL.registry.byId("media_" + elem)) {
                $GLOBAL.registry.byId("media_" + elem).set("value", value || "");
              }
            }
            
            if(checkbox_itms.contains(elem)) {
              $GLOBAL.registry.byId("media_" + elem).set("checked", value === 1 ? true : false);
            }
            
            if(date_itms.contains(elem)) {
              if(value) {
                var elem_date = elem === "rel_date" ? "rel" : "lock";
                console.log(">> " + value);
                var val_date = value.split(/T/)[0];
                var val_time = value.split(/T/)[1].split(/:/);
                console.log(">> " + val_date);
                console.log(">> " + val_time);
                
                $GLOBAL.registry.byId("media_" + elem_date + "_date").set("value", val_date);
                $GLOBAL.registry.byId("media_" + elem_date + "_time").set("value", new Date(0, 0, 0, val_time[0], val_time[1], val_time[2]));
              }
            }

            if(elem == "data" && typeof window['onmedia_data_load'] != "undefined" && data["data"]) {
              if(typeof data["data"] == "object") {
                onmedia_data_load(data.data);
              }
            }

          })
        });  
  });

}

/**
 * FUNCTION: media_delete(current_media)
 *
 * RETURNS: void
 *
 * Delete the media given by `current_media`. `current_media` if a media object.
 * This object must contain the key `id`.
 */
function media_delete(current_media) {
  $GLOBAL.request.del("media/" + current_media.id, {
    timeout: 2000,
    headers: {
      "Accept": "application/json"
    },
  }).then(function() {
    console.log("media deleted.");
    var parent_node = $GLOBAL.mediaTree.jstree("get_parent", current_media.id);
    $GLOBAL.mediaTree.jstree("delete_node", current_media.id);

    $GLOBAL.mediaTree.jstree("deselect_all", true);
    $GLOBAL.mediaTree.jstree("select_node", parent_node);
  });
}

/**
 * FUNCTION: media_new(parent_media, new_media)
 *
 * RETURNS: void
 *
 * Create a new media under `parent_media`. `parent_media` and `new_media` are
 * objects. `parent_media` must contain the key `id`. `new_media` must at least
 * contain `name`.
 */
function media_new(parent_media, new_media) {
  new_media['__utf8_check__'] = decodeURIComponent('%C3%96');
  $GLOBAL.request.post("media/" + parent_media.id, {
    data: $GLOBAL.json.stringify(new_media),
    timeout: 2000,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    },
    handleAs: "json"
  }).then(function(data) {
    console.log("media created.");
    console.log(data);
    var new_id = $GLOBAL.mediaTree.jstree("create_node", parent_media.id, data, "last");
    $GLOBAL.mediaTree.jstree("deselect_all", true);
    $GLOBAL.mediaTree.jstree("select_node", new_id);
  });
}

/**
 * FUNCTION: media_save
 *
 * RETURNS: void
 *
 * Saves a media given by `current_media` and `data`. `current_media` must be a 
 * object with at least the key `id`. `data` can contain any fields that needs
 * to be updated.
 */
function media_save(current_media, data) {
  data['__utf8_check__'] = decodeURIComponent('%C3%96');
  $GLOBAL.request.put("media/" + current_media.id, {
    data: $GLOBAL.json.stringify(data),
    timeout: 2000,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    }
  }).then(function() {
    alert("saved!");
    if(current_media['text'] != data['name']) {
      current_media['text'] = data['name'];
    }
    $GLOBAL.mediaTree.jstree("refresh_node", current_media.id);
  });

}
