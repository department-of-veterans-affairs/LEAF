/**
 * API for LEAF Request Portal
 */
function LEAFRequestPortalAPI() {
    this.baseURL = '/LEAF_Request_Portal/api/?a=';

    this.Forms = new PortalFormsAPI(this.baseURL);
}

/**
 * API for working with Forms
 *
 * @param baseAPIURL 
 */
function PortalFormsAPI(baseAPIURL) {
    this.apiBaseURL = baseAPIURL;
    this.apiURL = this.apiBaseURL + 'form';
}

/**
 * Query a form using the Report Builder JSON syntax
 *
 * @param query     object              the JSON query object
 * @param onSuccess function(results)   callback containing the results object
 * @param onFail    function(error)     callback when query fails
 */
PortalFormsAPI.prototype.query = function (query, onSuccess, onFail) {
    var fetchURL = this.apiURL + '/query/&q=' + JSON.stringify(query);

    $.ajax({
        method: 'GET',
        url: fetchURL,
        dataType: 'json'
    })
        .done(function (msg) {
            onSuccess(msg);
        })
        .fail(function (err) {
            onFail(err);
        });
    // .always(function() {});
}