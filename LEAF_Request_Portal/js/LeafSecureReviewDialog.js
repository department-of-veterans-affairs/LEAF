var LeafSecureReviewDialog = function(domId) {
    var prefixID = 'LeafSecureReviewDialog' + Math.floor(Math.random()*1000) + '_';

    $('#' + domId).html('<div id="'+ prefixID +'sensitiveFields">Loading field list for review...</div>'
                + '<div id="'+ prefixID +'nonSensitiveFields"></div>');

    $.ajax({
        type: 'GET',
        url: 'api/form/indicator/list',
        cache: false
    })
    .then(function(res) {

        var sensitiveFields = [];
        var nonSensitiveFields = [];
        for(var i in res) {
            var temp = {};
            temp = res[i];
            temp.recordID = res[i].indicatorID;
            if(res[i].is_sensitive == '1') {
                sensitiveFields.push(temp);
            }
            else {
                if(temp.categoryID.indexOf('leaf_') == -1) {
                    nonSensitiveFields.push(temp);
                }
            }
        }

        if(sensitiveFields.length > 0) {
            buildSensitiveGrid(sensitiveFields);
        }
        else {
            $('#'+ prefixID +'sensitiveFields').html('<h2>No data fields have been marked as sensitive.</h2>');
            if($('#'+ prefixID).val() == '') {
                $('#'+ prefixID).val('N/A');
            }
        }

        if(nonSensitiveFields.length > 0) {
            buildNonSensitiveGrid(nonSensitiveFields);
        }
        else {
            $('#'+ prefixID +'nonSensitiveFields').html('');
        }
    });

    function buildSensitiveGrid(sensitiveFields) {
        var gridSensitive = new LeafFormGrid(prefixID +'sensitiveFields');
        gridSensitive.hideIndex();
        gridSensitive.setData(sensitiveFields);
        gridSensitive.setDataBlob(sensitiveFields);
        gridSensitive.setHeaders([
        {name: 'Form', indicatorID: 'formName', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(gridSensitive.getDataByIndex(data.index).categoryName);
        }},
        {name: 'Field Name', indicatorID: 'fieldName', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(gridSensitive.getDataByIndex(data.index).name);
            $('#'+data.cellContainerID).css('font-size', '14px');
        }}
        ]);
        gridSensitive.sort('fieldName', 'desc');
        gridSensitive.renderBody();
        $('#'+ prefixID +'sensitiveFields').prepend('<h2>The following fields have been marked as sensitive.</h2>'
                                                + '<p>Sensitive fields automatically enable and enforce "Need to know" data restrictions in this system.</p>');
    }

    function buildNonSensitiveGrid(nonSensitiveFields) {
        var gridNonSensitive = new LeafFormGrid(prefixID + 'nonSensitiveFields');
        gridNonSensitive.hideIndex();
        gridNonSensitive.setData(nonSensitiveFields);
        gridNonSensitive.setDataBlob(nonSensitiveFields);
        gridNonSensitive.setHeaders([
        {name: 'Form', indicatorID: 'formName', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(gridNonSensitive.getDataByIndex(data.index).categoryName);
        }},
        {name: 'Field Name', indicatorID: 'fieldName', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(gridNonSensitive.getDataByIndex(data.index).name);
            $('#'+data.cellContainerID).css('font-size', '14px');
        }}
        ]);
        gridNonSensitive.sort('fieldName', 'desc');
        gridNonSensitive.renderBody();
        $('#'+ prefixID +'nonSensitiveFields').prepend('<br /><h2 style="color:#c00;">Please verify the remaining fields are not sensitive.</h2>');
    }
};
