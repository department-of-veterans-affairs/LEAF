/**
 * Form Query Helper
 */

var LeafFormQuery = function () {
  var query = {};
  var successCallback = null;
  var progressCallback = null;
  var rootURL = "";
  var useJSONP = false;
  var extraParams = "";

  clearTerms();

  /**
   * Reset search terms
   * @memberOf LeafFormQuery
   */
  function clearTerms() {
    query = {};
    query.terms = [];
    query.joins = [];
    query.sort = {};
    query.getData = [];
  }

  /**
   * Add a new search term
   * @param id - columnID
   * @param operator - SQL comparison operator
   * @param match - search term to match on
   * @param gate - AND or OR gate
   * @memberOf LeafFormQuery
   */
  function addTerm(id, operator, match, gate) {
    // @TODO IE Fix (No overloading)
    if (gate === undefined) {
      gate = "AND";
    }
    var temp = {};
    temp.id = id;
    temp.operator = operator;
    temp.match = match;
    temp.gate = gate;
    query.terms.push(temp);
  }

  /**
   * Add a new search term for data table
   * @param id - columnID / 'data' to search data table / 'dependencyID' to search records_dependencies data, matching on 'filled'
   * @param indicatorID - indicatorID / dependencyID / "0" to search all indicators
   * @param operator - SQL comparison operator
   * @param match - search term to match on
   * @param gate - AND or OR gate
   * @memberOf LeafFormQuery
   */
  function addDataTerm(id, indicatorID, operator, match, gate) {
    // @TODO IE Fix (No overloading)
    if (gate === undefined) {
      gate = "AND";
    }
    var temp = {};
    temp.id = id;
    temp.indicatorID = indicatorID;
    temp.operator = operator;
    temp.match = match;
    temp.gate = gate;
    query.terms.push(temp);
  }

  /**
   * Import query generated by formSearch
   * @param object - The JSON query object generated by formSearch
   * @memberOf LeafFormQuery
   */
  function importQuery(input) {
    for (let i in input.terms) {
      switch (Object.keys(input.terms[i]).length) {
        case 3:
          addTerm(
            input.terms[i].id,
            input.terms[i].operator,
            input.terms[i].match
          );
          break;
        case 4:
          if (input.terms[i].gate === undefined) {
            addDataTerm(
              input.terms[i].id,
              input.terms[i].indicatorID,
              input.terms[i].operator,
              input.terms[i].match
            );
            break;
          } else {
            addTerm(
              input.terms[i].id,
              input.terms[i].operator,
              input.terms[i].match,
              input.terms[i].gate
            );
            break;
          }
        case 5:
          addDataTerm(
            input.terms[i].id,
            input.terms[i].indicatorID,
            input.terms[i].operator,
            input.terms[i].match,
            input.terms[i].gate
          );
          break;
        default:
          console.log("Format error");
          break;
      }
    }

    for (var i in input.joins) {
      join(input.joins[i]);
    }

    for (var i in input.getData) {
      getData(input.getData[i]);
    }
  }

  /**
   * Limit number of results
   * @param offset / limit
   * @param limit (optional)
   * @memberOf LeafFormQuery
   */
  function setLimit(offset, limit) {
    if (limit === undefined) {
      query.limit = offset;
    } else {
      query.limit = limit;
      setLimitOffset(offset);
    }
  }

  /**
   * Limit number of results
   * @param offset
   * @memberOf LeafFormQuery
   */
  function setLimitOffset(offset) {
    query.limitOffset = offset;
  }

  /**
   * Join table
   * @param table
   * @memberOf LeafFormQuery
   */
  function join(table) {
    if (query.joins.indexOf(table) == -1) {
      query.joins.push(table);
    }
  }

  /**
   * Get data
   * @param string - indicatorID
   * @memberOf LeafFormQuery
   */
  function getData(indicatorID) {
    if (query.getData.indexOf(indicatorID) == -1) {
      query.getData.push(indicatorID);
    }
  }

  /**
   * Sort results
   * @param
   * @memberOf LeafFormQuery
   */
  function sort(column, direction) {
    query.sort.column = column;
    query.sort.direction = direction;
  }

  /**
   * Update an existing search term
   * @param id - columnID or "stepID"
   * @param operator - SQL comparison operator
   * @param match - search term to match on
   * @param gate - AND or OR gate
   * @memberOf LeafFormQuery
   */
  function updateTerm(id, operator, match, gate) {
    for (var i in query.terms) {
      if (query.terms[i].id == id && query.terms[i].operator == operator) {
        query.terms[i].match = match;
        query.terms[i].gate = gate;
        return;
      }
    }
    addTerm(id, operator, match, gate);
  }

  /**
   * Update an existing data search term
   * @param id - columnID / 'data' to search data table / 'dependencyID' to search records_dependencies data, matching on 'filled'
   * @param indicatorID - indicatorID / dependencyID
   * @param operator - SQL comparison operator
   * @param match - search term to match on
   * @param gate - AND or OR gate
   * @memberOf LeafFormQuery
   */
  function updateDataTerm(id, indicatorID, operator, match, gate) {
    var found = 0;
    for (var i in query.terms) {
      if (
        query.terms[i].id == id &&
        query.terms[i].indicatorID == indicatorID &&
        query.terms[i].operator == operator
      ) {
        query.terms[i].match = match;
        query.terms[i].gate = gate;
        return;
      }
    }
    addDataTerm(id, indicatorID, operator, match, gate);
  }

  /**
   * Add extra parameters to the end of the query API URL
   * @param string params
   */
  function setExtraParams(params) {
    extraParams = params;
  }

  /**
   * @param funct - Success callback (see format for jquery ajax success)
   * @memberOf LeafFormQuery
   */
  function onSuccess(funct) {
    successCallback = funct;
  }

  /**
   * onProgress assigns a callback to be called on every getBulkData() iteration
   * @param funct - funct(int Progress). Progress is the number of records that have been processed
   * @memberOf LeafFormQuery
   */
  function onProgress(funct) {
    progressCallback = funct;
  }

  /**
   * Execute search query in chunks
   * @param limitOffset Used in subsequent recursive calls to track current offset
   * @returns Promise resolving to query response
   * @memberOf LeafFormQuery
   */
  let results = {};
  let batchSize = 500;
  function getBulkData(limitOffset) {
    if (limitOffset == undefined) {
      limitOffset = 0;
    }
    if (limitOffset == 0) {
      results = {};
    }
    limitOffset = parseInt(limitOffset);

    query.limit = batchSize;
    query.limitOffset = limitOffset;

    let el = document.createElement("div");
    el.innerHTML = JSON.stringify(query);
    let queryUrl = el.innerText;

    let dataType = "json";
    let urlParamJSONP = "";
    if (useJSONP) {
      dataType = "jsonp";
      urlParamJSONP = "&format=jsonp";
    }

    return $.ajax({
      type: "GET",
      url:
        rootURL + "api/form/query?q=" + queryUrl + extraParams + urlParamJSONP,
      dataType: dataType,
    }).then(function (res, resStatus, resJqXHR) {
      results = Object.assign(results, res);

      if (
        Object.keys(res).length == batchSize ||
        resJqXHR.getResponseHeader("leaf-query") == "continue"
      ) {
        let newOffset = limitOffset + batchSize;
        if (typeof progressCallback == "function") {
          progressCallback(newOffset);
        }
        return getBulkData(newOffset);
      } else {
        if (typeof successCallback == "function") {
          successCallback(results, resStatus, resJqXHR);
        }
        return results;
      }
    });
  }

  /**
   * Execute search query
   * @returns $.ajax() object
   * @memberOf LeafFormQuery
   */
  function execute() {
    if (query.getData != undefined && query.getData.length == 0) {
      delete query.getData;
    }

    if (
      query.limit == undefined ||
      isNaN(query.limit) ||
      parseInt(query.limit) > 9999
    ) {
      return getBulkData();
    }

    let el = document.createElement("div");
    el.innerHTML = JSON.stringify(query);
    let queryUrl = el.innerText;

    if (useJSONP == false) {
      return $.ajax({
        type: "GET",
        url: rootURL + "api/form/query?q=" + queryUrl + extraParams,
        dataType: "json",
        success: successCallback,
      });
    } else {
      return $.ajax({
        type: "GET",
        url:
          rootURL +
          "api/form/query?q=" +
          queryUrl +
          "&format=jsonp" +
          extraParams,
        dataType: "jsonp",
        success: successCallback,
      });
    }
  }

  return {
    clearTerms: clearTerms,
    addTerm: addTerm,
    addDataTerm: addDataTerm,
    importQuery: importQuery,
    getQuery: function () {
      return query;
    },
    getData: getData,
    updateTerm: updateTerm,
    updateDataTerm: updateDataTerm,
    setQuery: function (inc) {
      query = inc;
    },
    setLimit: setLimit,
    setLimitOffset: setLimitOffset,
    setRootURL: function (url) {
      rootURL = url;
    },
    getRootURL: function () {
      return rootURL;
    },
    useJSONP: function (state) {
      useJSONP = state;
    },
    setExtraParams: setExtraParams,
    join: join,
    sort: sort,
    onSuccess: onSuccess,
    onProgress: onProgress,
    execute: execute,
  };
};