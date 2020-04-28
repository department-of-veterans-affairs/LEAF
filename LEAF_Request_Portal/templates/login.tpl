{if $name == ''}
    <form name="login" method="post" action="?a=login">
        <span class="alert">STATUS: {$status}</span>
        <input name="login" type="submit" title="Click to login" value="Login" class="submit" />
    </form>
{else}
    <span class="leaf-login-msg">Welcome, <span class="leaf-bold">{$name|sanitize}</span></span><a href="?a=logout" class="leaf-sign-out">SIGN OUT</a>
{/if}
