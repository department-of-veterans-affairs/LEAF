/*
 * API for LEAF Nexux
 */

 function LEAFNexusAPI() {
     this.baseURL = '/LEAF_Nexus/api/?a=';

     this.Groups = new NexusGroupsAPI(this.baseURL);
 }

 function NexusGroupsAPI(baseAPIURL) {
     this.apiBaseURL = baseAPIURL;
     this.apiURL = this.apiBaseURL + 'group';
 }

 /**
  * Search a Group for all its Users and return detailed information about them.
  * 
  * @param groupID      int                 The groupID to search
  * @param searchText   string              Searches the users by first/last name, if empty/null returns all users in that group 
  * @param limit        int                 the number of users to return
  * @param offset       int                 the number of users to offset in the query
  * @param onSuccess    function(coaches)   the callback containing all fetched users 
  * @param onFail       function(error)     callback when query fails
  */
NexusGroupsAPI.prototype.searchGroup = function(groupID, searchText, limit, offset, onSuccess, onFail) {
    var fetchURL = this.apiURL + "/" + groupID + "/employees/detailed";
    if (limit !== -1) {
        fetchURL += "&limit=" + limit;
    }
    
    if (offset > 0) {
        fetchURL += "&offset=" + offset;
    }

    if (searchText.length > 0) {
        fetchURL += "&search=" + searchText;
    }

    $.ajax({
        method: 'GET',
        url: fetchURL,
        dataType: 'json'
    })
    .done(function(msg) {
        onSuccess(msg);
    })
    .fail(function(err) {
        onFail(err);
    });
    // .always(function() {});
};
