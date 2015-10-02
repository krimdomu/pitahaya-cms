/******************************************************************************/
// Tree functions
/******************************************************************************/

/**
 * FUNCTION: pageTree_get_selected()
 *
 * RETURNS: Object
 *
 * Returns the selected tree object.
 *
 * var current_page = pageTree_get_selected();
 * console.log("current page id:" + current_page.id);
 */
function pageTree_get_selected() {
  return $GLOBAL.pageTree.jstree('get_selected', true)[0];
}


/**
 * FUNCTION: mediaTree_get_selected()
 *
 * RETURNS: Object
 *
 * Returns the selected media tree object.
 *
 * var current_media = mediaTree_get_selected();
 * console.log("current media id:" + current_media.id);
 */
function mediaTree_get_selected() {
  return $GLOBAL.mediaTree.jstree('get_selected', true)[0];
}


/**
 * FUNCTION: userTree_get_selected()
 *
 * RETURNS: Object
 *
 * Returns the selected tree object.
 *
 * var current_user = userTree_get_selected();
 * console.log("current user id:" + current_user.id);
 */
function userTree_get_selected() {
  return $GLOBAL.userTree.jstree('get_selected', true)[0];
}

/******************************************************************************/
// Admin-Area functions
/******************************************************************************/

/**
 * FUNCTION: mainAdminArea_load_page(url, cb)
 *
 * RETURNS: void
 *
 * Load `something` in the main admin area. Calls given callback (cb) after
 * loading.
 */
function mainAdminArea_load_page(url, cb) {
  var unhandle = $GLOBAL.on($GLOBAL.registry.byId('main_admin_area'), "Unload", function(evt) {
    unhandle.remove();

    if(typeof window["onpage_unload"] != "undefined" && window["onpage_unload"]) {
      onpage_unload();
    }

    if(typeof window["onpage_data_unload"] != "undefined" && window["onpage_data_unload"]) {
      onpage_data_unload();
    }
  });

  var handle = $GLOBAL.on($GLOBAL.registry.byId('main_admin_area'), "Load", function(evt) {
    handle.remove();
    cb();
  });

  $GLOBAL.registry.byId('main_admin_area').set('href', url);
}


/**
 * FUNCTION: treeAdminArea_load_page(url, cb)
 *
 * RETURNS: void
 *
 * Load `something` in the tree admin area. Calls given callback (cb) after
 * loading.
 */
function treeAdminArea_load_page(url, cb) {
  var unhandle = $GLOBAL.on($GLOBAL.registry.byId('leftCol'), "Unload", function(evt) {
    unhandle.remove();
    if(typeof window["ontree_unload"] != "undefined") {
      ontree_unload();
    }
  });

  var handle = $GLOBAL.on($GLOBAL.registry.byId('leftCol'), "Load", function(evt) {
    handle.remove();
    cb();
  });

  $GLOBAL.registry.byId('leftCol').set('href', url);
}

/**
 * FUNCTION: logout()
 *
 * RETURNS: void
 *
 * Remove the session cookie and redirect to login page.
 */
function logout() {
  $GLOBAL.cookie("mojolicious", "", {"expires": -1});
  document.location.href = "/admin/login";
}


/**
 * FUNCTION: dialog_select_PageOrMedia()
 *
 * RETURNS: void
 *
 * Display a dialog to select a page or media.
 */
var selected_thing;
function dialog_select_PageOrMedia(cb) {

  $GLOBAL.dialog.select_page_or_media.onExecute = function() {
    cb(selected_thing);
    $GLOBAL.dialog.select_page_or_media.hide();
  };

  $GLOBAL.dialog.select_page_or_media.show().then(function() {
  
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

        var xpath = data.instance.get_path(item, "/", true).split("/");
        xpath.shift();

        var url = new Array();
        for( var p in xpath ) {
          if(xpath.hasOwnProperty(p)) {
            var item_data = data.instance.get_node(xpath[p]).data;
            url.push(item_data.url);
          }
        }

        selected_thing = "/" + url.join("/") + ".html";
        //document.getElementById($GLOBAL['page_select_dialog_field']).value = "/" + url.join("/") + ".html";
      });

    }


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

        var xpath = data.instance.get_path(item, "/", true).split("/");
        xpath.shift();

        var url = new Array();
        for( var p in xpath ) {
          if(xpath.hasOwnProperty(p)) {
            var item_data = data.instance.get_node(xpath[p]).data;
            url.push(item_data.url);
          }
        }

        selected_thing = "/media/" + url.join("/");
        //document.getElementById($GLOBAL['page_select_dialog_field']).value = "/media/" + url.join("/");
      });

    }

  });

  document.getElementById("select_PageOrMedia").style.zIndex = 100000;
}

/**
 * FUNCTION: desktop_action()
 *
 * RETURNS: void
 *
 * Calls a desktop action
 */
function desktop_action(action) {
  $GLOBAL.request.get("desktop/" + action, 
      {
        "headers": {
          "Accept": "application/json"
        },
        "handleAs": "json"
      }
    ).then(function(data) {
      if(data['ok']) {
        $.notify("Action successfully triggert.", "success");
        return;
      }
      
      $.notify("Failed triggering action.", "error");
    });

}





