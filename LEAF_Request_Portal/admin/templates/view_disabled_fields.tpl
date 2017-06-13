<h2>List of disabled fields available for recovery</h2>
<div>Disabled fields and associated data may be permanently deleted after 30 days</div>

<table class="table">
    <thead>
        <tr>
            <td>indicatorID</td>
            <td>Form</td>
            <td>Field Name</td>
            <td>Input Format</td>
            <td>Restore</td>
        </tr>
    </thead>
    <tbody id="fields"></tbody>
</table>

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
                buffer += '<td>'+ res[i].indicatorID +'</td>';
                buffer += '<td>'+ res[i].categoryName +'</td>';
                buffer += '<td>'+ res[i].name +'</td>';
                buffer += '<td>'+ res[i].format +'</td>';
                buffer += '<td><button class="buttonNorm" onclick="restoreField('+res[i].indicatorID+');">Restore this field</button></td>';
                buffer += '</tr>';
            }
            $('#fields').html(buffer);
        
        },
        cache: false
    });

});
    
</script>
