/************************
 Form Search Widget for multiple sites
 Search features are limited to common denominators across all LEAF sites.
 */

var LeafFormSearchMultisite = function (containerID) {
    let prefixID =
        "LeafFormSearchMultisite" + Math.floor(Math.random() * 1000) + "_";
    let localStorageNamespace =
        "LeafFormSearchMultisite" + getLocalStorageHash();
    let orgchartPath = "";
    let timer = 0;
    let q = "";
    let intervalID = null;
    let currRequest = null;
    let numResults = 0;
    let searchFunc = null;
    let leafFormQuery = new LeafFormQuery();
    let widgetCounter = 0;
    let rootURL = "";
    let app_js_path = "";

    // constants
    const ALL_DATA_FIELDS = "0";
    const ALL_OC_EMPLOYEE_DATA_FIELDS = "0.0";

    function xscrubJs(s){
    var d = document.createElement('div');
    d.textContent = s == null ? '' : String(s);
    return d.innerHTML;
    }

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
                'searchtxt" name="searchtxt" size="50" title="Enter your search text" value="" />\
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
		        <button type="button" class="buttonNorm" id="' +
                prefixID +
                'addTerm" style="float: left">And...</button>\
		        <button type="button" class="buttonNorm" id="' +
                prefixID +
                'orTerm" style="float: left">Or...</button>\
		        <br /><br />\
		        <button type="button" id="' +
                prefixID +
                'advancedSearchApply" class="buttonNorm" style="text-align: center; width: 100%">Apply Filters</button>\
		    </fieldset>\
		    </div>\
		    <div id="' +
                prefixID +
                '_result" style="margin-top: 8px" role="status" aria-label="Search Results">\
		    </div>'
        );

        let searchOrigWidth = 0;
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

        newSearchWidget();
    }

    /**
     * @memberOf LeafFormSearchMultisite
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
            let lastSearch = getLastSearch();

            let isJSON = true;
            let advSearch = {};
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
     * @memberOf LeafFormSearchMultisite
     * prevQuery - optional JSON object
     */
    function renderPreviousAdvancedSearch(prevQuery) {
        let isJSON = true;
        let advSearch = {};
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
            for (let i = 1; i < advSearch.length; i++) {
                newSearchWidget(advSearch[i].gate);
                firstChild();
            }
            for (let i = 0; i < advSearch.length; i++) {
                $("#" + prefixID + "widgetTerm_" + i).val(advSearch[i].id);
                $("#" + prefixID + "widgetTerm_" + i).trigger("chosen:updated");
                if (
                    advSearch[i].indicatorID != undefined ||
                    advSearch[i].id == "serviceID" ||
                    advSearch[i].id == "categoryID" ||
                    advSearch[i].id == "stepID"
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
                                $("#" + prefixID + "widgetMat_" + widgetID).val(
                                    match.replace(/\*/g, "")
                                );
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
                if (typeof advSearch[i].match == "string") {
                    $("#" + prefixID + "widgetMat_" + i).val(
                        advSearch[i].match.replace(/\*/g, "")
                    );
                }
            }
        }
    }

    /**
     * @memberOf LeafFormSearchMultisite
     * From: http://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/
     */
    function getLocalStorageHash() {
        let hash = 0,
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
     * @memberOf LeafFormSearchMultisite
     */
    function setOrgchartPath(path) {
        orgchartPath = path;
    }

    /**
     * @memberOf LeafFormSearchMultisite
     */
    function getLastSearch() {
        return localStorage.getItem(localStorageNamespace + ".search");
    }

    /**
     * @memberOf LeafFormSearchMultisite
     */
    function setSearchFunc(func) {
        searchFunc = func;
    }

    /**
     * @memberOf LeafFormSearchMultisite
     */
    function search(txt) {
        if (txt != "*") {
            localStorage.setItem(localStorageNamespace + ".search", txt);
        }
        return searchFunc(txt);
    }

    /**
     * @memberOf LeafFormSearchMultisite
     */
    function inputLoop() {
        if ($("#" + prefixID + "searchtxt") == null) {
            clearInterval(intervalID);
            return false;
        }
        timer += timer > 5000 ? 0 : 200;
        if (timer > 400) {
            let txt = $("#" + prefixID + "searchtxt").val();

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
     * @memberOf LeafFormSearchMultisite
     */
    function focus() {
        $("#" + prefixID + "searchtxt").focus();
    }

    /**
     * @memberOf LeafFormSearchMultisite
     */
    function showBusy() {
        $("#" + prefixID + "searchIcon").css("display", "none");
        $("#" + prefixID + "searchIconBusy").css("display", "inline");
        $(".status").text("Loading");
    }

    /**
     * @memberOf LeafFormSearchMultisite
     */
    function showNotBusy() {
        $("#" + prefixID + "searchIcon").css("display", "inline");
        $("#" + prefixID + "searchIconBusy").css("display", "none");
    }

    /**
     * @memberOf LeafFormSearchMultisite
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
        }
    }

    /**
     * @memberOf LeafFormSearchMultisite
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
     * @memberOf LeafFormSearchMultisite
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
     * @memberOf LeafFormSearchMultisite
     */
    function renderSingleSelectInputType(widgetID, options) {
        switch ($("#" + prefixID + "widgetCod_" + widgetID).val()) {
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

    /**
     * @memberOf LeafFormSearchMultisite
     */
    function renderWidget(widgetID, callback) {
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
                $.ajax({
                    type: "GET",
                    url: "./api/system/services",
                    dataType: "json",
                    success: function (res) {
                        let services =
                            '<select id="' +
                            prefixID +
                            "widgetMat_" +
                            widgetID +
                            '" class="chosen" aria-label="services" style="width: 250px">';
                        for (let i in res) {
                            services +=
                                '<option value="' +
                                xscrubJs(res[i].groupID) +
                                '">' +
                                xscrubJs(res[i].groupTitle) +
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
                $.ajax({
                    type: "GET",
                    url: "./api/workflow/categoriesUnabridged",
                    dataType: "json",
                    success: function (res) {
                        let categories =
                            '<select id="' +
                            prefixID +
                            "widgetMat_" +
                            widgetID +
                            '" class="chosen" aria-label="categories" style="width: 250px">';
                        for (let i in res) {
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
                $.ajax({
                    type: "GET",
                    url: "./api/workflow/dependencies",
                    dataType: "json",
                    success: function (res) {
                        let dependencies =
                            '<select id="' +
                            prefixID +
                            "widgetIndicator_" +
                            widgetID +
                            '" class="chosen" aria-label="dependencies" style="width: 250px">';
                        for (let i in res) {
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

                        let options =
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
                    },
                    cache: false,
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
	            		<option value="!=">IS NOT</option>\
	            	</select>'
                );
                let categories =
                    '<select id="' +
                    prefixID +
                    "widgetMat_" +
                    widgetID +
                    '" class="chosen" aria-label="stepID" style="width: 250px">';
                categories += '<option value="submitted">Submitted</option>';
                categories += '<option value="deleted">Cancelled</option>';
                categories += '<option value="resolved">Resolved</option>';
                categories +=
                    '<option value="actionable">Actionable by me</option>';

                categories += "</select>";
                $("#" + prefixID + "widgetMatch_" + widgetID).html(categories);
                chosenOptions();
                if (callback != undefined) {
                    callback();
                }
                break;
            case "data":
                let indicators =
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

                indicators += "</select><br />";
                $("#" + prefixID + "widgetTerm_" + widgetID).after(indicators);
                chosenOptions();
                $("#" + prefixID + "widgetIndicator_" + widgetID).css(
                    "float",
                    "right"
                );
                $("#" + prefixID + "widgetIndicator_" + widgetID).on(
                    "change chosen:updated",
                    function () {
                        iID = $(
                            "#" + prefixID + "widgetIndicator_" + widgetID
                        ).val();

                        // set default conditions for "any data field"
                        if (iID == ALL_DATA_FIELDS) {
                            $(
                                "#" + prefixID + "widgetCondition_" + widgetID
                            ).html(
                                '<select id="' +
                                    prefixID +
                                    "widgetCod_" +
                                    widgetID +
                                    '" class="chosen" aria-label="condition" style="width: 120px">\
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
                                    '" style="width: 200px" />'
                            );
                            chosenOptions();
                        } else if (iID == ALL_OC_EMPLOYEE_DATA_FIELDS) {
                            // set conditions for orgchart employee fields
                            $(
                                "#" + prefixID + "widgetCondition_" + widgetID
                            ).html(
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
                            createEmployeeSelectorWidget(widgetID, "empUID");
                        }
                    }
                );
                $("#" + prefixID + "widgetTerm_" + widgetID + "_chosen").css(
                    "display",
                    "none"
                );
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
    }

    /**
     * @memberOf LeafFormSearchMultisite
     */
    function newSearchWidget(gate) {
        // @TODO IE Fix (No overloading)
        if (gate === undefined) {
            gate = "AND";
        }
        let widget =
            '<tr id="' +
            prefixID +
            "widget_" +
            widgetCounter +
            '" style="border-spacing: 5px">\
						<td id="' +
            prefixID +
            "widgetRemove_" +
            widgetCounter +
            '"><button type="button" id="widgetRemoveButton" aria-label="remove search term"><img src="' +
            rootURL +
            'dynicons/?img=list-remove.svg&w=16" style="cursor: pointer"></button></td>\
						<td style="text-align: center"><strong id="' +
            prefixID +
            "widgetGate_" +
            widgetCounter +
            '" value="' +
            gate +
            '">' +
            gate +
            '</strong></td>\
						<td><select id="' +
            prefixID +
            "widgetTerm_" +
            widgetCounter +
            '" style="width: 150px" class="chosen" aria-label="condition">\
            				<option value="title">Title</option>\
            				<option value="dateSubmitted">Date Submitted</option>\
            				<option value="userID">Initiator</option>\
            				<option value="stepID">Current Status</option>\
            				<option value="data">Data Field</option>\
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
                chosenOptions();
            }
        );
        $("#" + prefixID + "widgetRemove_" + widgetCounter).on(
            "click",
            "",
            widgetCounter,
            function (e) {
                $("#" + prefixID + "widget_" + e.data).remove();
                $("#" + prefixID + "widgetOp_" + e.data).remove();
                firstChild();
            }
        );

        widgetCounter++;
    }

    /**
     * @memberOf LeafFormSearchMultisite
     */
    function generateSearchQuery() {
        leafFormQuery.clearTerms();
        for (let i = 0; i < widgetCounter; i++) {
            if ($("#" + prefixID + "widgetTerm_" + i).val() != undefined) {
                term = $("#" + prefixID + "widgetTerm_" + i).val();
                if (term != "data" && term != "dependencyID") {
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
     * @memberOf LeafFormSearchMultisite
     */
    function chosenOptions() {
        $(".chosen").chosen({
            disable_search_threshold: 6,
            width: "100%",
        }); // needs to be here due to chosen issue with display:none
    }

    /**
     * Purpose: Refresh First Child in Search
     * @memberOf LeafFormSearchMultisite
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
