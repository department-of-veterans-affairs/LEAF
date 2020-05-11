<ul>
    <li>For Help contact your primary admin:
        <div id="help-primary-admin"></div>
    </li>
</ul>

<script type="text/javascript">
    $.ajax({
        url: "../api/system/primaryadmin",
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
</script>