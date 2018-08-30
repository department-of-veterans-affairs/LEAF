/**
 * API for LEAF Request Portal
 */
var LEAFRequestPortalAPI = function () {
    var baseURL = './api/?a=',
        Forms = PortalFormsAPI(baseURL),
        FormEditor = PortalFormEditorAPI(baseURL),
        Import = PortalImportAPI(baseURL),
        Signature = PortalSignaturesAPI(baseURL),
        System = PortalSystemAPI(baseURL),
        Workflow = PortalWorkflowAPI(baseURL),

        // used for POST requests
        csrfToken = '',

        /**
         * Get the base URL for the LEAF Portal API (e.g. "/LEAF_Request_Portal/api/?a=")
         * 
         * @return string   the base LEAF Portal API URL
         */
        getBaseURL = function () {
            return baseURL;
        },

        /**
         * Set the base URL for the LEAF Portal API (e.g. "/LEAF_Request_Portal/api/?a=")
         * 
         * @param baseURL   string  base URL
         */
        setBaseURL = function (urlBase) {
            baseURL = urlBase;
            Forms.setBaseAPIURL(baseURL);
            FormEditor.setBaseAPIURL(baseURL);
            Import.setBaseAPIURL(baseURL);
            Signature.setBaseAPIURL(baseURL);
            System.setBaseAPIURL(baseURL);
            Workflow.setBaseAPIURL(baseURL);
        },

        setCSRFToken = function (token) {
            csrfToken = token;
            Forms.setCSRFToken(token);
            FormEditor.setCSRFToken(token);
            Import.setCSRFToken(token);
            Signature.setCSRFToken(token);
            System.setCSRFToken(token);
            Workflow.setCSRFToken(token);
        };

    return {
        getBaseURL: getBaseURL,
        setBaseURL: setBaseURL,
        setCSRFToken: setCSRFToken,

        Forms: Forms,
        FormEditor: FormEditor,
        Import: Import,
        Signature: Signature,
        System: System,
        Workflow: Workflow
    };
};

/**
 * API for working with Forms
 *
 * @param baseAPIURL    string the base URL for the LEAF Portal API (e.g. "/LEAF_Request_Portal/api/?a=") 
 */
var PortalFormsAPI = function (baseAPIURL) {
    var apiBaseURL = baseAPIURL,
        apiURL = baseAPIURL + 'form',

        // used for POST requests
        csrfToken = '',

        /**
         * Get the URL for the LEAF Portal Forms API
         */
        getAPIURL = function () {
            return apiURL;
        },

        /**
         * Get the base URL for the LEAF Portal API
         * 
         * @return string   the base LEAF Portal API URL used in this Forms API
         */
        getBaseAPIURL = function () {
            return apiBaseURL;
        },

        /**
         * Set the base URL for the LEAF Portal API
         * 
         * @param baseAPIURL string the base URL for the Portal API
         */
        setBaseAPIURL = function (baseAPIURL) {
            apiBaseURL = baseAPIURL;
            apiURL = baseAPIURL + 'form';
        },

        getAllForms = function (onSuccess, onFail) {
            var fetchURL = apiURL + '/categories';

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: 'json'
            })
                .done(onSuccess)
                .fail(onFail);
            // .always(function() {});
        },

        /**
         * Get all indicators for the specifed form
         * 
         * @param formID    string              the form (category) ID
         * @param onSuccess function(results)   callback containing the results object
         * @param onFail    function(error)     callback when action fails
         */
        getIndicatorsForForm = function (formID, onSuccess, onFail) {
            var fetchURL = apiURL + '/category&id=' + formID;

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: 'json'
            })
                .done(onSuccess)
                .fail(onFail);
            // .always(function() {});
        },

        modifyRequest = function (recordID, requestData, onSuccess, onFail) {
            var postURL = apiURL + '/' + recordID;
            requestData['CSRFToken'] = csrfToken;

            $.ajax({
                method: 'POST',
                url: postURL,
                data: requestData,
                dataType: 'json'
            })
                .done(onSuccess)
                .fail(onFail);
            // .always(function() {});
        },

        newRequest = function (formID, requestData, onSuccess, onFail) {
            var postURL = apiURL + '/new';

            var postData = {};
            postData['CSRFToken'] = csrfToken;
            postData['num' + formID] = 1;
            postData['title'] = requestData.title;

            $.ajax({
                method: 'POST',
                url: postURL,
                data: postData,
                dataType: 'json'
            })
                .done(function (recordID) {
                    // title must be removed in order to process the rest of the indicator data
                    delete requestData.title;
                    modifyRequest(recordID, requestData, onSuccess, onFail);
                })
                .fail(onFail);
            // .always(function() {});
        },

        /**
         * Query a form using the Report Builder JSON syntax
         *
         * @param query     object              the JSON query object
         * @param onSuccess function(results)   callback containing the results object
         * @param onFail    function(error)     callback when query fails
         */
        query = function (query, onSuccess, onFail) {
            var fetchURL = apiURL + '/query/&q=' + JSON.stringify(query);

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
        },

        /**
         * Set the CSRFToken for POST requests
         */
        setCSRFToken = function (token) {
            csrfToken = token;
        };

    return {
        getAPIURL: getAPIURL,
        getAllForms: getAllForms,
        getBaseAPIURL: getBaseAPIURL,
        getIndicatorsForForm: getIndicatorsForForm,
        newRequest: newRequest,
        setBaseAPIURL: setBaseAPIURL,
        setCSRFToken: setCSRFToken,
        query: query
    };
};

