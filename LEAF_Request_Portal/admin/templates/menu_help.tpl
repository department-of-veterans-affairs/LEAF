For Help contact your primary admin:
<div id="help-primary-admin" style="font-weight:bold;"></div>
<script type="text/javascript">
    $.ajax({
        url: "../api/system/primaryadmin",
        dataType: "json",
        success: function(response) {
            if(response["Fname"] !== undefined)
            {
                $('#help-primary-admin').html(response['Fname'] + " " + response['Lname'] + "-" + response['Email']);
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
</script>