/************************
 Form Search Widget
 */

var LeafFormSearch = function (containerID) {
    var containerID = containerID;
    var prefixID = "LeafFormSearch" + Math.floor(Math.random() * 1000) + "_";
    var localStorageNamespace = "LeafFormSearch" + getLocalStorageHash();
    var orgchartPath = "";
    var timer = 0;
    var q = "";
    var intervalID = null;
    var currRequest = null;
    var numResults = 0;
    var searchFunc = null;
    var leafFormQuery = new LeafFormQuery();
    var widgetCounter = 0;
    var rootURL = "";
    var app_js_path = "";
    let openedAdvancedSearch = false;
    let cache = {};

    // constants
    var ALL_DATA_FIELDS = "0";
    var ALL_OC_EMPLOYEE_DATA_FIELDS = "0.0";

    function renderUI() {
        $("#" + containerID).html(
            '<div style="display:flex; align-items:center; width:fit-content; width: -moz-fit-content;">\
			    <img id="' +
                prefixID +
                'searchIcon" class="searchIcon" alt="" style="vertical-align: middle; padding-right: 4px; display: inline;" src="' +
                rootURL +
                'dynicons/?img=search.svg&w=16">\
			    <img id="' +
                prefixID +
                'searchIconBusy" class="searchIcon" alt="" style="vertical-align: middle; padding-right: 4px; display:none" src="' +
                rootURL +
                'images/indicator.gif">\
					<span style="position: absolute; width: 60%; height: 1px; margin: -1px; padding: 0; overflow: hidden; clip: rect(0,0,0,0); border: 0;" aria-atomic="true" aria-live="polite" class="status" role="status"></span>\
			    <input style="border: 1px solid black; padding: 4px" type="text" id="' +
                prefixID +
                'searchtxt" name="searchtxt" size="50" aria-label="Enter your search text" value="" />\
			    <button type="button" class="buttonNorm" id="' +
                prefixID +
                'advancedSearchButton">Advanced Options</button>\
			    <fieldset id="' +
                prefixID +
                'advancedOptions" style="position: relative; display: none; margin: 0px; border: 1px solid black; background-color: white">\
		        <legend>Advanced Search Options</legend>\
		        <button type="button" id="' +
                prefixID +
                'advancedOptionsClose" style="float: right; margin-top: -20px; margin-right: -14px; display: none; cursor: pointer; background-image:url(' +
                rootURL +
                'dynicons/?img=process-stop.svg&w=16); height: 16px;width: 16px; border: none; background-color: transparent; text-indent: -9999em">Close advanced search</button>\
                <div style="width: 550px">Find items where...</div>\
		        <table id="' +
                prefixID +
                'searchTerms"></table>\
		        <button type="button" aria-label="add logical and filter" class="buttonNorm" id="' +
                prefixID +
                'addTerm" style="float: left">And...</button>\
		        <button type="button" aria-label="add logical or filter" class="buttonNorm" id="' +
                prefixID +
                'orTerm" style="float: left">Or...</button>\
		        <br /><br />\
                <div id="unsubmitted_results_notice" style="display:none;color:#b00; margin:0.5rem 2px;">\
                    <div>Results can include unsubmitted requests.  Consider including \'Current Status IS Submitted\'.</div>\
                </div>\
		        <button type="button" id="' +
                prefixID +
                'advancedSearchApply" class="buttonNorm" style="text-align: center; width: 100%">Apply Filters</button>\
		    </fieldset>\
		    </div>\
		    <div id="' +
                prefixID +
                '_result" style="margin-top: 8px" aria-label="Search Results">\
		    </div>'
        );

        var searchOrigWidth = 0;
        $("#" + prefixID + "advancedOptionsClose").on("click", function () {
            localStorage.setItem(localStorageNamespace + ".search", "");
            $("#" + prefixID + "searchtxt").val("");
            search("");
            $("#" + prefixID + "advancedOptionsClose").css("display", "none");
            $("#" + prefixID + "advancedOptions").slideUp(function () {
                $("#" + prefixID + "advancedSearchButton").fadeIn();
                $("#" + prefixID + "searchtxt").css("display", "inline");
                $("#" + prefixID + "searchtxt").animate(
                    { width: searchOrigWidth },
                    400,
                    "swing"
                );
                $("#" + prefixID + "searchtxt").focus();
            });
        });
        //this element is a button, so this will also handle keyboard events
        $("#" + prefixID + "advancedSearchButton").on("click", function () {
            searchOrigWidth = $("#" + prefixID + "searchtxt").width();
            $("#" + prefixID + "advancedSearchButton").fadeOut();
            $("#" + prefixID + "searchtxt").animate(
                { width: "0px" },
                400,
                "swing",
                function () {
                    $("#" + prefixID + "searchtxt").css("display", "none");
                    $("#" + prefixID + "advancedOptions").slideDown(
                        function () {
                            $("#" + prefixID + "advancedOptionsClose").fadeIn();
                        }
                    );
                    $("#" + prefixID + "advancedOptions").css(
                        "display",
                        "inline"
                    );
                    chosenOptions();
                    renderPreviousAdvancedSearch();
                    $("#" + prefixID + "widgetMat_0").focus();
                }
            );
            if(!openedAdvancedSearch) {
                openedAdvancedSearch = true;
                newSearchWidget();
            }
        });

        $("#" + prefixID + "advancedSearchApply").on("click", function () {
            showBusy();
            generateSearchQuery();
        });
        $("#" + prefixID + "addTerm").on("click", function () {
            newSearchWidget("AND");
            chosenOptions();
        });
        $("#" + prefixID + "orTerm").on("click", function () {
            newSearchWidget("OR");
            chosenOptions();
        });

        $("#" + prefixID + "searchtxt").on("keydown", function (e) {
            showBusy();
            timer = 0;
            if (e.keyCode == 13) {
                // enter key
                search($("#" + prefixID + "searchtxt").val());
            }
        });
    }

    /**
     * @memberOf LeafFormSearch
     */
    function init() {
        renderUI();

        intervalID = setInterval(function () {
            inputLoop();
        }, 200);
        if (
            !/Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
                navigator.userAgent
            ) &&
            window.location.search !== ""
        ) {
            focus();
        }
        if (getLastSearch() == null) {
            search("*");
        } else {
            var lastSearch = getLastSearch();

            var isJSON = true;
            var advSearch = {};
            try {
                advSearch = JSON.parse(lastSearch);
            } catch (err) {
                isJSON = false;
            }

            if (lastSearch.substr(0, 1) != "[") {
                isJSON = false;
            }

            if (isJSON) {
                $("#" + prefixID + "advancedSearchButton").click();
                search(lastSearch);
            } else {
                if (lastSearch == "") {
                    search("*");
                }
                $("#" + prefixID + "searchtxt").val(lastSearch);
            }
        }
    }

    /**
     * @memberOf LeafFormSearch
     * prevQuery - optional JSON object
     */
    function renderPreviousAdvancedSearch(prevQuery) {
        var isJSON = true;
        var advSearch = {};
        try {
            if (prevQuery != undefined) {
                advSearch = prevQuery;
            } else {
                advSearch = JSON.parse(getLastSearch());
            }
        } catch (err) {
            isJSON = false;
        }
        if (isJSON && advSearch != null && widgetCounter <= advSearch.length) {
            for (var i = 1; i < advSearch.length; i++) {
                newSearchWidget(advSearch[i].gate);
                firstChild();
            }
            for (var i = 0; i < advSearch.length; i++) {
                $("#" + prefixID + "widgetTerm_" + i).val(advSearch[i].id);
                $("#" + prefixID + "widgetTerm_" + i).trigger("chosen:updated");
                if (
                    advSearch[i].indicatorID != undefined ||
                    advSearch[i].id == "serviceID" ||
                    advSearch[i].id == "categoryID" ||
                    advSearch[i].id == "stepID" ||
                    advSearch[i].id == "stepAction"
                ) {
                    renderWidget(
                        i,
                        (function (
                            widgetID,
                            indicatorID,
                            operator,
                            match,
                            gate
                        ) {
                            return function () {
                                $(
                                    "#" +
                                        prefixID +
                                        "widgetIndicator_" +
                                        widgetID
                                ).val(indicatorID);
                                $(
                                    "#" +
                                        prefixID +
                                        "widgetIndicator_" +
                                        widgetID
                                ).trigger("chosen:updated");
                                $("#" + prefixID + "widgetCod_" + widgetID).val(
                                    operator
                                );
                                $(
                                    "#" + prefixID + "widgetCod_" + widgetID
                                ).trigger("change");
                                $(
                                    "#" + prefixID + "widgetCod_" + widgetID
                                ).trigger("chosen:updated");

                                if(operator.indexOf('MATCH') == -1) {
                                    $("#" + prefixID + "widgetMat_" + widgetID).val(match.replace(/\*/g, ""));
                                }
                                else {
                                    $("#" + prefixID + "widgetMat_" + widgetID).val(match);
                                }

                                $(
                                    "#" + prefixID + "widgetMat_" + widgetID
                                ).trigger("chosen:updated");
                            };
                        })(
                            i,
                            advSearch[i].indicatorID,
                            advSearch[i].operator,
                            advSearch[i].match,
                            advSearch[i].gate
                        )
                    );
                } else {
                    renderWidget(i);
                }
                $("#" + prefixID + "widgetCod_" + i).val(advSearch[i].operator);
                $("#" + prefixID + "widgetCod_" + i).trigger("chosen:updated");
                if (typeof advSearch[i].match == "string" && advSearch[i].operator.indexOf('MATCH') == -1) {
                    $("#" + prefixID + "widgetMat_" + i).val(
                        advSearch[i].match.replace(/\*/g, "")
                    );
                }
            }
        }
    }

    /**
     * @memberOf LeafFormSearch
     * From: http://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/
     */
    function getLocalStorageHash() {
        var hash = 0,
            i,
            chr,
            len;
        if (document.URL.length == 0) return hash;
        for (i = 0, len = document.URL.length; i < len; i++) {
            chr = document.URL.charCodeAt(i);
            hash = (hash << 5) - hash + chr;
            hash |= 0; // Convert to 32bit integer
        }
        return hash;
    }

    /**
     * @memberOf LeafFormSearch
     */
    function setOrgchartPath(path) {
        orgchartPath = path;
    }

    /**
     * @memberOf LeafFormSearch
     */
    function getLastSearch() {
        return localStorage.getItem(localStorageNamespace + ".search");
    }

    /**
     * @memberOf LeafFormSearch
     */
    function setSearchFunc(func) {
        searchFunc = func;
    }

    /**
     * @memberOf LeafFormSearch
     */
    function search(txt) {
        if (txt != "*") {
            localStorage.setItem(localStorageNamespace + ".search", txt);
        }
        return searchFunc(txt);
    }

    /**
     * @memberOf LeafFormSearch
     */
    function inputLoop() {
        if ($("#" + prefixID + "searchtxt") == null) {
            clearInterval(intervalID);
            return false;
        }
        timer += timer > 5000 ? 0 : 200;
        if (timer > 400) {
            var txt = $("#" + prefixID + "searchtxt").val();

            if (txt != "" && txt != q) {
                q = txt;

                if (
                    currRequest != null &&
                    currRequest.abort != undefined &&
                    typeof currRequest.abort == "function"
                ) {
                    currRequest.abort();
                }

                currRequest = search(txt);
            } else if (txt == "") {
                if (txt != q) {
                    search("");
                }
                q = txt;
                $("#" + this.prefixID + "_result").html("");
                numResults = 0;
                showNotBusy();
            } else {
                showNotBusy();
            }
        }
    }

    /**
     * @memberOf LeafFormSearch
     */
    function focus() {
        $("#" + prefixID + "searchtxt").focus();
    }

    /**
     * @memberOf LeafFormSearch
     */
    function showBusy() {
        $("#" + prefixID + "searchIcon").css("display", "none");
        $("#" + prefixID + "searchIconBusy").css("display", "inline");
        $(".status").text("Loading");
    }

    /**
     * @memberOf LeafFormSearch
     */
    function showNotBusy() {
        $("#" + prefixID + "searchIcon").css("display", "inline");
        $("#" + prefixID + "searchIconBusy").css("display", "none");
    }

    /**
     * @memberOf LeafFormSearch
     */
    function createEmployeeSelectorWidget(widgetID, type) {
        if (type == undefined) {
            type = "userName";
        }
        if (typeof employeeSelector == "undefined") {
            $("head").append(
                '<link type="text/css" rel="stylesheet" href="' +
                    orgchartPath +
                    '/css/employeeSelector.css" />'
            );
            $.ajax({
                type: "GET",
                url: orgchartPath + "/js/employeeSelector.js",
                dataType: "script",
                success: function () {
                    let empSel = new employeeSelector(
                        prefixID + "widgetEmp_" + widgetID
                    );
                    empSel.apiPath = orgchartPath + "/api/";
                    empSel.rootPath = orgchartPath + "/";
                    empSel.outputStyle = "micro";

                    empSel.setSelectHandler(function () {
                        if (
                            empSel.selectionData[empSel.selection] != undefined
                        ) {
                            selection =
                                type == "empUID"
                                    ? empSel.selection
                                    : empSel.selectionData[empSel.selection]
                                          .userName;
                            $("#" + prefixID + "widgetMat_" + widgetID).val(
                                selection
                            );
                            //uses id.  report builder/search will not take userName:<username>
                            $("#" + empSel.prefixID + "input").val(
                                "#" + empSel.selection
                            );
                        }
                    });
                    empSel.setResultHandler(function () {
                        if (
                            empSel.selectionData[empSel.selection] != undefined
                        ) {
                            selection =
                                type == "empUID"
                                    ? empSel.selection
                                    : empSel.selectionData[empSel.selection]
                                          .userName;
                            $("#" + prefixID + "widgetMat_" + widgetID).val(
                                selection
                            );
                        }
                    });
                    empSel.initialize();
                    let previousSelectedEmp = $("#" + prefixID + "widgetMat_" + widgetID).val();
                    if(previousSelectedEmp != '') {
                        if(type == 'empUID') {
                            empSel.forceSearch(`#${previousSelectedEmp}`);
                        }
                        else {
                            empSel.forceSearch(previousSelectedEmp);
                        }
                    }
                },
            });
        } else {
            let empSel = new employeeSelector(
                prefixID + "widgetEmp_" + widgetID
            );
            empSel.apiPath = orgchartPath + "/api/";
            empSel.rootPath = orgchartPath + "/";
            empSel.outputStyle = "micro";

            empSel.setSelectHandler(function () {
                if (empSel.selectionData[empSel.selection] != undefined) {
                    selection =
                        type == "empUID"
                            ? empSel.selection
                            : empSel.selectionData[empSel.selection].userName;
                    $("#" + prefixID + "widgetMat_" + widgetID).val(selection);
                    $("#" + empSel.prefixID + "input").val(
                        "#" + empSel.selection
                    );
                }
            });
            empSel.setResultHandler(function () {
                if (empSel.selectionData[empSel.selection] != undefined) {
                    selection =
                        type == "empUID"
                            ? empSel.selection
                            : empSel.selectionData[empSel.selection].userName;
                    $("#" + prefixID + "widgetMat_" + widgetID).val(selection);
                }
            });
            empSel.initialize();
            let previousSelectedEmp = $("#" + prefixID + "widgetMat_" + widgetID).val();
            if(previousSelectedEmp != '') {
                if(type == 'empUID') {
                    empSel.forceSearch(`#${previousSelectedEmp}`);
                }
                else {
                    empSel.forceSearch(previousSelectedEmp);
                }
            }
        }
    }

    /**
     * @memberOf LeafFormSearch
     */
    function createPositionSelectorWidget(widgetID) {
        if (typeof positionSelector == "undefined") {
            $("head").append(
                '<link type="text/css" rel="stylesheet" href="' +
                    orgchartPath +
                    '/css/positionSelector.css" />'
            );
            $.ajax({
                type: "GET",
                url: orgchartPath + "/js/positionSelector.js",
                dataType: "script",
                success: function () {
                    let posSel = new positionSelector(
                        prefixID + "widgetPos_" + widgetID
                    );
                    posSel.apiPath = orgchartPath + "/api/";
                    posSel.rootPath = orgchartPath + "/";

                    posSel.setSelectHandler(function () {
                        $("#" + prefixID + "widgetMat_" + widgetID).val(
                            posSel.selection
                        );
                        $("#" + posSel.prefixID + "input").val(
                            "#" + posSel.selection
                        );
                    });
                    posSel.setResultHandler(function () {
                        $("#" + prefixID + "widgetMat_" + widgetID).val(
                            posSel.selection
                        );
                    });
                    posSel.initialize();
                },
            });
        } else {
            let posSel = new positionSelector(
                prefixID + "widgetPos_" + widgetID
            );
            posSel.apiPath = orgchartPath + "/api/";
            posSel.rootPath = orgchartPath + "/";

            posSel.setSelectHandler(function () {
                $("#" + prefixID + "widgetMat_" + widgetID).val(
                    posSel.selection
                );
                $("#" + posSel.prefixID + "input").val("#" + posSel.selection);
            });
            posSel.setResultHandler(function () {
                $("#" + prefixID + "widgetMat_" + widgetID).val(
                    posSel.selection
                );
            });
            posSel.initialize();
        }
    }

    /**
     * @memberOf LeafFormSearch
     */
    function createGroupSelectorWidget(widgetID) {
        if (typeof groupSelector == "undefined") {
            $("head").append(
                '<link type="text/css" rel="stylesheet" href="' +
                    orgchartPath +
                    '/css/groupSelector.css" />'
            );
            $.ajax({
                type: "GET",
                url: orgchartPath + "/js/groupSelector.js",
                dataType: "script",
                success: function () {
                    let grpSel = new groupSelector(
                        prefixID + "widgetGrp_" + widgetID
                    );
                    grpSel.apiPath = orgchartPath + "/api/";
                    grpSel.rootPath = orgchartPath + "/";

                    grpSel.setSelectHandler(function () {
                        $("#" + prefixID + "widgetMat_" + widgetID).val(
                            grpSel.selection
                        );
                        $("#" + grpSel.prefixID + "input").val(
                            "group#" + grpSel.selection
                        );
                    });
                    grpSel.setResultHandler(function () {
                        $("#" + prefixID + "widgetMat_" + widgetID).val(
                            grpSel.selection
                        );
                    });
                    grpSel.initialize();
                },
            });
        } else {
            let grpSel = new groupSelector(prefixID + "widgetGrp_" + widgetID);
            grpSel.apiPath = orgchartPath + "/api/";
            grpSel.rootPath = orgchartPath + "/";

            grpSel.setSelectHandler(function () {
                $("#" + prefixID + "widgetMat_" + widgetID).val(
                    grpSel.selection
                );
                $("#" + grpSel.prefixID + "input").val(
                    "group#" + grpSel.selection
                );
            });
            grpSel.setResultHandler(function () {
                $("#" + prefixID + "widgetMat_" + widgetID).val(
                    grpSel.selection
                );
            });
            grpSel.initialize();
        }
    }

    /**
     * Render the query match condition's input type for dropdown and radio fields
     * @param widgetID
     * @param options <select> html section matching the widgetID
     * @memberOf LeafFormSearch
     */
    function renderSingleSelectInputType(widgetID, options) {
        switch ($("#" + prefixID + "widgetCod_" + widgetID).val()) {
            case "MATCH ALL":
            case "NOT MATCH":
            case "MATCH":
            case "LIKE":
            case "NOT LIKE":
                $("#" + prefixID + "widgetMatch_" + widgetID).html(
                    '<input type="text" aria-label="text" id="' +
                        prefixID +
                        "widgetMat_" +
                        widgetID +
                        '" style="width: 200px" />'
                );
                break;
            default:
                $("#" + prefixID + "widgetMatch_" + widgetID).html(options);
                chosenOptions();
                break;
        }
    }

    /* assesses query logic for some term filters and updates display of status message if the query can return unsubmitted requests */
    function checkDateStatus() {
        let includesOnAndBefore = false;
        let filtersUnsubmitted = false;

        const elSelTerms = Array.from(document.querySelectorAll(`table select[id^="${prefixID}widgetTerm_"]`));
        elSelTerms.forEach(sel => {
            if(sel?.value === "dateSubmitted" || sel?.value === "stepID") {
                const codID = (sel?.id || '').replace('widgetTerm_', 'widgetCod_');
                const gateID = (sel?.id || '').replace('widgetTerm_', 'widgetGate_');
                const opValue = document.getElementById(codID)?.value || '';
                const gateVal = document.getElementById(gateID)?.innerText || 'AND';

                if(sel.value === "dateSubmitted") {
                    if(opValue === '<=') {
                        includesOnAndBefore = true;
                    } else {
                        if (gateVal === 'AND') {
                            filtersUnsubmitted = true;
                        }
                    }
                }
                if(sel.value === "stepID" && gateVal === 'AND' && opValue === '=') {
                    filtersUnsubmitted = true;
                }
            }
        });
        let msgEl = document.getElementById('unsubmitted_results_notice');
        if (msgEl !== null) {
            msgEl.style.display = includesOnAndBefore && !filtersUnsubmitted ? 'block' : 'none';
        }
    }

    // getStepActionOptions retrieves data to support stepAction queries
    async function getStepActionOptions(stepWorkflowIdx, widgetID) {
        let stepID = $("#" + prefixID + "widgetIndicator_" + widgetID).val();
        let options = '';
        if(stepID != '') {
            let actions = (await getWorkflowStepActions(stepWorkflowIdx[stepID]))[stepID];
            options = `<select id="${prefixID}widgetMat_${widgetID}" class="chosen" aria-label="options" style="width: 250px">`;
            for(let i in actions) {
                options += `<option value="${actions[i].actionType}">${actions[i].actionTextPasttense}</option>`;
            }
            options += '</select>';
        }

        return options;
    }

    // getWorkflowStepActions retrieves data to support stepAction queries
    async function getWorkflowStepActions(workflowID) {
        let url = `./api/workflow/${workflowID}/route?x-filterData=workflowID,stepID,actionType,actionTextPasttense`;
        if(rootURL != '') {
            url = rootURL + `api/workflow/${workflowID}/route?x-filterData=workflowID,stepID,actionType,actionTextPasttense`;
        }
        if(cache[`api/workflow/${workflowID}/route`] == undefined) {
            cache[`api/workflow/${workflowID}/route`] = $.ajax({
                type: "GET",
                url
            }).then(res => {
                let workflowStepActions = {};
                for(let i in res) {
                    workflowStepActions[res[i].stepID] = workflowStepActions[res[i].stepID] || [];
                    workflowStepActions[res[i].stepID].push({
                        actionType: res[i].actionType,
                        actionTextPasttense: res[i].actionTextPasttense
                    });
                }
                return workflowStepActions;
            }).catch(err => {
                console.error(err);
            });
        }

        return cache[`api/workflow/${workflowID}/route`];
    }

    /**
     * @memberOf LeafFormSearch
     */
    async function renderWidget(widgetID, callback) {
        let url;
        switch ($("#" + prefixID + "widgetTerm_" + widgetID).val()) {
            case "title":
                $("#" + prefixID + "widgetCondition_" + widgetID).html(
                    '<select id="' +
                        prefixID +
                        "widgetCod_" +
                        widgetID +
                        '" class="chosen"  aria-label="title" style="width: 120px">\
						<option value="LIKE">CONTAINS</option>\
						<option value="NOT LIKE">DOES NOT CONTAIN</option>\
	            		<option value="=">=</option>\
						<option value="!=">!=</option>\
	            	</select>'
                );
                $("#" + prefixID + "widgetMatch_" + widgetID).html(
                    '<input type="text" aria-label="text" id="' +
                        prefixID +
                        "widgetMat_" +
                        widgetID +
                        '" style="width: 96%" />'
                );
                break;
            case "serviceID":
                $("#" + prefixID + "widgetCondition_" + widgetID).html(
                    '<select id="' +
                        prefixID +
                        "widgetCod_" +
                        widgetID +
                        '" class="chosen"  aria-label="title" style="width: 120px">\
                        <option value="=">IS</option>\
                        <option value="!=">IS NOT</option>\
                    </select>'
                );
                url =
                    rootURL === ""
                        ? "./api/system/services"
                        : rootURL + "api/system/services";
                $.ajax({
                    type: "GET",
                    url,
                    dataType: "json",
                    success: function (res) {
                        var services =
                            '<select id="' +
                            prefixID +
                            "widgetMat_" +
                            widgetID +
                            '" class="chosen" aria-label="services" style="width: 250px">';
                        for (var i in res) {
                            services +=
                                '<option value="' +
                                res[i].groupID +
                                '">' +
                                res[i].groupTitle +
                                "</option>";
                        }
                        services += "</select>";
                        $("#" + prefixID + "widgetMatch_" + widgetID).html(
                            services
                        );
                        chosenOptions();
                        if (callback != undefined) {
                            callback();
                        }
                    },
                });
                break;
            case "date":
            case "dateInitiated":
            case "dateSubmitted":
                $("#" + prefixID + "widgetCondition_" + widgetID).html(
                    `<select id="${prefixID}widgetCod_${widgetID}" style="width: 140px" class="chosen" aria-label="date">
                        <option value="=">ON</option>
                        <option value=">=">ON AND AFTER</option>
                        <option value="<=">ON AND BEFORE</option>
                    </select>`
                );
                $(`#${prefixID}widgetCod_${widgetID}`).on("change", checkDateStatus);
                $("#" + prefixID + "widgetMatch_" + widgetID).html(
                    '<input type="text" aria-label="text" id="' +
                        prefixID +
                        "widgetMat_" +
                        widgetID +
                        '" style="width: 200px" />'
                );
                if (!jQuery.ui) {
                    $.getScript(
                        app_js_path + "/jquery/jquery-ui.custom.min.js",
                        function () {
                            $(
                                "#" + prefixID + "widgetMat_" + widgetID
                            ).datepicker();
                        }
                    );
                } else {
                    $("#" + prefixID + "widgetMat_" + widgetID).datepicker();
                }
                break;
            case "categoryID":
                $("#" + prefixID + "widgetCondition_" + widgetID).html(
                    '<select id="' +
                        prefixID +
                        "widgetCod_" +
                        widgetID +
                        '" style="width: 140px" class="chosen" aria-label="categoryID">\
	            		<option value="=">IS</option>\
	            		<option value="!=">IS NOT</option>\
	            	</select>'
                );
                url =
                    rootURL === ""
                        ? "./api/workflow/categoriesUnabridged"
                        : rootURL + "api/workflow/categoriesUnabridged";
                $.ajax({
                    type: "GET",
                    url,
                    dataType: "json",
                    success: function (res) {
                        var categories =
                            '<select id="' +
                            prefixID +
                            "widgetMat_" +
                            widgetID +
                            '" class="chosen" aria-label="categories" style="width: 250px">';
                        for (var i in res) {
                            categories +=
                                '<option value="' +
                                res[i].categoryID +
                                '">' +
                                res[i].categoryName +
                                "</option>";
                        }
                        categories += "</select>";
                        $("#" + prefixID + "widgetMatch_" + widgetID).html(
                            categories
                        );
                        chosenOptions();
                        if (callback != undefined) {
                            callback();
                        }
                    },
                    cache: false,
                });
                break;
            case "userID":
                $("#" + prefixID + "widgetCondition_" + widgetID).html(
                    '<input type="hidden" id="' +
                        prefixID +
                        "widgetCod_" +
                        widgetID +
                        '" value="=" /> IS'
                );
                $("#" + prefixID + "widgetMatch_" + widgetID).html(
                    '<div id="' +
                        prefixID +
                        "widgetEmp_" +
                        widgetID +
                        '" style="width: 280px"></div><input type="hidden" id="' +
                        prefixID +
                        "widgetMat_" +
                        widgetID +
                        '" />'
                );
                createEmployeeSelectorWidget(widgetID);
                break;
            case "dependencyID":
                $("#" + prefixID + "widgetCondition_" + widgetID).html(
                    '<input type="hidden" id="' +
                        prefixID +
                        "widgetCod_" +
                        widgetID +
                        '" value="=" /> ='
                );
                url =
                    rootURL === ""
                        ? "./api/workflow/dependencies"
                        : rootURL + "api/workflow/dependencies";
                $.ajax({
                    type: "GET",
                    url,
                    dataType: "json",
                    success: function (res) {
                        var dependencies =
                            '<select id="' +
                            prefixID +
                            "widgetIndicator_" +
                            widgetID +
                            '" class="chosen" aria-label="dependencies" style="width: 250px">';
                        for (var i in res) {
                            dependencies +=
                                '<option value="' +
                                res[i].dependencyID +
                                '">' +
                                res[i].description +
                                "</option>";
                        }
                        dependencies += "</select>";
                        $("#" + prefixID + "widgetTerm_" + widgetID).after(
                            dependencies
                        );

                        var options =
                            '<select id="' +
                            prefixID +
                            "widgetMat_" +
                            widgetID +
                            '" class="chosen" aria-label="options" style="width: 250px">';
                        options += '<option value="1">Reviewed</option>';
                        options += '<option value="0">Not Reviewed</option>';
                        options +=
                            '<option value="-1">Returned to a previous step</option>';
                        options += "</select>";
                        $("#" + prefixID + "widgetMatch_" + widgetID).html(
                            options
                        );

                        chosenOptions();
                        $(
                            "#" +
                                prefixID +
                                "widgetTerm_" +
                                widgetID +
                                "_chosen"
                        ).css("display", "none");
                        if (callback != undefined) {
                            callback();
                        }
                    }
                });
                break;
            case "stepID":
                $("#" + prefixID + "widgetCondition_" + widgetID).html(
                    '<select id="' +
                        prefixID +
                        "widgetCod_" +
                        widgetID +
                        '" style="width: 140px" class="chosen" aria-label="categoryID">\
	            		<option value="=">IS</option>\
	            		<option value="!=" selected>IS NOT</option>\
	            	</select>'
                );
                $(`#${prefixID}widgetCod_${widgetID}`).on("change", checkDateStatus);
                url =
                    rootURL === ""
                        ? "./api/workflow/steps?x-filterData=workflowID,stepID,stepTitle,description"
                        : rootURL + "api/workflow/steps?x-filterData=workflowID,stepID,stepTitle,description";
                if(cache['api/workflow/steps'] == undefined) {
                    cache['api/workflow/steps'] = $.ajax({
                        type: "GET",
                        url,
                        dataType: "json"
                    }).then(res => {
                        // Hide standard workflows unless the GET parameter "dev" exists
                        if(new URLSearchParams(window.location.search).get('dev') == null) {
                            res = res.filter(step => step.workflowID > 0);
                        }
                        return res;
                    }).catch(error => {
                        console.error(error);
                    });
                }
                let allStepsData = await cache['api/workflow/steps'];
                let categories = `<select id="${prefixID}widgetMat_${widgetID}" class="chosen" aria-label="stepID" style="width: 250px">
                                    <option value="submitted">Submitted</option>
                                    <option value="deleted">Cancelled</option>
                                    <option value="resolved" selected>Resolved</option>
                                    <option value="actionable">Actionable by me</option>`;
                //categories += '<option value="destruction">Scheduled for Destruction</option>';
                for (let i in allStepsData) {
                    categories += `<option value="${allStepsData[i].stepID}">${allStepsData[i].description}: ${allStepsData[i].stepTitle}</option>`;
                }
                categories += "</select>";
                // quick and dirty fix to avoid a race condition related to common
                // implementations of formSearch. Since the new default UI will trigger
                // the parent ajax call, we don't want to overwrite the existing widget.
                if($("#" + prefixID + "widgetTerm_" + widgetID).val() == 'stepID') {
                    $("#" + prefixID + "widgetMatch_" + widgetID).html(
                        categories
                    );
                }

                if (callback != undefined) {
                    callback();
                }
                break;
            case "data":
                let resultFilter =
                    "?x-filterData=indicatorID,categoryName,name,format";
                url =
                    rootURL === ""
                        ? `./api/form/indicator/list${resultFilter}`
                        : rootURL + `api/form/indicator/list${resultFilter}`;
                $.ajax({
                    type: "GET",
                    url,
                    dataType: "json",
                    success: function (res) {
                        var indicators =
                            '<select id="' +
                            prefixID +
                            "widgetIndicator_" +
                            widgetID +
                            '" class="chosen" aria-label="data" style="width: 250px">';
                        indicators +=
                            '<option value="' +
                            ALL_DATA_FIELDS +
                            '">Any standard data field</option>';
                        indicators +=
                            '<option value="' +
                            ALL_OC_EMPLOYEE_DATA_FIELDS +
                            '">Any Org. Chart employee field</option>';
                        for (var i in res) {
                            indicators +=
                                '<option value="' +
                                res[i].indicatorID +
                                '">' +
                                res[i].categoryName +
                                ": " +
                                res[i].name +
                                "</option>";
                        }
                        indicators += "</select><br />";
                        $("#" + prefixID + "widgetTerm_" + widgetID).after(
                            indicators
                        );
                        chosenOptions();
                        $("#" + prefixID + "widgetIndicator_" + widgetID).css(
                            "float",
                            "right"
                        );
                        $("#" + prefixID + "widgetIndicator_" + widgetID).on(
                            "change chosen:updated",
                            function () {
                                iID = $(
                                    "#" +
                                        prefixID +
                                        "widgetIndicator_" +
                                        widgetID
                                ).val();

                                /* Set default conditions for "any data field"
                                 * Negative conditions are excluded because more extensive postprocessing
                                 * is needed for logically valid results
                                 */
                                if (iID == ALL_DATA_FIELDS) {
                                    $(
                                        "#" +
                                            prefixID +
                                            "widgetCondition_" +
                                            widgetID
                                    ).html(
                                        '<select id="' +
                                            prefixID +
                                            "widgetCod_" +
                                            widgetID +
                                            '" class="chosen" aria-label="condition" style="width: 120px">\
                                        <option value="MATCH ALL">CONTAINS</option>\
                                        <option value="MATCH">CONTAINS EITHER</option>\
					            		<option value="=">=</option>\
										<option value="LIKE">HAS FRAGMENT</option>\
					            	</select>'
                                    );
                                    $(
                                        "#" +
                                            prefixID +
                                            "widgetMatch_" +
                                            widgetID
                                    ).html(
                                        '<input type="text" aria-label="text" id="' +
                                            prefixID +
                                            "widgetMat_" +
                                            widgetID +
                                            '" style="width: 200px" />'
                                    );
                                    chosenOptions();
                                } else if (iID == ALL_OC_EMPLOYEE_DATA_FIELDS) {
                                    // set conditions for orgchart employee fields
                                    $(
                                        "#" +
                                            prefixID +
                                            "widgetCondition_" +
                                            widgetID
                                    ).html(
                                        '<input type="hidden" id="' +
                                            prefixID +
                                            "widgetCod_" +
                                            widgetID +
                                            '" value="=" /> IS'
                                    );
                                    $(
                                        "#" +
                                            prefixID +
                                            "widgetMatch_" +
                                            widgetID
                                    ).html(
                                        '<div id="' +
                                            prefixID +
                                            "widgetEmp_" +
                                            widgetID +
                                            '" style="width: 280px"></div><input type="hidden" id="' +
                                            prefixID +
                                            "widgetMat_" +
                                            widgetID +
                                            '" />'
                                    );
                                    createEmployeeSelectorWidget(
                                        widgetID,
                                        "empUID"
                                    );
                                }

                                for (var i in res) {
                                    if (res[i].indicatorID == iID) {
                                        var format = "";
                                        var tIdx = res[i].format.indexOf("\n");
                                        if (tIdx == -1) {
                                            format = res[i].format;
                                        } else {
                                            format = res[i].format
                                                .substr(0, tIdx)
                                                .trim();
                                        }
                                        switch (format) {
                                            case "number":
                                            case "currency":
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetCondition_" +
                                                        widgetID
                                                ).html(
                                                    '<select id="' +
                                                        prefixID +
                                                        "widgetCod_" +
                                                        widgetID +
                                                        '" class="chosen" aria-label="currency" style="width: 55px">\
								            		<option value="=">=</option>\
								            		<option value=">">></option>\
								            		<option value=">=">>=</option>\
								            		<option value="<"><</option>\
								            		<option value="<="><=</option>\
								            	</select>'
                                                );
                                                chosenOptions();
                                                break;
                                            case "date":
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetCondition_" +
                                                        widgetID
                                                ).html(
                                                    '<select id="' +
                                                        prefixID +
                                                        "widgetCod_" +
                                                        widgetID +
                                                        '" style="width: 140px" class="chosen" aria-label="date">\
                            	            		<option value="=">ON</option>\
                            	            		<option value=">=">ON AND AFTER</option>\
                            	            		<option value="<=">ON AND BEFORE</option>\
                            	            	</select>'
                                                );
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetMatch_" +
                                                        widgetID
                                                ).html(
                                                    '<input type="text" aria-label="text" id="' +
                                                        prefixID +
                                                        "widgetMat_" +
                                                        widgetID +
                                                        '" style="width: 200px" />'
                                                );
                                                if (!jQuery.ui) {
                                                    $.getScript(
                                                        "js/jquery/jquery-ui.custom.min.js",
                                                        function () {
                                                            $(
                                                                "#" +
                                                                    prefixID +
                                                                    "widgetMat_" +
                                                                    widgetID
                                                            ).datepicker();
                                                        }
                                                    );
                                                } else {
                                                    $(
                                                        "#" +
                                                            prefixID +
                                                            "widgetMat_" +
                                                            widgetID
                                                    ).datepicker();
                                                }
                                                chosenOptions();
                                                break;
                                            case "orgchart_employee":
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetCondition_" +
                                                        widgetID
                                                ).html(
                                                    '<select id="' +
                                                        prefixID +
                                                        "widgetCod_" +
                                                        widgetID +
                                                        '" class="chosen" aria-label="condition" style="width: 120px">\
								            		<option value="=">IS</option>\
													<option value="!=">IS NOT</option>\
								            	</select>'
                                                );
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetMatch_" +
                                                        widgetID
                                                ).html(
                                                    '<div id="' +
                                                        prefixID +
                                                        "widgetEmp_" +
                                                        widgetID +
                                                        '" style="width: 280px"></div><input type="hidden" id="' +
                                                        prefixID +
                                                        "widgetMat_" +
                                                        widgetID +
                                                        '" />'
                                                );
                                                chosenOptions();
                                                createEmployeeSelectorWidget(
                                                    widgetID,
                                                    "empUID"
                                                );
                                                break;
                                            case "orgchart_position":
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetCondition_" +
                                                        widgetID
                                                ).html(
                                                    '<select id="' +
                                                        prefixID +
                                                        "widgetCod_" +
                                                        widgetID +
                                                        '" class="chosen" aria-label="condition" style="width: 120px">\
								            		<option value="=">IS</option>\
													<option value="!=">IS NOT</option>\
								            	</select>'
                                                );
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetMatch_" +
                                                        widgetID
                                                ).html(
                                                    '<div id="' +
                                                        prefixID +
                                                        "widgetPos_" +
                                                        widgetID +
                                                        '" style="width: 280px"></div><input type="hidden" id="' +
                                                        prefixID +
                                                        "widgetMat_" +
                                                        widgetID +
                                                        '" />'
                                                );
                                                chosenOptions();
                                                createPositionSelectorWidget(
                                                    widgetID,
                                                    "empUID"
                                                );
                                                break;
                                            case "orgchart_group":
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetCondition_" +
                                                        widgetID
                                                ).html(
                                                    '<select id="' +
                                                        prefixID +
                                                        "widgetCod_" +
                                                        widgetID +
                                                        '" class="chosen" aria-label="condition" style="width: 120px">\
								            		<option value="=">IS</option>\
													<option value="!=">IS NOT</option>\
								            	</select>'
                                                );
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetMatch_" +
                                                        widgetID
                                                ).html(
                                                    '<div id="' +
                                                        prefixID +
                                                        "widgetGrp_" +
                                                        widgetID +
                                                        '" style="width: 280px"></div><input type="hidden" id="' +
                                                        prefixID +
                                                        "widgetMat_" +
                                                        widgetID +
                                                        '" />'
                                                );
                                                chosenOptions();
                                                createGroupSelectorWidget(
                                                    widgetID
                                                );
                                                break;
                                            case "dropdown":
                                            case "radio":
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetCondition_" +
                                                        widgetID
                                                ).html(
                                                    '<select id="' +
                                                        prefixID +
                                                        "widgetCod_" +
                                                        widgetID +
                                                        '" class="chosen" aria-label="condition" style="width: 120px">\
                                                    <option value="=">IS</option>\
                                                    <option value="!=">IS NOT</option>\
                                                    <option value="MATCH ALL">CONTAINS</option>\
                                                    <option value="NOT MATCH">DOES NOT CONTAIN</option>\
                                                    <option value="MATCH">CONTAINS EITHER</option>\
								            		<option value=">">></option>\
								            		<option value=">=">>=</option>\
								            		<option value="<"><</option>\
								            		<option value="<="><=</option>\
                                                    <option value="LIKE">HAS FRAGMENT</option>\
                                                    <option value="NOT LIKE">DOES NOT HAVE FRAGMENT</option>\
								            	</select>'
                                                );
                                                var resOptions =
                                                    res[i].format.split("\n");
                                                resOptions.shift();
                                                var options =
                                                    '<select id="' +
                                                    prefixID +
                                                    "widgetMat_" +
                                                    widgetID +
                                                    '" class="chosen" aria-label="options" style="width: 250px">';
                                                for (var i in resOptions) {
                                                    var currOption =
                                                        resOptions[i].indexOf(
                                                            "default:"
                                                        ) == -1
                                                            ? resOptions[
                                                                  i
                                                              ].trim()
                                                            : resOptions[i]
                                                                  .substr(8)
                                                                  .trim();
                                                    options +=
                                                        '<option value="' +
                                                        currOption +
                                                        '">' +
                                                        currOption +
                                                        "</option>";
                                                }
                                                options += "</select>";

                                                renderSingleSelectInputType(
                                                    widgetID,
                                                    options
                                                );

                                                $(
                                                    `#${prefixID}widgetCod_${widgetID}`
                                                ).on("change", function () {
                                                    renderSingleSelectInputType(
                                                        widgetID,
                                                        options
                                                    );
                                                });
                                                break;
                                            default:
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetCondition_" +
                                                        widgetID
                                                ).html(
                                                    '<select id="' +
                                                        prefixID +
                                                        "widgetCod_" +
                                                        widgetID +
                                                        '" class="chosen" aria-label="condition" style="width: 120px">\
                                                        <option value="MATCH ALL">CONTAINS</option>\
                                                        <option value="NOT MATCH">DOES NOT CONTAIN</option>\
                                                        <option value="MATCH">CONTAINS EITHER</option>\
                                                        <option value="=">=</option>\
                                                        <option value="!=">!=</option>\
                                                        <option value="LIKE">HAS FRAGMENT</option>\
                                                        <option value="NOT LIKE">DOES NOT HAVE FRAGMENT</option>\
								            	</select>'
                                                );
                                                $(
                                                    "#" +
                                                        prefixID +
                                                        "widgetMatch_" +
                                                        widgetID
                                                ).html(
                                                    '<input type="text" aria-label="text" id="' +
                                                        prefixID +
                                                        "widgetMat_" +
                                                        widgetID +
                                                        '" style="width: 200px" />'
                                                );
                                                chosenOptions();
                                                break;
                                        }
                                    }
                                }
                            }
                        );
                        $("#" + prefixID + "widgetIndicator_" + widgetID).trigger("chosen:updated"); // trigger render on first load
                        $(
                            "#" +
                                prefixID +
                                "widgetTerm_" +
                                widgetID +
                                "_chosen"
                        ).css("display", "none");
                        if (callback != undefined) {
                            callback();
                        }
                    },
                });
                break;
            case "recordID":
                $("#" + prefixID + "widgetCondition_" + widgetID).html(
                    '<select id="' +
                        prefixID +
                        "widgetCod_" +
                        widgetID +
                        '" class="chosen" aria-label="condition" style="width: 55px">\
		            		<option value="=">=</option>\
		            		<option value=">">></option>\
		            		<option value=">=">>=</option>\
		            		<option value="<"><</option>\
		            		<option value="<="><=</option>\
		            	</select>'
                );
                $("#" + prefixID + "widgetMatch_" + widgetID).html(
                    '<input type="text" aria-label="text" id="' +
                        prefixID +
                        "widgetMat_" +
                        widgetID +
                        '" style="width: 200px" />'
                );
                break;
            case "stepAction":
                    $("#" + prefixID + "widgetCondition_" + widgetID).html(`<select id="${prefixID}widgetCod_${widgetID}" style="width: 140px" class="chosen" aria-label="categoryID">
                            <option value="=">IS</option>
                            <option value="!=">IS NOT</option>
                        </select>`);
                    $("#" + prefixID + "widgetMatch_" + widgetID).html('');
                    if(rootURL == "") {
                        url = "./api/workflow/steps?x-filterData=workflowID,stepID,stepTitle,description";
                    } else {
                        url = rootURL + "api/workflow/steps?x-filterData=workflowID,stepID,stepTitle,description";
                    }

                    if(cache['api/workflow/steps'] == undefined) {
                        cache['api/workflow/steps'] = $.ajax({
                            type: "GET",
                            url,
                            dataType: "json"
                        }).then(res => {
                            // Hide standard workflows unless the GET parameter "dev" exists
                            if(new URLSearchParams(window.location.search).get('dev') == null) {
                                res = res.filter(step => step.workflowID > 0);
                            }
                            return res;
                        }).catch(err => console.error(err));
                    }

                    let workflowStepsData = await cache['api/workflow/steps'];

                    let groupedStepData = {};
                    for(let i in workflowStepsData) {
                        groupedStepData[workflowStepsData[i].workflowID] = groupedStepData[workflowStepsData[i].workflowID] || {};
                        groupedStepData[workflowStepsData[i].workflowID].description = workflowStepsData[i].description;
                        groupedStepData[workflowStepsData[i].workflowID].steps = groupedStepData[workflowStepsData[i].workflowID].steps || {};
                        groupedStepData[workflowStepsData[i].workflowID].steps[workflowStepsData[i].stepID] = workflowStepsData[i].stepTitle;
                    }

                    let workflowSteps = `<select id="${prefixID}widgetIndicator_${widgetID}" class="chosen" aria-label="workflow steps" style="width: 250px">`;
                    let stepWorkflowIdx = {};
                    workflowSteps += `<option value="">Select a workflow step...</option>`;
                    for(let i in groupedStepData) {
                        workflowSteps += `<optgroup label="${groupedStepData[i].description}">`;
                        for(let j in groupedStepData[i].steps) {
                            workflowSteps += `<option value="${j}">${groupedStepData[i].steps[j]}</option>`;
                            stepWorkflowIdx[j] = i;
                        }
                        workflowSteps += `</optgroup>`;
                    }
                    workflowSteps += "</select>";
                    $("#" + prefixID + "widgetTerm_" + widgetID).after(
                        workflowSteps
                    );

                    if (callback != undefined) {
                        callback();
                    }

                    let options = await getStepActionOptions(stepWorkflowIdx, widgetID);
                    renderSingleSelectInputType(widgetID, options);

                    $("#" + prefixID + "widgetIndicator_" + widgetID).on("change", async () => {
                        options = await getStepActionOptions(stepWorkflowIdx, widgetID);
                        renderSingleSelectInputType(widgetID, options);
                    });

                    $(`#${prefixID}widgetTerm_${widgetID}_chosen`).css("display", "none");

                    if (callback != undefined) {
                        callback();
                    }
                break;
            default:
                $("#" + prefixID + "widgetCondition_" + widgetID).html(
                    '<select id="' +
                        prefixID +
                        "widgetCod_" +
                        widgetID +
                        '" class="chosen" aria-label="condition" style="width: 55px">\
		            		<option value="=">=</option>\
		            		<option value=">">></option>\
		            		<option value=">=">>=</option>\
		            		<option value="<"><</option>\
		            		<option value="<="><=</option>\
		            		<option value="LIKE">CONTAINS</option>\
		            	</select>'
                );
                $("#" + prefixID + "widgetMatch_" + widgetID).html(
                    '<input type="text" aria-label="text" id="' +
                        prefixID +
                        "widgetMat_" +
                        widgetID +
                        '" style="width: 200px" />'
                );
                break;
        }
        chosenOptions();
    }

    /**
     * @memberOf LeafFormSearch
     */
    function newSearchWidget(gate) {
        // @TODO IE Fix (No overloading)
        if (gate === undefined) {
            gate = "AND";
        }

        let widget = `<tr id="${prefixID}widget_${widgetCounter}" style="border-spacing: 5px">
                <td id="${prefixID}widgetRemove_${widgetCounter}">
                    <button type="button" id="${prefixID}widgetRemoveButton_${widgetCounter}" aria-label="remove filter row" style="cursor: pointer">
                        <img src="${rootURL}dynicons/?img=list-remove.svg&w=16" alt="" />
                    </button>
                </td>
                <td style="text-align: center">
                    <strong id="${prefixID}widgetGate_${widgetCounter}" value="${gate}">${gate}</strong>
                </td>` +
			'<td><select id="' +
            prefixID +
            "widgetTerm_" +
            widgetCounter +
            '" style="width: 150px" class="chosen" aria-label="condition">\
                            <option value="stepID">Current Status</option>\
            				<option value="data">Data Field ...</option>\
            				<option value="dateSubmitted">Date Submitted</option>\
                            <option value="userID">Initiator</option>\
            				<option value="serviceID">Service</option>\
            				<option value="title">Title</option>\
            				<option value="categoryID">Type</option>\
                            <option value="recordID">Record ID</option>\
                            <option value="stepAction">Record Actions ...</option>\
            				<option value="dependencyID">Requirement ...</option>\
            				</select></td>\
			            <td id="' +
            prefixID +
            "widgetCondition_" +
            widgetCounter +
            '"></td>\
						<td id="' +
            prefixID +
            "widgetMatch_" +
            widgetCounter +
            '"></td>\
					  </tr>';

        $(widget).appendTo("#" + prefixID + "searchTerms");
        renderWidget(widgetCounter);
        firstChild();

        $("#" + prefixID + "widgetTerm_" + widgetCounter).on(
            "change",
            "",
            widgetCounter,
            function (e) {
                renderWidget(e.data);
                checkDateStatus();
                chosenOptions();
            }
        );
        $("#" + prefixID + "widgetRemoveButton_" + widgetCounter).on(
            "click",
            "",
            widgetCounter,
            function (e) {
                $("#" + prefixID + "widget_" + e.data).remove();
                $("#" + prefixID + "widgetOp_" + e.data).remove();
                checkDateStatus();
                firstChild();
            }
        );

        widgetCounter++;
    }

    /**
     * @memberOf LeafFormSearch
     */
    function generateSearchQuery() {
        leafFormQuery.clearTerms();
        for (var i = 0; i < widgetCounter; i++) {
            if ($("#" + prefixID + "widgetTerm_" + i).val() != undefined) {
                term = $("#" + prefixID + "widgetTerm_" + i).val();
                if (term != "data" && term != "dependencyID" && term != "stepAction") {
                    id = $("#" + prefixID + "widgetTerm_" + i).val();
                    cod = $("#" + prefixID + "widgetCod_" + i).val();
                    match = $("#" + prefixID + "widgetMat_" + i).val();
                    gate = document.getElementById(
                        prefixID + "widgetGate_" + i
                    ).innerHTML; // Assign Operator
                    if (cod == "LIKE") {
                        match = "*" + match + "*";
                    }
                    leafFormQuery.addTerm(id, cod, match, gate);
                } else {
                    id = $("#" + prefixID + "widgetTerm_" + i).val();
                    indicatorID = $(
                        "#" + prefixID + "widgetIndicator_" + i
                    ).val();
                    cod = $("#" + prefixID + "widgetCod_" + i).val();
                    match = $("#" + prefixID + "widgetMat_" + i).val();
                    gate = document.getElementById(
                        prefixID + "widgetGate_" + i
                    ).innerHTML; // Assign Operator
                    if (cod == "LIKE") {
                        match = "*" + match + "*";
                    }
                    leafFormQuery.addDataTerm(
                        id,
                        indicatorID,
                        cod,
                        match,
                        gate
                    );
                }
            }
        }
        if (leafFormQuery.getQuery().terms.length > 0) {
            $("#" + prefixID + "searchtxt").val(
                JSON.stringify(leafFormQuery.getQuery().terms)
            );
        } else {
            $("#" + prefixID + "searchtxt").val("*");
        }
    }

    /**
     * Purpose: Update Chosen Options for Fields
     * @memberOf LeafFormSearch
     */
    function chosenOptions() {
        $(".chosen").chosen({
            disable_search_threshold: 6,
            width: "100%",
        }); // needs to be here due to chosen issue with display:none
        $('input.chosen-search-input').attr('role', 'combobox');
    }

    /**
     * Purpose: Refresh First Child in Search
     * @memberOf LeafFormSearch
     */
    function firstChild() {
        if (
            document.getElementById(prefixID + "searchTerms").children[0] !=
            undefined
        ) {
            document.getElementById(
                prefixID + "searchTerms"
            ).children[0].children[1].style.display = "none"; // Hide First Operator
            document
                .getElementById(prefixID + "searchTerms")
                .children[0].children[2].setAttribute("colspan", "2"); // Resize col
            document.getElementById(
                prefixID + "searchTerms"
            ).children[0].children[2].style.width = "175px";
            document.getElementById(
                prefixID + "searchTerms"
            ).children[0].children[3].style.width = "130px";
        }
    }

    return {
        init: init,
        renderUI: renderUI,
        setOrgchartPath: setOrgchartPath,
        focus: focus,
        getPrefixID: function () {
            return prefixID;
        },
        getSearchInput: function () {
            return $("#" + prefixID + "searchtxt").val();
        },
        getResultContainerID: function () {
            return prefixID + "_result";
        },
        getLastSearch: getLastSearch,
        generateQuery: generateSearchQuery,
        getLeafFormQuery: function () {
            return leafFormQuery;
        },
        renderPreviousAdvancedSearch: renderPreviousAdvancedSearch,
        setSearchFunc: setSearchFunc,
        search: search,
        showBusy: showBusy,
        showNotBusy: showNotBusy,
        setRootURL: function (url) {
            rootURL = url;
        },
        setJsPath: function (url) {
            app_js_path = url;
        },
    };
};
