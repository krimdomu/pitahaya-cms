define(["../_base/xhr", "../_base/declare", "./util/QueryResults", "../request", "../json" /*=====, "./api/Store" =====*/],
function(xhr, declare, QueryResults, request, json /*=====, Store =====*/){

// module:
//		dojo/store/MemoryRest

// No base class, but for purposes of documentation, the base class is dojo/store/api/Store
var base = null;
/*===== base = Store; =====*/

return declare("dojo.store.MemoryRest", base, {
	// summary:
	//		This is a basic in-memory object store. It implements dojo/store/api/Store.
	constructor: function(options){
		// summary:
		//		Creates a memory object store.
		// options: dojo/store/MemoryRest
		//		This provides any configuration information that will be mixed into the store.
		//		This should generally include the data property to provide the starting set of data.
		for(var i in options){
			this[i] = options[i];
		}
		
		this['data'] = new Array();
	},
	// idProperty: String
	//		Indicates the property to use as the identity property. The values of this
	//		property should be unique.
	idProperty: "id",

	// index: Object
	//		An index of data indices into the data array by id
	index:null,

	get: function(id){
		// summary:
		//		Retrieves an object by its identity
		// id: Number
		//		The identity to use to lookup the object
		// returns: Object
		//		The object in the store that matches the given id.
	  console.log("(store) get: begin: ------------------------------------------------------------------");
			  var ret = xhr("GET", {
	    "url": this.page_url + id,
	    handleAs: "json",
	    headers: {
	      "Accept": "application/json"
	    }
	  });
	  console.log("(store) get: xhr returned: ------------------------------------------------------------------");
	  console.log(ret);

	  console.log("(store) get: end: ------------------------------------------------------------------");
	  return ret;
	},
	getIdentity: function(object){
		// summary:
		//		Returns an object's identity
		// object: Object
		//		The object to get the identity from
		// returns: Number
		return object[this.idProperty];
	},
	put: function(object, options){
		// summary:
		//		Stores an object
		// object: Object
		//		The object to store.
		// options: dojo/store/api/Store.PutDirectives?
		//		Additional metadata for storing the data.  Includes an "id"
		//		property if a specific id is to be used.
		// returns: Number
		
	  console.log("(store) put: begin: ------------------------------------------------------------------");
		console.log(object);
		console.log(options);

    var ret;
    if(options && options['overwrite']) {
      ret = request.post("page/" + object.parent, {
        data: json.stringify(object),
        timeout: 2000,
        headers: {
          "Content-Type": "application/json"
        },
        handleAs: "json"
      });
    }
    else {
      ret = request.put("page/" + object.id, {
        data: json.stringify(object),
        timeout: 2000,
        headers: {
          "Content-Type": "application/json"
        },
        handleAs: "json"
      });
    }

    ret.then(function(data) {
      console.log("(store) put: data: ");
      console.log(data);
      object['id'] = data['id'];
    });

	  console.log("(store) put: end: ------------------------------------------------------------------");
	},
	add: function(object, options){
		// summary:
		//		Creates an object, throws an error if the object already exists
		// object: Object
		//		The object to store.
		// options: dojo/store/api/Store.PutDirectives?
		//		Additional metadata for storing the data.  Includes an "id"
		//		property if a specific id is to be used.
		// returns: Number
		(options = options || {}).overwrite = false;
		// call put with overwrite being false
		return this.put(object, options);
	},
	remove: function(id){
		// summary:
		//		Deletes an object by its identity
		// id: Number
		//		The identity to use to delete the object
		// returns: Boolean
		//		Returns true if an object was removed, falsy (undefined) if no object matched the id
	  return true;
	},
	query: function(query, options){
	  console.log("(store) query: begin: ------------------------------------------------------------------");
	  console.log(query);
	  console.log(options);
	  
	  var url = (query['is_root'] && query['is_root'] == true ? this.root_url : this.children_url + query['parent'] );
	  console.log("querying: " + url);

	  
	  var ret = xhr("GET", {
	    "url": url,
	    handleAs: "json",
	    headers: {
	      "Accept": "application/json"
	    }
	  });
	  console.log("(store) query: got:");
	  console.log(ret);
	  console.log("(store) query: end: ------------------------------------------------------------------");

	  return QueryResults(ret);
	}
});

});
