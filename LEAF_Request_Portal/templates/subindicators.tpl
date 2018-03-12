    <!--{if !isset($depth)}-->
    <!--{assign var='depth' value=0}-->
    <!--{/if}-->

    <!--{if $depth == 0}-->
    <!--{assign var='color' value='#e0e0e0'}-->
    <!--{else}-->
    <!--{assign var='color' value='white'}-->
    <!--{/if}-->

    <!--{if $form}-->
    <div class="formblock">
    <!--{foreach from=$form item=indicator}-->

                <!--{if $indicator.format == null || $indicator.format == 'textarea'}-->
                <!--{assign var='colspan' value=2}-->
                <!--{else}-->
                <!--{assign var='colspan' value=1}-->
                <!--{/if}-->

                <!--{if $depth == 0}-->
        <div class="mainlabel">
            <div>
            <span>
                <b><!--{$indicator.name}--></b><!--{if $indicator.required == 1}--><span id="<!--{$indicator.indicatorID|strip_tags}-->_required" style="margin-left: 8px; color: red;">*&nbsp;Required</span><!--{/if}--><br />
            </span>
            </div>
                <!--{else}-->
        <div class="sublabel blockIndicator_<!--{$indicator.indicatorID|strip_tags}-->">
            <span>
                    <!--{if $indicator.format == null}-->
                        <br /><b><!--{$indicator.name|indent:$depth:""}--></b><!--{if $indicator.required == 1}--><span id="<!--{$indicator.indicatorID|strip_tags}-->_required" style="margin-left: 8px; color: red;">*&nbsp;Required</span><!--{/if}-->
                    <!--{else}-->
                        <br /><!--{$indicator.name|indent:$depth:""}--><!--{if $indicator.required == 1}--><span id="<!--{$indicator.indicatorID|strip_tags}-->_required" style="margin-left: 8px; color: red;">*&nbsp;Required</span><!--{/if}-->
                    <!--{/if}-->
            </span>
                <!--{/if}-->
        </div>
        <div class="response blockIndicator_<!--{$indicator.indicatorID|strip_tags}-->">
        <!--{if $indicator.isMasked == 1 && $indicator.value != ''}-->
            <span class="text">
                [protected data]
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'textarea' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <textarea id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" style="width: 97%; padding: 8px; font-size: 1.3em; font-family: monospace" rows="10"><!--{$indicator.value|sanitize}--></textarea>
            <div id="textarea_format_button_<!--{$indicator.indicatorID|strip_tags}-->" style="text-align: right; font-size: 12px"><span class="link">formatting options</span></div>
            <script>
            $(function() {
                if($('#<!--{$indicator.indicatorID|strip_tags}-->').val().indexOf('<p>') >= 0
                	|| $('#<!--{$indicator.indicatorID|strip_tags}-->').val().indexOf('<table') >= 0) {
                	useAdvancedEditor();
                }
                else {
                	var tmp = $('#<!--{$indicator.indicatorID|strip_tags}-->').val();
                	$('#<!--{$indicator.indicatorID|strip_tags}-->').val(tmp.replace(/\<br\s?\/?>/g, "\n"));
                }
                function useAdvancedEditor() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->').trumbowyg({
                        btns: ['bold', 'italic', 'underline', '|', 'unorderedList', 'orderedList', '|', 'justifyLeft', 'justifyCenter', 'justifyRight', 'fullscreen']
                    });
                    $('#textarea_format_button_<!--{$indicator.indicatorID|strip_tags}-->').css('display', 'none');
                }
                $('#textarea_format_button_<!--{$indicator.indicatorID|strip_tags}-->').on('click', function() {
                    useAdvancedEditor();
                });
            });
            <!--{if $indicator.required == 1}-->
            formRequired.id<!--{$indicator.indicatorID}--> = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val().trim() == '');
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').css({"background-color": "red", "color": "white", "padding": "4px", "font-weight": "bold"});
                }
            };
            <!--{/if}-->
            </script>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'radio' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
                <span>
                <!--{counter assign='ctr' print=false}-->
            <!--{foreach from=$indicator.options item=option}-->
                <!--{if is_array($option)}-->
                    <!--{assign var='option' value=$option[0]}-->
                    <!--{if $option|escape == $indicator.value}-->
                        <input type="radio" id="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->" class="icheck<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|sanitize}-->" checked="checked" />
                        <label class="checkable" for="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->"><!--{$option|sanitize}--></label><br />
                    <!--{else}-->
                        <input type="radio" id="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->" class="icheck<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|sanitize}-->" />
                        <label class="checkable" for="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->"><!--{$option|sanitize}--></label><br />
                    <!--{/if}-->
                <!--{elseif $option|escape == $indicator.value}-->
                    <input type="radio" id="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->" class="icheck<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|sanitize}-->" checked="checked" />
                    <label class="checkable" for="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->"><!--{$option|sanitize}--></label><br />
                <!--{else}-->
                    <input type="radio" id="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->" class="icheck<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|sanitize}-->" />
                    <label class="checkable" for="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->"><!--{$option|sanitize}--></label><br />
                <!--{/if}-->
                <!--{counter print=false}-->
            <!--{/foreach}-->
                </span>
                <script>
                $(function() {
                    $('.icheck<!--{$indicator.indicatorID|strip_tags}-->').icheck({checkboxClass: 'icheckbox_square-blue', radioClass: 'iradio_square-blue'});
                });
                <!--{if $indicator.required == 1}-->
                formRequired.id<!--{$indicator.indicatorID}--> = {
                    setRequired: function() {
                        return ($('.icheck<!--{$indicator.indicatorID|strip_tags}-->').is(':checked') == false);
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').css({"background-color": "red", "color": "white", "padding": "4px", "font-weight": "bold"});
                    }
                };
                <!--{/if}-->
                </script>
                <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'dropdown' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
                <span><select id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" style="width: 50%">
            <!--{foreach from=$indicator.options item=option}-->
                <!--{if is_array($option)}-->
                    <!--{assign var='option' value=$option[0]}-->
                    <!--{if $option|escape == $indicator.value}-->
                        <option value="<!--{$option|sanitize}-->" selected="selected"><!--{$option|sanitize}--></option>
                    <!--{else}-->
                        <option value="<!--{$option|sanitize}-->"><!--{$option|sanitize}--></option>
                    <!--{/if}-->
                <!--{elseif $option|escape == $indicator.value}-->
                    <option value="<!--{$option|sanitize}-->" selected="selected"><!--{$option|sanitize}--></option>
                    <!--{$option|sanitize}-->
                <!--{else}-->
                    <option value="<!--{$option|sanitize}-->"><!--{$option|sanitize}--></option>
                <!--{/if}-->
            <!--{/foreach}-->
                </select></span>
                <script>
                $(function() {
                	$('#<!--{$indicator.indicatorID|strip_tags}-->').chosen({disable_search_threshold: 5, allow_single_deselect: true, width: '80%'});
                });
                <!--{if $indicator.required == 1}-->
                formRequired.id<!--{$indicator.indicatorID}--> = {
                    setRequired: function() {
                        return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').css({"background-color": "red", "color": "white", "padding": "4px", "font-weight": "bold"});
                    }
                };
                <!--{/if}-->
                </script>
                <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'text' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <span class="text">
                <input type="text" id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$indicator.value|sanitize}-->" trim="true" style="width: 50%; font-size: 1.3em; font-family: monospace" />
            </span>
            <script>
            <!--{if $indicator.required == 1}-->
            formRequired.id<!--{$indicator.indicatorID}--> = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                },
                setRequiredError: function() {
                	$('#<!--{$indicator.indicatorID|strip_tags}-->_required').css({"background-color": "red", "color": "white", "padding": "4px", "font-weight": "bold"});
                }
            };
            <!--{/if}-->
            </script>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'number' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <span class="text">
                <input type="text" id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$indicator.value|strip_tags}-->" style="font-size: 1.3em; font-family: monospace" />
                <span id="<!--{$indicator.indicatorID|strip_tags}-->_error" style="color: red; display: none">Data must be numeric</span>
            </span>
            <script type="text/javascript">
            formValidator.id<!--{$indicator.indicatorID}--> = {
            	setValidator: function() {
                    return ($.isNumeric($('#<!--{$indicator.indicatorID|strip_tags}-->').val()) || $('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
            	},
            	setValidatorError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->').css('border', '2px solid red');
                    if($('#<!--{$indicator.indicatorID|strip_tags}-->_error').css('display') != 'none') {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_error').effect('pulsate');
                    }
                    else {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_error').show('fade');
                    }
            	},
            	setValidatorOk: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->').css('border', '1px solid gray');
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_error').hide('fade');
            	}
            };
            <!--{if $indicator.required == 1}-->
            formRequired.id<!--{$indicator.indicatorID}--> = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                },
                setRequiredError: function() {
                	$('#<!--{$indicator.indicatorID|strip_tags}-->_required').css({"background-color": "red", "color": "white", "padding": "4px", "font-weight": "bold"});
                }
            };
            <!--{/if}-->
            </script>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'numberspinner' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <span class="text">
                <br /><input type="text" id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$indicator.value|sanitize}-->" />
            </span>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'date' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <span class="text">
                <input type="text" id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" style="background: url(../libs/dynicons/?img=office-calendar.svg&w=16); background-repeat: no-repeat; background-position: 4px center; padding-left: 24px; font-size: 1.3em; font-family: monospace" value="<!--{$indicator.value|sanitize}-->" />
            </span>
            <script>
            $(function() {
            	$('#<!--{$indicator.indicatorID|strip_tags}-->').datepicker();
                $('#<!--{$indicator.indicatorID|strip_tags}-->').datepicker('option', 'showAnim', 'slideDown');
            });
            <!--{if $indicator.required == 1}-->
            formRequired.id<!--{$indicator.indicatorID}--> = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').css({"background-color": "red", "color": "white", "padding": "4px", "font-weight": "bold"});
                }
            };
            <!--{/if}-->
            </script>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'time' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <span class="text">
                <br /><input type="text" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$indicator.value|sanitize}-->" />
            </span>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'currency' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <span class="text">
                <br />$<input type="text" id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$indicator.value|sanitize}-->" style="font-size: 1.3em; font-family: monospace" /> (Amount in USD)
                <span id="<!--{$indicator.indicatorID|strip_tags}-->_error" style="color: red; display: none">Data must be numeric</span>
            </span>
            <script type="text/javascript">
            formValidator.id<!--{$indicator.indicatorID}--> = {
                    setValidator: function() {
                    	return ($.isNumeric($('#<!--{$indicator.indicatorID|strip_tags}-->').val()) || $('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');                 
                    },
                    setValidatorError: function() {
                    	$('#<!--{$indicator.indicatorID|strip_tags}-->').css('border', '2px solid red');
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_error').css('display', 'inline');
                    }
                };
            <!--{if $indicator.required == 1}-->
            formRequired.id<!--{$indicator.indicatorID}--> = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                },
                setRequiredError: function() {
                	$('#<!--{$indicator.indicatorID|strip_tags}-->_required').css({"background-color": "red", "color": "white", "padding": "4px", "font-weight": "bold"});
                }
            };
            <!--{/if}-->
            </script>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'checkbox' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
                <span id="parentID_<!--{$indicator.parentID|strip_tags}-->">
                    <input type="hidden" name="<!--{$indicator.indicatorID|strip_tags}-->" value="no" /> <!-- dumb workaround -->
            <!--{foreach from=$indicator.options item=option}-->
                <!--{if $option|escape == $indicator.value}-->
                    <input type="checkbox" class="icheck<!--{$indicator.indicatorID|strip_tags}-->" id="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|sanitize}-->" checked="checked" />
                    <label class="checkable" for="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->"><!--{$option|sanitize}--></label><br />
                <!--{else}-->
                    <input type="checkbox" class="icheck<!--{$indicator.indicatorID|strip_tags}-->" id="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|strip_tags}-->" />
                    <label class="checkable" for="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->"><!--{$option|sanitize}--></label><br />
                <!--{/if}-->
            <!--{/foreach}-->
                </span>
                <script>
                $(function() {
                	$('.icheck<!--{$indicator.indicatorID|strip_tags}-->').icheck({checkboxClass: 'icheckbox_square-blue', radioClass: 'iradio_square-blue'});
                });
                <!--{if $indicator.required == 1}-->
                formRequired.id<!--{$indicator.indicatorID}--> = {
                    setRequired: function() {
                        return ($('#<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->').prop('checked') == false);
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').css({"background-color": "red", "color": "white", "padding": "4px", "font-weight": "bold"});
                    }
                };
                <!--{/if}-->
                </script>
                <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'checkboxes' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
                <span id="parentID_<!--{$indicator.parentID|strip_tags}-->_indicatorID_<!--{$indicator.indicatorID|strip_tags}-->">
            <!--{assign var='idx' value=0}-->
            <!--{foreach from=$indicator.options item=option}-->
                    <input type="hidden" name="<!--{$indicator.indicatorID|strip_tags}-->[<!--{$idx}-->]" value="no" /> <!-- dumb workaround -->
                    <!--{if $option == $indicator.value[$idx]}-->
                        <br /><input type="checkbox" class="icheck<!--{$indicator.indicatorID|strip_tags}-->" id="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->" name="<!--{$indicator.indicatorID|strip_tags}-->[<!--{$idx}-->]" value="<!--{$option|sanitize}-->" checked="checked" />
                        <label class="checkable" for="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->"><!--{$option|sanitize}--></label>
                    <!--{else}-->
                        <br /><input type="checkbox" class="icheck<!--{$indicator.indicatorID|strip_tags}-->" id="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->" name="<!--{$indicator.indicatorID|strip_tags}-->[<!--{$idx}-->]" value="<!--{$option|sanitize}-->" />
                        <label class="checkable" for="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->"><!--{$option|sanitize}--></label>
                    <!--{/if}-->
                    <!--{assign var='idx' value=$idx+1}-->
            <!--{/foreach}-->
                </span>
                <script>
                $(function() {
                	$('.icheck<!--{$indicator.indicatorID|strip_tags}-->').icheck({checkboxClass: 'icheckbox_square-blue', radioClass: 'iradio_square-blue'});
                });
                </script>
                <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'fileupload' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <fieldset>
                <legend>File Attachment(s)</legend>
                <span class="text">
                <!--{if $indicator.value[0] != ''}-->
                <!--{assign "counter" 0}-->
                <!--{foreach from=$indicator.value item=file}-->
                <div id="file_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_<!--{$counter}-->" style="background-color: #b7c5ff; padding: 4px"><img src="../libs/dynicons/?img=mail-attachment.svg&amp;w=16" /> <a href="file.php?form=<!--{$recordID|strip_tags}-->&amp;id=<!--{$indicator.indicatorID|strip_tags}-->&amp;series=<!--{$indicator.series|strip_tags}-->&amp;file=<!--{$counter}-->" target="_blank"><!--{$file|sanitize}--></a>
                    <span style="float: right; padding: 4px">
                    [ <span class="link" onclick="deleteFile_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_<!--{$counter}-->();">Delete</span> ]
                    </span>
                </div>
                <script>
                    function deleteFile_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_<!--{$counter}-->() {
                    	dialog_confirm.setTitle('Delete File?');
                    	dialog_confirm.setContent('Are you sure you want to delete:<br /><br /><b><!--{$file}--></b>');
                    	dialog_confirm.setSaveHandler(function() {
                    	    $.ajax({
                    	        type: 'POST',
                    	        url: "ajaxIndex.php?a=deleteattachment&recordID=<!--{$recordID|strip_tags}-->&indicatorID=<!--{$indicator.indicatorID|strip_tags}-->&series=<!--{$indicator.series|strip_tags}-->",
                    	        data: {recordID: <!--{$recordID|strip_tags}-->,
                    	               indicatorID: <!--{$indicator.indicatorID|strip_tags}-->,
                    	               series: <!--{$indicator.series|strip_tags}-->,
                    	               file: '<!--{$counter}-->',
                    	               CSRFToken: '<!--{$CSRFToken}-->'},
                    	        success: function(response) {
                    	            $('#file_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_<!--{$counter}-->').css('display', 'none');
                    	            dialog_confirm.hide();
                    	        }
                    	    });
                    	});
                    	dialog_confirm.show();
                    }
                </script>
                <!--{assign "counter" $counter+1}-->
                <!--{/foreach}-->
                <!-- TODO: whenever we can drop support for old browsers IE9, use modern method -->
                <iframe id="fileIframe_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->" style="visibility: hidden; display: none" src="ajaxIframe.php?a=getuploadprompt&amp;recordID=<!--{$recordID|strip_tags}-->&amp;indicatorID=<!--{$indicator.indicatorID|strip_tags}-->&amp;series=<!--{$indicator.series|strip_tags}-->" frameborder="0" width="500px"></iframe>
                <br />
                <span id="fileAdditional" class="buttonNorm" onclick="$('#fileIframe_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').css('display', 'inline'); $('#fileIframe_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').css('visibility', 'visible'); $('#fileAdditional').css('visibility', 'hidden')"><img src="../libs/dynicons/?img=document-open.svg&amp;w=32" /> Attach Additional File</span>
                <!--{else}-->
                    <iframe src="ajaxIframe.php?a=getuploadprompt&amp;recordID=<!--{$recordID|strip_tags}-->&amp;indicatorID=<!--{$indicator.indicatorID|strip_tags}-->&amp;series=<!--{$indicator.series|strip_tags}-->" frameborder="0" width="480px" height="100px"></iframe><br />
                <!--{/if}-->
                </span>
            </fieldset>
        <!--{/if}-->
        <!--{if $indicator.format == 'image' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <fieldset>
                <legend>Image Attachment(s)</legend>
                <span class="text">
                <!--{if $indicator.value[0] != ''}-->
                <!--{assign "counter" 0}-->
                <!--{foreach from=$indicator.value item=file}-->
                <div id="file_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_<!--{$counter}-->" style="background-color: #b7c5ff; padding: 4px"><img src="../libs/dynicons/?img=mail-attachment.svg&amp;w=16" /> <a href="file.php?form=<!--{$recordID|strip_tags}-->&amp;id=<!--{$indicator.indicatorID|strip_tags}-->&amp;series=<!--{$indicator.series|strip_tags}-->&amp;file=<!--{$counter}-->" target="_blank"><!--{$file|sanitize}--></a>
                    <span style="float: right; padding: 4px">
                    [ <span class="link" onclick="deleteFile_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_<!--{$counter}-->();">Delete</span> ]
                    </span>
                </div>
                <script>
                    function deleteFile_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_<!--{$counter}-->() {
                        dialog_confirm.setTitle('Delete File?');
                        dialog_confirm.setContent('Are you sure you want to delete:<br /><br /><b><!--{$file}--></b>');
                        dialog_confirm.setSaveHandler(function() {
                            $.ajax({
                                type: 'POST',
                                url: "ajaxIndex.php?a=deleteattachment&recordID=<!--{$recordID|strip_tags}-->&indicatorID=<!--{$indicator.indicatorID|strip_tags}-->&series=<!--{$indicator.series|strip_tags}-->",
                                data: {recordID: <!--{$recordID|strip_tags}-->,
                                       indicatorID: <!--{$indicator.indicatorID|strip_tags}-->,
                                       series: <!--{$indicator.series|strip_tags}-->,
                                       file: '<!--{$counter}-->',
                                       CSRFToken: '<!--{$CSRFToken}-->'},
                                success: function(response) {
                                    $('#file_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_<!--{$counter}-->').css('display', 'none');
                                    dialog_confirm.hide();
                                }
                            });
                        });
                        dialog_confirm.show();
                    }
                </script>
                <!--{assign "counter" $counter+1}-->
                <!--{/foreach}-->
                <!-- TODO: whenever we can drop support for old browsers IE9, use modern method -->
                <iframe id="fileIframe_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->" style="visibility: hidden; display: none" src="ajaxIframe.php?a=getimageuploadprompt&amp;recordID=<!--{$recordID|strip_tags}-->&amp;indicatorID=<!--{$indicator.indicatorID|strip_tags}-->&amp;series=<!--{$indicator.series|strip_tags}-->" frameborder="0" width="500px"></iframe>
                <br />
                <span id="fileAdditional" class="buttonNorm" onclick="$('#fileIframe_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').css('display', 'inline'); $('#fileIframe_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').css('visibility', 'visible'); $('#fileAdditional').css('visibility', 'hidden')"><img src="../libs/dynicons/?img=document-open.svg&amp;w=32" /> Attach Additional File</span>
                <!--{else}-->
                    <iframe src="ajaxIframe.php?a=getimageuploadprompt&amp;recordID=<!--{$recordID|strip_tags}-->&amp;indicatorID=<!--{$indicator.indicatorID|strip_tags}-->&amp;series=<!--{$indicator.series|strip_tags}-->" frameborder="0" width="480px" height="100px"></iframe><br />
                <!--{/if}-->
                </span>
            </fieldset>
        <!--{/if}-->
        <!--{if $indicator.format == 'table' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <!--{foreach from=$indicator.options item=option}-->
                <!--{if is_array($option)}-->
                    <!--{assign var='option' value=$option[0]}-->
                    <!--{$option}--> <input type="checkbox" name="<!--{$indicator.indicatorID|strip_tags}-->[]" value="<!--{$option|sanitize}-->" checked="checked" /><br />
                <!--{else}-->
                    <!--{$option}--> <input type="checkbox" name="<!--{$indicator.indicatorID|strip_tags}-->[]" value="<!--{$option|sanitize}-->" /><br />
                <!--{/if}-->
            <!--{/foreach}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'orgchart_group' && ($indicator.isMasked == 0 || $indicator.data == '')}-->
            <div id="grpSel_<!--{$indicator.indicatorID|strip_tags}-->"></div>
            <input id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$indicator.value|strip_tags}-->" style="display: none"></input>
            
            <script>
            $(function() {
                if(typeof groupSelector == 'undefined') {
                    $('head').append('<link type="text/css" rel="stylesheet" href="<!--{$orgchartPath}-->/css/groupSelector.css" />');
                    $.ajax({
                        type: 'GET',
                        url: "<!--{$orgchartPath}-->/js/groupSelector.js",
                        dataType: 'script',
                        success: function() {
                        	grpSel = new groupSelector('grpSel_<!--{$indicator.indicatorID|strip_tags}-->');
                        	grpSel.apiPath = '<!--{$orgchartPath}-->/api/';
                        	grpSel.rootPath = '<!--{$orgchartPath}-->/';
                        	grpSel.searchTag('<!--{$orgchartImportTag}-->');

                        	grpSel.setSelectHandler(function() {
                                $('#<!--{$indicator.indicatorID|strip_tags}-->').val(grpSel.selection);
                            });
                        	grpSel.setResultHandler(function() {
                                $('#<!--{$indicator.indicatorID|strip_tags}-->').val(grpSel.selection);
                            });
                        	grpSel.initialize();
                            <!--{if $indicator.value != ''}-->
                            grpSel.forceSearch('group#<!--{$indicator.value|strip_tags}-->');
                            <!--{/if}-->
                        }
                    });
                }
                else {
                	grpSel = new groupSelector('grpSel_<!--{$indicator.indicatorID|strip_tags}-->');
                	grpSel.apiPath = '<!--{$orgchartPath}-->/api/';
                	grpSel.rootPath = '<!--{$orgchartPath}-->/';

                	grpSel.setSelectHandler(function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->').val(grpSel.selection);
                    });
                	grpSel.setResultHandler(function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->').val(grpSel.selection);
                    });

                	grpSel.initialize();
                    <!--{if $indicator.value != ''}-->
                    grpSel.forceSearch('group#<!--{$indicator.value|strip_tags}-->');
                    <!--{/if}-->
                }
            });
            </script>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'orgchart_position' && ($indicator.isMasked == 0 || $indicator.data == '')}-->
            <!--{if $indicator.value != ''}-->
            <div id="indata_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->" style="padding: 0px">
            <script>
            $(function() {
                $.ajax({
                    type: 'GET',
                    url: "<!--{$orgchartPath}-->/api/?a=position/<!--{$indicator.value|strip_tags}-->",
                    dataType: 'json',
                    success: function(data) {
                        $('#indata_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').html('<b>' + data.title + '</b>'
                            /* Pay Plan, Series, Pay Grade */ + '<br />' + data[2].data + '-' + data[13].data + '-' + data[14].data);

                        if(data[3].data != '') {
                            for(i in data[3].data) {
                                var pdLink = document.createElement('a');
                                pdLink.innerHTML = data[3].data[i];
                                pdLink.setAttribute('href', '<!--{$orgchartPath}-->/file.php?categoryID=2&UID=<!--{$indicator.value|strip_tags}-->&indicatorID=3&file=' + encodeURIComponent(data[3].data[i]));
                                pdLink.setAttribute('class', 'printResponse');
                                pdLink.setAttribute('target', '_blank');

                                $('#indata_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').append('<br />Position Description: ');
                                $('#indata_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').append(pdLink);
                            }
                        }

                        br = document.createElement('br');
                        $('#indata_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').append(br);

                        var ocLink = document.createElement('div');
                        ocLink.innerHTML = '<img src="../libs/dynicons/?img=preferences-system-windows.svg&w=32" alt="View Position Details" /> View Details in Org. Chart';
                        ocLink.setAttribute('onclick', "window.open('<!--{$orgchartPath}-->/?a=view_position&positionID=<!--{$indicator.value|strip_tags}-->','Resource_Request','width=870,resizable=yes,scrollbars=yes,menubar=yes');");
                        ocLink.setAttribute('class', 'buttonNorm');
                        ocLink.setAttribute('style', 'margin-top: 8px');
                        $('#indata_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').append(ocLink);
                    },
                    cache: false
                });
            });
            </script>
            Loading...
            </div>
            <!--{else}-->
            Search and select:
            <!--{/if}--><br />
            <div id="posSel_<!--{$indicator.indicatorID|strip_tags}-->"></div>
            <input id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" style="visibility: hidden"></input>
            <script>
            $(function() {
            	var posSel;
                if(typeof positionSelector == 'undefined') {
                    $('head').append('<link type="text/css" rel="stylesheet" href="<!--{$orgchartPath}-->/css/positionSelector.css" />');
                    $.ajax({
                        type: 'GET',
                        url: "<!--{$orgchartPath}-->/js/positionSelector.js",
                        dataType: 'script',
                        success: function() {
                            posSel = new positionSelector('posSel_<!--{$indicator.indicatorID|strip_tags}-->');
                            posSel.apiPath = '<!--{$orgchartPath}-->/api/';
                            posSel.enableEmployeeSearch();

                            posSel.setSelectHandler(function() {
                                $('#<!--{$indicator.indicatorID|strip_tags}-->').val(posSel.selection)
                            });
                            posSel.setResultHandler(function() {
                                $('#<!--{$indicator.indicatorID|strip_tags}-->').val(posSel.selection)
                            });

                            posSel.initialize();
                            <!--{if $indicator.value != ''}-->
                            posSel.forceSearch('#<!--{$indicator.value|strip_tags|trim}-->');
                            <!--{/if}-->
                        }
                    });
                }
                else {
                    posSel = new positionSelector('posSel_<!--{$indicator.indicatorID|strip_tags}-->');
                    posSel.apiPath = '<!--{$orgchartPath}-->/api/';
                    posSel.enableEmployeeSearch();

                    posSel.setSelectHandler(function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->').val(posSel.selection);
                    });
                    posSel.setResultHandler(function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->').val(posSel.selection);
                    });

                    posSel.initialize();
                    <!--{if $indicator.value != ''}-->
                    posSel.forceSearch('#<!--{$indicator.value|strip_tags|trim}-->');
                    <!--{/if}-->
                }
            });
            <!--{if $indicator.required == 1}-->
            formRequired.id<!--{$indicator.indicatorID}--> = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val().trim() == '');
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').css({"background-color": "red", "color": "white", "padding": "4px", "font-weight": "bold"});
                }
            };
            <!--{/if}-->
            </script>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'orgchart_employee' && ($indicator.isMasked == 0 || $indicator.data == '')}-->
            <div id="empSel_<!--{$indicator.indicatorID}-->"></div>
            <input id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$indicator.value|sanitize}-->" style="display: none"></input>
            
            <script>
            $(function() {
                function importFromNational(empSel) {
                    if(empSel.selection != '') {
                        var selectedUserName = empSel.selectionData[empSel.selection].userName;
                        $.ajax({
                            type: 'POST',
                            url: '<!--{$orgchartPath}-->/api/employee/import/_' + selectedUserName,
                            data: {CSRFToken: '<!--{$CSRFToken}-->'},
                            success: function(res) {
                            	$('#<!--{$indicator.indicatorID|strip_tags}-->').val(res);
                            }
                        });
                    }
                }

            	var empSel;
                if(typeof nationalEmployeeSelector == 'undefined') {
                    $('head').append('<link type="text/css" rel="stylesheet" href="<!--{$orgchartPath}-->/css/employeeSelector.css" />');
                    $.ajax({
                        type: 'GET',
                        url: "<!--{$orgchartPath}-->/js/nationalEmployeeSelector.js",
                        dataType: 'script',
                        success: function() {
                            empSel = new nationalEmployeeSelector('empSel_<!--{$indicator.indicatorID|strip_tags}-->');
                            empSel.apiPath = '<!--{$orgchartPath}-->/api/';
                            empSel.rootPath = '<!--{$orgchartPath}-->/';

                            empSel.setSelectHandler(function() {
                            	importFromNational(empSel);
                            });
                            empSel.setResultHandler(function() {
                            	importFromNational(empSel);
                            });
                            empSel.initialize();
                            <!--{if $indicator.value != ''}-->
                            empSel.forceSearch('#<!--{$indicator.value|strip_tags|escape|trim}-->');
                            <!--{/if}-->
                        }
                    });
                }
                else {
                    empSel = new nationalEmployeeSelector('empSel_<!--{$indicator.indicatorID|strip_tags}-->');
                    empSel.apiPath = '<!--{$orgchartPath}-->/api/';
                    empSel.rootPath = '<!--{$orgchartPath}-->/';

                    empSel.setSelectHandler(function() {
                    	importFromNational(empSel);
                    });
                    empSel.setResultHandler(function() {
                    	importFromNational(empSel);
                    });

                    empSel.initialize();
                    <!--{if $indicator.value != ''}-->
                    empSel.forceSearch('#<!--{$indicator.value|strip_tags|trim}-->');
                    <!--{/if}-->
                }
            });
            <!--{if $indicator.required == 1}-->
            formRequired.id<!--{$indicator.indicatorID}--> = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val().trim() == '');
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').css({"background-color": "red", "color": "white", "padding": "4px", "font-weight": "bold"});
                }
            };
            <!--{/if}-->
            </script>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'raw_data' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <input type="text" id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$indicator.value|sanitize}-->" style="display: none" />
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{include file=$subindicatorsTemplate form=$indicator.child depth=$depth+4 recordID=$recordID}-->

        </div>
    <!--{/foreach}-->
    </div>
    <!--{/if}-->
