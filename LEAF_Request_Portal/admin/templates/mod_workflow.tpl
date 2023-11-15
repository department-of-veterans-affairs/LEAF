<div id="sideBar" style="float: left; width: 180px">
    <div id="btn_createStep" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="createStep();" style="font-size: 120%; display: none"
        role="button" tabindex="0"><img src="../dynicons/?img=list-add.svg&w=32" alt="Add Step" /> Add Step</div><br />
    Workflows: <br />
    <div id="workflowList"></div>
    <br />
    <div id="btn_newWorkflow" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="newWorkflow();" style="font-size: 120%" role="button"
        tabindex="0"><img src="../dynicons/?img=list-add.svg&w=32" alt="New Workflow" /> New Workflow</div><br />
    <br />
    <div id="btn_deleteWorkflow" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="deleteWorkflow();" style="font-size: 120%; display: none"
        role="button" tabindex="0"><img src="../dynicons/?img=list-remove.svg&w=16" alt="Delete workflow" /> Delete
        workflow</div><br />
    <div id="btn_listActionType" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="listActionType();" style="font-size: 120%; display: none"
        role="button" tabindex="0">Edit Actions</div><br />
    <div id="btn_listEvents" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="listEvents();" style="font-size: 120%; display: none"
        role="button" tabindex="0">Edit Events</div><br />
    <div id="btn_viewHistory" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="viewHistory();" style="font-size: 120%; display: none;"
        role="button" tabindex="0"><img src="../dynicons/?img=appointment.svg&amp;w=32" alt="View History" /> View
        History</div><br />
    <div id="btn_renameWorkflow" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="renameWorkflow();" style="font-size: 120%; display: none;"
        role="button" tabindex="0"><img src="../dynicons/?img=accessories-text-editor.svg&amp;w=32"
            alt="Rename Workflow" /> Rename
        Workflow</div>
    <div id="btn_duplicateWorkflow" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="duplicateWorkflow();" style="font-size: 100%; display: none; margin-top: 10px;"
        role="button" tabindex="0"><img src="../dynicons/?img=edit-copy.svg&amp;w=32"
            alt="Duplicate Workflow" /> Duplicate
        Workflow</div>
