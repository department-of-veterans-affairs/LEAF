/*
 * API for LEAF Nexux
 */
var LEAFNexusAPI = function () {
    var baseURL = './api/?a=',
        Employee = NexusEmployeeAPI(baseURL),
        Groups = NexusGroupsAPI(this.baseURL),

        /**
         * Get the base URL for the LEAF Nexus API (e.g. "/LEAF_Nexus/api/?a=")
         */
        getBaseURL = function () {
            return baseURL;
        },

        /**
         * Set the base URL for the LEAF Nexus API (e.g. "/LEAF_Nexus/api/?a=")
         */
        setBaseURL = function (baseAPIURL) {
            baseURL = baseAPIURL;
            Employee.setBaseAPIURL(baseURL);
        },

        setCSRFToken = function (token) {
            csrfToken = token;
            Employee.setCSRFToken(csrfToken);
        };

    return {
        getBaseURL: getBaseURL,
        setBaseURL: setBaseURL,
        setCSRFToken: setCSRFToken,
        Employee: Employee,
        Groups: Groups
    };
};

var NexusEmployeeAPI = function (baseAPIURL) {
    var apiBaseURL = baseAPIURL,
        apiURL = baseAPIURL + 'employee',

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
            apiURL = baseAPIURL + 'employee';
        },

        /**
         * Set the CSRFToken for POST requests
         */
        setCSRFToken = function (token) { csrfToken = token; },

        getByEmail = function (emailAddress, onSuccess, onFail) {
            var fetchURL = apiURL + '/search&q=' + emailAddress + '&noLimit=0';

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: "json",
                cache: false
            })
                .done(onSuccess)
                .fail(onFail);
                // .always(function () {});
        },

        getByEmailNational = function (emailAddress, onSuccess, onFail) {
            var fetchURL = apiBaseURL + 'national/employee/search&q=' + emailAddress + '&noLimit=0';

            $.ajax({
                method: 'GET',
                url: fetchURL,
                dataType: "json",
                async: false,
                cache: false
            })
                .done(onSuccess)
                .fail(onFail);
                // .always(function () {});
        },
        
        /**
         * Import a user from the National Orgchart into the local Nexus
         * 
         * @param userName  string              the userName to import
         * @param async     boolean             if the POST request should not wait to complete before calling the onSuccess method
         * @param onSuccess function(results)   the callback when the query is successful
         * @param onFail    function(err)       the callback when the action fails
         */
        importFromNational = function(userName, async, onSuccess, onFail) {
            var fetchURL = apiURL + '/import/_' + userName;
            var postData = {};
            postData['CSRFToken'] = csrfToken;

            $.ajax({
                method: 'POST',
                url: fetchURL,
                data: postData,
                dataType: 'json',
                async: async
            })
                .done(onSuccess)
                .fail(onFail);
                // .always(function() {});
        };

    return {
        getAPIURL: getAPIURL,
        getBaseAPIURL: getBaseAPIURL,
        getByEmail: getByEmail,
        getByEmailNational: getByEmailNational,
        importFromNational: importFromNational,
        setBaseAPIURL: setBaseAPIURL,
        setCSRFToken: setCSRFToken,
    };
};

/**
 * API for working the Nexus Groups
 * 
 * @param baseAPIURL    string  the base URL for the LEAF Nexus API (e.g. "/LEAF_Nexus/api/?a=") 
 */
var NexusGroupsAPI = function (baseAPIURL) {
    var apiBaseURL = baseAPIURL,
        apiURL = apiBaseURL + 'group',

        /**
         * Get the URL for the LEAF Nexus Groups API
         */
        getAPIURL = function () {
            return apiURL;
        },

        /**
         * Get the base URL for the LEAF Nexus API
         */
        getBaseAPIURL = function () {
            return apiBaseURL;
        },

        /**
         * Get all employees associated with a group with their extended
         * Employee info (data and positions). 
         * 
         * @param groupID      int                 The groupID to search
         * @param limit        int                 the number of users to return
         * @param offset       int                 the number of users to offset in the query
         * @param onSuccess    function(employees)   the callback containing all fetched users 
         * @param onFail       function(error)     callback when query fails
         */
        listGroupEmployeesDetailed = function (groupID, limit, offset, onSuccess, onFail) {
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
        };

    return {
        getAPIURL: getBaseAPIURL,
        getBaseAPIURL: getBaseAPIURL,
        listGroupEmployeesDetailed: listGroupEmployeesDetailed
    };
};