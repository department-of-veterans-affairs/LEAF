{if $action != ''}
    <a href="./" class="buttonNorm"><img src="dynicons/?img=go-home.svg&amp;w=16" alt="" title="Main Page" />Main Page</a>
{/if}
    <div id="headerMenuHelp_container" style="display: inline-block">
        <a id="button_showHelp" tabindex="0" class="buttonNorm" title="Help" aria-haspopup="true" aria-expanded="false" role="button"><img style="vertical-align: sub;" src="dynicons/?img=help-browser.svg&amp;w=16" alt=""/>&nbsp;Help</a>
        <div id="headerMenu_help" tabindex="0">
            For Help contact your primary admin:
            <div id="help-primary-admin" style="font-weight:bold;">
                <script type="text/javascript">
                    $.ajax({
                        type: 'GET',
                        url: "api/system/primaryadmin",
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
    <a href="./admin/" class="buttonNorm"><img src="dynicons/?img=applications-system.svg&amp;w=16" alt="" title="Admin Panel" />OC Admin Panel</a>
{/if}
<br />
<noscript class="alert"><span>Javascript must be enabled for this version of software to work!</span></noscript>
