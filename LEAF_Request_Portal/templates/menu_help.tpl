For Help contact your primary admin:
<div id="help-primary-admin" style="font-weight:bold;">Searching...</div>
<script type="text/javascript">
    let observPrimaryAdmin = new IntersectionObserver(function(entities) {
        if(entities[0].isIntersecting) {
            observPrimaryAdmin.disconnect();
            $.ajax({
                url: "api/system/primaryadmin",
                dataType: "json",
                success: function(response) {
                    const fullName = ((response['Fname'] || '') + ' ' + (response['Lname'] || '')).trim();
                    const userName = response["userName"] || '';
                    const nameDisplay = fullName || userName || '';
                    const email = response['Email'] || '';

                    const emailString = email !== '' ?
                        nameDisplay + ':<br/><a href="mailto:' + email+ '">' + email + '</a>' :
                        'Primary Admin has not been set.';

                    $('#help-primary-admin').html('<div id="help_admin_info">' + emailString + '</div>');
                }
            });
        }
    }, {
        threshold: 1.0
    });
    observPrimaryAdmin.observe(document.querySelector('#help-primary-admin'));
</script>