var PortalFormEditorAPI = function (baseAPIURL) {
    var apiBaseURL = baseAPIURL,
        apiURL = baseAPIURL + 'formEditor',

        // used for POST requests
        csrfToken = '',

        /**
         * Get the URL for the LEAF Portal FormEditor API
         */
        getAPIURL = function () {
            return apiURL;
        },

        /**
         * Get the base URL for the LEAF Portal API
         * 
         * @return string   the base LEAF Portal API URL used in this FormEditor API
         */
        getBaseAPIURL = function () {
            return apiBaseURL;
        },

        /**
         * Set the base URL for the LEAF Portal API
         * 
         * @param baseAPIURL string the base URL for the Portal API
         */
        setBaseAPIURL = function (baseAPIURL) {
            apiBaseURL = baseAPIURL;
            apiURL = baseAPIURL + 'formEditor';
        },

        /**
         * Set the CSRFToken for POST requests
         */
        setCSRFToken = function (token) {
            csrfToken = token;
        },

        /**
         * Get information about the given indicator
         * 
         * @param indicatorID   int                 the id of the indicator
         * @param onSuccess     function(result)    callback containing indicator info
         * @param onFail        function(error)     callback when action fails
         */
        getIndicator = function (indicatorID, onSuccess, onFail) {
            var fetchURL = apiURL + '/indicator/' + indicatorID;

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
        },

        /**
         * Get the access privileges for the given indicator
         * 
         * @param indicatorID   int                     the id of the indicator to retrieve privileges for
         * @param onSuccess     function(array[int])    callback containing an array of group IDs
         * @param onFail        function(err)           callback when action fails
         */
        getIndicatorPrivileges = function (indicatorID, onSuccess, onFail) {
            var fetchURL = apiURL + '/indicator/' + indicatorID + '/privileges';

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
        },

        /**
         * Remove access privilege for the given indicator and group
         * 
         * @param indicatorID   int                 the id of the indicator to remove access for
         * @param groupID       int                 the id of the group to remove access for
         * @param onSuccess     function(success)   callback containing true/false if action succeeded
         * @param onFail        function(err)       callback when action contains an error
         */
        removeIndicatorPrivilege = function (indicatorID, groupID, onSuccess, onFail) {
            var postURL = apiURL + '/indicator/' + indicatorID + '/privileges/remove';

            $.ajax({
                method: 'POST',
                url: postURL,
                dataType: "text",
                data: {
                    "groupID": groupID,
                    CSRFToken: csrfToken
                }
            })
                .done(function (msg) {
                    onSuccess(msg);
                })
                .fail(function (err) {
                    onFail(err);
                });
        },

        /**
         * Set the access privileges for the given indicator
         * 
         * @param indicatorID   int                 the id of the indicator to set privileges for
         * @param groupIDs      array[int]          an array containing the IDs of the groups that should have access
         * @param onSuccess     function(success)   callback containing true/false if action succeeded
         * @param onFail        function(err)       callback when action fails
         */
        setIndicatorPrivileges = function (indicatorID, groupIDs, onSuccess, onFail) {

            $.ajax({
                method: 'POST',
                url: apiURL + '/indicator/' + indicatorID + '/privileges',
                dataType: "text",
                data: {
                    "groupIDs": groupIDs,
                    CSRFToken: csrfToken
                }
            })
                .done(function (msg) {
                    onSuccess(msg);
                })
                .fail(function (err) {
                    onFail(err);
                });
        };

    return {
        getAPIURL: getAPIURL,
        getBaseAPIURL: getBaseAPIURL,
        getIndicator: getIndicator,
        getIndicatorPrivileges: getIndicatorPrivileges,
        setBaseAPIURL: setBaseAPIURL,
        setCSRFToken: setCSRFToken,
        removeIndicatorPrivilege: removeIndicatorPrivilege,
        setIndicatorPrivileges: setIndicatorPrivileges
    };
};

