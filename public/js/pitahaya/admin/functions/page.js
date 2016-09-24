/******************************************************************************/
// Page functions
/******************************************************************************/

/**
 * FUNCTION: page_load_view()
 *
 * RETURNS: void
 *
 * Load the admin inteface for pages.
 */
function page_load_view() {

  $GLOBAL['view'] = "page";

  treeAdminArea_load_page("./page/view/tree", function() {
    console.log("page tree loaded...");
    page_initialize_trees();
  });

  mainAdminArea_load_page("./page/view/desktop", function() {
    console.log("page desktop loaded...");
  });

}

/**
 * FUNCTION: page_initialize_trees()
 *
 * RETURNS: void
 *
 * Initialize and loads the trees for page admin view.
 */
function page_initialize_trees() {
  $GLOBAL['pageTree'] = $('#pageTree').jstree({
    core: {
      check_callback: function(operation, node, node_parent, node_pos, more) {
        if(node_parent.id === '#') {
          return false;
        }
        return true;
      },
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
    },
    plugins: ["dnd"]
  });

  $GLOBAL.pageTree.on("changed.jstree", function(e, data) {
    var item = data.instance.get_node(data.selected[0]);
    page_load(item.id);
  });

  $GLOBAL.pageTree.on("move_node.jstree", function(e, data) {
    console.log("moved node: " + data.node.text + " to: " + data.parent + " -> pos: " + data.position );

    $GLOBAL.request.put("./page/tree/" + data.node.id + "/move/" + data.parent + "/" + data.position, {
      "headers": {
        "Accept": "application/json",
      },
      handleAs: "json"
    }).then(function(data) {
      console.log("moved...");
      console.log(data);
    });
  });


  $GLOBAL['mediaTree'] = $('#mediaTree').jstree({
    core: {
      check_callback: function(operation, node, node_parent, node_pos, more) {
        if(node_parent.id === '#') {
          return false;
        }
        return true;
      },
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
    },
    plugins: ["dnd"]
  });

  $GLOBAL.mediaTree.on("changed.jstree", function(e, data) {
    var item = data.instance.get_node(data.selected[0]);
    media_load(item.id);
  });


  $GLOBAL.mediaTree.on("move_node.jstree", function(e, data) {
    console.log("moved node: " + data.node.text + " to: " + data.parent + " -> pos: " + data.position );

    $GLOBAL.request.put("./media/tree/" + data.node.id + "/move/" + data.parent + "/" + data.position, {
      "headers": {
        "Accept": "application/json",
      },
      handleAs: "json"
    }).then(function(data) {
      console.log("moved...");
      console.log(data);
    });
  });

}

/**
 * FUNCTION: page_set(key, value, options)
 *
 * RETURNS: void
 *
 * Set a field for the current loaded page.
 */
function page_set(key, value, opts) {
  console.log("setting page info: " + key + " -> " + value);

  if(typeof $GLOBAL['page'] == "object" && $GLOBAL['page'] != null) {
    if(typeof opts == "object" && typeof opts['is_bool'] != "undefined" && opts['is_bool']) {
      $GLOBAL['page'][key] = value === 'on' ? 1 : 0;
    }
    else {
      $GLOBAL['page'][key] = value;
    }
  }
  else {
    console.log("No page selected...");
  }
}

/**
 * FUNCTION: page_get(key)
 *
 * RETURNS: mixed
 *
 * Get a field of the current loaded page.
 */
function page_get(key) {
  if(typeof $GLOBAL['page'] == "object" && typeof $GLOBAL['page'][key] != "undefined") {
    return $GLOBAL['page'][key];
  }
  else {
    return null;
  }
}

/**
 * FUNCTION: page_data_set(key, value, options)
 *
 * RETURNS: void
 *
 * Set a `data` value for current loaded page.
 */
function page_data_set(key, value, opts) {
  console.log("setting page data: " + key + " -> " + value);
  if(typeof $GLOBAL['page']['data'] == "object" && $GLOBAL['page']['data'] != null) {
    if(typeof opts == "object" && typeof opts['is_bool'] != "undefined" && opts['is_bool']) {
      $GLOBAL['page']['data'][key] = value === 'on' ? 1 : 0;
    }
    else {
      $GLOBAL['page']['data'][key] = value;
    }
  }
  else {
    $GLOBAL['page']['data'] = {};
    if(typeof opts == "object" && typeof opts['is_bool'] != "undefined" && opts['is_bool']) {
      $GLOBAL['page']['data'][key] = value === 'on' ? 1 : 0;
    }
    else {
      $GLOBAL['page']['data'][key] = value;
    }
  }
}

/**
 * FUNCTION: page_data_get(key)
 *
 * RETURNS: mixed
 *
 * Get a `data` value of the current loaded page.
 */
function page_data_get(key) {
	  console.log("page_data_get: " + typeof $GLOBAL.page);
	  console.log($GLOBAL);
	  
  if($GLOBAL.page['data'] != null && typeof $GLOBAL.page['data'] == "object" && typeof $GLOBAL.page['data'][key] != "undefined") {
    return $GLOBAL.page['data'][key];
  }
  else {
    return null;
  }
}

/**
 * FUNCTION: page_load(id)
 *
 * RETURNS: void
 *
 * Load a page into the main admin area. Populates the formular elements after
 * this.
 */
