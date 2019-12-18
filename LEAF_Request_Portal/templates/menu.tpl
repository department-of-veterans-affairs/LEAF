<!--{if $action != ''}-->
    <a href="./" class="buttonNorm"><img src="../libs/dynicons/?img=go-home.svg&amp;w=16" role="button" />Main Page</a>
<!--{/if}-->
<div id="headerMenu_container" style="display: inline-block">
    <a id="button_showLinks" tabindex="0" class="buttonNorm" alt="Links Dropdown" title="Links" aria-haspopup="true" aria-expanded="false" role="button">Links</a>
    <div id="headerMenu_links">
    {include file="menu_links.tpl"}
    </div>
</div>
<!--{if $is_admin == true}-->
     <a href="./admin/" class="buttonNorm" role="button"><img src="../libs/dynicons/?img=applications-system.svg&amp;w=16"/>Admin Panel</a>
{/if}
    <a class="buttonNorm" role="button" id="helpButton"><img src="../libs/dynicons/?img=help-browser.svg&amp;w=16">Help</a>
{if $hide_main_control == 1}
{/if}

<script>
    $(document).ready(function(){
                var menuButton = $('#button_showLinks');
        var subMenu = $('#headerMenu_links');
        var subMenuButton = $('#headerMenu_links').find('a');

        $(menuButton).keypress(function(e) {
            if (e.keyCode === 13) {
                $(subMenu).css("display", "block");
                $(menuButton).attr('aria-expanded', 'true');
                subMenuButton.focus();
            }
        });

        $("#helpButton").click(function(){
            dialog_message.setTitle('LEAF Knowledge Base');

            $.ajax({
                type: 'GET',
                url: 'ajaxIndex.php?a=faqcategories',
                dataType: 'text',
                success: function(res) {
                    dialog_message.setContent(res);
                    dialog_message.show();
                },
                cache: false
            });
        });

        $(subMenuButton).focusout(function() {
                $(subMenu).css("display", "none");
                $(menuButton).attr('aria-expanded', 'false');
                $(menuButton).focus();
        });

        dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');



    });


</script>
{include file="site_elements/generic_dialog.tpl"}

<br />
<noscript><div class="alert"><span>Javascript must be enabled for this version of software to work!</span></div></noscript>
