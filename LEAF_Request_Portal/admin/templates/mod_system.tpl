<div class="leaf-center-content">

    <!-- LEFT SIDE NAV -->
    <!--{assign var=left_nav_content value="
        <aside class='sidenav'></aside>
    "}-->
    <!--{include file="partial_layouts/left_side_nav.tpl" contentLeft="$left_nav_content"}-->

    <main class="main-content">

        <h2>Site Settings</h2>

        <form class="usa-form">
        
            <label for="heading" class="usa-label">Title of LEAF site</label>
            <input id="heading" class="usa-input" type="text" title="" size="48" />

            <label for="subHeading" class="usa-label">Facility Name</label>
            <input id="subHeading" class="usa-input" type="text" title="" size="48" />

            <label for="timeZone" class="usa-label">Time Zone</label>
            <select id="timeZone" class="usa-select">
                <!--{foreach from=$timeZones item=tz}-->
                    <option value="<!--{$tz}-->"><!--{$tz}--></option>
                <!--{/foreach}-->
            </select>

            <label for="requestLabel" class="usa-label">Label for Request</label>
            <input id="requestLabel" class="usa-input" type="text" title="" size="48" />

            <div class="leaf-row-space"></div>

            <div class="usa-label"><b>LEAF Secure Status</b></div>
            <div class="leaf-marginTop-halfRem"><span id="leafSecureStatus">Loading...</span></div>

            <div>
                <div class="usa-label">Import Tags [<a href="#" title="Groups in the Org. Chart with any one of these tags will be imported for use">?</a>]:&nbsp;</div>
                <div class="leaf-marginTop-1rem">
                    <!--{foreach from=$importTags item=importTag}-->
                        <!--{$importTag}--><br />
                    <!--{/foreach}-->
                </div>
            </div>

            <h3 class="leaf-marginTop-1rem">Advanced Settings</h3>

            <div class="item">
                <label for="siteType" class="usa-label">Type of Site</label>
                <select id="siteType" class="usa-select">
                    <option value="standard">Standard</option>
                    <option value="national_primary">Nationally Standardized Primary</option>
                    <option value="national_subordinate">Nationally Standardized Subordinate</option>
                </select>
            </div>

            <div class="item siteType national_primary" style="display: none">
                <label for="national_linkedSubordinateList" class="usa-label">Nationally Standardized Subordinate Sites</label>
                <div>The first site in the list should be a TEST site.<br />URLs must end with a trailing slash.</div>
                <textarea id="national_linkedSubordinateList" cols="50" rows="5" class="usa-textarea"></textarea>
            </div>

            <div class="item siteType national_subordinate" style="display: none">
                <label for="national_linkedPrimary" class="usa-label">Nationally Standardized Primary Site URLs must end with a trailing slash.</label>
                <input id="national_linkedPrimary" type="text" class="usa-input" size="48" />
                <span id="primary_changed_warning_status" role="status" aria-live="polite" aria-label=""></span>
                <div id="primary_changed_warning" style="display: none; margin-top:0.25rem;">
                    <div style="padding:3px 4px;background-color:#ffffc0;color:#c00;">WARNING</div>
                    <div style="padding:3px 4px;background-color:#fff;border-top:1px solid #000">
                        This will cause data alignment problems.&nbsp; Please contact your business process owner to coordinate changes.
                    </div>
                </div>
            </div>

            <div style="display:flex; flex-wrap: wrap; gap: 0.5em; align-items: center; margin-top:0.75rem;">
                <button class="usa-button" id="btn_save" type="button">Save</button>
                <h3 id="progress" style="color: #c00; margin:0;"></h3>
            </div>
        </form>

    </main>

    <!-- RIGHT SIDE NAV -->
    <!--{assign var=right_nav_content value="
        <aside class='sidenav-right'></aside>
    "}-->
    <!--{include file="partial_layouts/right_side_nav.tpl" contentRight="$right_nav_content"}-->

<!-- end main content -->
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
const CSRFToken = '<!--{$CSRFToken}-->';
let siteSettings = {};

function saveSettings() {
    const heading = $('#heading').val();
    const subHeading = $('#subHeading').val();
    const requestLabel = $('#requestLabel').val();
    const timeZone = $('#timeZone').val();
    const siteType = $('#siteType').val();
    const national_linkedSubordinateList = $('#national_linkedSubordinateList').val();
    const national_linkedPrimary = $('#national_linkedPrimary').val();

    let calls = [];
    let errors = [];
    if (siteSettings.heading !== heading) {
        calls.push(
            $.ajax({
                type: 'POST',
                url: '../api/system/settings/heading',
                data: {
                    heading: heading,
                    CSRFToken: '<!--{$CSRFToken}-->'
                },
                success: function(res) {
                    siteSettings.heading = heading;
                    $('#headerDescription').html(heading);
                },
                error: function(err) {
                    console.log(err);
                    errors.push('Error saving site Title');
                }
            })
        );
    }
    if (siteSettings.subHeading !== subHeading) {
        calls.push(
            $.ajax({
                type: 'POST',
                url: '../api/system/settings/subHeading',
                data: {
                    subHeading: subHeading,
                    CSRFToken: '<!--{$CSRFToken}-->'
                },
                success: function(res) {
                    siteSettings.subHeading = subHeading;
                    $('#logo .leaf-site-title').html(subHeading);
                },
                error: function(err) {
                    console.log(err);
                    errors.push('Error saving site Facility Name');
                }
            })
        );
    }
    if (siteSettings.requestLabel !== requestLabel) {
        calls.push(
            $.ajax({
                type: 'POST',
                url: '../api/system/settings/requestLabel',
                data: {
                    requestLabel: requestLabel,
                    CSRFToken: '<!--{$CSRFToken}-->'
                },
                success: function(res) {
                    siteSettings.requestLabel = requestLabel;
                },
                error: function(err) {
                    console.log(err);
                    errors.push("Error saving Label for Request");
                }
            })
        );
    }
    if (siteSettings.timeZone !== timeZone) {
        calls.push(
            $.ajax({
                type: 'POST',
                url: '../api/system/settings/timeZone',
                data: {
                    timeZone: timeZone,
                    CSRFToken: '<!--{$CSRFToken}-->'
                },
                success: function(res) {
                    siteSettings.timeZone = timeZone;
                },
                error: function(err) {
                    console.log(err);
                    errors.push("Error saving TimeZone");
                }
            })
        );
    }
    if (siteSettings.siteType !== siteType) {
        calls.push(
            $.ajax({
                type: 'POST',
                url: '../api/system/settings/siteType',
                data: {
                    siteType: siteType,
                    CSRFToken: '<!--{$CSRFToken}-->'
                },
                success: function(res) {
                    siteSettings.siteType = siteType;
                },
                error: function(err) {
                    console.log(err);
                    errors.push("Error saving siteType");
                }
            }),
        );
    }
    if (siteSettings.national_linkedSubordinateList !== national_linkedSubordinateList) {
        calls.push(
            $.ajax({
                type: 'POST',
                url: '../api/system/settings/national_linkedSubordinateList',
                data: {
                    national_linkedSubordinateList: national_linkedSubordinateList,
                    CSRFToken: '<!--{$CSRFToken}-->'
                },
                success: function(res) {
                    siteSettings.national_linkedSubordinateList = national_linkedSubordinateList;
                },
                error: function(err) {
                    console.log(err);
                    errors.push("Error saving Subordinate Site URLs");
                }
            })
        );
    }
    if (siteSettings.national_linkedPrimary !== national_linkedPrimary) {
        calls.push(
            $.ajax({
                type: 'POST',
                url: '../api/system/settings/national_linkedPrimary',
                data: {
                    national_linkedPrimary: national_linkedPrimary,
                    CSRFToken: '<!--{$CSRFToken}-->'
                },
                success: function(res) {
                    siteSettings.national_linkedPrimary = national_linkedPrimary;
                },
                error: function(err) {
                    console.log(err);
                    errors.push("Error saving Primary Site URL");
                }
            })
        );
    }
    if (calls.length === 0) {
        $('#progress').html('No changes to save.');
        $('#progress').fadeIn(10, function() {
            $('#progress').fadeOut(2000);
        });
    } else {
        $('#btn_save').prop('disabled', true);
        $('#btn_save').html('Saving...');
        $.when.apply(undefined, calls)
        .then(
            function() { //on success
                $('#btn_save').prop('disabled', false);
                $('#btn_save').html('Save');
                $('#progress').html('Settings saved.');
                setListeners();
                $('#national_linkedPrimary').trigger('change');
                $('#progress').fadeIn(10, function() {
                    $('#progress').fadeOut(2000);
                });
            },
            function() { //on error
                $('#btn_save').prop('disabled', false);
                $('#btn_save').html('Save');
                let errorText = errors.map(msg => msg + '<br>');
                $('#progress').html(errorText);
                $('#progress').fadeIn();
            }
        );
    }

}

function setListeners() {
    $('#national_linkedPrimary').off();
    $('#btn_save').off();
    if ((siteSettings.siteType || '').toLowerCase() === 'national_subordinate') {
        const currentPrimary = (siteSettings.national_linkedPrimary || '').trim();
        const primaryChangeWarning = (event) => {
            const inputValue = event?.currentTarget?.value;
            const showWarn = currentPrimary !== '' && inputValue !== currentPrimary;
            const ariaWarn = "WARNING: This will cause data alignment problems. Please contact your business process owner to coordinate changes";
            $('#primary_changed_warning').css('display', `${showWarn ? 'block' : 'none'}`);
            $('#primary_changed_warning_status').attr(
                'aria-label', `${showWarn ? ariaWarn : ''}`
            );
        }
        const checkPrimaryChanged = () => {
            const inputValue = $('#national_linkedPrimary').val();
            const showWarn = currentPrimary !== '' && inputValue !== currentPrimary;
            if (showWarn) {
                dialog_confirm.setTitle('WARNING');
                dialog_confirm.setContent(`<div style="padding:1em 0.5em; height:80px;line-height:1.8;">
                    <div>This will cause data alignment problems.</div>
                    <div>Please contact your business process owner to coordinate changes.</div>
                </div>`);
                dialog_confirm.setSaveHandler(() => {
                    saveSettings();
                    dialog_confirm.hide();
                });
                $('#confirm_saveBtnText').html('Make Change');
                $('#confirm_button_cancelchange').html('Cancel');
                dialog_confirm.show();
            } else {
                saveSettings();
            }
        }
        $('#national_linkedPrimary').on('change', primaryChangeWarning);
        $('#btn_save').on('click', checkPrimaryChanged);
    } else {
        $('#btn_save').on('click', saveSettings);
    }
}

function renderSiteType() {
    $('.siteType').css('display', 'none');
    switch($('#siteType').val()) {
        case 'national_primary':
            $('.national_primary').css('display', 'inline');
            break;
        case 'national_subordinate':
            $('.national_subordinate').css('display', 'inline');
            break;
        default:
            break;
    }
}

function renderSettings(res) {
    var query = new LeafFormQuery();
    query.setRootURL('../');
    query.addTerm('categoryID', '=', 'leaf_secure');

    for(var i in res) {
        $('#' + i).val(res[i]);
        if(i == 'leafSecure') {
            if(res[i] >= 1) { // Certified
                query.addTerm('stepID', '=', 'resolved');
                query.join('recordResolutionData');
                query.onSuccess(function(data) {
                    if(Object.keys(data).length == 0) {
                        $('#leafSecureStatus').html('<span style="font-size: 120%; padding: 4px; background-color: red; color: white; font-weight: bold">Not Certified</span> <a class="buttonNorm" href="../report.php?a=LEAF_start_leaf_secure_certification">Start Certification Process</a>');
                        $.ajax({
                            type: 'DELETE',
                            url: '../api/system/settings/leaf-secure',
                            data: {CSRFToken: CSRFToken}
                        });
                    }
                    else {
                        let mostRecentID = null;
                        let mostRecentDate = 0;
                        for(let i in data) {
                            if(data[i].recordResolutionData.lastStatus == 'Approved'
                                && data[i].recordResolutionData.fulfillmentTime > mostRecentDate) {
                                mostRecentDate = data[i].recordResolutionData.fulfillmentTime;
                                mostRecentID = i;
                            }
                        }
                        $('#leafSecureStatus').html('<span style="font-size: 120%; padding: 4px; background-color: green; color: white; font-weight: bold">Certified</span> <a class="buttonNorm" href="../index.php?a=printview&recordID='+ mostRecentID +'">View details</a>');
                    }
                });
                query.execute();
            }
            else { // Not certified
                query.addTerm('stepID', '!=', 'resolved');
                query.onSuccess(function(data) {
                    if(Object.keys(data).length == 0) {
                        $('#leafSecureStatus').html('<span style="font-size: 120%; padding: 4px; background-color: red; color: white; font-weight: bold">Not Certified</span> <a class="buttonNorm" href="../report.php?a=LEAF_start_leaf_secure_certification">Start Certification Process</a>');
                    }
                    else {
                        var recordID = data[Object.keys(data)[0]].recordID;
                        $('#leafSecureStatus').html(`<span style="font-size: 120%; padding: 4px; background-color: red; color: white; font-weight: bold">Not Certified</span> <a class="buttonNorm" href="../index.php?a=printview&recordID=${recordID}&masquerade=nonAdmin">Check Certification Progress</a>`);
                    }
                });
                query.execute();
            }
        }
    }
    renderSiteType();
}

var dialog, dialog_confirm;
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    $.ajax({
        type: 'GET',
        url: '../api/system/settings',
        cache: false
    })
    .then(function(res) {
        siteSettings = res;
        renderSettings(res)
        setListeners();
    });

    $('#siteType').on('change', function() {
        renderSiteType();
    });
});

</script>
