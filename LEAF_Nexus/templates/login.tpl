{if $name == ''}
    <form name="login" method="post" action="?a=login">
    <font class="alert">STATUS: {$status}</font>
    <input name="login" type="submit" title="Click to login" value="Login" class="submit" />
    </form>
{else}
    Logged in as: <b>{$name}</b>
{/if}
