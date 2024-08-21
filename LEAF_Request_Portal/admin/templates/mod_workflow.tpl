<div id="workflow_editor">
    <div id="sideBar">
        <div>
            <label id="workflows_label" for="workflows"> Workflows:</label>
            <div id="workflowList"></div>
        </div>
        <button type="button" id="btn_newWorkflow" class="buttonNorm" onclick="newWorkflow();">
            <img src="../dynicons/?img=list-add.svg&w=26" alt="" /> New Workflow
        </button>

        <div style="margin-top:0.5rem;">
            <label id="steps_label" for="workflow_steps"> Workflow Steps:</label>
            <div id="stepList"></div>
        </div>
        <button type="button" id="btn_createStep" class="buttonNorm" onclick="createStep();">
            <img src="../dynicons/?img=list-add.svg&w=26" alt="" /> New Step
        </button>

        <hr />
        <button type="button" id="btn_renameWorkflow" class="buttonNorm" onclick="renameWorkflow();">
            <img src="../dynicons/?img=accessories-text-editor.svg&amp;w=26" alt="" /> Rename Workflow
        </button>

        <button type="button" id="btn_duplicateWorkflow" class="buttonNorm" onclick="duplicateWorkflow();">
            <img src="../dynicons/?img=edit-copy.svg&amp;w=26" alt="" /> Copy Workflow
        </button>

        <hr />
        <button type="button" id="btn_viewHistory" class="buttonNorm" onclick="viewHistory();">
            <img src="../dynicons/?img=appointment.svg&amp;w=26" alt="" /> View History
        </button>

        <hr />
        <button type="button" id="btn_listActionType" class="buttonNorm" onclick="listActionType();">
            <img src="../dynicons/?img=applications-other.svg&amp;w=26" alt="" /> Edit Actions
        </button>

        <button type="button" id="btn_listEvents" class="buttonNorm" onclick="listEvents();">
            <img src="../dynicons/?img=gnome-system-run.svg&amp;w=26" alt="" /> Edit Events
        </button>

        <hr />
        <button type="button" id="btn_deleteWorkflow" class="buttonNorm" onclick="deleteWorkflow();">
            <img src="../dynicons/?img=list-remove.svg&w=26" alt="" /> Delete Workflow
        </button>
    </div>
    <div id="workflow"></div>
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_OkDialog.tpl"}-->

