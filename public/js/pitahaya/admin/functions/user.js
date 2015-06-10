/******************************************************************************/
// User functions
/******************************************************************************/

/**
 * FUNCTION: user_load_view()
 *
 * RETURNS: void
 *
 * Load the admin inteface for user management.
 */
function user_load_view(cb) {

  $GLOBAL['view'] = "user";

  treeAdminArea_load_page("./user/view/tree", function() {
    console.log("user tree loaded...");
    user_initialize_trees();

    $GLOBAL.on($GLOBAL.registry.byId("dialog_new_user_ok"), "Click", function(evt) {
      var data = {};
      data['username'] = $GLOBAL.registry.byId("dialog_user_username").get("value");
      data['password'] = $GLOBAL.registry.byId("dialog_user_password").get("value");
      console.log("creating new user...");
      console.log(data);
      user_new(data);
    });

    if(cb) {
      window.setTimeout(function() { cb(); }, 300);
    }
  });

  mainAdminArea_load_page("./user/view/desktop", function() {
    console.log("user desktop loaded...");
  });

}

function user_initialize_trees() {
  $GLOBAL['userTree'] = $('#userTree').jstree({
    core: {
      check_callback: true,
      data: {
        url: function(node) {
          if(node.id === '#') {
            return "./user/tree";
          }
          else {
            return "./user/tree/children/" + node.id;
          }
        }
      }
    }
  });

  $GLOBAL.userTree.on("changed.jstree", function(e, data) {
    var item = data.instance.get_node(data.selected[0]);
    if(item.id != "root") {
      user_load(item.id);
    }
  });
}

/**
 * FUNCTION: user_load(id)
 *
 * RETURNS: void
 *
 * Load a user into the main admin area. Populates the formular elements after
 * this.
 */
function user_load(id) {

  mainAdminArea_load_page("./user/" + id, function() {
  
    $GLOBAL.request.get("./user/" + id, 
          {
            "headers": {
              "Accept": "application/json"
            },
            "handleAs": "json"
          }
        ).then(function(data) {
          $GLOBAL['user'] = data;
          console.log(data);
          $GLOBAL.dom.byId("user_username").value = data.username;
          $GLOBAL.dom.byId("user_email").value = data.email;
        });  
  });

}

/**
 * FUNCTION: user_delete(current_user)
 *
 * RETURNS: void
 *
 * Delete the current selected user.
 */
function user_delete(current_user) {
  $GLOBAL.request.del("./user/" + current_user.id, {
    timeout: 2000,
    headers: {
      "Accept": "application/json"
    },
  }).then(function() {
    console.log("user deleted.");
    var parent_node = $GLOBAL.userTree.jstree("get_parent", current_user.id);
    $GLOBAL.userTree.jstree("delete_node", current_user.id);

    $GLOBAL.userTree.jstree("deselect_all", true);
    $GLOBAL.userTree.jstree("select_node", parent_node);
  });
}

/**
 * FUNCTION: user_new(data)
 *
 * RETURNS: void
 *
 * Create a new user.
 */
function user_new(data) {

  data['__utf8_check__'] = decodeURIComponent('%C3%96');
  $GLOBAL.request.post("./user", {
    data: $GLOBAL.json.stringify(data),
    timeout: 2000,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    },
    handleAs: "json"
  }).then(function(data) {
    console.log("user created.");
    var new_id = $GLOBAL.userTree.jstree("create_node", "root", data, "last");
    $GLOBAL.userTree.jstree("deselect_all", true);
    $GLOBAL.userTree.jstree("select_node", new_id);
  });

}


/**
 * FUNCTION: user_save
 *
 * RETURNS: void
 *
 * Saves a user given by `current_user` and `data`. `current_user` must be a 
 * object with at least the key `id`. `data` can contain any fields that needs
 * to be updated.
 */
function user_save(current_user, data) {
  data['__utf8_check__'] = decodeURIComponent('%C3%96');
  console.log("saving user...");
  console.log(data);
  $GLOBAL.request.put("./user/" + current_user.id, {
    data: $GLOBAL.json.stringify(data),
    timeout: 2000,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    }
  }).then(function() {
    alert("saved!");
    if(current_user['text'] != data['username']) {
      current_user['text'] = data['username'];
    }
    $GLOBAL.userTree.jstree("refresh_node", current_user.id);
  });

}
