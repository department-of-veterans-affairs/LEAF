    <a href="../" class="buttonNorm"><img src="{$lib_path}dynicons/?img=go-home.svg&amp;w=16" alt="Main Page" title="Main Page" />Main Page</a>
    <div id="headerMenuHelp_container" style="display: inline-block">
        <a id="button_showHelp" tabindex="0" class="buttonNorm" alt="Help Popup"
            title="Help" aria-haspopup="true" aria-expanded="false"
            role="button"><img style="vertical-align: sub;" src="{$lib_path}dynicons/?img=help-browser.svg&amp;w=16">&nbsp;Help</a>
        <div id="headerMenu_help" tabindex="0">
            For Help contact your primary admin:
            <div id="help-primary-admin" style="font-weight:bold;">
            <script type="text/javascript">
                $.ajax({
                    type: 'GET',
                    url: "../api/system/primaryadmin",
                    success: function(res) {
                        let emailString = res['email'] != '' ? " - " + res['email'] : '';
                        if(res["firstName"] !== undefined)
                        {
                            $('#help-primary-admin').html(res['firstName'] + " " + res['lastName'] + emailString);
                        }
                        else if(res["userName"] !== undefined)
                        {
                            $('#help-primary-admin').html(res['userName']);
                        }
                        else
                        {
                            $('#help-primary-admin').html('Primary Admin has not been set.');
                        }
                    },
                    fail: function(err) {
                        console.log(err);
                    }
                });
            </script>
            </div>
        </div>
    </div>
{if isset($isAdmin)}
    <a href="./" class="buttonNorm"><img src="{$lib_path}dynicons/?img=applications-system.svg&amp;w=16" alt="Admin Panel" title="Admin Panel" />OC Admin Panel</a>
{/if}
<br />
<noscript class="alert"><span>Javascript must be enabled for this version of software to work!</span></noscript>