</div>
<div id="workflow"
    style="margin-left: 184px; background-color: #444444; margin-top: 16px; overflow-x: auto; overflow-y: auto; width: 72%;">
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
        if ($('#subordinate_site_warning').length) {
            alert('To make changes, please contact the administrator for the Nationally Standardized Primary site.');
        } else {
            $('.workflowStepInfo').css('display', 'none');

            dialog.setTitle('Create new workflow');
            dialog.setContent('<br /><label for="description">Workflow Title:</label> <input type="text" id="description"/>');
            dialog.setSaveHandler(function() {
                let workflowID;

                postWorkflow(function(workflow_id) {
                    loadWorkflowList(workflow_id);
                    dialog.hide();
                });
            });
            dialog.show();
        }
    }

    function deleteWorkflow() {
        if ($('#subordinate_site_warning').length) {
            alert('To make changes, please contact the administrator for the Nationally Standardized Primary site.');
        } else {
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
                    <button class="buttonNorm" onclick="editEvent('${events[i].eventID}')"
                        style="background: #22b;color: #fff; padding: 2px 4px;">
                        Edit
                    </button>
                    <button class="buttonNorm" onclick="deleteEvent('${events[i].eventID}')"
                        style="background: #c00;color: #fff;margin-left: 10px; padding: 2px 4px;">
                        Delete
                    </button>
                </td>
            </tr>`;
        }

        content += `</table><br /><br />
            <span class="buttonNorm" id="create-event" tabindex="0">Create a new Event</span><br /><br />
            You can edit custom email events here: <a href="./?a=mod_templates_email" target="_blank">Email Template Editor</a>`;

        return content;
    }

    /**
     * Purpose: List all Custom Events
     */
    function listEvents() {
        if ($('#subordinate_site_warning').length) {
            alert('To make changes, please contact the administrator for the Nationally Standardized Primary site.');
        } else {
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
    }

    /**
     * Purpose: Content for group dropdown on newEvent
     * @groups Group list pass-through
     */
    function groupListContent(groups) {
        if (!Array.isArray(groups)) {
            return 'Invalid parameter(s): groups must be an array.';
        }
        let content = 'Notify Group: <select id="groupID">' +
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

        dialog.setSaveHandler(function() {
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
                    loadWorkflow(currentWorkflow);
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
    function newEvent(events) {
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
        let createEventContent = '<div>Event Type: <select id="eventType">' +
            '<option value="Email" selected>Email</option>' +
            '</select><br /><br />' +
            '<span>Event Name: </span><input type="text" id="eventName" class="eventTextBox" /><br /><br />' +
            '<span>Short Description: </span><input type="text" id="eventDesc" class="eventTextBox" /><br /><br />' +
            '<div id="eventEmailSettings" style="display: none">Notify Requestor Email: <input id="notifyRequestor" type="checkbox" /><br /><br />Notify Next Approver Email: <input id="notifyNext" type="checkbox" /><br /><br />' +
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
                }).done(function() {
                    alert('Event was successfully created.');
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

        let content = '';
        content = 'Add an event: ';
        content += '<br /><div><select id="eventID" name="eventID">';
        for (let i in events) {
            content += '<option value="' + events[i].eventID + '">' + events[i].eventType + ' - ' + events[i]
                .eventDescription + '</option>';
        }
        content += '</select></div>';

        return content;
    }

    /**
     * Purpose: Dialog for adding events
     * @workdflowID Current Workflow ID for email reminder
     * @stepID Step ID holding the action for email reminder
     * @actionType Action type for email reminder
     */
    function addEventDialog(workflowID, stepID, actionType) {
        $('.workflowStepInfo').css('display', 'none');
        dialog.setTitle('Add Event');
        let eventDialogContent =
            '<div><button id="createEvent" class="usa-button leaf-btn-med">Create Event</button></div>' +
            '<div id="addEventDialog"></div>' +
            '<div id="eventData"></div>';
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
                    newEvent(res);
                });
                $('#eventID').chosen({disable_search_threshold: 5})
                .change(function() {
                        $('#eventData').html('');
                        dialog.clearValidators();
                        if ($("#eventID").val() == 'automated_email_reminder') {
                            setEmailReminderHTML(workflowID, stepID, actionType, dialog);
                        }
                    })
                    .trigger("change");
                dialog.setSaveHandler(function() {
                    let ajaxData = {eventID: $('#eventID').val(),
                                    CSRFToken: CSRFToken};
                    if ($('#eventID').val() == 'automated_email_reminder') {
                        var formObj = {};
                        $.each($('#eventData :input').serializeArray(), function() {
                            formObj[this.name] = this.value;
                        });
                        $.extend(ajaxData, formObj);
                    }

                    postEvent(stepID, actionType, workflowID, ajaxData, function (res) {
                        loadWorkflow(workflowID);
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

        let content = '<div>Event Type: <select id="eventType">' +
            '<option value="Email" selected>Email</option>' +
            '</select><br /><br />' +
            '<span>Event Name: </span><input type="text" id="eventName" class="eventTextBox" value="' + event[0].eventID
            .replace('CustomEvent_', '') + '" /><br /><br />' +
            '<span>Short Description: </span><input type="text" id="eventDesc" class="eventTextBox" value="' + event[0]
            .eventDescription + '" /><br /><br />' +
            '<div id="eventEmailSettings" style="display: none">Notify Requestor Email: <input id="notifyRequestor" type="checkbox" /><br /><br />Notify Next Approver Email: <input id="notifyNext" type="checkbox" /><br /><br />';

        content += 'Notify Group: <select id="groupID">' +
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
                        }).done(function() {
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
        dialog_confirm.setSaveHandler(function() {
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
        dialog.setSaveHandler(function() {
            updateTitle($('#title').val(), stepID, function(step_id) {
                if (step_id == 1) {
                    loadWorkflow(currentWorkflow);
                    dialog.hide();
                } else {
                    alert(res);
                }
            });
        });
        dialog.show();
    }

    function editRequirement(dependencyID) {
        $('.workflowStepInfo').css('display', 'none');
        dialog.setTitle('Edit Requirement');
        dialog.setContent('Label: <input type="text" id="description"></input>');
        dialog.setSaveHandler(function() {
            if ($('#description').val() == '') {
                dialog_ok.setTitle('Description Validation');
                dialog_ok.setContent('Description cannot be blank, please enter a Title or click cancel.');
                dialog_ok.setSaveHandler(function() {
                    dialog_ok.clearDialog();
                    dialog_ok.hide();
                    dialog.hide();
                    editRequirement(dependencyID);
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
                        loadWorkflow(currentWorkflow);
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
        dialog_confirm.setSaveHandler(function() {
            dialog_confirm.indicateBusy();
            $.ajax({
                type: 'DELETE',
                url: `../api/workflow/step/${stepID}/dependencies?`
                    + $.param({ 'dependencyID': dependencyID, 'CSRFToken': CSRFToken }),
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

    function dependencyRevokeAccess(dependencyID, groupID) {
        $('.workflowStepInfo').css('display', 'none');
        dialog_confirm.setTitle('Confirmation required');
        dialog_confirm.setContent('Are you sure you want to revoke these privileges?');
        dialog_confirm.setSaveHandler(function() {
            $.ajax({
                type: 'DELETE',
                url: '../api/workflow/dependency/' + dependencyID + '/privileges?'
                    + $.param({ 'groupID': groupID, 'CSRFToken': CSRFToken }),
                success: function() {
                    $('.workflowStepInfo').css('display', 'none');
                    loadWorkflow(currentWorkflow);
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
                let buffer = 'Grant Privileges to Group:<br /><select id="groupID">' +
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
                dialog.indicateIdle();
            },
            error: (err) => console.log(err),
            cache: false
        });

        dialog.setSaveHandler(function() {
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
        dialog.show();
    }

    function newDependency(stepID) {
        dialog.setTitle('Create a new requirement');
        dialog.setContent(
            '<br />Requirement Label: <input type="text" id="description"></input><br /><br />Requirements determine the WHO and WHAT part of the process.<br />Example: "Fiscal Team Review"'
        );

        dialog.setSaveHandler(function() {
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
                buffer = 'Select an existing requirement ';
                buffer += '<br /><div><select id="dependencyID" name="dependencyID">';

                var reservedDependencies = [-3, -2, -1, 1, 8];
                var maskedDependencies = [5];

                buffer += '<optgroup label="Custom Requirements">';
                for (let i in res) {
                    if (reservedDependencies.indexOf(res[i].dependencyID) == -1 &&
                        maskedDependencies.indexOf(res[i].dependencyID) == -1) {
                        buffer += '<option value="' + res[i].dependencyID + '">' + res[i].description +
                            '</option>';
                    }
                }
                buffer += '</optgroup>';

                buffer += '<optgroup label="&quot;Smart&quot; Requirements">';
                for (let i in res) {
                    if (reservedDependencies.indexOf(res[i].dependencyID) != -1) {
                        buffer += '<option value="' + res[i].dependencyID + '">' + res[i].description +
                            '</option>';
                    }
                }
                buffer += '</optgroup>';

                buffer += '</select></div>';
                buffer +=
                    '<br /><br /><br /><br /><div>If a requirement does not exist: <span tabindex=0 class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="newDependency(' + stepID +
                    ')">Create a new requirement</span></div>';
                $('#dependencyList').html(buffer);
                $('#dependencyID').chosen({disable_search_threshold: 5});

                dialog.setSaveHandler(function() {
                    linkDependency(stepID, $('#dependencyID').val());
                });
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    function createStep() {
        if ($('#subordinate_site_warning').length) {
            alert('To make changes, please contact the administrator for the Nationally Standardized Primary site.');
        } else {
            $('.workflowStepInfo').css('display', 'none');
            if (currentWorkflow == 0) {
                return;
            }

            dialog.setTitle('Create new Step');
            dialog.setContent(
                '<br /><label for="stepTitle">Step Title:</label> <input type="text" id="stepTitle"></input><br /><br />Example: "Service Chief"'
            );
            dialog.setSaveHandler(function() {
                addStep(currentWorkflow, $('#stepTitle').val(), function(stepID) {
                    if (isNaN(stepID)) {
                        console.log(stepID);
                    } else {
                        loadWorkflow(currentWorkflow);
                    }

                    dialog.hide();
                });
            });
            dialog.show();
        }
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
        if ($('#subordinate_site_warning').length) {
            alert('To make changes, please contact the administrator for the Nationally Standardized Primary site.');
        } else {
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
                        <span class="buttonNorm" id="create-action-type" tabindex="0">Create a new Action</span>`;

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
    }

    /**
    * @param {Object} action
    * @returns string template for action editing modal
    */
    function renderActionInputModal(action = {}) {
        return `
            <table style="margin-bottom:2rem;">
                <tr>
                    <td><span id="action_label">Action <span style="color: red">*Required</span></span></td>
                    <td>
                        <input id="actionText" type="text" maxlength="50" style="border: 1px solid red"
                        value="${action?.actionText || ''}" aria-labelledby="action_label"/>
                    </td>
                    <td>eg: Approve</td>
                </tr>
                <tr>
                    <td><span id="action_past_tense_label">Action Past Tense <span style="color: red">*Required</span></span></td>
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
    function createAction(params) {
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
                    loadWorkflow(currentWorkflow);
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
                    '<br />- OR -<br /><br /><span class="buttonNorm" tabindex=0 onkeydown="onKeyPressClick(event)" onclick="newAction();">Create a new Action Type</span>';

                dialog.indicateIdle();
                dialog.setContent(buffer);
                $('#actionType').chosen({disable_search_threshold: 5});
                // TODO: Figure out why this triggers even when the user clicks save
                /*
                dialog.setCancelHandler(function() {
                    loadWorkflow(currentWorkflow);
                });*/
                dialog.setSaveHandler(function() {
                    postAction(source, target, $('#actionType').val(), currentWorkflow, function(res) {
                        loadWorkflow(currentWorkflow);
                    });
                    dialog.hide();
                });
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    function removeAction(workflowID, stepID, nextStepID, action) {
        $('.workflowStepInfo').css('display', 'none');
        dialog_confirm.setTitle('Confirm action removal');
        dialog_confirm.setContent('Confirm removal of:<br /><br />' + stepID + ' -> ' + action + ' -> ' + nextStepID);
        dialog_confirm.setSaveHandler(function() {
            $.ajax({
                type: 'DELETE',
                url: `../api/workflow/${workflowID}/step/${stepID}/_${action}/${nextStepID}?`
                    + $.param({ 'CSRFToken': CSRFToken }),
                success: function() {
                    loadWorkflow(workflowID);
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

        let stepID = params.stepID;
        $.ajax({
            type: 'GET',
            url: '../api/workflow/' + currentWorkflow + '/step/' + stepID + '/_' + params.action + '/events',
            success: function(res) {
                let find_required = '';
                if (typeof params.required === 'undefined' || params.required === '') {
                    find_required = $.parseJSON('{"required":"false"}');
                } else {
                    find_required = $.parseJSON(params.required);
                }
            }
        });

        getRouteEvents(currentWorkflow, stepID, params.action, function (res) {
            let find_required = '';

            if (typeof params.required === 'undefined' || params.required === '') {
                find_required = $.parseJSON('{"required":"false"}');
            } else {
                find_required = $.parseJSON(params.required);
            }

            let output = '';
            let required = '';

            if (find_required.required == 'true') {
                required = 'checked=checked';
            }

            stepTitle = steps[stepID] != undefined ? steps[stepID].stepTitle : 'Requestor';
            output = '<h2>Action: ' + stepTitle + ' clicks ' + params.action + '</h2>';

            if (params.action == 'sendback') {
                output += '<br /><input type="checkbox" id="require_sendback_' + stepID + '" onchange="switchRequired(this)" ' + required + ' /> Require a comment to sendback.<br />';
            }

            output += '<br /><div>Triggers these events:<ul>';
            // the sendback action always notifies the requestor
            if (params.action == 'sendback') {
                output += '<li><b>Email - Notify the requestor</b></li>';
            }
            for (let i in res) {
                output += '<li><b title="' + res[i].eventID + '">' + res[i].eventType + ' - ' + res[i]
                    .eventDescription +
                    '</b> <img tabindex=0 onkeydown="onKeyPressClick(event)" src="../dynicons/?img=dialog-error.svg&w=16" style="cursor: pointer" onclick="unlinkEvent(' +
                    currentWorkflow + ', ' + stepID + ', \'' + params.action + '\', \'' + res[i]
                    .eventID + '\')" alt="Remove Action" title="Remove Action" /></li>';
            }
            output += '<li style="padding-top: 8px"><span tabindex=0 class="buttonNorm" id="event_' +
                currentWorkflow + '_' + stepID + '_' + params.action + '" onkeydown="onKeyPressClick(event)">Add Event</span>';
            output += '</ul></div>';
            output +=
                '<hr /><div style="padding: 4px"><span class="buttonNorm" tabindex=0 onkeydown="onKeyPressClick(event)" onclick="removeAction(' +
                currentWorkflow + ', ' + stepID + ', ' + params.nextStepID + ', \'' + params.action +
                '\')">Remove Action</span></div>';
            $('#stepInfo_' + stepID).html(output);
            $('#event_' + currentWorkflow + '_' + stepID + '_' + params.action).on('click', function() {
                addEventDialog(currentWorkflow, stepID, params.action);
            });
        });

        $('#stepInfo_' + stepID).css({
            left: evt.pageX + 'px',
            top: evt.pageY + 'px'
        });
        $('#stepInfo_' + stepID).show('slide', null, 200);
    }

    function switchRequired(element) {
        let stepID = element.id.split('_');
        let e = document.getElementById("workflows");
        let workflowID = e.value;

        updateRequiredCheckbox(workflowID, stepID[2], element.checked, function(res) {
            console.log(res);
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
                        indicatorList += '<option value="' + res[i].indicatorID + '">' + res[i]
                            .categoryName + ': ' + res[i].name + ' (id: ' + res[i].indicatorID +
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
                                    $('#workflowIndicator_' + stepID).append('<option value="' + indicatorList[
                                            j].indicatorID + '">' + indicatorList[j].categoryName + ': ' +
                                        indicatorList[j].name + ' (id: ' + indicatorList[j].indicatorID +
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

    function showStepInfo(stepID) {
        $('#stepInfo_' + stepID).html('');
        if ($('#stepInfo_' + stepID).css('display') != 'none') { // hide info window on second click
            $('.workflowStepInfo').css('display', 'none');
            return;
        }
        $('.workflowStepInfo').css('display', 'none');
        $('#stepInfo_' + stepID).html('Loading...');

        switch (Number(stepID)) {
            case -1:
                $('#stepInfo_' + stepID).html('Request initiator (stepID #: -1)');
                break;
            case 0:
                $('#stepInfo_' + stepID).html('The End.  (stepID #: 0)');
                break;
            default:
                $.ajax({
                    type: 'GET',
                    url: '../api/workflow/step/' + stepID + '/dependencies',
                    success: function(res) {
                        var control_removeStep =
                            '<img style="cursor: pointer" src="../dynicons/?img=dialog-error.svg&w=16" tabindex=0 onkeydown="onKeyPressClick(event)" onclick="removeStep(' +
                            stepID + ')" alt="Remove" />';
                        let output = '<h2>stepID: #' + stepID + ' ' + control_removeStep +
                            '</h2><br />Step: <b>' + steps[stepID].stepTitle +
                            '</b> <img style="cursor: pointer" src="../dynicons/?img=accessories-text-editor.svg&w=16" tabindex=0 onkeydown="onKeyPressClick(event)" onclick="editStep(' +
                            stepID + ')" alt="Edit Step" /><br />';

                        output += '<br /><br /><div>Requirements:<ul>';
                        var tDeps = {};
                        for (let i in res) {
                            control_editDependency =
                                '<img style="cursor: pointer" src="../dynicons/?img=accessories-text-editor.svg&w=16" tabindex=0 onkeydown="onKeyPressClick(event)" onclick="editRequirement(' +
                                res[i].dependencyID + ')" alt="Edit Requirement" />';
                            control_unlinkDependency =
                                '<img style="cursor: pointer" src="../dynicons/?img=dialog-error.svg&w=16" tabindex=0 onkeydown="onKeyPressClick(event)" onclick="unlinkDependency(' +
                                stepID + ', ' + res[i].dependencyID + ')" alt="Remove" />';
                            if (res[i].dependencyID == 1) { // special case for service chief and quadrad
                                output += '<li><b style="color: green">' + res[i].description + '</b> ' +
                                    control_editDependency + ' ' + control_unlinkDependency + ' (depID: ' +
                                    res[i].dependencyID + ')</li>';
                            } else if (res[i].dependencyID ==
                                8) { // special case for service chief and quadrad
                                output += '<li><b style="color: green">' + res[i].description + '</b> ' +
                                    control_editDependency + ' ' + control_unlinkDependency + ' (depID: ' +
                                    res[i].dependencyID + ')</li>';
                            } else if (res[i].dependencyID == -
                                1
                            ) { // dependencyID -1 : special case for person designated by the requestor
                                var indicatorWarning = '';
                                if (res[i].indicatorID_for_assigned_empUID == null || res[i]
                                    .indicatorID_for_assigned_empUID == 0) {
                                    indicatorWarning =
                                        '<li><span style="color: red; font-weight: bold">A data field (indicatorID) must be set.</span></li>';
                                }
                                output += '<li><b style="color: green">' + res[i].description + '</b> ' +
                                    control_unlinkDependency + ' (depID: ' + res[i].dependencyID + ')<ul>' +
                                    indicatorWarning + '<li>indicatorID: ' + res[i]
                                    .indicatorID_for_assigned_empUID +
                                    '<br /><div class="buttonNorm" tabindex=0 onkeydown="onKeyPressClick(event)" onclick="setDynamicApprover(' + res[i]
                                    .stepID + ')">Set Data Field</div></li></ul></li>';
                            } else if (res[i].dependencyID == -2) { // dependencyID -2 : requestor followup
                                output += '<li><b style="color: green">' + res[i].description + '</b> ' +
                                    control_unlinkDependency + ' (depID: ' + res[i].dependencyID + ')</li>';
                            } else if (res[i].dependencyID == -
                                3) { // dependencyID -3 : special case for group designated by the requestor
                                var indicatorWarning = '';
                                if (res[i].indicatorID_for_assigned_groupID == null || res[i]
                                    .indicatorID_for_assigned_groupID == 0) {
                                    indicatorWarning =
                                        '<li><span style="color: red; font-weight: bold">A data field (indicatorID) must be set.</span></li>';
                                }
                                output += '<li><b style="color: green">' + res[i].description + '</b> ' +
                                    control_unlinkDependency + ' (depID: ' + res[i].dependencyID + ')<ul>' +
                                    indicatorWarning + '<li>indicatorID: ' + res[i]
                                    .indicatorID_for_assigned_groupID +
                                    '<br /><div class="buttonNorm" tabindex=0 onkeydown="onKeyPressClick(event)" onclick="setDynamicGroupApprover(' + res[
                                        i].stepID + ')">Set Data Field</div></li></ul></li>';
                            } else {
                                if (tDeps[res[i].dependencyID] == undefined) { //
                                    tDeps[res[i].dependencyID] = 1;
                                    output += '<li style="padding-bottom: 8px"><b title="depID: ' + res[i]
                                        .dependencyID + '" tabindex=0 onkeydown="onKeyPressClick(event)" onclick="dependencyGrantAccess(' + res[i]
                                        .dependencyID + ')">' + res[i].description + '</b> ' +
                                        control_editDependency + ' ' + control_unlinkDependency +
                                        '<ul id="step_' + stepID + '_dep' + res[i].dependencyID +
                                        '"><li style="padding-top: 8px"><span tabindex=0 onkeydown="onKeyPressClick(event)" class="buttonNorm" onclick="dependencyGrantAccess(' +
                                        res[i].dependencyID + ')"><img src="../dynicons/?img=list-add.svg&w=16" alt="Add" /> Add Group</span></li>\
                                </ul></li>';
                                }
                            }
                        }
                        if (res.length == 0) {
                            output +=
                                '<li><span style="color: red; font-weight: bold">A requirement must be added.</span></li>';
                        }
                        output += '</ul><div>';

                        // TODO: This will eventually be moved to some sort of Workflow extension plugin
                        output += '<fieldset><legend>Options</legend><ul>';
                        output += '<li>Form Field: <select id="workflowIndicator_' + stepID +
                            '" style="width: 240px"><option value="">None</option></select></li>';
                        output += '</ul></fieldset>';

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
                            '<hr /><div style="padding: 4px; display:flex;"><span tabindex=0 class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="linkDependencyDialog(' + stepID +
                            ')">Add Requirement</span>';
                        output +=
                            '<span tabindex=0 class="buttonNorm" style="margin-left: auto;" onkeydown="onKeyPressClick(event)" onclick="addEmailReminderDialog(' +
                            stepID + ')">Email Reminder</span></div>';

                        $('#stepInfo_' + stepID).html(output);

                        // setup UI for form fields in the workflow area
                        buildWorkflowIndicatorDropdown(stepID, steps);

                        // TODO: clean everything here up
                        var counter = 0;
                        for (let i in res) {
                            group = '';
                            if (res[i].groupID != null) {
                                $('#step_' + stepID + '_dep' + res[i].dependencyID).prepend(
                                    '<li><span style="white-space: nowrap"><b title="groupID: ' + res[i]
                                    .groupID + '">' + res[i].name +
                                    '</b> <img tabindex=0 onkeydown="onKeyPressClick(event)" style="cursor: pointer" src="../dynicons/?img=dialog-error.svg&w=16" onclick="dependencyRevokeAccess(' +
                                    res[i].dependencyID + ', ' + res[i].groupID +
                                    ')" alt="Remove" /></span></li>');
                                counter++;
                            }
                            if (counter == 0 &&
                                res[i] != undefined) {
                                $('#step_' + stepID + '_dep' + res[i].dependencyID).prepend(
                                    '<li><span style="color: red; font-weight: bold">A group must be added.</span></li>'
                                );
                            }
                        }
                    },
                    error: (err) => console.log(err),
                    cache: false
                });
                break;
        }

        position = $('#step_' + stepID).offset();
        width = $('#step_' + stepID).width();

        $('#stepInfo_' + stepID).css({
            left: position.left + width + 'px',
            top: position.top + 'px'
        });
        $('#stepInfo_' + stepID).show('slide', null, 200);
    }

    var endPoints = [];

    function drawRoutes(workflowID) {
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
                                        id: 'stepLabel_' + res[i].stepID + '_0_' + res[i]
                                            .actionType,
                                        cssClass: "workflowAction",
                                        label: res[i].actionText,
                                        location: loc,
                                        parameters: {'stepID': res[i].stepID,
                                        'nextStepID': 0,
                                        'action': res[i].actionType,
                                        'required': res[i].displayConditional
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
                                        cssClass: "workflowAction",
                                        label: res[i].actionText,
                                        location: loc,
                                        parameters: {'stepID': res[i].stepID,
                                        'nextStepID': res[i].nextStepID,
                                        'action': res[i].actionType,
                                        'required': res[i].displayConditional
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
                                    cssClass: "workflowAction",
                                    label: 'Submit',
                                    location: loc,
                                    parameters: {'stepID': -1,
                                    'nextStepID': workflows[workflowID].initialStepID,
                                    'action': 'submit',
                                    'required': '{"required":"false"}'
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
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    var currentWorkflow = 0;

    function loadWorkflow(workflowID) {
        if ($('#subordinate_site_warning').length) {
            $('#btn_createStep').css('display', 'none');
            $('#btn_deleteWorkflow').css('display', 'none');
            $('#btn_newWorkflow').css('display', 'none');
            $('#btn_listActionType').css('display', 'none');
            $('#btn_listEvents').css('display', 'none');
            $('#btn_viewHistory').css('display', 'none');
            $('#btn_renameWorkflow').css('display', 'none');
            $('#btn_duplicateWorkflow').css('display', 'none');
        } else {
            $('#btn_createStep').css('display', 'block');
            $('#btn_deleteWorkflow').css('display', 'block');
            $('#btn_listActionType').css('display', 'block');
            $('#btn_listEvents').css('display', 'block');
            $('#btn_viewHistory').css('display', 'block');
            $('#btn_renameWorkflow').css('display', 'block');
            $('#btn_duplicateWorkflow').css('display', 'block');
        }

        currentWorkflow = workflowID;
        jsPlumb.reset();
        endPoints = [];
        steps = {};
        jsPlumb.setSuspendDrawing(true);

        $('#workflows').val(workflowID);
        $('#workflows').trigger('chosen:updated');

        $('#workflow').html('');
        $('#workflow').append(
            '<div tabindex="0" class="workflowStep" id="step_-1" tabindex="0">Requestor</div><div class="workflowStepInfo" id="stepInfo_-1"></div>'
        );
        $('#step_-1').css({
            'left': 180 + 40 + 'px',
            'top': 80 + 40 + 'px',
            'background-color': '#e0e0e0'
        });
        $('#workflow').append(
            '<div tabindex="0" class="workflowStep" id="step_0" tabindex="0">End</div><div class="workflowStepInfo" id="stepInfo_0"></div>'
        );
        $('#step_0').css({
            'left': 180 + 40 + 'px',
            'top': 80 + 40 + 'px',
            'background-color': '#ff8181'
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
                            emailNotificationIcon = `<img src="../dynicons/?img=appointment.svg&w=18" style="margin-bottom: -3px;" alt="Email reminders will be sent after ${dayCount} ${dayText} of inactivity" />`
                        }
                    }

                    $('#workflow').append('<div tabindex="0" class="workflowStep" id="step_' + res[i]
                        .stepID + '">' + res[i].stepTitle + ' ' + emailNotificationIcon +
                        '</div><div class="workflowStepInfo" id="stepInfo_' + res[i].stepID + '"></div>'
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

                    // attach click event
                    $('#step_' + res[i].stepID).on('click keydown', null, res[i].stepID, function(e) {
                        if (e.type === 'keydown' && e.which === 13 || e.type === 'click') {
                            showStepInfo(e.data);
                        }
                    });

                    if (maxY < posY) {
                        maxY = posY;
                    }
                }
                // draw the last step
                $('#step_0').css({
                    'left': 180 + 400 + 'px',
                    'top': 160 + maxY + 'px',
                    'background-color': '#ff8181'
                });
                // attach click events for first and last step
                $('#step_-1').on('click', null, -1, function(e) {
                    showStepInfo(e.data);
                });
                $('#step_0').on('click', null, 0, function(e) {
                    showStepInfo(e.data);
                });

                $('#workflow').css('height', 300 + maxY + 'px');
                drawRoutes(workflowID);
            },
            error: (err) => console.log(err),
            cache: false
        });
    }

    function loadWorkflowList(workflowID) {
        $.ajax({
            async: false,
            type: 'GET',
            url: '../api/workflow',
            success: function(res) {
                let output = '<select tabindex=0 id="workflows" style="width: 100%">';
                var count = 0;
                var firstWorkflowID = 0;
                let firstWorkflowDescription = '';
                for (let i in res) {
                    if (count == 0) {
                        firstWorkflowDescription = res[i].description;
                        firstWorkflowID = res[i].workflowID;
                    }
                    workflows[res[i].workflowID] = res[i];
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
                $('#workflows').chosen({disable_search_threshold: 5, allow_single_deselect: true, width: '100%'});
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
        if ($('#subordinate_site_warning').length) {
            alert('To make changes, please contact the administrator for the Nationally Standardized Primary site.');
        } else {
            $('.workflowStepInfo').css('display', 'none');
            dialog.setContent(
                '<input type="text" id="workflow_rename" name="workflow_rename" value="' + workflowDescription +
                '" tabindex="0">' +
                '</input>');
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
                            loadWorkflowList(res);
                            workflowDescription = $('#workflow_rename').val();
                            dialog.hide();
                        }
                    },
                    error: (err) => console.log(err),
                });
            });
            dialog.show();
        }
    }

    /**
     * The script to duplicate the currently selected workflow
     *
     * Created at: 7/26/2023, 1:08:10 PM (America/New_York)
     */
    function duplicateWorkflow() {
        if ($('#subordinate_site_warning').length) {
            alert('To make changes, please contact the administrator for the Nationally Standardized Primary site.');
        } else {
            $('.workflowStepInfo').css('display', 'none');

            dialog.setTitle('Duplicate current workflow');
            dialog.setContent('<br /><label for="description">New Workflow Title:</label> <input type="text" id="description"/><br /><br />The following will NOT be copied over:<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;Data fields that show up next to the workflow action buttons');
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
                loadWorkflowList(workflowID);
            });
            dialog.show();
        }
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
                data: {dependencyID: dependencyID,
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
                callback(res)
            },
            error: (err) => console.log(err),
        });
    }

    /**
     * @param int stepID
     * @param string action
     * @param int workflowID
     * @param string event
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

    /*
        START: EMAIL REMINDER BLOCK
    */
    function setEmailReminderHTML(workflowID, stepID, actionType) {
        Promise.all([getEmailTemplates(), getDateIndicators(), getSavedEmailReminderData(workflowID, stepID,
                actionType)])
            .then(function(data) {
                var emailTemplates = data[0];
                var dateIndicators = data[1];
                var formFields = data[2];

                var indicatorList = '';
                for (let i in dateIndicators) {
                    indicatorList += '<option value="' + dateIndicators[i].indicatorID + '">' + dateIndicators[i]
                        .categoryName + ': ' + dateIndicators[i].name + ' (id: ' + dateIndicators[i].indicatorID +
                        ')</option>';
                }
                var emailTemplateList = '';
                for (let i in emailTemplates) {
                    emailTemplate = emailTemplates[i].fileName;
                    emailTemplateList += '<option value="' + emailTemplate + '">' + emailTemplate + '</option>';
                }

                eventDataHTML = '<div id="emailReminder">';
                eventDataHTML += '<h2>Email Reminder Details</h2>';

                eventDataHTML += '<div class="eventDataInput">';
                eventDataHTML += '<label for="frequency">Frequency of Reminders (in Business Days)</label>';
                eventDataHTML += '<input type="number" id="frequency" name="frequency" min="0">';
                eventDataHTML += '</div>';

                eventDataHTML += '<div class="eventDataInput">';
                eventDataHTML += '<label for="startDateIndicatorID">Reminder Start Date</label>';
                eventDataHTML += '<select id="startDateIndicatorID" name="startDateIndicatorID">';
                eventDataHTML += indicatorList;
                eventDataHTML += '</select>';
                eventDataHTML += '</div>';

                eventDataHTML += '<div class="eventDataInput">';
                eventDataHTML += '<label for="emailTemplate">Email Template</label>';
                eventDataHTML += '<select id="emailTemplate" name="emailTemplate">';
                eventDataHTML += emailTemplateList;
                eventDataHTML += '</select>';
                eventDataHTML += '</div>';

                eventDataHTML += '<div class="eventDataInput">';
                eventDataHTML += '<label for="emailGroupSelector">Recipient Group</label>';
                eventDataHTML += '<div id="emailGroupSelector"></div>';
                eventDataHTML += '<input id="recipientGroupID" name="recipientGroupID" style="display: none;">';
                eventDataHTML += '</div>';

                eventDataHTML += '</div>'; //emailReminder div
                $('#eventData').html(eventDataHTML);

                $.each(formFields, function(key, value) {
                    $('#emailReminder #' + key).val(value);
                });

                $('#emailTemplate').chosen({disable_search_threshold: 5});
                $('#startDateIndicatorID').chosen({disable_search_threshold: 5});

                var grpSel = new groupSelector('emailGroupSelector');
                grpSel.basePath = '<!--{$orgchartPath}-->/';
                grpSel.apiPath = '<!--{$orgchartPath}-->/api/?a=';
                grpSel.tag = '<!--{$orgchartImportTags[0]}-->';
                grpSel.setSelectHandler(function() {
                    $('#recipientGroupID').val(grpSel.selection);
                });
                grpSel.setResultHandler(function() {
                    $('#recipientGroupID').val(grpSel.selection);
                });
                grpSel.initialize();
                if ($('#recipientGroupID').val() != '') {
                    grpSel.forceSearch('group#' + $('#recipientGroupID').val());
                }

                dialog.setValidator('frequency', function() {
                    return $('#emailReminder #frequency').val() != '';
                });
                dialog.setValidatorError('frequency', function() {
                    alert('Frequency is required.');
                });

                dialog.setValidator('frequency_pos', function() {
                    return $('#emailReminder #frequency').val() > 0;
                });
                dialog.setValidatorError('frequency_pos', function() {
                    alert('Frequency must be greater than zero.');
                });

                dialog.setValidator('startDateIndicatorID', function() {
                    return $('#emailReminder #startDateIndicatorID').val() != '';
                });
                dialog.setValidatorError('startDateIndicatorID', function() {
                    alert('Please select a start date indicator.');
                });

                dialog.setValidator('emailTemplate', function() {
                    return $('#emailReminder #emailTemplate').val() != '';
                });
                dialog.setValidatorError('emailTemplate', function() {
                    alert('Please select an email template.');
                });

                dialog.setValidator('recipientGroupID', function() {
                    return $('#emailReminder #recipientGroupID').val() != '';
                });
                dialog.setValidatorError('recipientGroupID', function() {
                    alert('Please select a group.');
                });
            });
    }

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

    function getEmailTemplates() {
        return new Promise(function(resolve, reject) {
            $.ajax({
                url: '../api/emailTemplates/',
                type: 'GET',
                success: function(res) {
                    resolve(res);
                },
                error: function() {
                    reject();
                },
                cache: false
            });
        });
    }

    function getDateIndicators() {
        return new Promise(function(resolve, reject) {
            $.ajax({
                url: '../api/form/indicator/list',
                type: 'GET',
                success: function(res) {
                    var data = []
                    for (let i in res) {
                        if (res[i]['format'] == 'date') {
                            data.push(res[i]);
                        }
                    }
                    resolve(data);
                },
                error: function() {
                    reject();
                },
                cache: false
            });
        });
    }

    function getSavedEmailReminderData(workflowID, stepID, actionType) {
        return new Promise(function(resolve, reject) {
            $.ajax({
                url: '../api/workflow/' + workflowID + '/step/' + stepID + '/_' + actionType +
                    '/events/emailReminder?CSRFToken=' + CSRFToken,
                type: 'GET',
                success: function(res) {
                    resolve(res[0]);
                },
                error: function() {
                    reject();
                },
                cache: false
            });
        });
    }
    /*
        END: EMAIL REMINDER BLOCK
    */
    var dialog, dialog_confirm, dialog_simple;
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
    $(document).mouseup(function(e) {
        let container = $(".workflowStepInfo");
        if (!container.is(e.target) && container.has(e.target).length === 0) {
            container.hide();
        }
        container.on('keydown', function(e) {
            if (e.keyCode === 27) {
                container.hide();
            }
        });
    });

    $(function() {
        dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save',
            'button_cancelchange');
        dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator',
            'confirm_button_save', 'confirm_button_cancelchange');
        dialog_simple = new dialogController('simplexhrDialog', 'simplexhr', 'simpleloadIndicator',
            'simplebutton_save', 'simplebutton_cancelchange');
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

                    $('#btn_createStep').css('display', 'none');
                    $('#btn_deleteWorkflow').css('display', 'none');
                    $('#btn_newWorkflow').css('display', 'none');
                    $('#btn_listActionType').css('display', 'none');
                    $('#btn_listEvents').css('display', 'none');
                    $('#btn_viewHistory').css('display', 'none');
                    $('#btn_renameWorkflow').css('display', 'none');
                    $('#btn_duplicateWorkflow').css('display', 'none');
                }
            },
            error: err => console.log(err),
            cache: false
        })
    });
</script>