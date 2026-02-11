/************************
    Workflow widget
*/
var workflow;
var workflowModule = new Object();
var workflowStepModule = new Object();
var LeafWorkflow = function (containerID, CSRFToken) {
    var containerID = containerID;
    var CSRFToken = CSRFToken;
    var prefixID = "LeafFlow" + Math.floor(Math.random() * 1000) + "_";
    var htmlFormID = prefixID + "record";
    var dialog;
    var currRecordID = 0;
    var postModifyCallback;
    var antiDblClick = 0;
    var actionPreconditionFunc;
    var actionSuccessCallback;
    var rootURL = "";
    let extraParams;
    const bgColorReg = /^#[0-9a-f]{6}$/i;
    const fColorReg = /^[a-z]+?$/i;

    /**
     * @memberOf LeafWorkflow
     */
    function darkenColor(color) {
        const bgColor = parseInt(color.substring(1), 16);
        r = (bgColor & 0xff0000) >> 16;
        g = (bgColor & 0x00ff00) >> 8;
        b = bgColor & 0x0000ff;

        factor = -0.1;
        r = r + Math.round(r * factor);
        g = g + Math.round(g * factor);
        b = b + Math.round(b * factor);

        return "#" + ((r << 16) + (g << 8) + b).toString(16);
    }

    function scrubHTML(input) {
        if(input == undefined) {
            return '';
        }
        let t = new DOMParser().parseFromString(input, 'text/html').body;
        while(input != t.textContent) {
            return scrubHTML(t.textContent);
        }
        return t.textContent;
    }

    /**
     * @memberOf LeafWorkflow
     */
    function applyAction(data) {
        let required = false;

        if (antiDblClick == 1) {
            return 1;
        } else {
            antiDblClick = 1;
        }

        if (typeof data["require_comment"]["required"] === "boolean") {
            required = data["require_comment"]["required"];
        } else {
            if (data["require_comment"]["required"] === "") {
                required = false;
            } else {
                required =
                    data["require_comment"]["required"].toLowerCase() ===
                    "true";
            }
        }

        if (
            required &&
            ($("#comment_dep-" + data["dependencyID"]).val() == "" ||
                $("#comment_dep" + data["dependencyID"]).val() == "")
        ) {
            dialog_ok.setTitle("Comment Required");
            dialog_ok.setContent(
                "Please enter a comment. A comment is required to send this back."
            );
            dialog_ok.setSaveHandler(function () {
                dialog_ok.clearDialog();
                dialog_ok.hide();
                if (
                    document.getElementById(
                        "comment_dep-" + data["dependencyID"]
                    )
                ) {
                    $("#comment_dep-" + data["dependencyID"]).focus();
                } else {
                    $("#comment_dep" + data["dependencyID"]).focus();
                }
            });
            dialog_ok.show();
            antiDblClick = 0;
        } else {
            // Check if CSRFToken has Changed (Timeout Fix)
            $.ajax({
                type: "GET",
                url: rootURL + "api/formWorkflow/getCSRFToken",
                async: false,
                success: function (res) {
                    data.CSRFToken = res;
                },
                error: function (err) {
                    alert("Session Expired");
                },
            });

            $("#workflowbox_dep" + data["dependencyID"]).html(
                '<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Applying action... <img src="' +
                    rootURL +
                    'images/largespinner.gif" alt="" /></div>'
            );
            $.ajax({
                type: "POST",
                url: rootURL + "api/formWorkflow/" + currRecordID + "/apply",
                data: data,
                success: function (response) {
                    if (response !== "Invalid Token.") {
                        if (response.errors.length === 0) {
                            $("#workflowbox_dep" + data["dependencyID"]).html(
                                '<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Action applied!</div>'
                            );
                            $("#workflowbox_dep" + data["dependencyID"]).hide(
                                "blind",
                                500
                            );

                            getWorkflow(currRecordID);
                            if (actionSuccessCallback !== undefined) {
                                actionSuccessCallback({
                                    actionType: data.actionType,
                                    dependencyID: data.dependencyID,
                                    comment: data.comment
                                });
                            }

                            let new_note;
                            new_note =
                                '<div class="comment_block"> <span class="comments_time"> ' +
                                response.comment.date +
                                '</span> <span class="comments_name">' +
                                response.comment.responder +
                                " " +
                                response.comment.user_name +
                                '</span> <div class="comments_message">' +
                                response.comment.comment +
                                "</div> </div>";

                            if (response.comment.comment != "") {
                                $(new_note).insertAfter("#notes");
                            }

                            if ($("#comments").css("display") == "none") {
                                $("#comments").css("display", "block");
                            }

                            if (response.comment.nextStep == 0) {
                                $("#notes").css("display", "none");
                                if (!$(".comment_block")[0]) {
                                    $("#comments").css({ display: "none" });
                                }
                            } else {
                                $("#notes").css("display", "block");
                            }
                        } else {
                            let errors = "";
                            for (let i in response.errors) {
                                errors += response.errors[i] + "<br />";
                            }
                            $("#workflowbox_dep" + data["dependencyID"]).html(
                                '<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%"><img src="' +
                                    rootURL +
                                    'dynicons/?img=dialog-error.svg&w=48" style="vertical-align: middle" alt="" /> ' +
                                    errors +
                                    '<br /><span style="font-size: 14px; font-weight: normal">After resolving the errors, <button id="workflowbtn_tryagain" class="buttonNorm">click here to try again</button>.</span></div>'
                            );
                            $("#workflowbtn_tryagain").on("click", function () {
                                getWorkflow(currRecordID);
                            });
                        }
                    } else {
                        $("#workflowbox_dep" + data["dependencyID"]).html(
                            '<div style="border: 2px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%"><img src="' +
                                rootURL +
                                'dynicons/?img=dialog-error.svg&w=48" style="vertical-align: middle" alt="" />Session has expired.<br /><span style="font-size: 14px; font-weight: normal"><button id="workflowbtn_tryagain" class="buttonNorm">Click here to try again</button></span></div>'
                        );
                        $("#workflowbtn_tryagain").on("click", function () {
                            getWorkflow(currRecordID);
                            setTimeout(function () {
                                $("#comment_dep" + data.dependencyID).val(
                                    data.comment
                                );
                            }, 1000);
                        });
                    }

                    antiDblClick = 0;
                },
                error: function (response) {
                    if (data["dependencyID"] === null) {
                        $("#workflowbox_dep" + data["dependencyID"]).html(
                            `<div style="border: 2px solid red; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Error ${response.status}: ${response.responseText}</div>`
                        );
                    } else {
                        $("#workflowbox_dep" + data["dependencyID"]).html(
                            `<div style="border: 2px solid red; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; width: 95%">Error ${response.status}: ${response.responseText}
                                <p>Workflow Events may not have triggered</p>
                            </div>`
                        );
                    }
                },
            });
        }
    }

    /**
     * @memberOf LeafWorkflow
     * Called for each requirement with access. Initializes the step module if one exists for the step ID.
     * @param {object} step includes both step and depencency information for a specific requirement
     * @param {number} firstDepID dependencyID associated with first requirement drawn (where fields are loaded)
     */
    var modulesLoaded = {};
    function drawWorkflow(step, firstDepID = null) {
        step['dependencyID'] = +step['dependencyID'];
        step['stepBgColor'] = bgColorReg.test(step['stepBgColor']) ? step['stepBgColor'] : "#e0e0e0";
        step['stepFontColor'] = fColorReg.test(step['stepFontColor']) ? step['stepFontColor'] : "#000000";
        step['stepBorder'] = step?.['stepBorder'] ? scrubHTML(step['stepBorder']) : "1px solid black";
        step['description'] = scrubHTML(step?.['description'] ?? '').trim();

        // draw frame and header
        const stepDescription = step.description || "Error: The configuration in the Workflow Editor is incomplete."

        $("#" + containerID).append(
            '<div id="workflowbox_dep' +
                step.dependencyID +
                '" class="workflowbox">\
                <span>\
                <div id="stepDescription_dep' +
                step.dependencyID +
                '" style="background-color: ' +
                darkenColor(step.stepBgColor) +
                '; padding: 8px">' +
                stepDescription +
                '</div>\
                </span>\
                <form id="form_dep' +
                step.dependencyID +
                '" enctype="multipart/form-data" action="#">\
                    <div id="form_dep_extension' +
                step.dependencyID +
                '"></div>\
                </form>\
                </div>'
        );
        $("#workflowbox_dep" + step.dependencyID).css({
            padding: "0px",
            "background-color": step.stepBgColor,
            border: step.stepBorder,
        });
        $("#workflowbox_dep" + step.dependencyID + " span").css({
            "font-size": "120%",
            "font-weight": "bold",
            color: step.stepFontColor,
        });

        // draw comment area and button anchors
        $("#form_dep" + step.dependencyID).append(
            '<div id="form_dep_container' +
                step.dependencyID +
                '">\
                <span class="noprint" aria-label="comments">Comments:</span><br />\
                <textarea id="comment_dep' +
                step.dependencyID +
                '" aria-label="comment text area"></textarea>\
                </div>'
        );
        $("#form_dep_container" + step.dependencyID).css({
            margin: "auto",
            width: "95%",
            padding: "8px 0",
        });

        $("#comment_dep" + step.dependencyID).css({
            height: "40px",
            width: "100%",
            padding: "4px",
            resize: "vertical",
        });
        $("#comment_dep" + step.dependencyID).on("input", function () {
            let lines = $("#comment_dep" + step.dependencyID)
                .val()
                ?.match(/\n/g);
            if (lines != null && lines.length > 0) {
                $("#comment_dep" + step.dependencyID).css({
                    height: 40 + (lines.length - 1) * 16 + "px",
                });
            } else {
                $("#comment_dep" + step.dependencyID).css({
                    height: "40px",
                });
            }
        });

        //add alignment area for buttons
        $("#form_dep_container" + step.dependencyID).append(
            `<div class="action_button_container" style="display:flex; justify-content:space-between">
        <div class="actions_alignment_left" style="display:flex; flex-wrap:wrap;"></div>
        <div class="actions_alignment_right" style="display:flex; flex-wrap:wrap; justify-content:flex-end"></div>
      </div>`
        );

        // draw buttons
        for (let i in step.dependencyActions) {
            step.dependencyActions[i].actionIcon = scrubHTML(step.dependencyActions[i].actionIcon ?? '').trim();
            step.dependencyActions[i].actionType = scrubHTML(step.dependencyActions[i].actionType ?? '').trim();
            step.dependencyActions[i].actionText = scrubHTML(step.dependencyActions[i].actionText ?? '').trim();
            const icon =
                step.dependencyActions[i].actionIcon != ""
                    ? `<img src="${rootURL}dynicons/?img=${step.dependencyActions[i].actionIcon}&amp;w=22"
            alt="" style="vertical-align: middle" />`
                    : "";
            const alignment =
                step.dependencyActions[i].actionAlignment.toLowerCase();

            $(
                `#form_dep_container${step.dependencyID} .actions_alignment_${alignment}`
            ).append(
                `<div id="button_container${step.dependencyID}_${step.dependencyActions[i].actionType}">
          <button type="button" id="button_step${step.dependencyID}_${step.dependencyActions[i].actionType}" class="button" disabled>
            ${icon} ${step.dependencyActions[i].actionText}
          </button>
        </div>`
            );

            $(
                `#button_step${step.dependencyID}_${step.dependencyActions[i].actionType}`
            ).css({ border: "1px solid black", padding: "6px", margin: "4px" });

            $(
                "#button_step" +
                    step.dependencyID +
                    "_" +
                    step.dependencyActions[i].actionType
            ).on("click", { step: step, idx: i }, function (e) {
                let require_comment = "";

                if (
                    e.data.step.dependencyActions[e.data.idx][
                        "displayConditional"
                    ]
                ) {
                    require_comment = $.parseJSON(
                        e.data.step.dependencyActions[e.data.idx][
                            "displayConditional"
                        ]
                    );
                } else {
                    require_comment = $.parseJSON('{"required":"false"}');
                }

                let completeAction = function () {
                    let data = new Object();
                    data["comment"] = $(
                        "#comment_dep" + e.data.step.dependencyID
                    ).val();
                    data["actionType"] =
                        e.data.step.dependencyActions[e.data.idx].actionType;
                    data["dependencyID"] = e.data.step.dependencyID;
                    data["require_comment"] = require_comment;
                    data["index"] = e.data.idx;
                    data["CSRFToken"] = CSRFToken;
                    if (
                        e.data.step.dependencyActions[e.data.idx]
                            .fillDependency > 0
                    )
                        if (
                            typeof workflowModule[e.data.step.dependencyID] !==
                            "undefined"
                        ) {
                            workflowModule[e.data.step.dependencyID].trigger(
                                function () {
                                    applyAction(data);
                                }
                            );
                        } else if (
                            typeof workflowStepModule[e.data.step.stepID] !==
                            "undefined"
                        ) {
                            let actionTriggered = false;
                            for (let i in workflowStepModule[
                                e.data.step.stepID
                            ]) {
                                if (
                                    typeof workflowStepModule[
                                        e.data.step.stepID
                                    ][i].trigger !== "undefined"
                                ) {
                                    actionTriggered = true;
                                    workflowStepModule[e.data.step.stepID][
                                        i
                                    ].trigger(function () {
                                        applyAction(data);
                                    });
                                    break;
                                }
                            }
                            if (!actionTriggered) {
                                applyAction(data);
                            }
                        } else {
                            applyAction(data);
                        }
                    else {
                        applyAction(data);
                    }
                };

                if (actionPreconditionFunc !== undefined) {
                    actionPreconditionFunc(e.data, completeAction);
                } else {
                    completeAction();
                }
            });
            document.querySelector(`#button_step${step.dependencyID}_${step.dependencyActions[i].actionType}`)?.removeAttribute?.('disabled');
        }

        // load workflowStep modules
        if (step.requiresDigitalSignature == true) {
            $.ajax({
                type: "GET",
                url:
                    rootURL +
                    "ajaxScript.php?a=workflowStepModules&s=LEAF_digital_signature&stepID=" +
                    step.stepID,
                dataType: "script",
                success: function () {
                    workflowStepModule[step.stepID].LEAF_digital_signature.init(
                        step,
                        rootURL
                    );
                },
                error: function (err) {
                    console.log("Error: " + err);
                },
            });
        }
        if (step.stepModules != undefined) {
            for (let x in step.stepModules) {
                if (
                    modulesLoaded[
                        step.stepModules[x].moduleName + "_" + step.stepID
                    ] == undefined
                ) {
                    modulesLoaded[
                        step.stepModules[x].moduleName + "_" + step.stepID
                    ] = 1;

                    $(`#form_dep_extension${step.dependencyID}`)
                        .html(`<div style="padding: 8px 24px 8px">
                        <div style="background-color: white; border: 1px solid black; padding: 16px">
                            <h2>Loading...</h2>
                        </div>
                        </div>`);
                    $(`#form_dep_container${step.dependencyID} .button`).attr(
                        "disabled",
                        true
                    );
                    $.ajax({
                        type: "GET",
                        url:
                            rootURL +
                            "ajaxScript.php?a=workflowStepModules&s=" +
                            step.stepModules[x].moduleName +
                            "&stepID=" +
                            step.stepID,
                        dataType: "script",
                        success: function () {
                            workflowStepModule[step.stepID][
                                step.stepModules[x].moduleName
                            ].init(step, rootURL);
                            $(
                                `#form_dep_container${step.dependencyID} .button`
                            ).attr("disabled", false);
                        },
                        error: function (err) {
                            console.log("Error: " + err);
                        },
                    });
                } else {
                    //the module is already flagged as loaded and the first dependencyID is being drawn here, reinit
                    if(firstDepID === step.dependencyID && typeof workflowStepModule?.[step.stepID] !== "undefined") {
                        workflowStepModule[step.stepID][step.stepModules[x].moduleName].init(step, rootURL);
                    }
                }
            }
        }

        // legacy workflow modules based on dependencyIDs
        for (let u in step.jsSrcList) {
            $.ajax({
                type: "GET",
                url: rootURL + step.jsSrcList[u],
                dataType: "script",
                success: function () {
                    workflowModule[step.dependencyID].init(
                        currRecordID,
                        rootURL
                    );
                },
                error: function (err) {
                    console.log("Error: " + err);
                },
            });
        }
    }

    /**
     * @memberOf LeafWorkflow
     */
    function drawWorkflowNoAccess(step) {
        step['dependencyID'] = +step['dependencyID'];
        step['stepBgColor'] = bgColorReg.test(step['stepBgColor']) ? step['stepBgColor'] : "#e0e0e0";
        step['stepFontColor'] = fColorReg.test(step['stepFontColor']) ? step['stepFontColor'] : "#000000";
        step['stepBorder'] = step?.['stepBorder'] ? scrubHTML(step['stepBorder']) : "1px solid black";
        step['description'] = scrubHTML(step?.['description'] ?? '').trim();

        $("#" + containerID).append(
            '<div id="workflowbox_dep' +
                step.dependencyID +
                '" class="workflowbox"></div>'
        );
        $("#workflowbox_dep" + step.dependencyID).css({
            "background-color": step.stepBgColor,
            border: step.stepBorder,
            "text-align": "center",
            padding: "8px",
        });
        // dependencyID -1 : special case for person designated by the requestor
        if (step.dependencyID == -1) {
            $.ajax({
                type: "GET",
                url:
                    rootURL +
                    "api/form/customData/_" +
                    currRecordID +
                    "/_" +
                    step.indicatorID_for_assigned_empUID,
                success: function (res) {
                    const dataValue = res[currRecordID]["s1"]["id" + step.indicatorID_for_assigned_empUID] || null;
                    let name = "";

                    if (
                        dataValue == null
                    ) {
                        name =
                            "Warning: User not selected for current action (Contact Administrator)";
                    } else {
                        name =
                            "Pending action from " + scrubHTML(dataValue);
                    }

                    $("#workflowbox_dep" + step.dependencyID).append(
                        "<span>" + name + "</span>"
                    );
                    $("#workflowbox_dep" + step.dependencyID + " span").css({
                        "font-size": "150%",
                        "font-weight": "bold",
                        color: step.stepFontColor,
                    });
                },
                error: function (err) {
                    console.log("Error: " + err);
                },
            });
        } else if (step.dependencyID == -3) {
            // dependencyID -3 : special case for group designated by the requestor
            $.ajax({
                type: "GET",
                url:
                    rootURL +
                    "api/form/customData/_" +
                    currRecordID +
                    "/_" +
                    step.indicatorID_for_assigned_groupID,
                success: function (res) {
                    let name = "";

                    if (step.description == '') {
                        name =
                            "Warning: Group not selected for current action (Contact Administrator)";
                    } else {
                        name = "Pending action from " + step.description;
                    }

                    $("#workflowbox_dep" + step.dependencyID).append(
                        "<span>" + name + "</span>"
                    );
                    $("#workflowbox_dep" + step.dependencyID + " span").css({
                        "font-size": "150%",
                        "font-weight": "bold",
                        color: step.stepFontColor,
                    });
                },
                error: function (err) {
                    console.log("Error: " + err);
                },
            });
        } else {
            $("#workflowbox_dep" + step.dependencyID).append(
                "<span>Pending " + step.description + "</span>"
            );
            $("#workflowbox_dep" + step.dependencyID + " span").css({
                "font-size": "150%",
                "font-weight": "bold",
                color: step.stepFontColor,
            });
        }
    }

    /**
     * Add extra parameters to the end of the query API URL
     * @param {string} params
     */
    function setExtraParams(params = "") {
        extraParams = params;
    }

    /**
     * @memberOf LeafWorkflow
     * Get the last action taken on the request
     * If available, display a banner 'who took it: name of action' beneath the workflow field
     */
    function getLastAction(recordID, res) {
        $.ajax({
            type: "GET",
            url:
                rootURL + "api/formWorkflow/" + recordID + "/lastActionSummary",
            dataType: "json",
            success: function (lastActionSummary) {
                let response = lastActionSummary.lastAction;
                if (response == null) {
                    if (res == null) {
                        $("#" + containerID).append("No actions available");
                    }
                    return null;
                }
                //properties used for display
                response['stepBgColor'] = bgColorReg.test(response['stepBgColor']) ? response['stepBgColor'] : "#e0e0e0";
                response['stepFontColor'] = fColorReg.test(response['stepFontColor']) ? response['stepFontColor'] : "#000000";
                response['stepBorder'] = response?.['stepBorder'] ? scrubHTML(response['stepBorder']) : "1px solid black";
                response['dependencyID'] = +response['dependencyID'];
                response['categoryName'] = scrubHTML(response['categoryName']);
                response['stepTitle'] = scrubHTML(response['stepTitle']);
                response['description'] = scrubHTML(response['description']);
                response['actionType'] = scrubHTML(response['actionType']);
                response['actionText'] = scrubHTML(response['actionText']);
                response['actionTextPasttense'] = scrubHTML(response['actionTextPasttense']);

                let label =
                    response.dependencyID == 5
                        ? response.categoryName
                        : response.description;
                if (res != null) {
                    if (response.dependencyID != 5) {
                        $("#" + containerID).append(
                            '<div id="workflowbox_lastAction" class="workflowbox" style="padding: 0px; margin-top: 8px"></div>'
                        );
                        $("#workflowbox_lastAction").css({
                            "background-color": response.stepBgColor,
                            border: response.stepBorder,
                        });
                    }

                    let date = new Date(response.time * 1000);

                    let text = "";
                    if (
                        response.description != null &&
                        response.actionText != null
                    ) {
                        text =
                            '<div style="background-color: ' +
                            darkenColor(response.stepBgColor) +
                            '; padding: 4px"><span style="float: left; font-size: 90%">' +
                            label +
                            ": " +
                            response.actionTextPasttense +
                            "</span>";
                        text +=
                            '<span style="float: right; font-size: 90%">' +
                            date.toLocaleString("en-US", {
                                weekday: "long",
                                year: "numeric",
                                month: "long",
                                day: "numeric",
                            }) +
                            "</span><br /></div>";
                        if (
                            response.comment != "" &&
                            response.comment != null
                        ) {
                            text +=
                                '<div style="font-size: 80%; padding: 4px 8px 4px 8px">Comment:<br /><div style="font-weight: normal; padding-left: 16px; font-size: 12px; word-break:break-word;">' +
                                response.comment +
                                "</div></div>";
                        }
                    } else {
                        text =
                            "[ Please refer to this request's history for current status ]";
                    }

                    if (response.dependencyID != 5) {
                        $("#workflowbox_lastAction").append(
                            '<span style="font-weight: bold; color: ' +
                                response.stepFontColor +
                                '">' +
                                text +
                                "</span>"
                        );
                    }
                } else {
                    $("#workflowcontent").append(
                        '<div id="workflowbox_lastAction"></div>'
                    );
                    $("#workflowbox_lastAction").css({
                        "background-color": response.stepBgColor,
                        border: response.stepBorder,
                        "text-align": "center",
                        padding: "0px",
                    });
                    $("#workflowbox_lastAction").addClass("workflowbox");

                    let date = new Date(response.time * 1000);

                    let text = "";
                    if (
                        response.description != null &&
                        response.actionText != null
                    ) {
                        text =
                            '<div style="padding: 4px; background-color: ' +
                            darkenColor(response.stepBgColor) +
                            '">' +
                            label +
                            ": " +
                            response.actionTextPasttense;
                        text +=
                            '<br /><span style="font-size: 60%">' +
                            date.toLocaleString("en-US", {
                                weekday: "long",
                                year: "numeric",
                                month: "long",
                                day: "numeric",
                            }) +
                            "</span></div>";
                        if (
                            response.comment != "" &&
                            response.comment != null
                        ) {
                            text +=
                                '<div style="padding: 4px 16px"><fieldset style="border: 1px solid black;word-break:break-word;"><legend class="noprint">Comment</legend><span style="font-size: 80%; font-weight: normal">' +
                                response.comment +
                                "</span></fieldset></div>";
                        }
                    } else {
                        text =
                            "[ Please refer to this request's history for current status. ]";
                    }

                    $("#workflowbox_lastAction").append(
                        '<span style="font-size: 150%; font-weight: bold", color: ' +
                            response.stepFontColor +
                            ">" +
                            text +
                            "</span>"
                    );
                }

                // check signatures
                if (lastActionSummary.signatures.length > 0) {
                    $("#workflowcontent").append(
                        '<div id="workflowSignatureContainer" style="margin-top: 8px"></div>'
                    );
                    for (let i in lastActionSummary.signatures) {
                        let sigTime = new Date(
                            lastActionSummary.signatures[i].timestamp * 1000
                        );
                        let month = sigTime.getMonth() + 1;
                        let date = sigTime.getDate();
                        let year = sigTime.getFullYear();
                        $("#workflowSignatureContainer").append(
                            '<div style="float: left; width: 30%; margin: 0 4px 4px 0; padding: 8px; background-color: #d1ffcc; border: 1px solid black; text-align: center">' +
                                lastActionSummary.signatures[i].stepTitle +
                                ' - Digitally signed<br /><span style="font-size: 140%; line-height: 200%"><img src="' +
                                rootURL +
                                'dynicons/?img=application-certificate.svg&w=32" style="vertical-align: middle; padding-right: 4px" alt="digital signature (beta) logo" />' +
                                lastActionSummary.signatures[i].name +
                                " " +
                                month +
                                "/" +
                                date +
                                "/" +
                                year +
                                '</span><br /><span aria-hidden="true" style="font-size: 75%">x' +
                                lastActionSummary.signatures[
                                    i
                                ].signature.substr(0, 32) +
                                "</span></div>"
                        );
                    }
                    for (let i in lastActionSummary.stepsPendingSignature) {
                        $("#workflowSignatureContainer").append(
                            '<div style="float: left; width: 30%; margin: 0 4px 4px 0; padding: 8px; background-color: white; border: 1px dashed black; text-align: center">' +
                                lastActionSummary.stepsPendingSignature[i] +
                                '<br /><span style="font-size: 140%; line-height: 300%">X&nbsp;______________</span></div>'
                        );
                    }
                    $("#workflowcontent").append('<br style="clear: both" />');
                }
            },
            error: function (err) {
                console.log("Error: " + err);
            },
            cache: false,
        });
    }

    /**
     * @memberOf LeafWorkflow
     */
    function getWorkflow(recordID) {
        $("#" + containerID).empty();
        $("#" + containerID).css("display", "none");
        antiDblClick = 0;
        currRecordID = recordID;

        let masquerade = "";
        if (extraParams === "masquerade=nonAdmin") {
            masquerade = "?masquerade=nonAdmin";
        }

        return $.ajax({
            type: "GET",
            url:
                rootURL +
                "api/formWorkflow/" +
                recordID +
                "/currentStep" +
                masquerade,
            dataType: "json",
            success: function (res) {
                let firstDepID = null;
                for (let i in res) {
                    if (res[i].hasAccess == 1) {
                        if(firstDepID === null) {
                            firstDepID = res[i].dependencyID;
                        }
                        drawWorkflow(res[i], firstDepID);
                    } else {
                        drawWorkflowNoAccess(res[i]);
                    }
                }
                getLastAction(recordID, res);
                $("#" + containerID).show("blind", 250);
            },
            error: function (err) {
                console.log("Error: " + err);
            },
            cache: false,
        });
    }

    /**
     * @memberOf LeafWorkflow
     * func accepts 1 argument:
     *     data - {
     *                 actionType: the action type that was exectued
     *                 dependencyID: the dependencyID associated with the action
     *                 comment: the comment associated with the action
     *            }
     */
    function setActionSuccessCallback(func) {
        actionSuccessCallback = func;
    }

    /**
     * @memberOf LeafWorkflow
     * func accepts 2 arguments:
     *     data - {
     *                 idx: index matching the current action for data.step.dependencyActions[]
     *                 step: data related to the current step
     *            }
     *     completeAction - to be executed in order to complete the workflow action
     */
    function setActionPreconditionFunc(func) {
        actionPreconditionFunc = func;
    }

    return {
        getWorkflow: getWorkflow,
        setActionPreconditionFunc: setActionPreconditionFunc,
        setActionSuccessCallback: setActionSuccessCallback,
        setRootURL: function (url) {
            rootURL = url;
        },
        setExtraParams,
    };
};