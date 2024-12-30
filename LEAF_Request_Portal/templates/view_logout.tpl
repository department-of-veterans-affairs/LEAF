<div class="card" style="width: 50%; margin: auto; padding: 16px">
    <h2>You have signed out of this system.</h2>
    <p>You may close this window.</p>
</div>

<script>
    let closedSession = {
        sessExpireTime: null,
        lastAction: null
    };
    localStorage.setItem('LeafSession', JSON.stringify(closedSession));
</script>