var PortalImportAPI = function (baseAPIURL) {
    var apiBaseURL = baseAPIURL,
        apiURL = baseAPIURL + 'import',

        // used for POST requests
        csrfToken = '',

        /**
         * Get the URL for the LEAF Portal Signatures API
         */
        getAPIURL = function () { return apiURL; },

        /**
         * Get the base URL for the LEAF Portal API
         * 
         * @return string   the base LEAF Portal API URL used in this Forms API
         */
        getBaseAPIURL = function () { return apiBaseURL; },

        /**
         * Set the base URL for the LEAF Portal API
         * 
         * @param baseAPIURL string the base URL for the Portal API
         */
        setBaseAPIURL = function (baseAPIURL) {
            apiBaseURL = baseAPIURL;
            apiURL = baseAPIURL + 'import';
        },

        /**
         * Set the CSRFToken for POST requests
         */
        setCSRFToken = function (token) { csrfToken = token; },

        /**
         * Get a JSON object that represents the data present in an Excel 
         * Spreadsheet. The file must be uploaded through the Admin Panel
         * File Manager first.
         * 
         * @param fileName      string              the name of the file
         * @param hasHeaders    bool                If the first for of the xls is column headers 
         * @param onSuccess     function(result)    callback when operation succeeds
         * @param onFail        function(error)     callback when operation fails
         */
        parseXLS = function(fileName, hasHeaders, onSuccess, onFail) {
            var fetchURL = apiURL + '/xls&importFile=' + fileName + '&hasHeaders=' + (hasHeaders === true ? 1 : 0);

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: "json"
            })
                .done(onSuccess)
                .fail(onFail);
                // .always(function () {});
        };

    return {
        getAPIURL: getAPIURL,
        getBaseAPIURL: getBaseAPIURL,
        parseXLS: parseXLS,
        setBaseAPIURL: setBaseAPIURL,
        setCSRFToken: setCSRFToken,
    };
};

var PortalSignaturesAPI = function (baseAPIURL) {
    var apiBaseURL = baseAPIURL,
        apiURL = baseAPIURL + 'signature',

        // used for POST requests
        csrfToken = '',

        /**
         * Get the URL for the LEAF Portal Signatures API
         */
        getAPIURL = function () {
            return apiURL;
        },

        /**
         * Get the base URL for the LEAF Portal API
         * 
         * @return string   the base LEAF Portal API URL used in this Forms API
         */
        getBaseAPIURL = function () {
            return apiBaseURL;
        },

        /**
         * Set the base URL for the LEAF Portal API
         * 
         * @param baseAPIURL string the base URL for the Portal API
         */
        setBaseAPIURL = function (baseAPIURL) {
            apiBaseURL = baseAPIURL;
            apiURL = baseAPIURL + 'signature';
        },

        /**
         * Set the CSRFToken for POST requests
         */
        setCSRFToken = function (token) {
            csrfToken = token;
        },

        /**
         * Create a signature
         * 
         * @param signature string          the signature footprint
         * @param recordID  int             the id of the Record the Signature is associated with
         * @param message   string          the message that was signed
         * @param onSuccess function(id)    callback containing the id of the new signature
         * @param onFail    function(err)   callback when operation fails
         */
        create = function (signature, recordID, message, onSuccess, onFail) {
            $.ajax({
                method: 'POST',
                url: apiURL + '/create',
                dataType: "text",
                data: {
                    "signature": signature,
                    "recordID": recordID,
                    "message": message,
                    CSRFToken: csrfToken
                }
            })
                .done(function (msg) {
                    onSuccess(msg);
                })
                .fail(function (err) {
                    onFail(err);
                });

        };

    return {
        getAPIURL: getAPIURL,
        getBaseAPIURL: getBaseAPIURL,
        setBaseAPIURL: setBaseAPIURL,
        setCSRFToken: setCSRFToken,
        create: create
    };
};