function page_load(id) {

  // cleanup editor trees
  delete $GLOBAL['linkPageTree'];
  delete $GLOBAL['imgMediaTree'];

  // cleanup previously loaded functions
  window['onpage_data_load'] = null;
  window['onpage_data_unload'] = null;
  window['onpage_data_save'] = null;
  window['onpage_save'] = null;
  window['onpage_load'] = null;
  window['onpage_unload'] = null;

  mainAdminArea_load_page("./page/" + id, function() {
  
    $GLOBAL.request.get("page/" + id, 
          {
            "headers": {
              "Accept": "application/json"
            },
            "handleAs": "json"
          }
        ).then(function(data) {
          $GLOBAL['page'] = data;

          $GLOBAL.dom.byId("page_url").value = decodeURIComponent(data['url']);

          fill_form_elements(data, function(elem, value) {

            var skip_itm = new Array("content", "site_id", "keywords", "id", "m_date", "c_date", "active", "data", "navigation",
              "level", "lft", "type", "hidden", "rgt", "rel_date", "lock_date");

            var form_itms = new Array("name", "description", "title");

            var dropdown_itms = new Array("type");

            var editor_itms = new Array();
            
            var checkbox_itms = new Array("hidden", "navigation", "active");
            
            var date_itms = new Array("rel_date", "lock_date");

            if(form_itms.contains(elem)) {
              $GLOBAL.dom.byId("page_" + elem).value = value;
            }

            if(dropdown_itms.contains(elem)) {
              $GLOBAL.dom.byId("page_" + elem).value = value;
            }

            if(editor_itms.contains(elem)) {
              $GLOBAL.registry.byId("page_" + elem).set("value", value || "");
            }
            
            if(checkbox_itms.contains(elem)) {
              $GLOBAL.registry.byId("page_" + elem).set("checked", value === 1 ? true : false);
            }
            
            if(date_itms.contains(elem)) {
              if(value) {
                var elem_date = elem === "rel_date" ? "rel" : "lock";
                console.log(">> " + value);
                var val_date = value.split(/T/)[0];
                var val_time = value.split(/T/)[1].split(/:/);
                console.log(">> " + val_date);
                console.log(">> " + val_time);
                
                $GLOBAL.registry.byId("page_" + elem_date + "_date").set("value", val_date);
                $GLOBAL.registry.byId("page_" + elem_date + "_time").set("value", new Date(0, 0, 0, val_time[0], val_time[1], val_time[2]));
              }
            }

          });

          if(typeof window['onpage_load'] != "undefined" && window['onpage_load']) {
            onpage_load(data);
          }

          if(typeof window['onpage_data_load'] != "undefined" && window['onpage_data_load']) {
            onpage_data_load(data["data"]);
          }
        });  
  });

}

/**
 * FUNCTION: page_delete(current_page)
 *
 * RETURNS: void
 *
 * Delete the page given by `current_page`. `current_page` if a page object.
 * This object must contain the key `id`.
 */
function page_delete(current_page) {
  $GLOBAL.request.del("page/" + current_page.id, {
    timeout: 2000,
    headers: {
      "Accept": "application/json"
    },
  }).then(function() {
    console.log("page deleted.");
    var parent_node = $GLOBAL.pageTree.jstree("get_parent", current_page.id);
    $GLOBAL.pageTree.jstree("delete_node", current_page.id);

    $GLOBAL.pageTree.jstree("deselect_all", true);
    $GLOBAL.pageTree.jstree("select_node", parent_node);
  });
}

/**
 * FUNCTION: page_new(parent_page, new_page)
 *
 * RETURNS: void
 *
 * Create a new page under `parent_page`. `parent_page` and `new_page` are
 * objects. `parent_page` must contain the key `id`. `new_page` must at least
 * contain `name`.
 */
function page_new(parent_page, new_page) {
  new_page['__utf8_check__'] = decodeURIComponent('%C3%96');
  $GLOBAL.request.post("page/" + parent_page.id, {
    data: $GLOBAL.json.stringify(new_page),
    timeout: 2000,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    },
    handleAs: "json"
  }).then(function(data) {
    console.log("page created.");
    console.log(data);
    var new_id = $GLOBAL.pageTree.jstree("create_node", parent_page.id, data, "last");
    $GLOBAL.pageTree.jstree("deselect_all", true);
    $GLOBAL.pageTree.jstree("select_node", new_id);
  });
}

/**
 * FUNCTION: page_save
 *
 * RETURNS: void
 *
 * Saves a page given by `current_page` and `data`. `current_page` must be a 
 * object with at least the key `id`. `data` can contain any fields that needs
 * to be updated.
 */
function page_save(current_page, data) {
  data['__utf8_check__'] = decodeURIComponent('%C3%96');
  $GLOBAL.request.put("page/" + current_page.id, {
    data: $GLOBAL.json.stringify(data),
    timeout: 2000,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    },
    handleAs: "json"
  }).then(function(new_data) {
    console.log(current_page);
    if(current_page['text'] != data['name']) {
      current_page['text'] = data['name'];
    }
    if(current_page['icon'] != new_data['icon']) {
      current_page['icon'] = new_data['icon'];
    }

    $GLOBAL.pageTree.jstree("refresh_node", current_page.id);

    $.notify("Page saved.", "success");
  });

}
