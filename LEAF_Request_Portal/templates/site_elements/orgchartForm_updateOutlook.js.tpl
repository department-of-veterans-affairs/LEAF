    orgchartForm.addUpdateEvent(5, function(response) {
        dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
        dialog.setTitle('Update Outlook');
        dialog.setContent('<div style="border: 1px solid black; background-color: #e0e0e0"><div style="float: left; padding: 32px"><img src="dynicons/?img=contact-new.svg&amp;w=72" alt="" /></div>\
                   <div style="padding-top: 42px">Please enter your Windows Account password to update the Outlook address book.\
                   <br /><br /><span style="font-size: 120%"><!--{addslashes($userID)}--></span><br /><br /><input id="NTPW" type="password" />\
                   </div><br /><br /></div>');
        $('#NTPW').keypress(function(event) {
            if(event.which == 13) {
                $('#' + dialog.btnSaveID).trigger('click');
            }
        });
        dialog.setSaveHandler(function() {
            dialog.indicateBusy();
            $.ajax({
                type: 'POST',
                url: './auth/updateOutlook.php',
                data: {empUID: orgchartForm.currUID,
                       NTPW: $('#NTPW').val(),
                       CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(response) {
                },
                cache: false
            });
            dialog.hide();
            $('#NTPW').val('');
        });
        dialog.show();
        $('#NTPW').focus();
    });
