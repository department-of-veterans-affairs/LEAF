var LeafSecureReviewDialog = function(domId) {
    const prefixID = 'LeafSecureReviewDialog' + Math.floor(Math.random()*1000) + '_';
    const previewPath = './js/LeafPreview.js';
    const previewID = 'leafsFormPreview';
    let leafPreview = null;
    let formPreviews = {};


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

    const buildFormPreview = async (formName, formTree = []) => {
        if(typeof dialog_message !== 'undefined' && typeof dialog_message.show === 'function') {
            //fetch leafpreview file and init if needed
            if (leafPreview === null) {
                await new Promise((resolve, reject) => {
                    let scriptTag = document.createElement('script');
                    scriptTag.setAttribute('src', previewPath);
                    scriptTag.onload = () => {
                        try {
                            leafPreview = new LeafPreview(previewID);
                            resolve(1);
                        } catch (e) {
                            reject(e);
                        }
                    }
                    document.body.appendChild(scriptTag);
                });
            }
            let buffer = `<div id="leafsFormPreview" style="max-width:600px;">`;
            formTree.forEach((page, idx) => {
                buffer += leafPreview.renderSection(page, idx === 0);
            });
            buffer += "</div>";
            dialog_message.setTitle(formName);
            dialog_message.setContent(buffer);
            Array.from(document.querySelectorAll('.card')).forEach(c => c.style.fontSize = '14px');
            Array.from(document.querySelectorAll('.card .sensitiveIndicator')).forEach(
                el => {
                    el.textContent = 'Sensitive'
                    el.style.color = '#58585b';
                    el.style.border = '1px solid #58585b80';
                    el.style.backgroundColor = '#FEFFD2';
                    el.style.disabled = 'inline-block';
                    el.style.padding = '0.125em 0.25em';
                }
            );
            dialog_message.setSaveHandler(() => {
                dialog_message.clearDialog();
                dialog_message.hide();
            });
            dialog_message.show();
        }
    }
    const makeScopedPreviewFormListener = (catID, formName) => () => {
        if (typeof formPreviews[catID] !== 'undefined') {
            buildFormPreview(formName, formPreviews[catID]);
        } else {
            fetch(`./api/form/category?id=${catID}`)
            .then(res => res.json())
            .then(data => {
                if(data.length > 0 && data[0].categoryID) {
                    formPreviews[data[0].categoryID] = data;
                }
                buildFormPreview(formName, data);
            }).catch(err => console.log(err));
        }
    }
    function buildSensitiveGrid(sensitiveFields) {
        let gridSensitive = new LeafFormGrid(prefixID +'sensitiveFields');
        gridSensitive.hideIndex();
        gridSensitive.setData(sensitiveFields);
        gridSensitive.setDataBlob(sensitiveFields);
        gridSensitive.setHeaders([
        {name: 'Form', indicatorID: 'formName', editable: false, callback: function(data, blob) {
            const formConfig = gridSensitive.getDataByIndex(data.index);
            const formName = formConfig.categoryName;

            let content = formName; //only display the form name on the edit view
            if (domId === 'leafSecureDialogContentPrint') {
                const formID = formConfig.categoryID;
                const listener = makeScopedPreviewFormListener(formID, formName);
                const styles = `style="display:flex;gap:1rem;justify-content:space-between;"`;
                const btnID = `print_${formID}_${data.index}`;
                content = `<div ${styles}>
                    ${formName}
                    <button id="${btnID}" type="button" class="buttonNorm">Preview Form</button>
                </div>`;
                $('#'+data.cellContainerID).html(content);
                document.getElementById(btnID)?.addEventListener('click', listener);
            } else {
                $('#'+data.cellContainerID).html(content);
            }
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

    const validateInput = () => {
        let inputEl = document.getElementById('-2');
        
        let buttons = Array.from(document.querySelectorAll('button'));
        let elLeafFormButtonSave = buttons.find(button => button.textContent.trim() === "Save Change")
        if(inputEl !== null) {
            const val = inputEl?.value ?? '';
            if(val.length < 25) {
                elLeafFormButtonSave.disabled = true;
            } else {
                elLeafFormButtonSave.disabled = false;
            }
        }
    }    
    const elJustifyInput = document.getElementById('-2');
    // for now we will remove the wysiwyg editor as a variable.
    $('#-2').trumbowyg('destroy');
    $('#textarea_format_button_-2').hide();
    if(elJustifyInput !== null) {
        
        validateInput();
        elJustifyInput.removeEventListener('input', validateInput);
        elJustifyInput.addEventListener('input', validateInput);
    }

    function validateForm() {

      let validresponse = false;
      if (textArea.value.length < minLength) {
        // Display error message
        errorMessage.textContent = `Please provide a more detailed justification. Minimum ${minLength} characters required. `;
        $('.nextQuestion').off('click');
        $('.nextQuestion').on('click',function() {
            $('#-2_required').addClass('input-required-error');
        });

        validresponse = false;

      } else {
        errorMessage.textContent = ""; //Clear the error message if valid.
        $('#-2_required').removeClass('input-required-error');

        $('.nextQuestion').off('click');
        $('.nextQuestion').on('click',function() {
            form.dialog().indicateBusy();
            form.setPostModifyCallback(function() {
                getNext();
                updateProgress(true);
            });
            form.dialog().clickSave();
        });
        validresponse = true;

      }

      return validresponse;
    }

    $('.nextQuestion').off('click');
    
    // Optional: Real-time character count and feedback (improves user experience)
    const textArea = document.getElementById('-2');
    const errorMessage = document.getElementById('-2_required'); //Element to display character count
    const minLength = 25;
    if(textArea !== null) {
        validateForm();

        textArea?.addEventListener('input', function() {
            validateForm();
        });
    }

};
