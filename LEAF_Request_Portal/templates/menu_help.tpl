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
                    var emailString = response['Email'] != '' ? " - " + response['Email'] : '';
                    if(response["Fname"] !== undefined)
                    {
                        $('#help-primary-admin').html(response['Fname'] + " " + response['Lname'] + emailString);
                    }
                    else if(response["userName"] !== undefined)
                    {
                        $('#help-primary-admin').html(response['userName']);
                    }
                    else
                    {
                        $('#help-primary-admin').html('Primary Admin has not been set.');
                    }
                        
                }
            });
        }
    }, {
        threshold: 1.0
    });
    observPrimaryAdmin.observe(document.querySelector('#help-primary-admin'));
</script>