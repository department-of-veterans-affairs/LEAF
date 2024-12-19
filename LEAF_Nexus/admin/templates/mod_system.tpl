<div style="width: 90%; margin: auto">
    <div class="item" style="border: 2px solid black; float: left; margin: 4px; background-color: white; padding: 16px">
        <div class="item">
            <label for="heading">Site Heading:&nbsp;</label>
            <input id="heading" type="text" style="width: 300px" title="" value="<!--{$heading}-->" />
        </div>

        <div class="item">
            <label for="subHeading">Site Sub-heading:&nbsp;</label>
            <input id="subHeading" type="text" style="width: 300px" title="" value="<!--{$subheading}-->" />
        </div>

        <div class="item">
            <label for="primaryAdmin">Primary Admin:</label>
            <div id="primaryAdmin"></div>
        </div>

        <div class="item">
            <label for="leadershipName">Leadership Nomenclature:&nbsp;</label>
            <select id="leadershipName" style="width: 300px" title="">
                <option value="quadrad" <!--{if $serviceParent == 'quadrad'}-->selected<!--{/if}--> >Quadrad</option>
                <option value="pentad" <!--{if $serviceParent == 'pentad'}-->selected<!--{/if}--> >Pentad</option>
                <option value="ELT" <!--{if $serviceParent == 'ELT'}-->selected<!--{/if}--> >ELT</option>
                <option value="VISN" <!--{if $serviceParent == 'VISN'}-->selected<!--{/if}--> >VISN</option>
            </select>
        </div>

        <div class="item">
            <label for="timeZone">Time Zone:&nbsp;</label>
            <select id="timeZone">
                <!--{foreach from=$timeZones item=tz}-->
                <option
                        value="<!--{$tz}-->"

                <!--{if $tz eq $timeZone}-->
                selected
                <!--{/if}-->
                >
                <!--{$tz}-->
                </option>
                <!--{/foreach}-->
            </select>
        </div>

        <button class="buttonNorm" onclick="saveSettings();">Save</button>
    </div>
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
    var CSRFToken = '<!--{$CSRFToken}-->';

    function saveSettings()
    {
        $.when(
            $.ajax({
                type: 'POST',
                url: '../api/system/settings/heading',
                data: {heading: $('#heading').val(),
                CSRFToken: CSRFToken},
                fail: function(err) {
                    console.log(err);
                }
            }),
            $.ajax({
                type: 'POST',
                url: '../api/system/settings/subHeading',
                data: {subHeading: $('#subHeading').val(),
                CSRFToken: CSRFToken},
                fail: function(err) {
                    console.log(err);
                }
            }),
            $.ajax({
                type: 'POST',
                url: '../api/system/settings/timeZone',
                data: {timeZone: $('#timeZone').val(),
                CSRFToken: '<!--{$CSRFToken}-->'},
                fail: function(err) {
                    console.log(err);
                }
            }),
            $.ajax({
                type: 'POST',
                url: '../api/tag/_service/parent',
                data: {parentTag: $('#leadershipName').val(),
                CSRFToken: CSRFToken},
                fail: function(err) {
                    console.log(err);
                }
            })
        ).then(function() {
            if (primarySet.length === 0) {
                $.ajax({
                    type: 'POST',
                    url: '../api/system/setPrimaryadmin',
                    data: {userID: $('#primaryAdmin').val(),
                    CSRFToken: CSRFToken},
                    success: function(res) {
                        if(res['success'] !== true) {
                            alert('Primary Admin must be a System Administrator');
                        } else {
                            location.reload();
                            alert('Settings Saved.');
                        }
                    },
                    fail: function(err) {
                        console.log(err);
                        location.reload();
                        alert('An error has occurred, please try again.');
                    }
                })
            } else {
                location.reload();
                alert('Settings Saved.');
            }
        });
    }

    // convert to title case
    function toTitleCase(str) {
        return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
    }

    var dialog, dialog_confirm;
    var empSel;
    let primarySet = false;
    $(function() {
        dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
        dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

        $.ajax({
            type: 'GET',
            async: false,
            url: '../api/system/primaryadmin',
            success: function(res) {
                $('.employeeSelectorInput').val('userName:'+res['userName']);
                primarySet = res;
            },
            fail: function(err) {
                console.log(err);
            }
        })

        if (primarySet.length === 0) {
            empSel = new employeeSelector('primaryAdmin');
            empSel.apiPath = '../api/?a=';
            empSel.rootPath = '../';
            empSel.initialize();
            empSel.enableNoLimit();

            empSel.setSelectHandler(function () {
                $('#primaryAdmin').val(empSel.selectionData[empSel.selection].userName);
                $('.employeeSelectorInput').val('userName:' + empSel.selectionData[empSel.selection].userName);
            });
        } else {
            let firstName = toTitleCase(primarySet['firstName']);
            let lastName = toTitleCase(primarySet['lastName']);
            let userName = primarySet['userName'].toUpperCase();
            let adminContent = `<span style="white-space: pre;"> ${firstName} ${lastName} (${userName}) <a tabindex="0" title="Remove Primary Admin from ${firstName} ${lastName}" aria-label="Unset ${firstName} ${lastName}" href="#" class="text-secondary-darker leaf-font0-8rem" id="unsetPrimaryAdmin">UNSET</a></span>`;
            $('#primaryAdmin').html(adminContent);
            $('#unsetPrimaryAdmin').on('click', function() {
                $.ajax({
                    type: 'DELETE',
                    url: '../api/system/unsetPrimaryadmin?' +
                        $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
                    success: function() {
                        location.reload();
                    },
                    fail: function(err) {
                        console.log(err);
                    }
                })
            });
        }
    });
</script>
