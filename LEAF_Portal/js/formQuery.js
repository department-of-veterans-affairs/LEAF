/************************
    Form Query Helper
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: January 9, 2015
*/

var LeafFormQuery = function() {
	var query = {};
	var successCallback = null;

	clearTerms();

    /**
     * Reset search terms
     * @memberOf LeafFormGrid
     */
    function clearTerms() {
    	query = {};
    	query.terms = [];
    	query.joins = [];
    	query.sort = {};
    }

    /**
     * Add a new search term
     * @param id - columnID
     * @param operator - SQL comparison operator
     * @param match - search term to match on
     * @memberOf LeafFormGrid
     */
    function addTerm(id, operator, match) {
    	var temp = {};
    	temp.id = id;
    	temp.operator = operator;
    	temp.match = match;
    	query.terms.push(temp);
    }

    /**
     * Add a new search term for data table
     * @param id - columnID / 'data' to search data table / 'dependencyID' to search records_dependencies data, matching on 'filled'
     * @param indicatorID - indicatorID / dependencyID
     * @param operator - SQL comparison operator
     * @param match - search term to match on
     * @memberOf LeafFormGrid
     */
    function addDataTerm(id, indicatorID, operator, match) {
    	var temp = {};
    	temp.id = id;
    	temp.indicatorID = indicatorID;
    	temp.operator = operator;
    	temp.match = match;
    	query.terms.push(temp);
    }

    /**
     * Limit number of results
     * @param limit
     * @memberOf LeafFormGrid
     */
    function setLimit(limit) {
    	query.limit = limit;
    }

    /**
     * Limit number of results
     * @param offset
     * @memberOf LeafFormGrid
     */
    function setLimitOffset(offset) {
    	query.limitOffset = offset;
    }

    /**
     * Join table
     * @param table
     * @memberOf LeafFormGrid
     */
    function join(table) {
    	if(query.joins.indexOf(table) == -1) {
        	query.joins.push(table);
    	}
    }

    /**
     * Sort results
     * @param 
     * @memberOf LeafFormGrid
     */
    function sort(column, direction) {
    	query.sort.column = column;
    	query.sort.direction = direction;
    }

    /**
     * Update an existing search term
     * @param id - columnID
     * @param operator - SQL comparison operator
     * @param match - search term to match on
     * @memberOf LeafFormGrid
     */
    function updateTerm(id, operator, match) {
    	for(var i in query.terms) {
    		if(query.terms[i].id == id && query.terms[i].id == operator) {
    			query.terms[i].match = match
    		}
    	}
    }

    /**
     * @param funct - Success callback (see format for jquery ajax success)
     * @memberOf LeafFormGrid
     */
    function onSuccess(funct) {
    	successCallback = funct;
    }

    /**
     * Execute search query
     * @param callback - Success callback
     * @returns $.ajax() object
     * @memberOf LeafFormGrid
     */
    function execute() {
    	return $.ajax({
    		type: 'GET',
    		url: 'api/?a=form/query&q=' + JSON.stringify(query),
    		success: successCallback,
    		cache: false
    	});
    }

	return {
		clearTerms: clearTerms,
		addTerm: addTerm,
		addDataTerm: addDataTerm,
		getQuery: function() { return query; },
		setQuery: function(inc) { query = inc; },
		setLimit: setLimit,
		setLimitOffset: setLimitOffset,
		join: join,
		sort: sort,
		onSuccess: onSuccess,
		execute: execute
	}
};