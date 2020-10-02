<div class="leaf-center-content">

    <h2>List of disabled fields available for recovery</h2>
    <div>Disabled fields and associated data may be permanently deleted after 30 days</div>

    <table class="usa-table">
        <thead>
            <tr>
                <th>indicatorID</th>
                <th>Form</th>
                <th>Field Name</th>
                <th>Input Format</th>
                <th>Restore</th>
            </tr>
        </thead>
        <tbody id="fields"></tbody>
    </table>

</div>

<script>
function restoreField(indicatorID) {
    $.ajax({
        type: 'POST',
        url: '../api/formEditor/' + indicatorID + '/disabled',
        data: {
            CSRFToken: '<!--{$CSRFToken}-->',
            disabled: 0
        },
        success: function() {
            $('#field_' + indicatorID).fadeOut();
            alert('The field has been restored.');
        }
    });
}

$(function() {

    $.ajax({
        type: 'GET',
        url: '../api/form/indicator/list/disabled',
        success: function(res) {

            var buffer = '';
            for(var i in res) {
                buffer += '<tr id="field_'+ res[i].indicatorID +'">';
                buffer += '<th>'+ res[i].indicatorID +'</th>';
                buffer += '<th>'+ res[i].categoryName +'</th>';
                buffer += '<th>'+ res[i].name +'</th>';
                buffer += '<th>'+ res[i].format +'</th>';
                buffer += '<th><button class="buttonNorm" onclick="restoreField('+res[i].indicatorID+');">Restore this field</button></th>';
                buffer += '</tr>';
            }
            $('#fields').html(buffer);

        },
        cache: false
    });

});

</script>
