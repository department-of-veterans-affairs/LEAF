var LeafPreview = function(domID) {
    let numSection = 1;
    let rawForm = {};
    let LEAF_NEXUS_URL = 'https://LEAF_NEXUS_URL/';

    $('#' + domID).html('');

    /*
    * Backward compatibility: certain name properties are pre-sanitized server-side, and must be decoded before rendering
    * TODO: Migrate to markdown
    */
    function decodeHTMLEntities(txt) {
       let tmp = document.createElement("textarea");
       tmp.innerHTML = txt;
       return tmp.value;
    }
    function renderField(field, isChild) {
        const required = field.required == 1 ? '<span style="color:#b00;">* Required</span>': '';
        const sensitive = field.is_sensitive == 1 ? '<span style="color:#b00;">* Sensitive</span>': '';
        const labelledById = `leaf_library_preview_${field.indicatorID}`;
        const inputId = `leaf_library_input_${field.indicatorID}`;
        const indName = decodeHTMLEntities(field.name);
        let style_isChild = '';
        if(isChild == undefined) {
            style_isChild = 'font-weight:bold;';
        }
        let out = `<div style="margin-bottom:4px;${style_isChild}" id="${labelledById}">${indName}<span>${required} ${sensitive}</span></div>`;
        const f = field.format;
        switch(f) {
            case '':
                break;
            case 'textarea':
                out += `<textarea id="${inputId}" aria-labelledby="${labelledById}" style="width: 100%"></textarea>`;
                break;
            case 'radio':
                const r = Math.random();
                for(let i in field.options) {
                    out += `<input type="radio" id="${inputId}_${i}"
                        aria-labelledby="${labelledById}" name="${r}">${field.options[i]}<br>`;
                }
                break;
            case 'multiselect':
                out += `<select id="${inputId}" aria-labelledby="${labelledById}" style="min-width:185px;" multiple>`;
                for(let i in field.options) {
                    out += `<option>${field.options[i]}</option>`;
                }
                out += '</select>';
                break;
            case 'dropdown':
                out += `<select id="${inputId}" aria-labelledby="${labelledById}" style="min-width:185px;">`;
                for(let i in field.options) {
                    out += `<option>${field.options[i]}</option>`;
                }
                out += '</select>';
                break;
            case 'text':
            case 'number':
            case 'date':
                out += `<input type="${f}" id="${inputId}" aria-labelledby="${labelledById}">`;
                break;
            case 'currency':
                out += `$ <input type="number" id="${inputId}" aria-labelledby="${labelledById}">`;
                break;
            case 'checkbox':
            case 'checkboxes':
                for(let i in field.options) {
                    out += `<input type="checkbox" id="${inputId}_${i}" aria-labelledby="${labelledById}">${field.options[i]}<br>`;
                }
                break;
            case 'fileupload':
            case 'image':
                out += `<input type="file" aria-labelledby="${labelledById}">`;
                break;
            default:
                out += `<input type="text" aria-labelledby="${labelledById}">`;
                break;
        }
        if(field.format != '') {
            out += '<br><br>';
        } else {
            out += '<br>';
        }
        
        let childArr = [];
        if(field.child !== null) {
            for(let indIdKey in field.child) {
                childArr.push(field.child[indIdKey]);
            }
            childArr.sort((fieldA, fieldB) => fieldA.sort - fieldB.sort);
        }
        childArr.forEach(c => {
            out += renderField(c, true);
        });
        
        return out;
    }

    function renderSection(field) {
        const temp = renderField(field);
        const out = '<div style="font-size: 120%; padding: 4px; background-color: black; color: white">Section '+ numSection +'</div><div class="card" style="padding: 16px;line-height:1.3">'+ temp +'</div><br />';
        numSection++;
        return out;
    }

    function load(recordID, indicatorID, fileID, callback) {
    	$.ajax({
        	type: 'GET',
            url: LEAF_NEXUS_URL + 'LEAF/library/file.php?form='+ recordID +'&id='+ indicatorID +'&series=1&file=' + fileID,
            dataType: 'json',
            xhrFields: {withCredentials: true},
            success: function(res) {
                rawForm = res;
                const form = res.packet.form;
                numSection = 1;
                for(let i in form) {
                    const field = renderSection(form[i]);
                    $('#' + domID).append(field);
                }
                if(callback != undefined) {
                	callback();
                }
            }
        });
    }

    return {
        load: load,
        getRawForm: function() { return rawForm; },
        setNexusURL: function(url) { LEAF_NEXUS_URL = url; }
    };
}
