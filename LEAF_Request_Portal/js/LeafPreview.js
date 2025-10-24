var LeafPreview = function(domID) {
    var numSection = 1;
    var rawForm = {};
    var LEAF_NEXUS_URL = 'https://LEAF_NEXUS_URL/';

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
        var required = field.required == 1 ? '<span style="color: red">* Required</span>': '';
        var style_isChild = '';
        if(isChild == undefined) {
            style_isChild = 'font-weight: bold';
        }
        var out = '<span style="'+style_isChild+'">' + decodeHTMLEntities(field.name) +'</span> '+ required + '<br />';
        switch(field.format) {
            case 'textarea':
                out += '<textarea style="width: 100%"></textarea>';
                break;
            case 'radio':
                var r = Math.random();
                for(var i in field.options) {
                	out += '<input type="radio" name="'+ r +'" /> ' + field.options[i] + '<br />';
                }
                out = out.slice(0, -6);
                break;
            case 'multiselect':
                out += '<select multiple>';
                for(var i in field.options) {
                    out += '<option> ' + field.options[i] + '</option>';
                }
                out += '</select>';
                break;
            case 'dropdown':
                out += '<select>';
                for(var i in field.options) {
                	out += '<option> ' + field.options[i] + '</option>';
                }
                out += '</select>';
                break;
            case 'text':
                out += '<input type="text" />';
                break;
            case 'number':
                out += '<input type="number" />';
                break;
            case 'date':
                out += '<input type="date" />';
                break;
            case 'currency':
                out += '$ <input type="number" />';
                break;
            case 'checkbox':
            case 'checkboxes':
                for(var i in field.options) {
                	out += '<input type="checkbox" /> ' + field.options[i] + '<br />';
                }
                break;
            case 'fileupload':
                out += '<input type="file" />';
                break;
            default:
                out += '<input type="text" />';
                break;
        }
        if(field.format != '') {
        	out += '<br /><br />';
        }
        else {
            out += '<br />';
        }
        
        for(var i in field.child) {
            out += renderField(field.child[i], true);
        }
        
        return out;
    }

    function renderSection(field) {
        var temp = renderField(field);
        var out = '<div style="font-size: 120%; padding: 4px; background-color: black; color: white">Section '+ numSection +'</div><div class="card" style="padding: 16px">'+ temp +'</div><br />';
        numSection++;
        return out;
    }

    function load(recordID, indicatorID, fileID, callback) {
    	$.ajax({
        	type: 'GET',
            url: '/LEAF/library/file.php?form='+ recordID +'&id='+ indicatorID +'&series=1&file=' + fileID,
            dataType: 'json',
            xhrFields: {withCredentials: true},
            success: function(res) {
            	rawForm = res;
                var form = res.packet.form;
                numSection = 1
            	for(var i in form) {
    				var field = renderSection(form[i]);
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
