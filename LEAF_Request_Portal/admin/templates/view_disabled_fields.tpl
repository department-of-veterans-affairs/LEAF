<!--<div class="leaf-center-content">-->

<div style="margin: 2em;">
    <h2>List of disabled fields available for recovery</h2>
    <div>Deleted fields and associated data will be permanently deleted after 30 days</div>
    <div class="leaf-center-content">
        <table class="usa-table leaf-whitespace-normal">
            <thead>
                <tr>
                    <th>indicatorID</th>
                    <th>Form</th>
                    <th>Field Name</th>
                    <th>Input Format</th>
                    <th>Status</th>
                    <th>Restore</th>
                </tr>
            </thead>
            <tbody id="fields"></tbody>
        </table>

    </div>
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

            let buffer = '';

            for(let i in res) {

                buffer += '<tr id="field_'+ res[i].indicatorID +'">';
                buffer += '<td>'+ res[i].indicatorID +'</td>';
                buffer += '<td>'+ res[i].categoryName +'</td>';
                buffer += '<td>'+ res[i].name +'</td>';
                buffer += '<td>'+ res[i].format +'</td>';
                buffer += '<td>'+ res[i].disabled + '</td>';
                buffer += '<td><button class="buttonNorm" onclick="restoreField('+res[i].indicatorID+');">Restore this field</button></td>';
                buffer += '</tr>';
            }
            $('#fields').html(buffer);

        },
        cache: false
    });

});

</script>