<script type="text/javascript">
    var CSRFToken = '<!--{$CSRFToken}-->';

    function isJSON(input = '') {
        try {
            JSON.parse(input);
        } catch (e) {
            return false;
        }
        return true;
    }
    /* mediate keydown listeners on this page for enter key */
    function onKeyPressClick(event) {
        if(event.keyCode === 13) {
            $(event.target).trigger('click');
        }
    }

    function newWorkflow() {
        $('.workflowStepInfo').css('display', 'none');

        dialog.setTitle('Create new workflow');
        dialog.setContent('<br /><label for="description">Workflow Title:</label> <input type="text" id="description"/>');
        dialog.setSaveHandler(function() {
            let workflowID;

            postWorkflow(function(workflow_id) {
                let url = new URL(window.location.href);
                url.searchParams.set('workflowID', workflow_id);
                window.history.replaceState(null, null, url.toString());
                loadWorkflowList();
                dialog.hide();
            });
        });
        dialog.show();
    }

    function deleteWorkflow() {
        $('.workflowStepInfo').css('display', 'none');
        if (currentWorkflow == 0) {
            return;
        }

        dialog_confirm.setTitle('Confirmation required');
        dialog_confirm.setContent('Are you sure you want to delete this workflow?');
        dialog_confirm.setSaveHandler(function() {
            $.ajax({
                type: 'DELETE',
                url: `../api/workflow/${currentWorkflow}?` + $.param({ 'CSRFToken': CSRFToken }),
                success: (res) => {
                    if (res != true) {
                        alert("Prerequisite action needed:\n\n" + res);
                        dialog_confirm.hide();
                    } else {
                        window.location.reload();
                    }
                },
                error: (err) => console.log(err),
            });
        });
        dialog_confirm.show();
    }

    function unlinkEvent(workflowID, stepID, actionType, eventID) {
        $('.workflowStepInfo').css('display', 'none');
        dialog_confirm.setTitle('Confirmation required');
        dialog_confirm.setContent('Are you sure you want to remove this event?');
        dialog_confirm.setSaveHandler(function() {
            $.ajax({
                type: 'DELETE',
                url: `../api/workflow/${workflowID}/step/${stepID}/_${actionType}/events?`
                    + $.param({ 'eventID': eventID, 'CSRFToken': CSRFToken }),
                success: function() {
                    $('.workflowStepInfo').css('display', 'none');
                    loadWorkflow(workflowID);
                    dialog_confirm.hide();
                },

                error: (err) => console.log(err),
            });
        });
        dialog_confirm.show();
    }

    /**
     * Purpose: Buffer content for listEvents
     * @events Current Custom Events List
     * @return HTML Content for listEvents
     */
    function listEventsContent(events) {
        let content = `<table id="events" class="table" border="1">
            <caption><h2>List of Events</h2></caption>
            <thead><th scope="col">Event</th><th scope="col">Description</th><th scope="col">Type</th><th scope="col">Action</th></thead>`;

        if (events.length === 0) {
            content += `<tr>
                <td width="200px">No Custom Events Created</td>
                <td width="200px"></td>
                <td width="150px"></td>
                <td width="100px"></td>
            </tr>`;
        }

        for (let i in events) {
            content += `<tr>
                <td width="200px" id="${events[i].eventID}">
                    ${events[i].eventID.replace('CustomEvent_','').replaceAll('_', ' ')}
                </td>
                <td width="200px" id="${events[i].eventDescription}">${events[i].eventDescription}</td>
                <td width="150px" id="${events[i].eventType}">${events[i].eventType}</td>
                <td width="100px" id="editor_${events[i].eventID}">
                    <button type="button" class="buttonNorm" onclick="editEvent('${events[i].eventID}')"
                        style="background: #22b;color: #fff; padding: 2px 4px;">
                        Edit
                    </button>
                    <button type="button" class="buttonNorm" onclick="deleteEvent('${events[i].eventID}')"
                        style="background: #c00;color: #fff;margin-left: 10px; padding: 2px 4px;">
                        Delete
                    </button>
                </td>
            </tr>`;
        }

        content += `</table><br /><br />
            <button type="button" class="buttonNorm" id="create-event">Create a new Event</button><br /><br />
            You can edit custom email events here: <a href="./?a=mod_templates_email" target="_blank">Email Template Editor</a>`;

        return content;
    }

    /**
     * Purpose: List all Custom Events
     */
    function listEvents() {
        $('.workflowStepInfo').css('display', 'none');
        dialog.hide();
        $("#button_save").hide();
        dialog.setTitle('List of Events');
        dialog.show();
        $.ajax({
            type: 'GET',
            url: '../api/workflow/customEvents',
            cache: false
        }).done(function(res) {
            dialog.indicateIdle();
            dialog.setContent(listEventsContent(res));

            $("#create-event").click(function() {
                $("#button_save").show();
                newEvent(res);
            });
        }).fail(function(error) {
            alert(error);
        });
        //shows the save button for other dialogs
        $('div#xhrDialog').on('dialogclose', function() {
            $("#button_save").show();
            $('div#xhrDialog').off();
        });
    }

    /**
     * Purpose: Content for group dropdown on newEvent
     * @groups Group list pass-through
     */
    function groupListContent(groups) {
        if (!Array.isArray(groups)) {
            return 'Invalid parameter(s): groups must be an array.';
        }
        let content = '<label for="groupID">Notify Group: </label><select id="groupID">' +
            '<optgroup label="User Groups">' +
            '<option value="None">None</option>';

        for (let i in groups) {
            if (groups[i].parentGroupID === null) {
                content += '<option value="' + groups[i].groupID + '">' + groups[i].name + '</option>';
            }
        }

        content += '</optgroup>';
        content += '<optgroup label="Service Groups">';

        for (let i in groups) {
            if (groups[i].parentGroupID !== null) {
                content += '<option value="' + groups[i].groupID + '">' + groups[i].name + '</option>';
            }
        }

        content += '</optgroup></select><br /><br />';

        return content;
    }

    /**
     * Email reminder dialog that will be triggered via the step popup
     * @param stepID
     */
    function addEmailReminderDialog(stepID) {
        $('.workflowStepInfo').css('display', 'none');
        let workflowStep = null;
        let reminderChecked = false;
        let reminderType = 'duration';
        let reminderDays = '';
        let reminderDate = '';
        let reminder_days_additional = '';

        const d = new Date();
        const dateMin = d.getFullYear().toString() + '-'
            + (d.getMonth() + 1).toString().padStart(2, '0') + '-'
            + d.getDate().toString().padStart(2, '0');

        getStep(stepID, function (workflow_step) { //async is set to false
            workflowStep = workflow_step;
        });
        if(typeof workflowStep?.stepData === 'string' && isJSON(workflowStep?.stepData)) {
            const stepData = JSON.parse(workflowStep.stepData);
            if (stepData?.AutomatedEmailReminders?.DateSelected?.length > 0) {
                reminderType = 'date';
            }
            reminderChecked = stepData.AutomatedEmailReminders?.AutomateEmailGroup === 'true'; //string
            reminderDays = stepData.AutomatedEmailReminders?.DaysSelected || '';
            reminderDate = stepData.AutomatedEmailReminders?.DateSelected || '';
            reminder_days_additional = stepData.AutomatedEmailReminders?.AdditionalDaysSelected || '';
        }

        dialog.setTitle('Email Reminder');

        let output =`<label for="edit_email_check" style="display: block; width:400px;">
                Enable Automated Emails?
                <input type="checkbox" id="edit_email_check" onclick="editEmailChecked()" ${reminderChecked ? "checked" : ""} />
            </label>
            <div id="edit_email_container"
                style="display:${reminderChecked ? "flex" : "none"};flex-direction:column;gap:1.25rem;margin:1.25rem 0;width:400px;">
                <div>
                    <label for="reminder_type_select">Type of Reminder</label>
                    <select id="reminder_type_select" onchange="toggleReminderType()">
                        <option value="duration" ${reminderType === "duration" ? "selected" : ""}>Reminder for Inactivity</option>
                        <option value="date" ${reminderType === "date" ? "selected" : ""}>Reminder on Specific Date</option>
                    </select>
                </div>
                <div id="email_reminder_duration" style="display: ${reminderType === "duration" ? "block" : "none"}">
                    Send a reminder after
                    <input aria-label="number of days" type="number" min="1"
                        id="reminder_days"
                        style="width: 50px" value="${reminderDays}"
                        ${reminderType !== 'duration' ? 'aria-disabled="true" disabled' : ''} /> days of inactivity.
                </div>
                <div id="email_reminder_date" style="display: ${reminderType === "date" ? "block" : "none"}">
                    Start sending reminders on
                    <input aria-label="specific date" type="date"
                    id="reminder_date"
                    min="${dateMin}" value="${reminderDate}"
                    ${reminderType !== 'date' ? 'aria-disabled="true" disabled' : ''} />
                </div>
                <div>
                    After the initial notification send another reminder every
                    <input aria-label="number of days additional" type="number" min="1"
                        id="reminder_days_additional" style="width: 50px" value="${reminder_days_additional}" /> days of inactivity.
                </div>
            </div>`;
        dialog.setContent(output);

        dialog.setValidator('reminder_days', function() {
            const remindersChecked = document.getElementById('edit_email_check')?.checked;
            const reminderType = (document.getElementById('reminder_type_select')?.value || '').toLowerCase();
            const reminderDays = remindersChecked === true ? parseInt(document.getElementById('reminder_days')?.value || 0) : null;
            return !(remindersChecked === true && reminderType === 'duration' && reminderDays < 1 )
        });
        dialog.setSubmitValid('reminder_days', function() {
            alert('Number of days to remind user must be greater than 0!');
        });

        dialog.setValidator('reminder_date', function() {
            const remindersChecked = document.getElementById('edit_email_check')?.checked;
            const reminderType = (document.getElementById('reminder_type_select')?.value || '').toLowerCase();
            const reminderDate = remindersChecked === true ? document.getElementById('reminder_date')?.value : null;
            return !(remindersChecked === true && reminderType === 'date' && !/^\d{4}-\d{2}-\d{2}$/.test(reminderDate));
        });
        dialog.setSubmitValid('reminder_date', function() {
            alert('Please enter a valid date!');
        });

        dialog.setValidator('reminder_days_additional', function() {
            const remindersChecked = document.getElementById('edit_email_check')?.checked;
            const additionalDays = remindersChecked === true ? document.getElementById('reminder_days_additional')?.value || 0 : null;
            return !(remindersChecked === true && parseInt(additionalDays) < 1);
        });
        dialog.setSubmitValid('reminder_days_additional', function() {
            alert('Additional Number of days to remind user must be greater than 0!');
        });
        let saving = false;
        dialog.setCancelHandler(function() {
            if(saving === false) {
                showStepInfo(stepID);
            }
        });
        dialog.setSaveHandler(function() {
            saving = true;
            const remindersChecked = document.getElementById('edit_email_check')?.checked;
            const reminderType = (document.getElementById('reminder_type_select')?.value || '').toLowerCase();
            const reminderDays = remindersChecked === true && reminderType === 'duration' ?
                document.getElementById('reminder_days')?.value : '';
            const reminderDate = remindersChecked === true && reminderType === 'date' ?
                document.getElementById('reminder_date')?.value : '';
            const additionalDays = remindersChecked === true ? document.getElementById('reminder_days_additional')?.value : '';

            let seriesData = {
                AutomatedEmailReminders: {
                    'Automate Email Group': remindersChecked,
                    'Days Selected': reminderDays,
                    'Date Selected': reminderDate,
                    'Additional Days Selected': additionalDays,
                }
            }
            updateStepData(seriesData, stepID, function (res) {
                if (res == 1) {
                    loadWorkflow(currentWorkflow, stepID);
                    dialog.hide();
                } else {
                    alert(res);
                }
            });
        });
        dialog.show();
    }

    ///// Edit Automated Emails
    function editEmailChecked() {
        const emailChecked = document.getElementById("edit_email_check");
        document.getElementById('edit_email_container').style.display = emailChecked.checked ? 'flex' : 'none';
    }

    /**
     * Purpose: Create new custom event
     * @events Custom Event List
     */
    function newEvent(events, params = null) {
        $('.workflowStepInfo').css('display', 'none');
        dialog.clear();
        dialog.setTitle('Create Event');
        let groupList = {};
        $.ajax({
            type: 'GET',
            url: '../api/system/groups',
            cache: false,
            async: false
        }).done(function(res) {
            groupList = groupListContent(res);
        }).fail(function(error) {
            alert(error);
        });
        let createEventContent = '<div><label for="eventType">Event Type: </label><select id="eventType">' +
            '<option value="Email" selected>Email</option>' +
            '</select><br /><br />' +
            '<label for="eventName">Event Name: </label><input type="text" id="eventName" class="eventTextBox" /><br /><br />' +
            '<label for="eventDesc">Short Description: </span><input type="text" id="eventDesc" class="eventTextBox" /><br /><br />' +
            '<div id="eventEmailSettings" style="display: none">' +
            '<label for="notifyRequestor">Notify Requestor Email: </label><input id="notifyRequestor" type="checkbox" /><br /><br />' +
            '<label for="notifyNext">Notify Next Approver Email: </label><input id="notifyNext" type="checkbox" /><br /><br />' +
            groupList + '</div>';
        dialog.setContent(createEventContent);
        if ($('#eventType').val() === 'Email') {
            $('#eventEmailSettings').show();
        }
        $('#eventType').on('click', function() {
            if ($('#eventType').val() === 'Email') {
                $('#eventEmailSettings').show();
            } else {
                $('#eventEmailSettings').hide();
            }
        });
        $('#eventName').on('keyup', function() {
            $('#eventName').val($('#eventName').val().replace(/[^a-z0-9]/gi, '_'));
        });
        $('#eventName').attr('maxlength', 25);
        $('#eventDesc').attr('maxlength', 40);
        dialog.setSaveHandler(function() {
            let eventName = 'CustomEvent_' + $('#eventName').val();
            let eventDesc = $('#eventDesc').val();
            let eventType = $('#eventType').val();
            let eventData = {
                'Notify Requestor':$('#notifyRequestor').prop("checked"),
                'Notify Next': $('#notifyNext').prop("checked"),
                'Notify Group': $('#groupID option:selected').val()
            };
            let ajaxData = {
                name: eventName,
                description: eventDesc,
                type: eventType,
                data: eventData,
                CSRFToken: CSRFToken
            };
            let eventExists = false;
            for (let i in events) {
                if (events[i].eventID === eventName) {
                    eventExists = true;
                }
            }
            if (eventExists === false && $('#eventName').val() !== '' && $('#eventDesc').val() !== '') {
                $.ajax({
                    type: 'POST',
                    url: '../api/workflow/events',
                    data: ajaxData,
                    cache: false
                }).done(function(res) {
                    if(+res !== 1) {
                        alert(res);
                        listEvents();

                    } else {
                        if(params !== null) {
                            const { stepID, action } = params;
                            const postEventData = { eventID: eventName, CSRFToken: CSRFToken };
                            const workflowID = currentWorkflow;
                            postEvent(stepID, action, workflowID, postEventData, function(res) {
                                if (+res === 1) {
                                    dialog.hide();
                                    loadWorkflow(workflowID, null, params);
                                }
                            });
                        } else {
                            listEvents();
                        }
                    }

                }).fail(function(error) {
                    alert(error);
                });
            } else {
                if ($('#eventDesc').val() === '') {
                    alert('Event description cannot be blank.');
                    listEvents();
                } else {
                    alert('Event name already exists.');
                    listEvents();
                }
            }
        });
    }

    /**
     * Purpose: Buffer content for addEventDialog
     * @events Current Events List
     * @return HTML Content for addEventDialog
     */
    function addEventContent(events) {
        if (typeof events === 'string') {
            return 'Invalid parameter(s): events must be an array.';
        }

        let content = '<label id="event_label">Add an event: </label>';
        content += `<br /><div>
            <span id="event_select_status" role="status" aria-live="polite" aria-label="" style="position:absolute"></span>
            <select id="eventID" name="eventID" title="Select Event" onchange="updateSelectionStatus(this, 'event_select_status')">`;
        for (let i in events) {
            content += `<option value="${events[i].eventID}">${events[i].eventType} - ${events[i].eventDescription}</option>`;
        }
        content += '</select></div>';

        return content;
    }

    /**
     * Purpose: Dialog for adding events
     * @workdflowID Current Workflow ID for email reminder
     * @params jsplumb params including action, stepID, nextStepID
     */
    function addEventDialog(workflowID, params) {
        const actionType = params.action;
        const stepID = params.stepID;
        $('.workflowStepInfo').css('display', 'none');
        dialog.setTitle('Add Event');
        let eventDialogContent =
            '<div><button type="button" id="createEvent" class="usa-button leaf-btn-med">Create Event</button></div>' +
            '<div id="addEventDialog"></div>';

        dialog.setContent(eventDialogContent);
        dialog.indicateBusy();
        dialog.show();
        $.ajax({
            type: 'GET',
            url: '../api/workflow/events',
            cache: false
        }).done(function(res) {
                dialog.indicateIdle();
                $('#addEventDialog').html(addEventContent(res));
                $('#createEvent').on('click', function() {
                    newEvent(res, params);
                });
                $('#eventID').chosen({disable_search_threshold: 5});
                $('#xhrDialog').css('overflow', 'visible');

                updateChosenAttributes("eventID", "event_label", "Select Event");

                dialog.setSaveHandler(function() {
                    let ajaxData = {eventID: $('#eventID').val(),
                                    CSRFToken: CSRFToken};

                    postEvent(stepID, actionType, workflowID, ajaxData, function (res) {
                        loadWorkflow(workflowID, null, params);
                    });

                    dialog.hide();
                });
            }).fail(function(error) {
            alert(error);
        });
    }

    /**
     * Purpose: Buffer content for editEvent
     * @event Event being edited
     * @groups Groups list for dropdown selection
     * @return HTML Content for editEvent
     */
    function editEventContent(event, groups) {
        if (typeof groups === 'string') {
            return 'Invalid parameter(s): groups must be an array.';
        }

        let content = '<div><label for="eventType">Event Type: </label><select id="eventType">' +
            '<option value="Email" selected>Email</option>' +
            '</select><br /><br />' +
            '<label for="eventName">Event Name: </label><input type="text" id="eventName" class="eventTextBox" value="' + event[0].eventID
            .replace('CustomEvent_', '') + '" /><br /><br />' +
            '<label for="eventDesc">Short Description: </label><input type="text" id="eventDesc" class="eventTextBox" value="' + event[0]
            .eventDescription + '" /><br /><br />' +
            '<div id="eventEmailSettings" style="display: none"><label for="notifyRequestor">Notify Requestor Email: </label><input id="notifyRequestor" type="checkbox" /><br /><br />' +
            '<label for="notifyNext">Notify Next Approver Email: </label><input id="notifyNext" type="checkbox" /><br /><br />';

        content += '<label for="groupID">Notify Group: </label><select id="groupID">' +
            '<optgroup label="User Groups">' +
            '<option value="None">None</option>';

        for (let i in groups) {
            if (groups[i].parentGroupID === null) {
                content += '<option value="' + groups[i].groupID + '">' + groups[i].name + '</option>';
            }
        }

        content += '</optgroup>';
        content += '<optgroup label="Service Groups">';

        for (let i in groups) {
            if (groups[i].parentGroupID !== null) {
                content += '<option value="' + groups[i].groupID + '">' + groups[i].name + '</option>';
            }
        }

        content += '</optgroup></select><br /><br />';
        content +=
            'You can edit custom email events here: <a href="./?a=mod_templates_email" target="_blank">Email Template Editor</a></div>';

        return content;
    }

    /**
     * Purpose: Edit already created event
     * @event eventID being edited
     */
    function editEvent(event) {
        $('.workflowStepInfo').css('display', 'none');
        dialog.hide();
        $("#button_save").show();
        dialog.setTitle('Edit Event ' + event.replace('CustomEvent_', '').replaceAll('_', ' '));
        dialog.show();
        let groupList = {};
        $.ajax({
            type: 'GET',
            url: '../api/system/groups',
            cache: false,
            async: false
        }).done(function(res) {
            groupList = res;
        }).fail(function(error) {
            alert(error);
        });
        $.ajax({
            type: 'GET',
            url: '../api/workflow/event/_' + event,
            cache: false
        }).done(function(res) {
            dialog.setContent(editEventContent(res, groupList));
            if ($('#eventType').val() === 'Email') {
                $('#eventEmailSettings').show();
            }
            let eventParse = JSON.parse(res[0].eventData);
            let notifyRequestor = eventParse.NotifyRequestor;
            let notifyNext = eventParse.NotifyNext;
            let notifyGroup = eventParse.NotifyGroup;
            $('#groupID option[value=' + notifyGroup + ']').prop("selected", true);
            if (notifyRequestor === 'true') {
                $('#notifyRequestor').prop('checked', true);
            } else {
                $('#notifyRequestor').prop('checked', false);
            }
            if (notifyNext === 'true') {
                $('#notifyNext').prop('checked', true);
            } else {
                $('#notifyNext').prop('checked', false);
            }
            $('#eventType').on('click', function() {
                if ($('#eventType').val() === 'Email') {
                    $('#eventEmailSettings').show();
                } else {
                    $('#eventEmailSettings').hide();
                }
            });
            $('#eventName').on('keyup', function() {
                $('#eventName').val($('#eventName').val().replace(/[^a-z0-9]/gi, '_'));
            });
            $('#eventName').attr('maxlength', 25);
            $('#eventDesc').attr('maxlength', 40);
            dialog.indicateIdle();
            dialog.setSaveHandler(function() {
                let eventName = 'CustomEvent_' + $('#eventName').val();
                let eventDesc = $('#eventDesc').val();
                let eventType = $('#eventType').val();
                let eventData = {'Notify Requestor':$('#notifyRequestor').prop("checked"),
                'Notify Next': $('#notifyNext').prop("checked"),
                    'Notify Group': $('#groupID option:selected').val()
                };
                let ajaxData = {newName: eventName,
                    description: eventDesc,
                    type: eventType,
                    data: eventData,
                    CSRFToken: CSRFToken
                };
                let eventNameChange = false;
                $.ajax({
                    type: 'GET',
                    url: '../api/workflow/customEvents',
                    cache: false
                }).done(function(res) {
                    for (let i in res) {
                        if (event !== eventName) { // Check if name change
                            if (res[i].eventID === eventName) {
                                eventNameChange = true;
                            }
                        }
                    }
                    if (eventNameChange === false && $('#eventName').val() !== '' && $('#eventDesc')
                        .val() !== '') {
                        $.ajax({
                            type: 'POST',
                            url: '../api/workflow/editEvent/_' + event,
                            data: ajaxData,
                            cache: false
                        }).done(function(res) {
                            if(+res !== 1) {
                                alert(res);
                            }
                            listEvents();
                        }).fail(function(error) {
                            alert(error);
                        });
                    } else {
                        if ($('#eventDesc').val() === '') {
                            alert('Event description cannot be blank.');
                            listEvents();
                        } else {
                            alert('Event name already exists.');
                            listEvents();
                        }
                    }
                }).fail(function(error) {
                    alert(error);
                });
            });
        }).fail(function(error) {
            alert(error);
        });
    }

    /**
     * Purpose: Delete an event
     * @event eventID being deleted
     */
    function deleteEvent(event) {
        $('.workflowStepInfo').css('display', 'none');
        dialog_confirm.setTitle('Confirmation required');
        dialog_confirm.setContent('Are you sure you want to delete this event?');
        dialog_confirm.setSaveHandler(function() {
            $.ajax({
                type: 'DELETE',
                url: `../api/workflow/event/_${event}?` + $.param({ 'CSRFToken': CSRFToken }),
            }).done(function() {
                listEvents();
            }).fail(function(error) {
                alert(error);
            });
            dialog_confirm.hide();
        });
        dialog_confirm.show();
    }

    function removeStep(stepID) {
        $('.workflowStepInfo').css('display', 'none');
        dialog_confirm.setTitle('Confirmation required');
        dialog_confirm.setContent('Are you sure you want to remove this step?');
        let saving = false;
        dialog_confirm.setCancelHandler(function() {
            if(saving === false) {
                showStepInfo(stepID);
            }
        });
        dialog_confirm.setSaveHandler(function() {
            saving = true;
            $.ajax({
                type: 'DELETE',
                url: `../api/workflow/step/${stepID}?` + $.param({ 'CSRFToken': CSRFToken }),
                success: function(res) {
                    if (res == 1) {
                        loadWorkflow(currentWorkflow);
                        dialog_confirm.hide();
                    } else {
                        alert(res);
                    }
                },
                error: (err) => console.log(err),
            });
        });
        dialog_confirm.show();
    }

    function editStep(stepID) {
        $('.workflowStepInfo').css('display', 'none');

        let workflowStep = null;

        getStep(stepID, function(workflow_step) {
            workflowStep = workflow_step;
        })

        dialog.setTitle('Edit Step');
        dialog.setContent(`<label for="title">Title:</label> <input type="text" id="title" value="${workflowStep?.stepTitle}" />`);
        let saving = false;
        dialog.setCancelHandler(function() {
            if(saving === false) {
                showStepInfo(stepID);
            }
        });
        dialog.setSaveHandler(function() {
            saving = true;
            updateTitle($('#title').val(), stepID, function(step_id) {
                if (step_id == 1) {
                    loadWorkflow(currentWorkflow, stepID);
                    dialog.hide();
                } else {
                    alert(res);
                }
            });
        });
        dialog.show();
    }

    function editRequirement(dependencyID, description = "", reopenStepID = null) {
        const inputDescription = description.replace(/"|'/g, '');
        $('.workflowStepInfo').css('display', 'none');
        dialog.setTitle('Edit Requirement');
        dialog.setContent(`<label for="description">Label:</label><input type="text" id="description" value="${inputDescription}" />`);
        let saving = false;
        dialog.setCancelHandler(function() {
            if(reopenStepID !== null && saving === false) {
                showStepInfo(reopenStepID);
            }
        });
        dialog.setSaveHandler(function() {
            saving = true;
            if ($('#description').val() == '') {
                dialog_ok.setTitle('Description Validation');
                dialog_ok.setContent('Description cannot be blank, please enter a Title or click cancel.');
                dialog_ok.setSaveHandler(function() {
                    dialog_ok.clearDialog();
                    dialog_ok.hide();
                    dialog.hide();
                    editRequirement(dependencyID, description, reopenStepID);
                });
                dialog_ok.show();
            } else {
                $.ajax({
                        type: 'POST',
                        data: {CSRFToken: CSRFToken,
                        description: $('#description').val()
                    },
                    url: '../api/workflow/dependency/' + dependencyID,
                    success: function() {
                        $('.workflowStepInfo').css('display', 'none');
                        loadWorkflow(currentWorkflow, reopenStepID);
                        dialog.hide();
                    },
                    error: (err) => console.log(err),
                });
            }

        });
        dialog.show();
    }

    function unlinkDependency(stepID, dependencyID) {
        $('.workflowStepInfo').css('display', 'none');
        dialog_confirm.setTitle('Confirmation required');
        dialog_confirm.setContent('Are you sure you want to remove this requirement?');
        let saving = false;
        dialog_confirm.setCancelHandler(function() {
            if(saving === false) {
                showStepInfo(stepID);
            }
        });
        dialog_confirm.setSaveHandler(function() {
            saving = true;
            dialog_confirm.indicateBusy();
            $.ajax({
                type: 'DELETE',
                url: `../api/workflow/step/${stepID}/dependencies?`
                    + $.param({
                        'dependencyID': dependencyID,
                        'workflowID': currentWorkflow,
                        'CSRFToken': CSRFToken
                    }),
                success: function() {
                    $('.workflowStepInfo').css('display', 'none');
                    showStepInfo(stepID);
                    dialog_confirm.hide();
                },
                error: (err) => console.log(err),
            });
        });
        dialog_confirm.show();
    }

    function linkDependency(stepID, dependencyID) {
        dialog.indicateBusy();
        postStepDependency(stepID, dependencyID, function(res) {
            dialog.hide();
            showStepInfo(stepID);
        });
    }

    function dependencyRevokeAccess(dependencyID, groupID, reopenStepID = null) {
        $('.workflowStepInfo').css('display', 'none');
        dialog_confirm.setTitle('Confirmation required');
        dialog_confirm.setContent('Are you sure you want to revoke these privileges?');
        let saving = false;
        dialog_confirm.setCancelHandler(function() {
            if(reopenStepID !== null && saving === false) {
                showStepInfo(reopenStepID);
            }
        });
        dialog_confirm.setSaveHandler(function() {
            saving = true;
            $.ajax({
                type: 'DELETE',
                url: '../api/workflow/dependency/' + dependencyID + '/privileges?'
                    + $.param({ 'groupID': groupID, 'CSRFToken': CSRFToken }),
                success: function() {
                    $('.workflowStepInfo').css('display', 'none');
                    loadWorkflow(currentWorkflow, reopenStepID);
                    dialog_confirm.hide();
                },
                error: (err) => console.log(err),
            });
        });
        dialog_confirm.show();
    }

    // stepID optional
    function dependencyGrantAccess(dependencyID, stepID) {
        $('.workflowStepInfo').css('display', 'none');
        dialog.setTitle('What group should have access to this requirement?');
        dialog.indicateBusy();

        $.ajax({
            type: 'GET',
            url: '../api/system/groups',
            success: function(res) {
                let buffer = '<label for="groupID">Grant Privileges to Group:</label><br /><select id="groupID">' +
                    '<optgroup label="User Groups">';

                for (let i in res) {
                    if (res[i].parentGroupID === null) {
                        buffer += '<option value="' + res[i].groupID + '">' + res[i].name + '</option>';
                    }
                }

                buffer += '</optgroup>';
                buffer += '<optgroup label="Service Groups">';

                for (let i in res) {
                    if (res[i].parentGroupID !== null) {
                        buffer += '<option value="' + res[i].groupID + '">' + res[i].name + '</option>';
                    }
                }

                buffer += '</optgroup></select>';
                dialog.setContent(buffer);
                dialog.show();
                dialog.indicateIdle();
            },
            error: (err) => console.log(err),
            cache: false
        });
        let saving = false;
        dialog.setCancelHandler(function() {
            if(saving === false) {
                showStepInfo(stepID)
            }
        });
        dialog.setSaveHandler(function() {
            saving = true;
            $.ajax({
                    type: 'POST',
                    url: '../api/workflow/dependency/' + dependencyID + '/privileges',
                    data: {groupID: $('#groupID').val(),
                    CSRFToken: CSRFToken
                },
                success: function(res) {
                    dialog.hide();
                    loadWorkflow(currentWorkflow);
                    if (stepID != undefined) {
                        linkDependency(stepID, dependencyID);
                    }
                },
                error: (err) => console.log(err),
            });
        });
    }

    function newDependency(stepID) {
        let saving = false;
        dialog.setTitle('Create a new requirement');
        dialog.setContent(
            '<br /><label for="description">Requirement Label: </label><input type="text" id="description"/><br /><br />Requirements determine the WHO and WHAT part of the process.<br />Example: "Fiscal Team Review"'
        );

        dialog.setSaveHandler(function() {
            saving = true;
            $.ajax({
                    type: 'POST',
                    url: '../api/workflow/dependencies',
                    data: {description: $('#description').val(),
                    CSRFToken: CSRFToken
                },
                success: function(res) {
                    dialog.hide();
                    dependencyGrantAccess(res, stepID);
                },
                error: (err) => console.log(err),
            });
        });
        dialog.setCancelHandler(function() {
            if(saving === false) {
                showStepInfo(stepID);
            }
        });
        dialog.show();
    }

    function linkDependencyDialog(stepID) {
        $('.workflowStepInfo').css('display', 'none');
        dialog.setTitle('Add requirement to a workflow step');
        dialog.setContent('<br /><div id="dependencyList"></div>');
        dialog.show();

        $.ajax({
            type: 'GET',
            url: '../api/workflow/dependencies',
            success: function(res) {
                let buffer = '';
                buffer = '<label id="requirements_label">Select an existing requirement</label>';
                buffer += `<div><span id="req_select_status" role="status" aria-live="polite" aria-label="" style="position:absolute"></span>
                    <select id="dependencyID" name="dependencyID" title="Select a requiremement" onchange="updateSelectionStatus(this, 'req_select_status')">`;

                var reservedDependencies = [-3, -2, -1, 1, 8];
                var maskedDependencies = [5];

                buffer += '<optgroup label="Custom Requirements" aria-label="Custom Requirements">';
                for (let i in res) {
                    if (reservedDependencies.indexOf(res[i].dependencyID) == -1 &&
                        maskedDependencies.indexOf(res[i].dependencyID) == -1) {
                        buffer += '<option value="' + res[i].dependencyID + '">' + res[i].description +
                            '</option>';
                    }
                }
                buffer += '</optgroup>';

                buffer += '<optgroup label="&quot;Smart&quot; Requirements" aria-label="Smart Requirements">';
                for (let i in res) {
                    if (reservedDependencies.indexOf(res[i].dependencyID) != -1) {
                        buffer += '<option value="' + res[i].dependencyID + '">' + res[i].description +
                            '</option>';
                    }
                }
                buffer += '</optgroup>';

                buffer += '</select></div>';
                buffer +=
                    '<br /><br /><br /><div>If a requirement does not exist: ' +
                    '<button type="button" id="btn_newDependency" class="buttonNorm" style="font-size:1rem;padding:0.25em;">Create a new requirement</button></div>';
                $('#dependencyList').html(buffer);
                $('#xhrDialog').css('overflow', 'visible');
                $('#dependencyID').chosen({
                    disable_search_threshold: 5
                });
                updateChosenAttributes("dependencyID", "requirements_label", "Select Requirement");

                let saving = false;
                $('#btn_newDependency').on('click', ()=> {
                    saving = true;
                    newDependency(stepID);
                });
                dialog.setCancelHandler(function() {
                    if(saving === false) {
                        showStepInfo(stepID);
                    }
                });
                dialog.setSaveHandler(function() {
                    saving = true;
                    linkDependency(stepID, $('#dependencyID').val());
                });
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    function createStep() {
        $('.workflowStepInfo').css('display', 'none');
        if (currentWorkflow == 0) {
            return;
        }

        dialog.setTitle('Create new Step');
        dialog.setContent(
            '<br /><label for="stepTitle">Step Title: </label><input type="text" id="stepTitle"/><br /><br />Example: "Service Chief"'
        );
        dialog.setSaveHandler(function() {
            addStep(currentWorkflow, $('#stepTitle').val(), function(stepID) {
                if (isNaN(stepID)) {
                    alert(stepID);
                } else {
                    loadWorkflow(currentWorkflow);
                }

                dialog.hide();
            });
        });
        dialog.show();
    }

    function setInitialStep(stepID) {
        updateInitialStep(currentWorkflow, stepID, function() {
            // ending step
            if (stepID == 0) {
                postAction(-1, 0, 'submit', currentWorkflow, function (res) {
                    // nothing happened here to begin with
                });
            }

            workflows = {};
            $.ajax({
                type: 'GET',
                url: '../api/workflow',
                success: function(res) {
                    for (let i in res) {
                        workflows[res[i].workflowID] = res[i];
                    }
                    loadWorkflow(currentWorkflow);
                },
                error: (err) => console.log(err),
                cache: false
            });
        });
    }

    //list all action type to edit/delete
    function listActionType() {
        $('.workflowStepInfo').css('display', 'none');
        dialog.hide();
        $("#button_save").hide();
        dialog.setTitle('List of Actions');
        dialog.show();
        $.ajax({
            type: 'GET',
            url: '../api/workflow/userActions',
            success: function(res) {
                let buffer = `<table id="actions" class="table" border="1">
                    <caption><h2>List of Actions</h2></caption>
                    <thead>
                        <th scope="col">Action</th>
                        <th scope="col">Action (Past Tense)</th>
                        <th scope="col">Button Order</th>
                        <th scope="col"></th>
                    </thead>`;

                for (let i in res) {
                    buffer += `<tr>
                        <td width="300px" id="${res[i].actionType}">${res[i].actionText}</td>
                        <td width="300px" id="${res[i].actionTextPasttense}">${res[i].actionTextPasttense}</td>
                        <td width="100px">${res[i]?.sort || 0}</td>
                        <td width="150px" id="editor_${res[i].actionType}">
                            <button type="button" class="buttonNorm" onclick="editActionType('${res[i].actionType}')"
                                style="background: #22b;color: #fff; padding: 2px 4px;">
                                Edit
                            </button>
                            <button type="button" class="buttonNorm" onclick="deleteActionType('${res[i].actionType}')"
                                style="background: #c00;color: #fff;margin-left: 10px; padding: 2px 4px;">
                                Delete
                            </button>
                        </td>
                    </tr>`;
                }

                buffer += `</table><br /><br />
                    <button type="button" class="buttonNorm" id="create-action-type">Create a new Action</button>`;

                dialog.indicateIdle();
                dialog.setContent(buffer);

                $("#create-action-type").click(function() {
                    $("#button_save").show();
                    newAction();
                });
            },
            error: (err) => console.log(err),
            cache: false
        });
        //shows the save button for other dialogs
        $('div#xhrDialog').on('dialogclose', function(event) {
            $("#button_save").show();
            $('div#xhrDialog').off();
        });
    }

    /**
    * @param {Object} action
    * @returns string template for action editing modal
    */
    function renderActionInputModal(action = {}) {
        return `
            <table style="margin-bottom:2rem;">
                <tr>
                    <td><span id="action_label">Action <span style="color: #c00000">*Required</span></span></td>
                    <td>
                        <input id="actionText" type="text" maxlength="50" style="border: 1px solid red"
                        value="${action?.actionText || ''}" aria-labelledby="action_label"/>
                    </td>
                    <td>eg: Approve</td>
                </tr>
                <tr>
                    <td><span id="action_past_tense_label">Action Past Tense <span style="color: #c00000">*Required</span></span></td>
                    <td>
                        <input id="actionTextPasttense" type="text" maxlength="50" style="border: 1px solid red"
                        value="${action?.actionTextPasttense || ''}" aria-labelledby="action_past_tense_label"/>
                    </td>
                    <td>eg: Approved</td>
                </tr>
                <tr>
                    <td><span id="choose_icon_label">Icon</span></td>
                    <td>
                        <input id="actionIcon" type="text" maxlength="50"
                        value="${action?.actionIcon || ''}" aria-labelledby="choose_icon_label"/>
                    </td>
                    <td>eg: go-next.svg &nbsp;<a href="/libs/dynicons/gallery.php" style="color:#005EA2;" target="_blank">List of available icons</a></td>
                </tr>
                <tr>
                    <td><span id="action_sort_label">Button Order</span></td>
                    <td>
                        <input id="actionSortNumber" type="number" min="-128" max="127"
                        value="${action?.sort || 0}" aria-labelledby="action_sort_label"/>
                    </td>
                    <td>lower numbers appear first</td>
                </tr>
            </table>
            <label for="fillDependency" style="font-family:'Source Sans Pro Web', sans-serif; font-size: 1rem;">
                Does this action represent moving forwards or backwards in the process?
            </label>
            <select id="fillDependency">
                <option value="1">Forwards</option>
                <option value="-1">Backwards</option>
            </select>
            <div id="backwards_action_note" style="margin-top:0.5rem; max-width:600px; display: none;">
                Note: Backwards actions do not save form field data.
            </div>`
    }

    //edit action type
    function editActionType(actionType) {
        dialog.hide();
        $("#button_save").show();
        dialog.setTitle('Edit Action ' + actionType);
        dialog.show();

        getAction(actionType, function (res) {
            dialog.indicateIdle();
            dialog.setContent(renderActionInputModal(res[0]));

            $('#fillDependency').val(res[0].fillDependency);
            document.getElementById('backwards_action_note').style.display = parseInt(res[0].fillDependency) < 0 ? 'block': 'none';
            document.getElementById('fillDependency').addEventListener('change', actionDirectionNote);

            dialog.setSaveHandler(function() {
                let sort = parseInt($('#actionSortNumber').val());
                sort = Number.isInteger(sort) ? sort : 0;
                sort = sort < -128 ? -128
                        : sort > 127 ? 127
                        : sort;
                $.ajax({
                    type: 'POST',
                    url: '../api/workflow/editAction/_' + actionType,
                    data: {
                        actionText: $('#actionText').val(),
                        actionTextPasttense: $('#actionTextPasttense').val(),
                        actionIcon: $('#actionIcon').val(),
                        sort: sort,
                        fillDependency: $('#fillDependency').val(),
                        CSRFToken: CSRFToken
                    },
                    success: function() {
                        listActionType();
                    },
                    error: (err) => console.log(err),
                });
                dialog.hide();
            });
        });
    }

    function getAction(actionType, callback) {
        $.ajax({
            type: 'GET',
            url: '../api/workflow/action/_' + actionType,
            success: function(res) {
                callback(res);
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    //deletes action type
    function deleteActionType(actionType) {
        // find out if this action is being used in a workflow currently
        getUsedActionType(actionType, function (res) {
            console.log(res);
            let workflows = '';

            for (let i in res.data) {
                workflows += res.data[i].description + "<br />";
            }

            if (res.status.code == 2 && res.data.length) {
                dialog_ok.setTitle('Modify Actions');
                dialog_ok.setContent("This Action cannot be deleted. It is currently being used in the following workflows:<br /><br />" + workflows);
                dialog_ok.setSaveHandler(function() {
                    dialog_ok.clearDialog();
                    dialog_ok.hide();
                });
                dialog_ok.show();
            } else {
                dialog_confirm.setTitle('Confirmation required');
                dialog_confirm.setContent('Are you sure you want to delete this action?');
                dialog_confirm.setSaveHandler(function() {
                    $.ajax({
                        type: 'DELETE',
                        url: '../api/workflow/action/_' + actionType + '?'
                            + $.param({'CSRFToken': CSRFToken}),
                        success: function() {
                            listActionType();
                        },
                        error: (err) => console.log(err),
                    });
                    dialog_confirm.hide();
                });
                dialog_confirm.show();
            }
        })

    }

    function getUsedActionType(actionType, callback) {
        $.ajax({
            async: false,
            type: 'GET',
            url: '../api/workflowRoute/action/_' + actionType,
            success: function(res) {
                callback(res);
            },
            error: (err) => console.log(err),
        });
    }

    function actionDirectionNote() {
        const val = document.getElementById('fillDependency').value || 0
        document.getElementById('backwards_action_note').style.display = parseInt(val) < 0 ? 'block': 'none';
    }

    // create a brand new action
    function newAction() {
        dialog.hide();
        dialog.setTitle('Create New Action Type');
        dialog.show();

        dialog.setSaveHandler(function() {
            if ($('#actionText').val() == '' ||
                $('#actionTextPasttense').val() == '') {
                alert('Please fill out required fields.');
            } else {
                let sort = parseInt($('#actionSortNumber').val());
                sort = Number.isInteger(sort) ? sort : 0;
                sort = sort < -128 ? -128
                        : sort > 127 ? 127
                        : sort;
                $.ajax({
                    type: 'POST',
                    url: '../api/system/action',
                    data: {
                        actionText: $('#actionText').val(),
                        actionTextPasttense: $('#actionTextPasttense').val(),
                        actionIcon: $('#actionIcon').val(),
                        sort: sort,
                        fillDependency: $('#fillDependency').val(),
                        CSRFToken: CSRFToken
                    },
                    success: function(res) {
                        loadWorkflow(currentWorkflow);
                    },
                    error: (err) => console.log(err),
                });
                dialog.hide();
            }
        });

        dialog.setContent(renderActionInputModal());
        document.getElementById('fillDependency').addEventListener('change', actionDirectionNote);
    }

    // connect 2 steps with an action
    function createAction(params, reopenStepID = null) {
        $('.workflowStepInfo').css('display', 'none');
        source = parseFloat(params.sourceId.substr(5));
        sourceTitle = '';
        target = parseFloat(params.targetId.substr(5));
        targetTitle = '';
        if (source == 0) {
            sourceTitle = 'End';
            alert('Ending step cannot be set as a triggering step.');
            loadWorkflow(currentWorkflow);
            return;
        }
        if (target == 0) {
            targetTitle = 'End';
        }
        if (source == -1) {
            source = 0;
            sourceTitle = 'Requestor';
            // handle intial step separately
            setInitialStep(target);
            return;
        }
        if (target == -1) {
            target = 0;
            targetTitle = 'Requestor';

            // automatically select "return to requestor" if the user links a step to the requestor's step
            if (source > 0) {
                postAction(source, target, 'sendback', currentWorkflow, function(res) {
                    loadWorkflow(currentWorkflow, reopenStepID);
                });
                return;
            }
        }
        if (source > 0) {
            sourceTitle = steps[source].stepTitle;
        }
        if (target > 0) {
            targetTitle = steps[target].stepTitle;
        }

        dialog.setTitle('Create New Workflow Action');
        dialog.indicateBusy();
        dialog.show();

        $.ajax({
            type: 'GET',
            url: '../api/workflow/actions',
            success: function(res) {
                let buffer = '';
                buffer = 'Select action for ';
                buffer += '<b>' + sourceTitle + '</b> to <b>' + targetTitle + '</b>:';
                buffer +=
                    '<br /><br /><br />Use an existing action type: <select id="actionType" name="actionType">';

                for (let i in res) {
                    buffer += '<option value="' + res[i].actionType + '">' + res[i].actionText + '</option>';
                }

                buffer += '</select>';
                buffer +=
                    '<br />- OR -<br /><br /><button type="button" class="buttonNorm" style="font-size:1rem;padding:0.25rem;" onclick="newAction();">Create a new Action Type</button>';

                dialog.indicateIdle();
                dialog.setContent(buffer);
                $('#xhrDialog').css('overflow', 'visible');
                $('#actionType').chosen({disable_search_threshold: 5});
                let saving = false;
                dialog.setCancelHandler(function() {
                    if(reopenStepID !== null && saving === false) {
                        showStepInfo(reopenStepID);
                    }
                });
                dialog.setSaveHandler(function() {
                    saving = true;
                    postAction(source, target, $('#actionType').val(), currentWorkflow, function(res) {
                        loadWorkflow(currentWorkflow, reopenStepID);
                    });
                    dialog.hide();
                });
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    function removeAction(workflowID, stepID, nextStepID, action, reopenStepID = null) {
        $('.workflowStepInfo').css('display', 'none');
        dialog_confirm.setTitle('Confirm action removal');
        dialog_confirm.setContent('Confirm removal of:<br /><br />' + stepID + ' -> ' + action + ' -> ' + nextStepID);
        let saving = false;
        dialog_confirm.setCancelHandler(function() {
            if(reopenStepID !== null && saving === false) {
                showStepInfo(reopenStepID);
            }
        });
        dialog_confirm.setSaveHandler(function() {
            saving = true;
            $.ajax({
                type: 'DELETE',
                url: `../api/workflow/${workflowID}/step/${stepID}/_${action}/${nextStepID}?`
                    + $.param({ 'CSRFToken': CSRFToken }),
                success: function(res) {
                    if (+res === 1) {
                        loadWorkflow(workflowID, reopenStepID);
                    } else {
                        alert(res)
                    }
                },
                error: (err) => console.log(err),
            });
            dialog_confirm.hide();
        });

        dialog_confirm.show();
    }

    function showActionInfo(params, evt) {
        $('.workflowStepInfo').css('display', 'none');
        $('#stepInfo_' + params.stepID).html('Loading...');
        const reopenStepID = evt?.detail?.reopenStepID || null;
        const stepID = params.stepID;

        getRouteEvents(currentWorkflow, stepID, params.action, function (res) {
            const stepTitle = steps[stepID] != undefined ? steps[stepID].stepTitle : 'Requestor';

            let output = `<div style="display:flex;gap:0.5rem;align-items:center; justify-content:space-between;">
                <h2 style="display:inline-block;margin:0;">Action: ${stepTitle} clicks ${params.action}</h2>
                <button type="button" id="closeModal" onclick="closeStepInfo(${stepID})" aria-label="Close Modal" title="close modal">&#10006</button>
            </div>`;

            if (params.action == 'sendback') {
                //routes is global.
                const sendBackRoute = routes.find(r => r.actionType === "sendback" && +r.stepID === +stepID);
                const parseRequired = isJSON(sendBackRoute?.displayConditional) && JSON.parse(sendBackRoute.displayConditional)?.required;
                const required = parseRequired === "true" ? "checked" : ""; //true is a string
                output += `<br /><label for="require_sendback_${stepID}">
                    <input type="checkbox" id="require_sendback_${stepID}" onchange="switchRequired(this)" ${required} /> Require a comment to sendback.
                </label><br />`;
            }

            output += '<br /><div>Triggers these events:<ul>';
            // the sendback action always notifies the requestor
            if (params.action == 'sendback') {
                output += '<li><b>Email - Notify the requestor</b></li>';
            }
            for (let i in res) {
                output += `<li><b>${res[i].eventType} - ${res[i].eventDescription}</b>
                    <button type="button" class="buttonNorm icon" onclick="unlinkEvent('${currentWorkflow}', '${stepID}', '${params.action}', '${res[i].eventID}')"
                        title="Remove Event" aria-label="Remove Event">
                        <img src="../dynicons/?img=dialog-error.svg&w=16"  alt="" />
                    </button>
                </li>`;
            }
            output += `<li style="padding-top: 8px">
                <button type="button" class="buttonNorm" id="event_${currentWorkflow}_${stepID}_${params.action}"
                    onclick="addEventDialog('${currentWorkflow}', params);">Add Event
                </button>
            </li>`;
            output += '</ul></div>';
            output +=
                `<hr /><div style="padding: 4px"><button type="button" class="buttonNorm"
                    onclick="removeAction('${currentWorkflow}', '${stepID}', '${params.nextStepID}', '${params.action}', ${reopenStepID})">Remove Action</button></div>`;
            $('#stepInfo_' + stepID).html(output);
            $('#stepInfo_' + stepID).show('slide', 200, () => modalSetup(stepID));
        });
        $('#stepInfo_' + stepID).css({
            left: (evt?.pageX || 200) + 'px',
            top: (evt?.pageY || 300) + 'px'
        });
    }

    function switchRequired(element) {
        let stepID = element.id.split('_')[2];
        let e = document.getElementById("workflows");
        let workflowID = e.value;

        updateRequiredCheckbox(workflowID, stepID, element.checked, function(res) {
            if(res?.data?.length === 1) {
                const displayConditional = res.data[0].displayConditional;
                let sendBackRoute = routes.find(r => r.actionType === "sendback" && +r.stepID === +stepID) || null;
                if (sendBackRoute !== null) {
                    sendBackRoute.displayConditional = displayConditional;
                }
            }
        });
    }

    function setDynamicApprover(stepID) {
        $('.workflowStepInfo').css('display', 'none');
        dialog.setTitle('Set Indicator ID');
        dialog.setContent('Loading...');

        $.ajax({
            type: 'GET',
            url: '../api/form/indicator/list',
            success: function(res) {
                let indicatorList = '';
                for (let i in res) {
                    if (res[i]['format'] == 'orgchart_employee' ||
                        res[i]['format'] == 'raw_data') {
                        let name = XSSHelpers.stripAllTags(res[i].name);
                        name = name.length <= 50 ? name : name.slice(0, 50) + '...';
                        indicatorList += '<option value="' + res[i].indicatorID + '">' + res[i]
                            .categoryName + ': ' + name + ' (id: ' + res[i].indicatorID +
                            ')</option>';
                    }
                }
                dialog.setContent(
                    '<br />Select the data field that will be used to route to selected individual.<br /><select id="indicatorID">' +
                    indicatorList + '</select><br /><br />\
    			    * Your form must have a field with the "Orgchart Employee" or "Raw Data" input format');
            },
            error: (err) => console.log(err),
            cache: false
        });

        dialog.setSaveHandler(function() {
            updateApprover($('#indicatorID').val(), stepID, function(res) {
                loadWorkflow(currentWorkflow);
                dialog.hide();
            });
        });
    dialog.show();
    }

    function setDynamicGroupApprover(stepID) {
        $('.workflowStepInfo').css('display', 'none');
        dialog.setTitle('Set Indicator ID');
        dialog.setContent('Loading...');

        $.ajax({
            type: 'GET',
            url: '../api/form/indicator/list',
            success: function(res) {
                var indicatorList = '';
                for (let i in res) {
                    if (res[i]['format'] == 'orgchart_group' ||
                        res[i]['format'] == 'raw_data') {
                        indicatorList += '<option value="' + res[i].indicatorID + '">' + res[i]
                            .categoryName + ': ' + res[i].name + ' (id: ' + res[i].indicatorID +
                            ')</option>';
                    }
                }
                dialog.setContent(
                    '<br />Select a field that the requestor fills out. The workflow will route to the group they select.<br /><select id="indicatorID">' +
                    indicatorList + '</select><br /><br />\
                    * Your form must have a field with the "Orgchart Group" input format');
            },
            error: (err) => console.log(err),
            cache: false
        });

        dialog.setSaveHandler(function() {
            updateGroupApprover($('#indicatorID').val(), stepID, function (res) {
                loadWorkflow(currentWorkflow);
                dialog.hide();
            });
        });
    dialog.show();
    }

    function signatureRequired(cb, stepID) {
        var innerRequired = function(required, stepID) {
            portalAPI.Workflow.setStepSignatureRequirement(
                currentWorkflow,
                stepID,
                required ? 1 : 0,
                function(msg) {
                    // nothing to see here...
                },
                function(err) {
                    cb.checked = false;
                    console.log(err);
                }
            );
        }

        if (cb.checked) {
            $('.workflowStepInfo').css('display', 'none');
            dialog_confirm.setTitle('Confirmation required');
            dialog_confirm.setContent(
                'Are you sure you want to require a digital signature (beta) on this step?<br /><br />' +
                '<span>Digital signatures should only be used if a "wet signature" is required by your business process.</span>'
            );
            dialog_confirm.setSaveHandler(function() {
                dialog_confirm.hide();
                innerRequired(true, stepID);
                steps[stepID].requiresDigitalSignature = true;
                showStepInfo(stepID);
            });
            dialog_confirm.setCancelHandler(function() {
                cb.checked = false;
            });
            dialog_confirm.show();
        } else {
            innerRequired(false, stepID);
            steps[stepID].requiresDigitalSignature = false;
            cb.checked = false;
        }
    }

    /**
    * Creates a function that restricts tabbing to a modal area
    * @param firstEl first dom element
    * @param lastEl last dom element
    * @returns {function}
    */
    function controlTabbing(firstEl = null, lastEl = null) {
        return function(event) {
            if (firstEl !== null && lastEl !== null) {
                if (event?.shiftKey === true && event?.keyCode === 9 && event?.currentTarget === firstEl) {
                    lastEl.focus();
                    event.preventDefault();
                }
                if (event?.shiftKey === false && event?.keyCode === 9 && event?.currentTarget === lastEl) {
                    firstEl.focus();
                    event.preventDefault();
                }
            }
        }
    }

    function buildWorkflowIndicatorDropdown(stepID, steps) {
        $.ajax({
                type: 'GET',
                url: '../api/workflow/' + currentWorkflow + '/categories',
                cache: false
            })
            .then(function(associatedCategories) {
                var formList = '';
                for (let i in associatedCategories) {
                    formList += associatedCategories[i].categoryID + ',';
                }
                formList = formList.replace(/,$/, '');
                $.ajax({
                        type: 'GET',
                        url: '../api/form/indicator/list?includeHeadings=1&forms=' + formList,
                        cache: false
                    })
                    .then(function(indicatorList) {
                        var stapledInternalIndicators;
                        for (let i in associatedCategories) {
                            for (let j in indicatorList) {
                                if ((associatedCategories[i].categoryID == indicatorList[j].categoryID ||
                                        associatedCategories[i].categoryID == indicatorList[j].parentCategoryID
                                    ) &&
                                    indicatorList[j].parentIndicatorID == null) {
                                    let name = XSSHelpers.stripAllTags(indicatorList[j].name);
                                    name = name.length <= 50 ? name : name.slice(0, 50) + '...';
                                    $('#workflowIndicator_' + stepID).append('<option value="' + indicatorList[
                                            j].indicatorID + '">' + indicatorList[j].categoryName + ': ' +
                                            name + ' (id: ' + indicatorList[j].indicatorID +
                                        ')</option>');
                                } else if (indicatorList[j].parentStaples != null) {
                                    for (let k in indicatorList[j].parentStaples) {
                                        if (indicatorList[j].parentStaples[k] == associatedCategories[i]
                                            .categoryID) {
                                            $('#workflowIndicator_' + stepID).append('<option value="' +
                                                indicatorList[j].indicatorID + '">' + indicatorList[j]
                                                .categoryName + ': ' + indicatorList[j].name + ' (id: ' +
                                                indicatorList[j].indicatorID + ')</option>');
                                        }
                                    }
                                }
                            }
                        }
                        if (steps[stepID].stepModules != undefined) {
                            for (let i in steps[stepID].stepModules) {
                                if (steps[stepID].stepModules[i].moduleName == 'LEAF_workflow_indicator') {
                                    var config = JSON.parse(steps[stepID].stepModules[i].moduleConfig);
                                    $('#workflowIndicator_' + stepID).val(config.indicatorID);
                                }
                            }
                        }
                    });
            });

        $('#workflowIndicator_' + stepID).on('change', function() {
            for (let i in steps[stepID].stepModules) {
                if (steps[stepID].stepModules[i].moduleName == 'LEAF_workflow_indicator') {
                    steps[stepID].stepModules[i].moduleConfig = JSON.stringify({indicatorID: $('#workflowIndicator_' + stepID).val()});
                }
            }

            postModule(stepID, $('#workflowIndicator_' + stepID).val());
        });
    }

    function addConnection(fromStepID = null, toStepID = null) {
        if(Number.isInteger(parseInt(fromStepID)) && Number.isInteger(parseInt(toStepID))) {
            const jsPlumbParams = {
                sourceId: `step_${fromStepID}`,
                targetId: `step_${toStepID}`,
            }
            createAction(jsPlumbParams, fromStepID);
        } else {
            console.log('unexpected arguments')
        }
    }

    /**
    * close the step or action info modal.
    * @param {string} stepID - active modal step
    * @param {string} reopenStepID - used to reopen the stepinfo modal if viewing actions via the stepinfo modal
    */
    function closeStepInfo(stepID = "", reopenStepID = null) {
        $('.workflowStepInfo').css('display', 'none');
        $('.workflowStep').attr('aria-expanded', false);
        $('#stepInfo_' + stepID).html("");
        if(reopenStepID === null) {
            $(`#workflow_steps_chosen input.chosen-search-input`).focus();
        } else {
            showStepInfo(reopenStepID);
        }
    }

    function toggleManageActions() {
        let elMng = document.getElementById('manage_actions_options');
        if(elMng !== null) {
            const currDisplay = elMng.style.display;
            elMng.style.display = currDisplay === 'none' ? 'block' : 'none';
        }
    }

    function modalSetup(stepID) {
        const modalEl = document.getElementById('stepInfo_' + stepID);
        if(modalEl !== null) {
            $('#step_' + stepID).attr('aria-expanded', true);
            const interActiveEls = Array.from(modalEl.querySelectorAll('img, button, input, select'));
            const first = interActiveEls[0] || null
            const last = interActiveEls[interActiveEls.length - 1] || null;
            if (first !== null && last !== null) {
                const stepTabbing = controlTabbing(first, last);
                first.addEventListener('keydown', stepTabbing);
                last.addEventListener('keydown', stepTabbing);
                first.focus();
            }
        }
        $('#stepInfo_' + stepID).on('keydown', function(event) {
            const code = event.code.toLowerCase();
            if (code === 'escape') {
                closeStepInfo(stepID);
            }
        });
    }

    function showStepInfo(stepID) {
        $('.workflowStepInfo').off();
        $('.workflowStep').attr('aria-expanded', false);
        $('.workflowStepInfo').html('');
        if ($('#stepInfo_' + stepID).css('display') != 'none') { // hide info window on second step click
            $('.workflowStepInfo').css('display', 'none');
            return;
        }
        $('.workflowStepInfo').css('display', 'none');
        const position = $('#step_' + stepID).offset();
        const height = $('#step_' + stepID).height();
        $('#stepInfo_' + stepID).css({
            left: position.left + 'px',
            top: position.top + height + 20 + 'px'
        });
        $('#stepInfo_' + stepID).html('Loading...');

        let routeOptions = "";
        if (currentWorkflow > 0) {
            const stepKeys = Object.keys(steps);
            let options = [];
            stepKeys.forEach(k => {
                if (+k !== +stepID) {
                    options.push({...steps[k]});
                }
            });
            const sortedOptions = options.sort((a, b) => {
                const stepA = a.stepTitle.toLowerCase();
                const stepB = b.stepTitle.toLowerCase();
                return stepA < stepB ? -1 : stepA > stepB ? 1 : 0
            });
            let step_options = "";
            sortedOptions.forEach(opt => {
                if (+opt.stepID !== +stepID) {
                    step_options += `<option value="${opt.stepID}">${opt.stepTitle} (id#${opt.stepID})</option>`;
                }
            });
            routeOptions = `<div>
                <label for="create_route">Add Action:</label>
                <select id="create_route" style="width:300px;" title="Choose a step to connect to" onchange="addConnection(${stepID}, this.value)">
                    <option value="">Choose Step to Connect to</option>
                    <option value="0">End</option>`;
            if(stepID !== -1) {
                routeOptions += `<option value="-1">Requestor</option>`;
                routeOptions += `<option value="${stepID}">Self</option>`;
            }
            routeOptions += `${step_options}</select><div>`;
        }
        const actionList = buildRoutesList(+stepID, +currentWorkflow);
        switch (Number(stepID)) {
            case -1:
                const output = `<div style="display:flex;">
                        <div>Request initiator (stepID #: -1)</div>
                        <button type="button" id="closeModal" onclick="closeStepInfo(${stepID})" aria-label="Close Modal" title="close modal">&#10006</button>
                    </div>
                    <fieldset>
                        <legend>Options</legend>
                        <div>
                            <label for="toggleManageActions">
                                <input id="toggleManageActions" type="checkbox" onchange="toggleManageActions()"/>View Step Actions
                            </label>
                            <div id="manage_actions_options" style="display:none;">
                                ${actionList}
                                ${currentWorkflow > 0 ? routeOptions : ""}
                            </div>
                        </div>
                    </fieldset>`;
                $('#stepInfo_' + stepID).html(output);
                $('#stepInfo_' + stepID).show('slide', 200, () => modalSetup(stepID));
                break;
            case 0:
                $('#stepInfo_' + stepID).html(`<div style="display:flex;align-items:center;">
                    <div>The End.  (stepID #: 0)</div>
                    <button type="button" id="closeModal" onclick="closeStepInfo(${stepID})" aria-label="Close Modal" title="close modal">&#10006</button>
                </div>`);
                $('#stepInfo_' + stepID).show('slide', 200, () => modalSetup(stepID));
                break;
            default:
                $.ajax({
                    type: 'GET',
                    url: '../api/workflow/step/' + stepID + '/dependencies',
                    success: function(res) {
                        const control_removeStep = `<button type="button" class="buttonNorm icon" onclick="removeStep(${stepID})" title="Remove Step" aria-label="Remove Step">
                            <img src="../dynicons/?img=dialog-error.svg&w=16" alt="" /></button>`;

                        let output = `<div style="display:flex;gap:0.25rem;align-items:center;">
                                <h2 style="display:inline-block;margin:0;">stepID: #${stepID}</h2>${control_removeStep}
                                <button type="button" id="closeModal" onclick="closeStepInfo(${stepID})" aria-label="Close Modal" title="close modal">&#10006</button>
                            </div></br>
                            <div style="display:flex;gap:0.25rem;align-items:center;">
                                Step: <b>${steps[stepID].stepTitle}</b>
                                <button type="button" class="buttonNorm icon" onclick="editStep(${stepID})" title="Edit Step Name" aria-label="Edit Step Name">
                                    <img src="../dynicons/?img=accessories-text-editor.svg&w=16" alt="" />
                                </button>
                            </div>`;

                        output += '<br /><br /><div>Requirements:<ul id="step_requirements">';
                        let tDeps = {};
                        for (let i in res) {
                            const depID = res[i].dependencyID;
                            const depText = `<b style="color:green;vertical-align:middle;">${res[i].description}</b>`;
                            const control_editDependency = `<button type="button" class="buttonNorm icon" onclick="editRequirement(${depID},'${res[i].description}',${stepID})"
                                    title="Edit Requirement Name" aria-label="Edit Requirement Name">
                                    <img src="../dynicons/?img=accessories-text-editor.svg&w=16" alt="" />
                                </button>`;
                            const control_unlinkDependency = `<button type="button" class="buttonNorm icon" onclick="unlinkDependency(${stepID}, '${depID}')"
                                    title="Remove Requirement" aria-label="Remove Requirement">
                                    <img src="../dynicons/?img=dialog-error.svg&w=16"  alt="" />
                                </button>`;

                            if (depID === 1 || depID === 8) { // special cases for service chief and quadrad
                                output += `<li>${depText} ${control_editDependency} ${control_unlinkDependency} (depID:${depID})</li>`;

                            } else if (depID == -1) { // dependencyID -1 : special case for person designated by the requestor
                                const indicatorWarning = (res[i].indicatorID_for_assigned_empUID == null || res[i].indicatorID_for_assigned_empUID == 0) ?
                                    '<div style="color:#c00000;font-weight:bold">A data field (indicatorID) must be set.</div>' : '';

                                output += `<li>${depText} ${control_unlinkDependency} (depID:${depID})
                                    ${indicatorWarning}
                                    <div>indicatorID: ${res[i].indicatorID_for_assigned_empUID ?? '<b style="color: #c00000;">not set</b>'}</div>
                                    <button type="button" class="buttonNorm" onclick="setDynamicApprover('${res[i].stepID}')">Set Data Field</button>
                                </li>`;

                            } else if (depID === -2) { // dependencyID -2 : requestor followup
                                output += `<li>${depText} ${control_unlinkDependency} (depID:${depID})</li>`;

                            } else if (depID === -3) { // dependencyID -3 : special case for group designated by the requestor
                                const indicatorWarning = (res[i].indicatorID_for_assigned_groupID == null || res[i].indicatorID_for_assigned_groupID == 0) ?
                                    '<div style="color:#c00000;font-weight:bold">A data field (indicatorID) must be set.</div>' : '';

                                output += `<li>${depText} ${control_unlinkDependency} (depID:${depID})
                                    ${indicatorWarning}
                                    <div>indicatorID: ${res[i].indicatorID_for_assigned_groupID ?? '<b style="color: #c00000;">not set</b>'}</div>
                                    <button type="button" class="buttonNorm" onclick="setDynamicGroupApprover('${res[i].stepID}')">Set Data Field</button>
                                </li>`;
                            } else {
                                if (tDeps[depID] == undefined) {
                                    tDeps[depID] = 1;
                                    output += `<li>
                                        <b tabindex=0 title="depID: ${res[i].dependencyID}"
                                            onkeydown="onKeyPressClick(event)" onclick="dependencyGrantAccess(${res[i].dependencyID},${stepID})">
                                            ${res[i].description}
                                        </b>
                                        ${control_editDependency} ${control_unlinkDependency}
                                            <ul id="step_${stepID}_dep${depID}">
                                                <li>
                                                    <button type="button" class="buttonNorm" onclick="dependencyGrantAccess('${depID}',${stepID})">
                                                    <img src="../dynicons/?img=list-add.svg&w=16" alt="" /> Add Group</button>
                                                </li>
                                            </ul>
                                        </li>`;
                                }
                            }
                        }
                        if (res.length == 0) {
                            output += '<li><span style="color: #c00000; font-weight: bold">A requirement must be added.</span></li>';
                        }
                        output += '</ul><div>';

                        output += `<fieldset>
                            <legend>Options</legend>
                            <div style="display:flex;flex-direction:column;gap:1rem;">
                                <div>
                                    <label for="workflowIndicator_${stepID}">Form Field:</label>
                                    <select id="workflowIndicator_${stepID}" style="width:300px;">
                                        <option value="">None</option>
                                    </select>
                                </div>
                                <div>
                                    <label for="toggleManageActions">
                                        <input id="toggleManageActions" type="checkbox" onchange="toggleManageActions()"/>View Step Actions
                                    </label>
                                    <div id="manage_actions_options" style="display:none;">
                                        ${actionList}
                                        ${routeOptions}
                                    </div>
                                </div>
                            </div>
                        </fieldset>`;

                        // button options for steps
                        output += '<hr />';

                        if (res.length > 0) {
                            if (typeof res[0].stepData == 'string' && isJSON(res[0].stepData)) {
                                let stepParse = JSON.parse(res[0].stepData);
                                if (stepParse.AutomatedEmailReminders?.AutomateEmailGroup === 'true') {
                                    const dayCount = stepParse.AutomatedEmailReminders?.DaysSelected || '';
                                    const dateSelected = stepParse.AutomatedEmailReminders?.DateSelected || '';
                                    const additionalDays = stepParse.AutomatedEmailReminders?.AdditionalDaysSelected || '';
                                    let reminderText = dayCount !== '' && dayCount !== null ?
                                        `Email reminders will be sent after ${dayCount} Day${dayCount > 1 ? 's':''} of inactivity.` :
                                        `Email reminders will be sent starting on ${dateSelected}.`;
                                    if (additionalDays !== '') {
                                        reminderText += `<br/>
                                        Follow-up reminders will be sent after ${additionalDays} Day${additionalDays > 1 ? 's':''} of inactivity.`;
                                    }
                                    output += `${reminderText}<hr/>`;
                                }
                            }
                        }
                        output +=
                            '<hr /><div style="padding: 4px; display:flex;"><button type="button" class="buttonNorm" onclick="linkDependencyDialog(' + stepID +
                            ')">Add Requirement</button>';
                        output +=
                            '<button type="button" class="buttonNorm" style="margin-left:auto;" onclick="addEmailReminderDialog(' +
                            stepID + ')">Email Reminder</button></div>';
                        $('#stepInfo_' + stepID).html(output);
                        $('#stepInfo_' + stepID).show('slide', 200, () => modalSetup(stepID));
                        // setup UI for form fields in the workflow area
                        buildWorkflowIndicatorDropdown(stepID, steps);
                        let counter = 0;
                        for (let i in res) {
                            group = '';
                            if (res[i].groupID != null) {
                                $('#step_' + stepID + '_dep' + res[i].dependencyID).prepend(
                                    `<li style="white-space:nowrap">
                                        <b title="groupID: ${res[i].groupID}">${res[i].name}</b>
                                        <button type="button" class="buttonNorm icon" onclick="dependencyRevokeAccess('${res[i].dependencyID}', '${res[i].groupID}', ${stepID})"
                                            title="Remove Group" aria-label="Remove Group">
                                            <img src="../dynicons/?img=dialog-error.svg&w=16" alt="" />
                                        </button>
                                    </li>`);
                                counter++;
                            }
                            if (counter == 0 && res[i] != undefined) {
                                $('#step_' + stepID + '_dep' + res[i].dependencyID).prepend(
                                    '<li><span style="color: #c00000; font-weight: bold">A group must be added.</span></li>'
                                );
                            }
                        }
                    },
                    error: (err) => console.log(err),
                    cache: false
                });
                break;
        }
    }

    var endPoints = [];

    function drawRoutes(workflowID, stepID = null) {
        $.ajax({
            type: 'GET',
            url: '../api/workflow/' + workflowID + '/route',
            success: function(res) {
                routes = res;
                if (endPoints[-1] == undefined) {
                    endPoints[-1] = jsPlumb.addEndpoint('step_-1', {anchor: 'Continuous'}, endpointOptions);
                    jsPlumb.draggable('step_-1');
                }
                if (endPoints[0] == undefined) {
                    endPoints[0] = jsPlumb.addEndpoint('step_0', {anchor: 'Continuous'}, endpointOptions);
                    jsPlumb.draggable('step_0');
                }

                // draw connector
                for (let i in res) {
                    var loc = 0.5;
                    switch (res[i].actionType.toLowerCase()) {
                        case 'sendback':
                            loc = 0.30;
                            break;
                        case 'approve':
                        case 'concur':
                            loc = 0.5;
                            break;
                        case 'defer':
                            loc = 0.25;
                            break;
                        case 'disapprove':
                            loc = 0.75;
                            break;
                        default:
                            break;
                    }
                    if (res[i].nextStepID == 0 && res[i].actionType == 'sendback') {
                        jsPlumb.connect({
                            source: 'step_' + res[i].stepID,
                            target: 'step_-1',
                            paintStyle: {stroke: 'red'},
                            overlays: [
                                ["Label", {
                                        id: 'stepLabel_' + res[i].stepID + '_0_' + res[i].actionType,
                                        cssClass: `workflowAction action-${res[i].stepID}-sendback--1`,
                                        label: res[i].actionText,
                                        location: loc,
                                        parameters: {'stepID': res[i].stepID,
                                        'nextStepID': 0,
                                        'action': res[i].actionType,
                                    },
                                    events: {
                                        click: function(overlay, evt) {
                                            params = overlay.getParameters();
                                            showActionInfo(params, evt);
                                        }
                                    }
                                }
                            ]]
                        });
                    } else {
                        lineOptions = {
                            source: 'step_' + res[i].stepID,
                            target: 'step_' + res[i].nextStepID,
                            connector: ["StateMachine", {curviness: 10}],
                            anchor: "Continuous",
                            overlays: [
                                ["Label", {
                                        id: 'stepLabel_' + res[i].stepID + '_' + res[i].nextStepID +
                                            '_' + res[i].actionType,
                                        cssClass: `workflowAction action-${res[i].stepID}-${res[i].actionType}-${res[i].nextStepID}`,
                                        label: res[i].actionText,
                                        location: loc,
                                        parameters: {'stepID': res[i].stepID,
                                        'nextStepID': res[i].nextStepID,
                                        'action': res[i].actionType,
                                    },
                                    events: {
                                        click: function(overlay, evt) {
                                            params = overlay.getParameters();
                                            showActionInfo(params, evt);
                                        }
                                    }
                                }
                            ]]
                        };
                        if (res[i].actionType == 'sendback') {
                            lineOptions.paintStyle = {stroke: 'red'};
                        }
                        jsPlumb.connect(lineOptions);
                    }
                }

                // connect the initial step if it exists
                if (workflows[workflowID].initialStepID != 0) {
                    jsPlumb.connect({
                        source: endPoints[-1],
                        target: endPoints[workflows[workflowID].initialStepID],
                        connector: ["StateMachine", {curviness: 10}],
                        anchor: "Continuous",
                        overlays: [
                            ["Label", {
                                    id: 'stepLabel_0_' + workflows[workflowID].initialStepID + '_submit',
                                    cssClass: `workflowAction action--1-submit-${workflows[workflowID].initialStepID}`,
                                    label: 'Submit',
                                    location: loc,
                                    parameters: {'stepID': -1,
                                    'nextStepID': workflows[workflowID].initialStepID,
                                    'action': 'submit',
                                },
                                events: {
                                    click: function(overlay, evt) {
                                        params = overlay.getParameters();
                                        showActionInfo(params, evt);
                                    }
                                }
                            }
                        ]]
                    });
                }

                // bind connection events
                jsPlumb.bind("connection", function(info) {
                    createAction(info);
                });
                jsPlumb.setSuspendDrawing(false, true);

                //if user came via stepinfo key nav re-open that modal
                if(stepID !== null) {
                    showStepInfo(stepID);
                }
            },
            error: (err) => console.log(err),
            cache: false,
            async: false
        });
    }

    var currentWorkflow = 0;

    function loadWorkflow(workflowID, stepID = null, params = null) {
        currentWorkflow = workflowID;
        jsPlumb.reset();
        endPoints = [];
        steps = {};
        jsPlumb.setSuspendDrawing(true);

        $('#workflows').val(workflowID);
        $('#workflows').trigger('chosen:updated');

        $('#workflow').html('');
        $('#workflow').append(
            `<button type="button" class="workflowStep" id="step_-1"
                aria-label="workflow step: Requestor"
                aria-controls="stepInfo_-1"
                aria-expanded="false"
                onclick="showStepInfo(-1)">
                Requestor
            </button>
            <div class="workflowStepInfo" id="stepInfo_-1"></div>`
        );
        $('#step_-1').css({
            'left': 180 + 40 + 'px',
            'top': 80 + 40 + 'px',
            'background-color': '#e0e0e0'
        });

        $.ajax({
            type: 'GET',
            url: '../api/workflow/' + workflowID,
            success: function(res) {
                var minY = 80;
                var maxY = 80;
                for (let i in res) {
                    steps[res[i].stepID] = res[i];
                    posY = parseFloat(res[i].posY);
                    if (posY < minY) {
                        posY = minY;
                    }

                    let emailNotificationIcon = '';
                    if (typeof res[i].stepData == 'string' && isJSON(res[i].stepData)) {
                        let stepParse = JSON.parse(res[i].stepData);
                        if (stepParse.AutomatedEmailReminders?.AutomateEmailGroup?.toLowerCase() === 'true') {
                            let dayCount = stepParse.AutomatedEmailReminders.DaysSelected;
                            let dayText = ((dayCount > 1) ? 'Days' : 'Day')
                            emailNotificationIcon = `<img src="../dynicons/?img=appointment.svg&w=18" style="margin-bottom: -3px;" alt="Email reminders will be sent after ${dayCount} ${dayText} of inactivity" title="Email reminders will be sent after ${dayCount} ${dayText} of inactivity" />`
                        }
                    }

                    $('#workflow').append(`<button type="button" class="workflowStep" id="step_${res[i].stepID}"
                        aria-label="workflow step: ${res[i].stepTitle}"
                        aria-controls="stepInfo_${res[i].stepID}"
                        aria-expanded="false"
                        onclick="showStepInfo(${res[i].stepID})">
                            ${res[i].stepTitle} ${emailNotificationIcon}
                        </button>
                        <div class="workflowStepInfo" id="stepInfo_${res[i].stepID}"></div>`
                    );

                    $('#step_' + res[i].stepID).css({
                        'left': parseFloat(res[i].posX) + 'px',
                        'top': posY + 'px',
                        'background-color': res[i].stepBgColor
                    });

                    if (endPoints[res[i].stepID] == undefined) {
                        endPoints[res[i].stepID] = jsPlumb.addEndpoint('step_' + res[i].stepID, {anchor: 'Continuous'}, endpointOptions);
                        jsPlumb.draggable('step_' + res[i].stepID, {
                            // save position of the box when moved
                            stop: function(stepID) {
                                return function() {
                                    var position = $('#step_' + stepID).offset();

                                    updatePosition(workflowID, stepID, position.left, position.top);
                                }
                            }(res[i].stepID)
                        });
                    }

                    if (maxY < posY) {
                        maxY = posY;
                    }
                }
                //append and draw the last step
                $('#workflow').append(`<button type="button" class="workflowStep" id="step_0"
                    aria-label="Workflow End"
                    aria-controls="stepInfo_0"
                    aria-expanded="false"
                    onclick="showStepInfo(0)">
                        End
                    </button>
                    <div class="workflowStepInfo" id="stepInfo_0"></div>`
                );
                $('#step_0').css({
                    'left': 180 + 400 + 'px',
                    'top': 160 + maxY + 'px',
                    'background-color': '#ff8181'
                });

                $('#workflow').css('height', 300 + maxY + 'px');
                drawRoutes(workflowID, stepID);
                buildStepList(steps);
                if(params !== null) {
                    const elAction = document.querySelector(`div[class*="action-${params?.stepID}-${params?.action}-"]`);
                    let position = { pageX: 200, pageY: 300 };
                    if(elAction !== null) {
                        const rect = elAction.getBoundingClientRect();
                        position.pageX = Number.parseInt(rect?.left || 200);
                        position.pageY = Number.parseInt(rect?.bottom || 300);
                    }
                    showActionInfo(params, position);
                }

                if(window.location.href.indexOf(`?a=workflow&workflowID=${workflowID}`) == -1) {
                    window.history.pushState('', '', `?a=workflow&workflowID=${workflowID}`);
                }
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    function loadWorkflowList() {
        // Don't show built-in workflows unless 'dev' exists as a GET parameter
        let devMode = false;
        let urlParams = new URLSearchParams(window.location.search);
        if(urlParams.get('dev') != null) {
            devMode = true;
        }
        
        $.ajax({
            async: false,
            type: 'GET',
            url: '../api/workflow',
            success: function(res) {
                let output = `
                <span id="workflow_select_status" role="status" aria-live="polite" aria-label="" style="position:absolute"></span>
                <select id="workflows" title="Select a Workflow" style="width: 100%" onchange="updateSelectionStatus(this, 'workflow_select_status')">`;
                var count = 0;
                var firstWorkflowID = 0;
                let firstWorkflowDescription = '';
                for (let i in res) {
                    if (count == 0) {
                        firstWorkflowDescription = res[i].description;
                        firstWorkflowID = res[i].workflowID;
                    }
                    workflows[res[i].workflowID] = res[i];

                    if(Number(res[i].workflowID) < 0 && !devMode) {
                        continue;
                    }
                    output += '<option value="' + res[i].workflowID + '" description = "' + res[i]
                        .description +
                        '"><b>' + res[i].description +
                        '</b> (ID: #' + res[i].workflowID + ')</option>';
                    count++;
                }
                if (count == 0) {
                    return;
                }

                output += '</select>';

                $('#workflowList').html(output);
                $('#workflows').on('change', function() {
                    workflowDescription = $('option:selected', this).attr('description');
                    loadWorkflow($('#workflows').val());
                });
                $('#workflows').chosen({
                    disable_search_threshold: 5,
                    allow_single_deselect: true,
                    width: '100%'
                });

                updateChosenAttributes("workflows", "workflows_label", "Select Workflow");
                const urlParams = new URLSearchParams(window.location.search);
                let workflowID = urlParams.get('workflowID');
                if (workflowID == undefined) {
                    workflowDescription = firstWorkflowDescription;
                    workflowID = firstWorkflowID;
                }
                loadWorkflow(workflowID);
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    function buildStepList(steps = {}) {
        let output = `<span id="step_select_status" role="status" aria-live="polite" aria-label="" style="position:absolute"></span>
            <select id="workflow_steps" title="Select a Workflow Step to edit it" onchange="updateSelectionStatus(this, 'step_select_status')">
            <option>Choose a step to edit</option>
            <option value="-1">Requestor</option>`;

        let arrSteps = [];
        for (let key in steps) {
            arrSteps.push(steps[key]);
        }
        const sortedSteps = arrSteps.sort((a, b) => {
            const stepA = a.stepTitle.toLowerCase();
            const stepB = b.stepTitle.toLowerCase();
            return stepA < stepB ? -1 : stepA > stepB ? 1 : 0
        });
        sortedSteps.forEach(step => {
            output += `<option value="${step.stepID}">${step.stepTitle} (#${step.stepID})</option>`;
        });
        output += '</select>';
        $('#stepList').html(output);
        $('#workflow_steps').chosen({
            disable_search_threshold: 5,
            width: '100%'
        });
        updateChosenAttributes("workflow_steps", "steps_label", "Select Workflow Step");

        $('#workflow_steps').on('change', function() {
            showStepInfo($('#workflow_steps').val());
        });
        $('#workflow_steps + .chosen-container').on('keydown', function(event) {
            const code = (event?.code || "").toLowerCase();
            if (code === 'space') {
                event.preventDefault();
                showStepInfo($('#workflow_steps').val());
            }
        });
    }

    function clickAction(selector, stepID = null) {
        const elOverlay = document.querySelector(`${selector}`);
        if(elOverlay !== null) {
            const actionEvent = new CustomEvent("click", {
                detail: {
                    reopenStepID: stepID
                },
                bubbles: true,
                cancelable: true
            });
            elOverlay.dispatchEvent(actionEvent)
        }
    }

    function buildRoutesList(stepID, workflowID) {
        let allRoutes = structuredClone(routes);
        let hasSubmit = false;
        allRoutes.forEach(r => {
            if(r.actionType === "sendback") {
                r.nextStepID = -1; //next step for sendback is referred to in global as 0 instead of -1, need -1 to filter
            }
            if(r.actionType === "submit") {
                hasSubmit = true;
            }
        });
        //sometimes needs submit route, depending where it is (only exists if requestor -> end)
        if(hasSubmit === false) {
            const initialStepID = workflows[currentWorkflow]?.initialStepID;
            const initialStepName = steps[initialStepID]?.stepTitle || "";
            const submit = {
                actionType: "submit",
                actionText: "Submit",
                stepID: -1,
                nextStepID: initialStepID
            }
            allRoutes.push(submit);
        }
        let stepRoutes = allRoutes.filter(a => a.stepID === stepID);
        stepRoutes = stepRoutes.sort((a, b) => {
            const rA = a.actionText.toLowerCase();
            const rB = b.actionText.toLowerCase();
            return rA < rB ? -1 : rA > rB ? 1 : 0
        });
        let output = "";
        if(stepRoutes.length > 0) {
            output = `<ul class="workflow_actions">`;
            stepRoutes.forEach(a => {
                const delNextID = a.actionType === "sendback" ? 0 : a.nextStepID; //needs to be 0 for POST
                output += `<li>${a.actionText}
                    <button type="button" class="buttonNorm icon" aria-label="Manage events for action: ${a.actionText}, step ${a.stepID}" title="Manage Action Events"
                        onclick="clickAction('.action-${a.stepID}-${a.actionType}-${a.nextStepID}','${stepID}')">
                        <img src="../dynicons/?img=accessories-text-editor.svg&w=16" alt="" />
                    </button>
                    ${workflowID > 0 && a.stepID !== -1 ?  //usually can't rm submit like other actions so not showing rm btn
                    `<button type="button" class="buttonNorm icon" aria-label="Remove action: ${a.actionText}, step ${a.stepID}" title="Remove this action"
                        onclick="removeAction(${currentWorkflow}, ${a.stepID}, ${delNextID},'${a.actionType}', ${stepID})">
                        <img src="../dynicons/?img=dialog-error.svg&w=16" alt="" />
                    </button>` : ``}
                </li>`;
            });
            output += '</ul>';
        }
        return output;
    }

    function viewHistory() {
        $('.workflowStepInfo').css('display', 'none');
        dialog_simple.setContent('');
        dialog_simple.setTitle('Workflow History');
        dialog_simple.indicateBusy();

        $.ajax({
            type: 'GET',
            url: 'ajaxIndex.php?a=gethistory&type=workflow&id=' + currentWorkflow,
            dataType: 'text',
            success: function(res) {
                dialog_simple.setContent(res);
                dialog_simple.indicateIdle();
                dialog_simple.show();
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    function renameWorkflow() {
        $('.workflowStepInfo').css('display', 'none');
        dialog.setContent(
            '<label for="workflow_rename">Workflow Name: </label><input type="text" id="workflow_rename" name="workflow_rename" value="' + workflowDescription +
            '" tabindex="0"/>');
        dialog.setTitle('Rename Workflow');
        dialog.setSaveHandler(function() {
            $.ajax({
                type: 'POST',
                url: '../api/workflow/' + currentWorkflow,
                data: {
                    description: $('#workflow_rename').val(),
                    CSRFToken: CSRFToken
                },
                success: function(res) {
                    if (res != currentWorkflow) {
                        alert("Prerequisite action needed:\n\n" + res);
                        dialog.hide();
                    } else {
                        let url = new URL(window.location.href);
                        url.searchParams.set('workflowID', res);
                        window.history.replaceState(null, null, url.toString());

                        loadWorkflowList();
                        workflowDescription = $('#workflow_rename').val();
                        dialog.hide();
                    }
                },
                error: (err) => console.log(err),
            });
        });
        dialog.show();
    }

    /**
     * The script to duplicate the currently selected workflow
     *
     * Created at: 7/26/2023, 1:08:10 PM (America/New_York)
     */
    function duplicateWorkflow() {
        $('.workflowStepInfo').css('display', 'none');

        dialog.setTitle('Duplicate current workflow');
        dialog.setContent('<br /><label for="description">New Workflow Title: </label><input type="text" id="description"/><br /><br />The following will NOT be copied over:<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;Data fields that show up next to the workflow action buttons');
        dialog.setSaveHandler(function() {
            let old_steps = {};
            let workflowID;
            let title = $('#description').val();

            postWorkflow(function(workflow_id) {
                workflowID = workflow_id;
                dialog.hide();
            });

            workflows[workflowID] = workflows[currentWorkflow];
            workflows[workflowID]['workflowID'] = parseInt(workflowID);
            workflows[workflowID]['description'] = title;
            old_steps[-1] = -1;

            for(let i in steps) {
                // add step, if successful update that step
                addStep(workflowID, steps[i].stepTitle, function(stepID) {

                    if (isNaN(stepID)) {
                        console.log(stepID);
                    } else {
                        old_steps[steps[i].stepID] = stepID;
                        updatePosition(workflowID, stepID, steps[i].posX, steps[i].posY);

                        updateTitle(steps[i].stepTitle, stepID, function(res) {
                            // Alls well that ends well.
                        });

                        if (steps[i].stepData != null) {
                            let auto = JSON.parse(steps[i].stepData);

                            let seriesData = {
                                AutomatedEmailReminders: {
                                    'Automate Email Group': auto.AutomatedEmailReminders.AutomateEmailGroup,
                                    'Days Selected': auto.AutomatedEmailReminders.DaysSelected,
                                    'Date Selected': auto.AutomatedEmailReminders?.DateSelected || '',
                                    'Additional Days Selected': auto.AutomatedEmailReminders.AdditionalDaysSelected,
                                }
                            };

                            updateStepData(seriesData, stepID, function (res) {
                                // Alls well that ends well.
                            });
                        }

                        updateApprover(steps[i].indicatorID_for_assigned_empUID, stepID, function (res) {
                            // Alls well that ends well.
                        });

                        updateGroupApprover(steps[i].indicatorID_for_assigned_groupID, stepID, function (res) {
                            // Alls well that ends well.
                        });

                        // set requireDigitalSignature
                        // this endpoint does not exist in this file at this time.

                        updateDependencies(steps[i].stepID, old_steps);
                    }
                });


            }

            workflows[workflowID]['initialStepID'] = parseInt(old_steps[workflows[currentWorkflow].initialStepID]);

            updateInitialStep(workflowID, workflows[workflowID]['initialStepID'], function () {
                // nothing to do here
            });

            updateRoutes(workflowID, old_steps);
            updateRouteEvents(currentWorkflow, workflowID, old_steps);

            let url = new URL(window.location.href);
            url.searchParams.set('workflowID', workflowID);
            window.history.replaceState(null, null, url.toString());

            loadWorkflowList();
        });
        dialog.show();
    }

    /**
     * @param int workflowID
     * @param int stepID
     * @param closure callback
     *
     * Created at: 7/26/2023, 1:13:07 PM (America/New_York)
     */
    function updateInitialStep(workflowID, stepID, callback) {
        $.ajax({
            async: false,
            type: 'POST',
            url: '../api/workflow/' + workflowID + '/initialStep',
            data: {
                stepID: stepID,
                CSRFToken: CSRFToken
            },
            success: function() {
                callback();

            },
            error: (err) => console.log(err),
        });
    }

    /**
     * This gets a list of dependencies to a particular step and
     * creates a duplicate for the new workflow
     *
     * @param int stepID
     * @param array old_steps
     *
     * Created at: 7/26/2023, 1:14:37 PM (America/New_York)
     */
    function updateDependencies(stepID, old_steps) {
        let dependency;

        getStepDependencies(stepID, function (res) {
            if (res.status.code == 2) {
                dependency = res.data;

                for (let i in dependency) {
                    postStepDependency(old_steps[dependency[i].stepID], dependency[i].dependencyID, function (res) {
                        // nothing to do here
                    });
                }
            } else {
                console.log('no dependencies exist');
            }
        });
    }

    /**
     * This gets a list of route_events to loop through and make
     * new records for the new workflow being duplicated
     *
     * @param int currentWorkflow
     * @param int workflow
     * @param array old_steps
     *
     * Created at: 7/26/2023, 1:16:18 PM (America/New_York)
     */
    function updateRouteEvents(currentWorkflow, workflow, old_steps) {
        let workflow_events;
        let listAllEvents;

        getWorkflowEvents(currentWorkflow, function (res ) {
            workflow_events = res;
        });


        if (workflow_events.status.code == 2) {
            listAllEvents = workflow_events.data;

            for (let i in listAllEvents) {
                let event = {eventID: listAllEvents[i].eventID,
                            CSRFToken: CSRFToken};

                postEvent(old_steps[listAllEvents[i].stepID], listAllEvents[i].actionType, workflow, event, function (res) {
                    // nothing to do here.
                });
            }
        }
    }

    /**
     * This is taking the routes array and looping through it to create
     * the new routes for the duplicated workflow
     *
     * @param int workflow
     * @param array old_steps
     *
     * Created at: 7/26/2023, 1:17:21 PM (America/New_York)
     */
    function updateRoutes(workflow, old_steps) {
        for (let i in routes) {
            postAction(old_steps[routes[i].stepID], old_steps[routes[i].nextStepID], routes[i].actionType, workflow, function (res) {
                // check to see if this is a sendback and if the requirement is true
                if (routes[i].displayConditional) {
                    let required = JSON.parse(routes[i].displayConditional);

                    updateRequiredCheckbox(workflow, old_steps[routes[i].stepID], required.required, function (res) {
                        // nothing to do here.
                    })
                }
            });
        }
    }

    /**
     * Create the group approver for a duplicated workflow
     *
     * @param int indicatorID
     * @param int stepID
     * @param closure callback
     *
     * Created at: 7/26/2023, 1:20:42 PM (America/New_York)
     */
    function updateGroupApprover(indicatorID, stepID, callback) {
        $.ajax({
            type: 'POST',
            url: '../api/workflow/step/' + stepID + '/indicatorID_for_assigned_groupID',
            data: {
                indicatorID: indicatorID,
                CSRFToken: CSRFToken
            },
            success: function(res) {
                callback(res);
            },
            error: (err) => console.log(err),
        });
    }

    /**
     * Create the approver for a duplicated workflow
     *
     * @param int indicatorID
     * @param int stepID
     * @param closure callback
     *
     * Created at: 7/26/2023, 1:23:08 PM (America/New_York)
     */
    function updateApprover(indicatorID, stepID, callback) {
        $.ajax({
            type: 'POST',
            url: '../api/workflow/step/' + stepID + '/indicatorID_for_assigned_empUID',
            data: {
                indicatorID: indicatorID,
                CSRFToken: CSRFToken
            },
            success: function(res) {
                callback(res);
            },
            error: (err) => console.log(err),
        });
    }

    /**
     * @param array data
     * @param int stepID
     * @param closure callback
     *
     * Created at: 7/26/2023, 1:23:50 PM (America/New_York)
     */
    function updateStepData(data, stepID, callback) {
        $.ajax({
            type: 'POST',
            data: {
                CSRFToken: CSRFToken,
                seriesData: data
            },
            url: '../api/workflow/stepdata/' + stepID,
            success: function(res) {
                callback(res);
            },
            error: function() { console.log('Failed to save automated email reminder data'); }
        });
    }

    /**
     * @param int workflowID
     * @param string title
     * @param closure callback
     *
     * @return [type]
     *
     * Created at: 7/26/2023, 1:25:08 PM (America/New_York)
     */
    function addStep(workflowID, title, callback) {
        $.ajax({
            async: false,
            type: 'POST',
            url: '../api/workflow/' + workflowID + '/step',
            data: {
                stepTitle: title,
                CSRFToken: CSRFToken
            },
            success: function(res) {
                callback(res);
            },
            error: (err) => callback(err),
        });
    }

    /**
     * This save the position of the step on the screen
     *
     * @param int workflowID
     * @param int stepID
     * @param int left
     * @param int top
     *
     * Created at: 7/26/2023, 1:25:40 PM (America/New_York)
     */
    function updatePosition(workflowID, stepID, left, top) {
        $.ajax({
            type: 'POST',
            url: '../api/workflow/' + workflowID +
                '/editorPosition',
            data: {
                stepID: stepID,
                x: left,
                y: top,
                CSRFToken: CSRFToken
            },
            success: function() {

            },
            error: (err) => console.log(err),
        });
    }

    /**
     * Updates the requirement label
     *
     * @param string title
     * @param int stepID
     * @param closure callback
     *
     * @return array
     *
     * Created at: 7/26/2023, 1:27:49 PM (America/New_York)
     */
    function updateTitle(title, stepID, callback) {
        $.ajax({
            type: 'POST',
            data: {
                CSRFToken: CSRFToken,
                title: title
            },
            url: '../api/workflow/step/' + stepID,
            success: function(res) {
                callback(res);
            },
            error: (err) => console.log(err),
        });
    }

    function updateRequiredCheckbox(workflow, stepID, checkMark, callback) {
        $.ajax({
            type: 'POST',
            url: '../api/workflowRoute/require',
            data: {required: checkMark,
            step_id: stepID,
            workflow_id: workflow,
            CSRFToken: CSRFToken},
            success: function (res) {
                callback(res);
            },
            error: function (err) {
                console.log(err);
            }
        });
    }

    /**
     * @param int stepID
     * @param int dependencyID
     * @param closure callback
     *
     * @return void
     *
     * Created at: 7/26/2023, 1:28:44 PM (America/New_York)
     */
    function postStepDependency(stepID, dependencyID, callback) {
        $.ajax({
            type: 'POST',
            url: '../api/workflow/step/' + stepID + '/dependencies',
            data: {
                dependencyID: dependencyID,
                workflowID: currentWorkflow,
                CSRFToken: CSRFToken
            },
            success: function() {
                callback();
            },
            error: (err) => console.log(err),
        });
    }

    /**
     * Create a new workflow
     *
     * @param closure callback
     *
     * @return int
     *
     * Created at: 7/26/2023, 1:29:18 PM (America/New_York)
     */
    function postWorkflow(callback) {
        $.ajax({
            async: false,
            type: 'POST',
            url: '../api/workflow/new',
            data: {
                description: $('#description').val(),
                CSRFToken: CSRFToken
            },
            success: function (res) {
                callback(res);
            },
            error: (err) => callback(err),
        });
    }

    /**
     * @param int stepID
     * @param int nextStepID
     * @param string action
     * @param int workflowID
     * @param closure callback
     *
     * @return array
     *
     * Created at: 7/26/2023, 1:29:52 PM (America/New_York)
     */
    function postAction(stepID, nextStepID, action, workflowID, callback) {
        $.ajax({
            type: 'POST',
            url: '../api/workflow/' + workflowID + '/action',
            data: {
                stepID: stepID,
                nextStepID: nextStepID,
                action: action,
                CSRFToken: CSRFToken
            },
            success: function(res) {
                if (+res === 1) {
                    callback(res)
                } else {
                    alert(res)
                }
            },
            error: (err) => console.log(err),
        });
    }

    /**
     * add a routing event to a specific workflow action
     * @param int stepID
     * @param string action
     * @param int workflowID
     * @param object event, eg { eventID: 'event id', CSRFToken: 'token' }
     * @param closure callback
     *
     * @return array
     *
     * Created at: 7/26/2023, 1:31:07 PM (America/New_York)
     */
    function postEvent(stepID, action, workflowID, event, callback) {
        $.ajax({
            type: 'POST',
            url: '../api/workflow/' + workflowID + '/step/' + stepID + '/_' + action +
                '/events',
            data: event,
            success: function (res) {
                callback(res);
            },
            error: function (err) {
                alert(err);
            },
            cache: false
        })
    }

    /**
     * @param int stepID
     * @param int indicatorID
     *
     * Created at: 7/26/2023, 1:31:50 PM (America/New_York)
     */
    function postModule(stepID, indicatorID) {
        $.ajax({
            type: 'POST',
            url: '../api/workflow/step/' + stepID + '/inlineIndicator',
            data: {
                indicatorID: indicatorID,
                CSRFToken: CSRFToken
            }
        });
    }

    /**
     * Get a specific step
     *
     * @param int stepID
     * @param closure callback
     *
     * @return array
     *
     * Created at: 7/26/2023, 1:32:32 PM (America/New_York)
     */
    function getStep(stepID, callback) {
        $.ajax({
            type: 'GET',
            data: {
                CSRFToken: CSRFToken
            },
            url: '../api/workflow/step/' + stepID,
            async: false,
            success: function(res) {
                callback(res);
            },
            error: function(err) {
                console.log('Failed to gather workflow step!');
                callback(err);
            }
        });
    }

    /**
     * @param int workflowID
     * @param int stepID
     * @param string action
     * @param closure callback
     *
     * @return array
     *
     * Created at: 7/26/2023, 1:33:15 PM (America/New_York)
     */
    function getRouteEvents(workflowID, stepID, action, callback) {
        $.ajax({
            type: 'GET',
            url: '../api/workflow/' + workflowID + '/step/' + stepID + '/_' + action + '/events',
            success: function(res) {
                callback(res);
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    /**
     * @param int workflowID
     * @param closure callback
     *
     * @return array
     *
     * Created at: 7/26/2023, 1:33:56 PM (America/New_York)
     */
    function getWorkflowEvents(workflowID, callback) {
        $.ajax({
            async: false,
            type: 'GET',
            url: '../api/workflow/' + workflowID + '/step/routeEvents',
            success: function(res) {
                callback(res);
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    /**
     * @param int stepID
     * @param closure callback
     *
     * @return array
     *
     * Created at: 7/26/2023, 1:34:49 PM (America/New_York)
     */
    function getStepDependencies(stepID, callback) {
        $.ajax({
            async: false,
            type: 'GET',
            url: '../api/workflow/' + stepID + '/stepDependencies',
            success: function(res) {
                callback(res);
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    // automated email reminder types, frequency and specific date
    function toggleReminderType() {
        const elSelect = document.getElementById('reminder_type_select');
        if(elSelect !== null) {
            const reminderType = elSelect.value.toLowerCase();

            let elInputDuration = document.getElementById('reminder_days');
            let elInputDate = document.getElementById('reminder_date');
            if(elInputDuration !== null) {
                elInputDuration.disabled = reminderType !== 'duration';
                elInputDuration.setAttribute('aria-disabled', reminderType !== 'duration');
            }
            if(elInputDate !== null) {
                elInputDate.disabled = reminderType !== 'date';
                elInputDate.setAttribute('aria-disabled', reminderType !== 'date');
            }

            let elContainerDuration = document.getElementById('email_reminder_duration');
            let elContainerDate = document.getElementById('email_reminder_date');
            if(elContainerDuration !== null) {
                elContainerDuration.style.display = reminderType === 'duration' ? 'block' : 'none';
            }
            if(elContainerDate !== null) {
                elContainerDate.style.display = reminderType === 'date' ? 'block' : 'none';
            }
        }
    }

    function updateChosenAttributes(selectID = "", labelID = "", title = "List Selection") {
        $(`#${selectID}_chosen input.chosen-search-input`).attr('role', 'combobox');
        $(`#${selectID}_chosen input.chosen-search-input`).attr('aria-labelledby', labelID);
        $(`#${selectID}-chosen-search-results`).attr('title', title);
        $(`#${selectID}-chosen-search-results`).attr('role', 'listbox');
    }
    function updateSelectionStatus(selectEl = null, statusID = "") {
        if(selectEl !== null && statusID !== "") {
            const statusEl = document.getElementById(statusID);
            const textVal = selectEl.querySelector(`option[value="${selectEl?.value}"]`)?.innerText || "";
            if(statusEl !== null && textVal !== "") {
                statusEl.setAttribute('aria-label', `${textVal} is selected`);
            }
        }
    }


    var dialog, dialog_confirm, dialog_simple, dialog_ok;
    var workflows = {};
    var steps = {};
    var routes = {};
    var endpointOptions = {
        isSource: true,
        isTarget: true,
        endpoint: ["Rectangle", {cssClass: "workflowEndpoint"}],
        paintStyle: {width: 48, height: 48},
        maxConnections: -1
    };

    this.portalAPI = LEAFRequestPortalAPI();
    this.portalAPI.setBaseURL('../api/?a=');
    this.portalAPI.setCSRFToken(CSRFToken);


    // Fix dialog boxes not going away when clicking outside of box
    $(document).on('mousedown', function(e) {
        let container = $(".workflowStepInfo");
        if (!container.is(e.target) && container.has(e.target).length === 0) {
            $('.workflowStep').attr('aria-expanded', false);
            container.hide();
        }
    });

    $(function() {
        dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save','button_cancelchange');
        dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator','confirm_button_save', 'confirm_button_cancelchange');
        dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator','simplebutton_save', 'simplebutton_cancelchange');
        dialog_ok = new dialogController('ok_xhrDialog', 'ok_xhr', 'ok_loadIndicator', 'confirm_button_ok', 'confirm_button_cancelchange');
        $('#simplexhrDialog').dialog({minWidth: ($(window).width() * .78) + 30});

        jsPlumb.Defaults.Container = "workflow";
        jsPlumb.Defaults.ConnectionOverlays = [["PlainArrow", {location:0.9, width:20, length:12}]];
        jsPlumb.Defaults.PaintStyle = {stroke: 'lime', lineWidth: 1};
        jsPlumb.Defaults.Connector = ["StateMachine", {curviness: 10}];
        jsPlumb.Defaults.Anchor = "Continuous";
        jsPlumb.Defaults.Endpoint = "Blank";

        loadWorkflowList();

        $.ajax({
            type: 'GET',
            url: '../api/system/settings',
            success: res => {
                const siteType = res?.siteType || '';
                if (siteType.toLowerCase() === 'national_subordinate') {
                    let warnContent =
                        `<div id="subordinate_site_warning"><h3>This is a Nationally Standardized Subordinate Site</h3>`;
                    warnContent +=
                        `<span>Do not make modifications! &nbsp;Synchronization problems will occur. &nbsp;`;
                    warnContent +=
                        `Please contact your process POC if modifications need to be made.</span></div>`;
                    $('#bodyarea').prepend(warnContent);
                }
            },
            error: err => console.log(err),
            cache: false
        })
    });
</script>