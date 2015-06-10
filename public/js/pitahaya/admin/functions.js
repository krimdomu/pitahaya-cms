var $GLOBAL = {};

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