/**
 * API for working with System functions
 * 
 * @param baseAPIURL    string  the base URL for the LEAF Portal API (e.g. "/LEAF_Request_Portal/api/?a=")
 */
var PortalSystemAPI = function (baseAPIURL) {
    var apiBaseURL = baseAPIURL,
        apiURL = baseAPIURL + 'system',

        // used for POST requests
        csrfToken = '',

        /**
         * Get the URL for the LEAF Portal Workflow API
         */
        getAPIURL = function () { return apiURL; },

        /**
         * Get the base URL for the LEAF Portal API
         * 
         * @return string   the base LEAF Portal API URL used in this Forms API
         */
        getBaseAPIURL = function () { return apiBaseURL; },

        /**
         * Set the base URL for the LEAF Portal API
         * 
         * @param baseAPIURL string the base URL for the Portal API
         */
        setBaseAPIURL = function (baseAPIURL) {
            apiBaseURL = baseAPIURL;
            apiURL = baseAPIURL + 'system';
        },

        setCSRFToken = function (token) { csrfToken = token; },

        /**
         * Get the list of files that have been uploaded through the admin panel File Manager
         * 
         * @param onSuccess function(result)    callback when operation succeeds
         * @param onFail    function(error)     callback when operation fails
         */
        getFileList = function (onSuccess, onFail) {
            $.ajax({
                method: 'GET',
                url: apiURL + '/files',
                dataType: "json"
            })
                .done(onSuccess)
                .fail(onFail);
                // .always(function () {});
        };

    return {
        getAPIURL: getAPIURL,
        getBaseAPIURL: getBaseAPIURL,
        getFileList: getFileList,
        setBaseAPIURL: setBaseAPIURL,
        setCSRFToken: setCSRFToken,
    };
};

/**
 * API for working with Workflows
 * 
 * @param baseAPIURL string the base URL for the LEAF Portal API (e.g. "/LEAF_Request_Portal/api/?a=")
 */
var PortalWorkflowAPI = function (baseAPIURL) {
    var apiBaseURL = baseAPIURL,
        apiURL = baseAPIURL + 'workflow',

        // used for POST requests
        csrfToken = '',

        /**
         * Get the URL for the LEAF Portal Workflow API
         */
        getAPIURL = function () {
            return apiURL;
        },

        /**
         * Get the base URL for the LEAF Portal API
         * 
         * @return string   the base LEAF Portal API URL used in this Forms API
         */
        getBaseAPIURL = function () {
            return apiBaseURL;
        },

        /**
         * Set the base URL for the LEAF Portal API
         * 
         * @param baseAPIURL string the base URL for the Portal API
         */
        setBaseAPIURL = function (baseAPIURL) {
            apiBaseURL = baseAPIURL;
            apiURL = baseAPIURL + 'workflow';
        },

        setCSRFToken = function (token) {
            csrfToken = token;
        },

        /**
         * Set whether a Step in the specified Workflow requires a Digital Signature
         * 
         * @param workflowID            int                 the Workflow ID
         * @param stepID                int                 the Step ID
         * @param requiresSignature     boolean             whether a Digital Signature is required
         * @param onSuccess             function(result)    callback when operation succeeds
         * @param onFail                function(error)     callback when operation fails
         */
        setStepSignatureRequirement = function (workflowID, stepID, requiresSignature, onSuccess, onFail) {
            $.ajax({
                method: 'POST',
                url: apiURL + '/' + workflowID + '/step/' + stepID + '/requiresig',
                dataType: "text",
                data: { "requiresSig": requiresSignature, CSRFToken: csrfToken }
            })
                .done(function (msg) {
                    onSuccess(msg);
                })
                .fail(function (err) {
                    onFail(err);
                });
        };

    return {
        getAPIURL: getAPIURL,
        getBaseAPIURL: getBaseAPIURL,
        setBaseAPIURL: setBaseAPIURL,
        setCSRFToken: setCSRFToken,
        setStepSignatureRequirement: setStepSignatureRequirement
    };
};