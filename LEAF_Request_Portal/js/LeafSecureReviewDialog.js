var LeafSecureReviewDialog = function(domId) {
    const prefixID = 'LeafSecureReviewDialog' + Math.floor(Math.random()*1000) + '_';
    const previewPath = './js/LeafPreview.js';
    const previewID = 'leafsFormPreview';
    const sensitiveGridMountID = prefixID + 'sensitiveFields';
    const nonSensitiveGridMountID = prefixID + 'nonSensitiveFields';
    let leafPreview = null;
    let formPreviews = {};

    let domEl = document.getElementById(domId);
    if(domEl !== null) {
        domEl.innerHTML =
        `<div id="${sensitiveGridMountID}">Loading field list for review...</div>` +
        `<div id="${nonSensitiveGridMountID}"></div>`;
    } else {
        return;
    }

    let sensitiveGridContainer = document.getElementById(sensitiveGridMountID);
    let nonsensitiveGridContainer = document.getElementById(nonSensitiveGridMountID);

    fetch(
        "api/form/indicator/list", { cache: "no-store" }
    ).then(res => {
        if (res.status !== 200) {
            throw new Error(`res status not ok, code: ${res.status}`);
        } else {
            return res.json();
        }
    }).then(data => {
        let sensitiveFields = [];
        let nonSensitiveFields = [];
        for(let i in data) {
            let temp = {};
            temp = data[i];
            temp.recordID = data[i].indicatorID;
            if(data[i].is_sensitive == '1') {
                sensitiveFields.push(temp);
            } else {
                if(temp.categoryID.indexOf('leaf_') == -1) {
                    nonSensitiveFields.push(temp);
                }
            }
        }

        if(sensitiveFields.length > 0) {
            buildSensitiveGrid(sensitiveFields);
        } else {
            sensitiveGridContainer.innerHTML = '<h2>No data fields have been marked as sensitive.</h2>';
        }

        if(nonSensitiveFields.length > 0) {
            buildNonSensitiveGrid(nonSensitiveFields);
        } else {
            nonsensitiveGridContainer.innerHTML = '';
        }
    }).catch(err => console.log("err", err));

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
        let gridSensitive = new LeafFormGrid(sensitiveGridMountID);
        gridSensitive.hideIndex();
        gridSensitive.setData(sensitiveFields);
        gridSensitive.setDataBlob(sensitiveFields);
        gridSensitive.setHeaders([
            {
                name: 'Form',
                indicatorID: 'formName',
                editable: false,
                callback: function(data, blob) {
                    let container = document.getElementById(data.cellContainerID);
                    if (container !== null) {
                        const formConfig = gridSensitive.getDataByIndex(data.index);
                        const formName = formConfig.categoryName;
                        let content = formName; //only display the form name button on the edit view
                        if (domId === 'leafSecureDialogContentPrint') {
                            if(typeof XSSHelpers !== 'undefined') {
                                content = XSSHelpers.stripTag(content, 'script');
                            }
                            const formID = formConfig.categoryID;
                            const listener = makeScopedPreviewFormListener(formID, formName);
                            const styles = `style="display:flex;gap:1rem;justify-content:space-between;align-items:center"`;
                            const btnID = `print_${formID}_${data.index}`;
                            content = `<div ${styles}>
                                ${formName}
                                <button id="${btnID}" type="button" class="buttonNorm">
                                    Preview Form
                                </button>
                            </div>`;
                            container.innerHTML = content;
                            document.getElementById(btnID)?.addEventListener('click', listener);
                        } else {
                            container.textContent = content;
                        }
                    }
                }
            },
            {
                name: 'Field Name',
                indicatorID: 'fieldName',
                editable: false,
                callback: function(data, blob) {
                    let container = document.getElementById(data.cellContainerID);
                    if (container !== null) {
                        let indName = gridSensitive.getDataByIndex(data.index)?.name ?? '';
                        if(typeof XSSHelpers !== 'undefined') {
                            indName = XSSHelpers.stripTag(indName, 'script');
                        }
                        container.innerHTML = indName;
                        container.style.fontSize = '14px';
                    }
                }
            },
        ]);
        gridSensitive.sort('fieldName', 'desc');
        gridSensitive.renderBody();

        let el = document.createElement('p');
        let t = document.createTextNode(
            'Sensitive fields automatically enable and enforce "Need to know" data restrictions in this system.'
        );
        el.appendChild(t);
        sensitiveGridContainer.insertBefore(el, sensitiveGridContainer.childNodes[0]);
        el = document.createElement('h2');
        t = document.createTextNode('The following fields have been marked as sensitive.');
        el.appendChild(t);
        sensitiveGridContainer.insertBefore(el, sensitiveGridContainer.childNodes[0]);
    }

    function buildNonSensitiveGrid(nonSensitiveFields) {
        let gridNonSensitive = new LeafFormGrid(nonSensitiveGridMountID);
        gridNonSensitive.hideIndex();
        gridNonSensitive.setData(nonSensitiveFields);
        gridNonSensitive.setDataBlob(nonSensitiveFields);
        gridNonSensitive.setHeaders([
            {
                name: 'Form',
                indicatorID: 'formName',
                editable: false,
                callback: function(data, blob) {
                    let container = document.getElementById(data.cellContainerID);
                    if (container !== null) {
                        container.textContent = gridNonSensitive.getDataByIndex(data.index).categoryName
                    }
                }
            },
            {
                name: 'Field Name',
                indicatorID: 'fieldName',
                editable: false,
                callback: function(data, blob) {
                    let container = document.getElementById(data.cellContainerID);
                    if (container !== null) {
                        let indName = gridNonSensitive.getDataByIndex(data.index)?.name ?? '';
                        if(typeof XSSHelperss !== 'undefined') {
                            indName = XSSHelpers.stripTag(indName, 'script');
                        }
                        container.innerHTML = indName;
                        container.style.fontSize = '14px';
                    }
                }
            }
        ]);
        gridNonSensitive.sort('fieldName', 'desc');
        gridNonSensitive.renderBody();
        let el = document.createElement('h2');
        el.style.marginTop = '2rem';
        el.style.color = '#c00';
        let t = document.createTextNode(
            'Please verify the remaining fields are not sensitive.'
        );
        el.appendChild(t);
        nonsensitiveGridContainer.insertBefore(el, nonsensitiveGridContainer.childNodes[0]);
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
    let formatOptionEl = document.getElementById('textarea_format_button_-2')
    if (formatOptionEl !== null) {
        formatOptionEl.style.display = 'none';
    }

    if(elJustifyInput !== null) {
        
        validateInput();
        elJustifyInput.removeEventListener('input', validateInput);
        elJustifyInput.addEventListener('input', validateInput);
    }

    function validateForm() {

      let validresponse = false;
      const currVal = (textArea?.value ?? '').trim();
      if (currVal.length < minLength) {
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
    
    // Optional: Real-time character count and feedback (improves user experience)
    const textArea = document.getElementById('-2');
    const errorMessage = document.getElementById('-2_required'); //Element to display character count
    const minLength = 25;
    if(textArea !== null) {
        $('.nextQuestion').off('click');
        validateForm();

        textArea.addEventListener('input', function() {
            validateForm();
        });
    }

};
