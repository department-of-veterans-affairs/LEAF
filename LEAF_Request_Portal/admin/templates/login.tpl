{if $name == ''}
    <form name="login" method="post" action="?a=login">
        <span class="alert">STATUS: {$status}</span>
        <input name="login" type="submit" title="Click to login" value="Login" class="submit" />
    </form>
{else}
    <ul class="leaf-user-menu" aria-haspopup="true">
        <li>Welcome, <span class="leaf-bold">{$name}</span><a href="../?a=logout">SIGN OUT</a></li>
    </ul>
{/if}

<script>
    menu508($('#button_showLinks'), $('#headerMenu_links'), $('#headerMenu_links').find('a'));
    menu508($('#button_showHelp'), $('#headerMenu_help'), $('#headerMenu_help'));

    function menu508(menuButton, subMenu, subMenuButton)
    {
        $(menuButton).keypress(function(e) {
            if (e.keyCode === 13) {
                $(subMenu).css("display", "block");
                $(menuButton).attr('aria-expanded', 'true');
                subMenuButton.focus();
            }
        });

        $(subMenuButton).focusout(function() {
                $(subMenu).css("display", "none");
                $(menuButton).attr('aria-expanded', 'false');
                $(menuButton).focus();
        });
    }
</script>

