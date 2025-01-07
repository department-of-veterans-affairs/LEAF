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
                dataType: 'json',
                cache: false
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
                dataType: 'json',
                cache: false
            })
                .done(onSuccess)
                .fail(onFail);
            // .always(function() {});
        },

        /**
         * Modify the given record with the given data
         * 
         * @param recordID      int                 the record to modify
         * @param requestData   Object              plain JSON object containing indicator ids and associated values
         * @param onSuccess     function(results)   callback when action is successful
         * @param onFail        function(err)       callback when action is not successful
         */
        modifyRequest = function (recordID, requestData, onSuccess, onFail) {
            // title must be removed in order to process the rest of the indicator data
            if(requestData.title != undefined) {
                delete requestData.title;
            }
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

        /**
         * Create a new request for the given form using the given data
         * 
         * @param formID        string              the form to create a request for
         * @param requestData   Object              plain JSON object containing indicator ids and associated values
         * @param onSuccess     function(results)   callback when action is successful
         * @param onFail        function(err)       callback when action is not successful
         */
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
                    modifyRequest(
                        recordID, 
                        requestData, 
                        function (result) {
                            if (result > 0) {
                                onSuccess(recordID);
                            } else {
                                onFail(false);
                            }
                        }, 
                        onFail);
                })
                .fail(onFail);
            // .always(function() {});
        },

        /**
         * --- BETA ---
         * Get a JSON representation of a form that is appropriate for digital signing.
         *
         * @param record    string              the record ID to generate JSON for
         * @param onSuccess function(results)   callback containing the JSON
         * @param onFail    function(error)     callback when operation fails
         */
        getJSONForSigning = function (recordID, onSuccess, onFail) {
            var fetchURL = apiURL + '/' + recordID + '/dataforsigning';

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: 'json',
                cache: false
            })
                .done(function (msg) {
                    onSuccess(msg);
                })
                .fail(function (err) {
                    onFail(err);
                });

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
                dataType: 'json',
                cache: false
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
        },
        
        /**
         * Set the initiator of the given record.
         * 
         * @param recordID  int                 the record ID to change
         * @param initiator string              the username to set as initiator
         * @param onSuccess function(results)   callback containing the results object
         * @param onFail    function(err)       callback when query fails
         */
        setInitiator = function(recordID, initiator, onSuccess, onFail) {
            var fetchURL = apiURL + '/' + recordID + '/initiator';
            var postData = {};
            postData['CSRFToken'] = csrfToken;
            postData['initiator'] = initiator;

            $.ajax({
                method: 'POST',
                url: fetchURL,
                data: postData,
                dataType: 'json'
            })
                .done(onSuccess)
                .fail(onFail);
                // .always(function() {});
        };

    return {
        getAPIURL: getAPIURL,
        getAllForms: getAllForms,
        getBaseAPIURL: getBaseAPIURL,
        getIndicatorsForForm: getIndicatorsForForm,
        modifyRequest: modifyRequest,
        newRequest: newRequest,
        setBaseAPIURL: setBaseAPIURL,
        setCSRFToken: setCSRFToken,
        setInitiator: setInitiator,
        getJSONForSigning: getJSONForSigning,
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
         * @param recordID      int                 the record ID to retrieve data for
         * @param parseTemplate bool                if the indicator ID should be included in the `html` and `htmlPrint` fields
         */
        getIndicator = function (indicatorID, onSuccess, onFail, recordID, parseTemplate) {
            var fetchURL = apiURL + '/indicator/' + indicatorID 
                + (parseTemplate != undefined && parseTemplate == true ? '&parseTemplate' : '')
                + (recordID != undefined && recordID != null ? '&recordID=' + recordID : '');

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: 'json',
                cache: false
            })
                .done(function (msg) {
                    onSuccess(msg);
                })
                .fail(function (err) {
                    onFail(err);
                });
        },

        /**
         * Get the HTML used to edit the given indicator
         * 
         * @param indicatorID   int                 the indicator to retrieve
         * @param recordID      int                 the record to retrieve the indicator data from
         * @param onSuccess     function(results)   callback when action is successful
         * @param onFail        function(error)     callback when action is not successful
         */
        getIndicatorEditor = function(indicatorID, recordID, onSuccess, onFail) {
            var fetchURL = 'ajaxIndex.php?a=getindicator&recordID=' + recordID + '&indicatorID=' + indicatorID + '&series=1';

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: 'html',
                cache: false
            })
                .done(onSuccess)
                .fail(onFail);
        },

        /**
         * Assigns workflow to form
         *
         * @param categoryID    string              name of form
         * @param workflowID    int                 workflow associated with form
         * @param onSuccess     function(success)   callback containing categoryID if action succeeded
         * @param onFail        function(err)       callback when action contains an error
         */
        assignFormWorkflow = function (categoryID, workflowID, onSuccess, onFail) {
            var postURL = apiURL + '/formWorkflow';

            $.ajax({
                method: 'POST',
                url: postURL,
                dataType: "text",
                data: {
                    "categoryID": categoryID,
                    "workflowID": workflowID,
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
         * Create custom form
         *
         * @param name          string                  name of form
         * @param description   string                  description of form
         * @param onSuccess     function(success)   callback containing categoryID if action succeeded
         * @param onFail        function(err)       callback when action contains an error
         */
        createCustomForm = function (name, description, onSuccess, onFail) {
            var postURL = apiURL + '/new';

            $.ajax({
                method: 'POST',
                url: postURL,
                dataType: "text",
                data: {
                    "name": name,
                    "description": description,
                    "parentID": "",
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

        publishForm = function (categoryID) {
            var postURL = apiURL + '/formVisible';
            $.ajax({
                method: 'POST',
                url: postURL,
                dataType: "text",
                data: {
                    "categoryID": categoryID,
                    "visible": "0",
                    CSRFToken: csrfToken
                },
                onSuccess(res) {
                    console.log(res)
                },
                error(err) {
                    console.log(err)
                },
                async: false
            });
        },

        /**
         * Add indicators to form
         *
         * @param name          string                  name of indicator
         * @param format        string                  format of indicator
         * @param categoryID    string                  form to associate indicator
         * @param required      int                  1 means required, 0 means not required
         * @param is_sensitive  int                  1 means sensitive, 0 means not sensitive
         * @param onSuccess     function(success)   callback containing categoryID if action succeeded
         * @param onFail        function(err)       callback when action contains an error
         */
        createFormIndicator = function (name, format, categoryID, required, is_sensitive, onSuccess, onFail) {
            var postURL = apiURL + '/newIndicator';

            $.ajax({
                method: 'POST',
                url: postURL,
                dataType: "text",
                data: {
                    "name": name,
                    "format": format,
                    "categoryID": categoryID,
                    "required": required,
                    "is_sensitive": is_sensitive,
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
                dataType: 'json',
                cache: false
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
        assignFormWorkflow: assignFormWorkflow,
        createCustomForm: createCustomForm,
        publishForm: publishForm,
        createFormIndicator: createFormIndicator,
        getIndicator: getIndicator,
        getIndicatorEditor: getIndicatorEditor,
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
                dataType: "json",
                cache: false
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
         * @param signature         string          the signature footprint
         * @param recordID          int             the id of the Record the Signature is associated with
         * @param message           string          the message that was signed
         * @param signerPublicKey   string          the signer's public key
         * @param onSuccess         function(id)    callback containing the id of the new signature
         * @param onFail            function(err)   callback when operation fails
         */
        create = function (signature, recordID, stepID, dependencyID, message, signerPublicKey, onSuccess, onFail) {
            $.ajax({
                method: 'POST',
                url: apiURL + '/create',
                dataType: "text",
                data: {
                    "signature": signature,
                    "recordID": recordID,
                    "stepID": stepID,
                    "dependencyID": dependencyID,
                    "message": message,
                    "signerPublicKey": signerPublicKey,
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
                dataType: "json",
                cache: false
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
         * Gets list of all workflows
         *
         * @param onSuccess             function(result)    callback when operation succeeds
         * @param onFail                function(error)     callback when operation fails
         */
        getAllWorkflows = function (onSuccess, onFail) {
            var fetchURL = apiURL;

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: 'json',
                cache: false
            })
                .done(function(msg){
                    onSuccess(msg);
                })
                .fail(function(err){
                    onFail(err);
                });
        },

        /**
         * --- BETA ---
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
                url: apiURL + '/step/' + stepID + '/requiresig',
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
        getAllWorkflows: getAllWorkflows,
        setStepSignatureRequirement: setStepSignatureRequirement
    };
};