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
                <b><!--{$indicator.name|sanitizeRichtext}--></b><!--{if $indicator.required == 1}--><span id="<!--{$indicator.indicatorID|strip_tags}-->_required" class="input-required">*&nbsp;Required</span><!--{/if}--><!--{if $indicator.is_sensitive == 1}--><span style="margin-left: 8px; color: red;">*&nbsp;Sensitive &nbsp; &nbsp; &nbsp;</span> <!--{/if}--><br />
            </span>
            </div>
                <!--{else}-->
        <div class="sublabel blockIndicator_<!--{$indicator.indicatorID|strip_tags}-->">
            <label for="<!--{$indicator.indicatorID|strip_tags}-->">
                    <!--{if $indicator.format == null}-->
                        <br /><b><!--{$indicator.name|sanitizeRichtext|indent:$depth:""}--></b><!--{if $indicator.required == 1}--><span id="<!--{$indicator.indicatorID|strip_tags}-->_required" class="input-required">*&nbsp;Required</span><!--{/if}-->
                    <!--{else}-->
                        <br /><!--{$indicator.name|sanitizeRichtext|indent:$depth:""}--><!--{if $indicator.required == 1}--><span id="<!--{$indicator.indicatorID|strip_tags}-->_required" class="input-required">*&nbsp;Required</span><!--{/if}-->
                    <!--{/if}-->
            </label>
            <!--{if $indicator.is_sensitive == 1}--><span role="button" aria-label="click here to toggle display" tabindex="0" id="<!--{$indicator.indicatorID|strip_tags}-->_sensitive" style="margin-left: 8px; color: red; background-repeat: no-repeat; background-image: url('/libs/dynicons/?img=eye_invisible.svg&w=16'); background-position-x: 70px;" onclick="toggleSensitive(<!--{$indicator.indicatorID|strip_tags}-->);" onkeydown="if (event.keyCode==13){ this.click(); }">*&nbsp;Sensitive &nbsp; &nbsp; &nbsp;</span><span id="sensitiveStatus" aria-label="sensitive data hidden" style="position: absolute; width: 60%; height: 1px; margin: -1px; padding: 0; overflow: hidden; clip: rect(0,0,0,0); border: 0;" role="status" aria-live="assertive" aria-atomic="true"></span> <!--{/if}-->
                <!--{/if}-->
        </div>
        <div class="response blockIndicator_<!--{$indicator.indicatorID|strip_tags}-->">
        <!--{if $indicator.isMasked == 1 && $indicator.value != ''}-->
            <span class="text">
                [protected data]
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'grid' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <span style="position: absolute; color: transparent" aria-atomic="true" aria-live="polite" id="tableStatus" role="status"></span>
            <div class="tableinput">
            <table class="table" id="grid_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->_input" style="word-wrap:break-word; table-layout: fixed; height: 100%; display: table">
                <thead>
                </thead>
                <tbody>
                </tbody>
            </table>
            </div>
            <button type="button" class="buttonNorm" id="addRowBtn" title="Grid input add row" alt="Grid input add row" aria-label="Grid input add row" onclick="gridInput_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->.addRow()"><img src="../libs/dynicons/?img=list-add.svg&w=16" style="height: 25px;"/>Add row</button>
            <script>
                var gridInput_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}--> = new gridInput(<!--{$indicator.options[0]}-->, <!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->);

                $(function() {
                    gridInput_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->.input(<!--{$indicator.value|json_encode}-->);
                    if (typeof (<!--{$indicator.value|json_encode}-->.cells) === "undefined") {
                        gridInput_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->.addRow();
                    }
                });

                <!--{if $indicator.required == 1}-->
                formRequired["id<!--{$indicator.indicatorID}-->"] = {
                    setRequired:  function() {
                        var gridElement = '#grid_' + <!--{$indicator.indicatorID}--> + '_' + <!--{$indicator.series}--> + '_input > tbody';
                        var valid = true;
                        var numColumns;

                        var numRows = $(gridElement).find('tr').length;

                        if(numRows > 0){
                            $(gridElement).find('tr').each(function(){
                                
                                numColumns = $(this).find('td').length;

                                $(this).find('td').each(function(j){
                                    
                                    if(j < numColumns - 2 ){ //skipping last two columns: sort & remove row

                                        var possibleInputs = [];

                                        possibleInputs.push($(this).find('input').first());

                                        possibleInputs.push($(this).find('textarea').first());

                                        possibleInputs.push($(this).find('select').first());

                                        var input;
                                        
                                        for(var k= 0; k < possibleInputs.length; k++){
                                            if($(possibleInputs[k]).length > 0){
                                                input = $(possibleInputs[k]);
                                                break;
                                            }
                                        }

                                        if(input){
                                            var inputValue = $(input).val(); 
                                            if(inputValue == null || inputValue.trim() == ''){
                                                valid = false;
                                            }
                                        }   
                                    }

                                });
                            });
                        }
                        else {
                            valid = false;
                        }
                        return !valid;
                    },
                    setSubmitError: function() {
                        $([document.documentElement, document.body]).animate({
                            scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                        }, 700).clearQueue();
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                    },
                    setRequiredOk: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
                    }
                };
                <!--{/if}-->
            </script>
        <!--{/if}-->
        <!--{if $indicator.format == 'textarea' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
            <textarea id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" style="width: 97%; padding: 8px; font-size: 1.3em; font-family: monospace" rows="10"><!--{$indicator.value|sanitize}--></textarea>
            <div id="textarea_format_button_<!--{$indicator.indicatorID|strip_tags}-->" style="text-align: right; font-size: 12px"><span class="link">formatting options</span></div>
            <script>
            $(function() {
                var indicator = $('#<!--{$indicator.indicatorID|strip_tags}-->');
                if(XSSHelpers.containsTags(indicator.val(), ['<b>','<i>','<u>','<ol>','<li>','<br>','<p>','<td>'])) {
                    useAdvancedEditor();
                }
                else {
                	indicator.val(indicator.val().replace(/\<br\s?\/?>/g, "\n"));
                }
                function useAdvancedEditor() {
                    indicator.val(XSSHelpers.stripTags(indicator.val(), ['<script>']));
                    indicator.trumbowyg({
                        btns: ['bold', 'italic', 'underline', '|', 'unorderedList', 'orderedList', '|', 'justifyLeft', 'justifyCenter', 'justifyRight', 'fullscreen']
                    });
                    $('#textarea_format_button_<!--{$indicator.indicatorID|strip_tags}-->').css('display', 'none');
                }
                $('#textarea_format_button_<!--{$indicator.indicatorID|strip_tags}-->').on('click', function() {
                    useAdvancedEditor();
                });
            });
            <!--{if $indicator.required == 1}-->
            formRequired["id<!--{$indicator.indicatorID}-->"] = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val().trim() == '');
                },
                setSubmitError: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                    }, 700).clearQueue();
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                },
                setRequiredOk: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
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
                        <label class="checkable leaf_check" for="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->">
                        <input type="radio" id="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->" class="icheck<!--{$indicator.indicatorID|strip_tags}--> leaf_check" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|sanitize}-->" checked="checked" />
                        <span class="leaf_check"></span> <!--{$option|sanitize}--></label>
                    <!--{else}-->
                        <label class="checkable leaf_check" for="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->">
                        <input type="radio" id="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->" class="icheck<!--{$indicator.indicatorID|strip_tags}--> leaf_check" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|sanitize}-->" />
                        <span class="leaf_check"></span> <!--{$option|sanitize}--></label>
                    <!--{/if}-->
                <!--{elseif $option|escape == $indicator.value}-->
                    <label class="checkable leaf_check" for="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->">
                    <input type="radio" id="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->" class="icheck<!--{$indicator.indicatorID|strip_tags}--> leaf_check" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|sanitize}-->" checked="checked" />
                    <span class="leaf_check"></span> <!--{$option|sanitize}--></label>
                <!--{else}-->
                    <label class="checkable leaf_check" for="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->">
                    <input type="radio" id="<!--{$indicator.indicatorID|strip_tags}-->_radio<!--{$ctr}-->" class="icheck<!--{$indicator.indicatorID|strip_tags}--> leaf_check" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|sanitize}-->" />
                    <span class="leaf_check"></span> <!--{$option|sanitize}--></label>
                <!--{/if}-->
                <!--{counter print=false}-->
            <!--{/foreach}-->
                </span>
                <script>
                <!--{if $indicator.required == 1}-->
                formRequired["id<!--{$indicator.indicatorID}-->"] = {
                    setRequired: function() {
                        return ($('.icheck<!--{$indicator.indicatorID|strip_tags}-->').is(':checked') == false);
                    },
                    setSubmitError: function() {
                        $([document.documentElement, document.body]).animate({
                            scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                        }, 700).clearQueue();
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                    },
                    setRequiredOk: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
                    }
                };
                <!--{/if}-->
                </script>
                <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'multiselect' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
                <span><select multiple id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" style="width: 80%">
            <!--{foreach from=$indicator.options item=option}-->
                <!--{assign var='found' value=false}-->
                <!--{foreach from=","|explode:$indicator.value item=val}-->
                    <!--{if $option|escape == $val|escape}-->
                        <option value="<!--{$option|sanitize}-->" selected="selected"><!--{$option|sanitize}--></option>
                        <!--{assign var='found' value=true}-->
                    <!--{/if}-->
                <!--{/foreach}-->
                <!--{if !$found}-->
                    <option value="<!--{$option|sanitize}-->"><!--{$option|sanitize}--></option>
                <!--{/if}-->
            <!--{/foreach}-->
                </select></span>
                <input type="hidden" id="<!--{$indicator.indicatorID|strip_tags}-->_selected" name="<!--{$indicator.indicatorID|strip_tags}-->_selected" value="" />
                <script>
                $(function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->').chosen({width: '80%'});
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_chosen .chosen-choices').css('border-radius', '6px');
                    // Hidden Value for array of items in _selected to export to POST
                    let hiddenValue = $('#<!--{$indicator.indicatorID|strip_tags}-->_chosen .chosen-choices')[0].innerText;
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_selected').val(hiddenValue.split("\n"));
                    // Change function for updating array on each selection or deselection
                    $('#<!--{$indicator.indicatorID|strip_tags}-->').on('change', function() {
                        setTimeout(function() {
                            hiddenValue = $('#<!--{$indicator.indicatorID|strip_tags}-->_chosen .chosen-choices')[0].innerText;
                            $('#<!--{$indicator.indicatorID|strip_tags}-->_selected').val(hiddenValue.split("\n"));
                        }, 500);
                    });
                });
                <!--{if $indicator.required == 1}-->
                formRequired["id<!--{$indicator.indicatorID}-->"] = {
                    setRequired: function() {
                        return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                    },
                    setSubmitError: function() {
                        $([document.documentElement, document.body]).animate({
                            scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                        }, 700).clearQueue();
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                    },
                    setRequiredOk: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
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
                formRequired["id<!--{$indicator.indicatorID}-->"] = {
                    setRequired: function() {
                        return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                    },
                    setSubmitError: function() {
                        $([document.documentElement, document.body]).animate({
                            scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                        }, 700).clearQueue();
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                    },
                    setRequiredOk: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
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
            formRequired["id<!--{$indicator.indicatorID}-->"] = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                },
                setSubmitError: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                    }, 700).clearQueue();
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                },
                setRequiredOk: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
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
            formValidator["id<!--{$indicator.indicatorID}-->"] = {
            	setValidator: function() {
                    return ($.isNumeric($('#<!--{$indicator.indicatorID|strip_tags}-->').val()) || $('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
            	},
                setSubmitValid: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_error').offset().top-50
                    }, 700).clearQueue();
                },
            	setValidatorError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->').css('border', '2px solid red');
                    if($('#<!--{$indicator.indicatorID|strip_tags}-->_error').css('display') != 'none') {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_error').show('fade');
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
            formRequired["id<!--{$indicator.indicatorID}-->"] = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                },
                setSubmitError: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                    }, 700).clearQueue();
                },
                setRequiredError: function() {
                	$('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                },
                setRequiredOk: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
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
                <input class="ui-helper-hidden-accessible" id="<!--{$indicator.indicatorID|strip_tags}-->_focusfix" type="text" />
                <span id="<!--{$indicator.indicatorID|strip_tags}-->_error" style="color: red; display: none">Incorrect Date</span>
            </span>
            <script>
            $(function() {
                $('#<!--{$indicator.indicatorID|strip_tags}-->').datepicker({
                    autoHide: true,
                    showAnim: "slideDown",
                    onSelect: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_focusfix').focus();
                    }
                });
            });
            formValidator["id<!--{$indicator.indicatorID}-->"] = {
                setValidator: function() {
                    let regex = new RegExp(/^(?:(?:(?:0?[13578]|1[02])(\/|-|\.)31)\1|(?:(?:0?[1,3-9]|1[0-2])(\/|-|\.)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:0?2(\/|-|\.)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:(?:0?[1-9])|(?:1[0-2]))(\/|-|\.)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/gm);
                    return (regex.test($('#<!--{$indicator.indicatorID|strip_tags}-->').val()) || $('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                },
                setSubmitValid: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_error').offset().top-50
                    }, 700).clearQueue();
                },
                setValidatorError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->').css('border', '2px solid red');
                    if($('#<!--{$indicator.indicatorID|strip_tags}-->_error').css('display') != 'none') {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_error').show('fade');
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
            formRequired["id<!--{$indicator.indicatorID}-->"] = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                },
                setSubmitError: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                    }, 700).clearQueue();
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                },
                setRequiredOk: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
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
                <span id="<!--{$indicator.indicatorID|strip_tags}-->_error" style="color: red; display: none">Value must be a valid currency</span>
            </span>
            <script type="text/javascript">
            formValidator["id<!--{$indicator.indicatorID}-->"] = {
                setValidator: function() {
                    let isValidValue = false;
                    let value = $('#<!--{$indicator.indicatorID|strip_tags}-->').val().trim();

                    if (value === ''){
                        isValidValue = true;
                    } else {
                        value = value.replace(/,/ig, '');
                        if (/^(\d*)(\.\d+)?$/.test(value)) {
                            let floatValue = parseFloat(value);
                            let strRoundTwoDecimals = (Math.round(100 * floatValue) / 100).toFixed(2);
                            $('#<!--{$indicator.indicatorID|strip_tags}-->').val(strRoundTwoDecimals);
                            isValidValue = ($.isNumeric($('#<!--{$indicator.indicatorID|strip_tags}-->').val()));
                        }
                    }
                    return isValidValue;
                },
                setSubmitValid: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_error').offset().top-50
                    }, 700).clearQueue();
                },
                setValidatorError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->').css('border', '2px solid red');
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_error').css('display', 'inline');
                },
                setValidatorOk: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->').css('border', '1px solid gray');
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_error').hide('fade');
                }
            };
            <!--{if $indicator.required == 1}-->
            formRequired["id<!--{$indicator.indicatorID}-->"] = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                },
                setSubmitError: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                    }, 700).clearQueue();
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                },
                setRequiredOk: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
                }
            };
            <!--{/if}-->
            </script>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'checkbox' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
                <span id="parentID_<!--{$indicator.parentID|strip_tags}-->">
                    <input type="hidden" name="<!--{$indicator.indicatorID|strip_tags}-->" value="no" />
            <!--{foreach from=$indicator.options item=option}-->
                <!--{if $option|escape == $indicator.value}-->
                    <label class="checkable leaf_check" for="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->">
                    <input type="checkbox" class="icheck<!--{$indicator.indicatorID|strip_tags}--> leaf_check" id="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|sanitize}-->" checked="checked" />
                    <span class="leaf_check"></span> <!--{$option|sanitize}--></label>
                <!--{else}-->
                    <label class="checkable leaf_check" for="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->">
                    <input type="checkbox" class="icheck<!--{$indicator.indicatorID|strip_tags}--> leaf_check" id="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$option|strip_tags}-->" />
                    <span class="leaf_check"></span> <!--{$option|sanitize}--></label>
                <!--{/if}-->
            <!--{/foreach}-->
                </span>
                <script>
                <!--{if $indicator.required == 1}-->
                formRequired["id<!--{$indicator.indicatorID}-->"] = {
                    setRequired: function() {
                        return ($('#<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->').prop('checked') == false);
                    },
                    setSubmitError: function() {
                        $([document.documentElement, document.body]).animate({
                            scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                        }, 700).clearQueue();
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                    },
                    setRequiredOk: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
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
                    <input type="hidden" name="<!--{$indicator.indicatorID|strip_tags}-->[<!--{$idx}-->]" value="no" />
                    <!--{if $option == $indicator.value[$idx]}-->
                        <label class="checkable leaf_check" for="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->">
                        <input type="checkbox" class="icheck<!--{$indicator.indicatorID|strip_tags}--> leaf_check" id="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->" name="<!--{$indicator.indicatorID|strip_tags}-->[<!--{$idx}-->]" value="<!--{$option|sanitize}-->" checked="checked" />
                        <span class="leaf_check"></span> <!--{$option|sanitize}--></label>
                    <!--{else}-->
                        <label class="checkable leaf_check" for="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->">
                        <input type="checkbox" class="icheck<!--{$indicator.indicatorID|strip_tags}--> leaf_check" id="<!--{$indicator.indicatorID|strip_tags}-->_<!--{$idx}-->" name="<!--{$indicator.indicatorID|strip_tags}-->[<!--{$idx}-->]" value="<!--{$option|sanitize}-->" />
                        <span class="leaf_check"></span> <!--{$option|sanitize}--></label>
                    <!--{/if}-->
                    <!--{assign var='idx' value=$idx+1}-->
            <!--{/foreach}-->
                </span>
                <script>
                <!--{if $indicator.required == 1}-->
                formRequired["id<!--{$indicator.indicatorID}-->"] = {
                    setRequired: function() {
                        var checkboxes = $('#parentID_<!--{$indicator.parentID|strip_tags}-->_indicatorID_<!--{$indicator.indicatorID|strip_tags}--> .icheck<!--{$indicator.indicatorID|strip_tags}-->');
                        var selectionMade = false;
                        for(var i=0; i <checkboxes.length; i++){
                            if($(checkboxes[i]).prop('checked')){
                                selectionMade = true;
                            }
                        }
                        return !selectionMade;
                    },
                    setSubmitError: function() {
                        $([document.documentElement, document.body]).animate({
                            scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                        }, 700).clearQueue();
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                    },
                    setRequiredOk: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
                    }
                };
                <!--{/if}-->
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
                    [ <button type="button" class="link" onclick="deleteFile_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_<!--{$counter}-->();">Delete</button> ]
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
                <button type="button" id="fileAdditional" class="buttonNorm" onclick="$('#fileIframe_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').css('display', 'inline'); $('#fileIframe_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').css('visibility', 'visible'); $('#fileAdditional').css('visibility', 'hidden')"><img src="../libs/dynicons/?img=document-open.svg&amp;w=32" /> Attach Additional File</button>
                <!--{else}-->
                    <iframe src="ajaxIframe.php?a=getuploadprompt&amp;recordID=<!--{$recordID|strip_tags}-->&amp;indicatorID=<!--{$indicator.indicatorID|strip_tags}-->&amp;series=<!--{$indicator.series|strip_tags}-->" frameborder="0" width="480px" height="100px"></iframe><br />
                <!--{/if}-->
                </span>
            </fieldset>
            <!--{if $indicator.required == 1}-->
            <script>
                formRequired["id<!--{$indicator.indicatorID}-->"] = {
                    setRequired: function() {
                        var oldFiles = $('[id*="file_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_"]:visible');
                        var iFrameDOM = $('.blockIndicator_<!--{$indicator.indicatorID|strip_tags}--> iframe').contents();
                        var newFiles = iFrameDOM.find('.newFile_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->');
                        
                        return oldFiles.length === 0 && newFiles.length === 0;
                    },
                    setSubmitError: function() {
                        $([document.documentElement, document.body]).animate({
                            scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                        }, 700).clearQueue();
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                    },
                    setRequiredOk: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
                    }
                };
            </script>
            <!--{/if}-->
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
                    [ <button type="button" class="link" onclick="deleteFile_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_<!--{$counter}-->();">Delete</button> ]
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
                <button type="button" id="fileAdditional" class="buttonNorm" onclick="$('#fileIframe_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').css('display', 'inline'); $('#fileIframe_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->').css('visibility', 'visible'); $('#fileAdditional').css('visibility', 'hidden')"><img src="../libs/dynicons/?img=document-open.svg&amp;w=32" /> Attach Additional File</button>
                <!--{else}-->
                    <iframe src="ajaxIframe.php?a=getimageuploadprompt&amp;recordID=<!--{$recordID|strip_tags}-->&amp;indicatorID=<!--{$indicator.indicatorID|strip_tags}-->&amp;series=<!--{$indicator.series|strip_tags}-->" frameborder="0" width="480px" height="100px"></iframe><br />
                <!--{/if}-->
                </span>
            </fieldset>
            <!--{if $indicator.required == 1}-->
            <script>
                formRequired["id<!--{$indicator.indicatorID}-->"] = {
                    setRequired: function() {
                        var oldFiles = $('[id*="file_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->_"]:visible');
                        var iFrameDOM = $('.blockIndicator_<!--{$indicator.indicatorID|strip_tags}--> iframe').contents();
                        var newFiles = iFrameDOM.find('.newFile_<!--{$recordID|strip_tags}-->_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->');
                        
                        return oldFiles.length === 0 && newFiles.length === 0;
                    },
                    setSubmitError: function() {
                        $([document.documentElement, document.body]).animate({
                            scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                        }, 700).clearQueue();
                    },
                    setRequiredError: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                    },
                    setRequiredOk: function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
                    }
                };
            </script>
            <!--{/if}-->
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
            <span id="<!--{$indicator.indicatorID|strip_tags}-->_error" style="color: red; display: none">Invalid Group</span>
            <script>
            formValidator["id<!--{$indicator.indicatorID}-->"] = {
                setValidator: function() {
                    return ($.isNumeric($('#<!--{$indicator.indicatorID|strip_tags}-->').val()) || $('#<!--{$indicator.indicatorID|strip_tags}-->').val() == '');
                },
                setSubmitValid: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_error').offset().top-50
                    }, 700).clearQueue();
                },
                setValidatorError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->').css('border', '2px solid red');
                    if($('#<!--{$indicator.indicatorID|strip_tags}-->_error').css('display') != 'none') {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->_error').show('fade');
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
            formRequired["id<!--{$indicator.indicatorID}-->"] = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val().trim() == '');
                },
                setSubmitError: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                    }, 700).clearQueue();
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                },
                setRequiredOk: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
                }
            };
            <!--{/if}-->
            $(function() {
                var grpSel;
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
                                $('#grpSel_<!--{$indicator.indicatorID|strip_tags}--> input.groupSelectorInput').val('group#'+grpSel.selection);
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
                        $('#grpSel_<!--{$indicator.indicatorID|strip_tags}--> input.groupSelectorInput').val('group#'+grpSel.selection);
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
                                $('#posSel_<!--{$indicator.indicatorID|strip_tags}--> input.positionSelectorInput').val('#'+posSel.selection);
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
                        $('#posSel_<!--{$indicator.indicatorID|strip_tags}--> input.positionSelectorInput').val('#'+posSel.selection);
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
            formRequired["id<!--{$indicator.indicatorID}-->"] = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val().trim() == '');
                },
                setSubmitError: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                    }, 700).clearQueue();
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                },
                setRequiredOk: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
                }
            };
            <!--{/if}-->
            </script>
            <!--{$indicator.html}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'orgchart_employee' && ($indicator.isMasked == 0 || $indicator.data == '')}-->
            <div id="loadingIndicator_<!--{$indicator.indicatorID}-->" style="color: red; font-weight: bold; font-size: 140%"></div>
            <div id="empSel_<!--{$indicator.indicatorID}-->"></div>
            <input id="<!--{$indicator.indicatorID|strip_tags}-->" name="<!--{$indicator.indicatorID|strip_tags}-->" value="<!--{$indicator.value|sanitize}-->" style="display: none"></input>

            <script>
            $(function() {
                if($('#<!--{$indicator.indicatorID|strip_tags}-->').val() != '') {
                    $('#btn_removeEmployee_<!--{$indicator.indicatorID}-->').css('display', 'inline');
                    $('#btn_removeEmployee_<!--{$indicator.indicatorID}-->').on('click', function() {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->').val('');
                        $('#empSel_<!--{$indicator.indicatorID}-->').css('display', 'none');
                    });
                }
                function importFromNational(empSel) {
                    if (empSel.selection === '') {
                        $('#<!--{$indicator.indicatorID|strip_tags}-->').val('');
                    } else {
                        $('#loadingIndicator_<!--{$indicator.indicatorID}-->').html('*** Loading... ***');

                        if(empSel.selectionData[empSel.selection] != undefined) {
                            var selectedUser = empSel.selectionData[empSel.selection];
                            var selectedUserName = selectedUser.userName;
                            //updates search field value when employee is selected.  Use double quotes to build username strings because some have apostrophes
                            $("#"+ empSel.prefixID+"input").val("userName:" + selectedUserName);
                            $.ajax({
                                type: 'POST',
                                url: "<!--{$orgchartPath}-->/api/employee/import/_" + selectedUserName,
                                data: {CSRFToken: '<!--{$CSRFToken}-->'},
                                success: function(res) {
                                    $('#<!--{$indicator.indicatorID|strip_tags}-->').val(res);
                                    $('#<!--{$indicator.indicatorID|strip_tags}-->').trigger('change');
                                    $('#loadingIndicator_<!--{$indicator.indicatorID}-->').html('');
                                }
                            });
                        }
                    }
                }

                function empSearchSuccess() {
                    var empSel = new nationalEmployeeSelector('empSel_<!--{$indicator.indicatorID|strip_tags}-->');
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
                    $.ajax({
                        type: 'GET',
                        url: '<!--{$orgchartPath}-->/api/employee/<!--{$indicator.value|strip_tags|escape|trim}-->'
                    })
                    .then(function(res) {
                        if(res.employee != undefined && res.employee.userName != '') {
                            var first = res.employee.firstName;
                            var last = res.employee.lastName;
                            var middle = res.employee.middleName;

                            var formatted = last + ", " + first + " " + middle;
                            var query = empSel.runSearchQuery("userName:" + res.employee.userName);
                            //here, updates search field value when modal is opened
                            $("#"+ empSel.prefixID+"input").val("userName:" + res.employee.userName);
                            query.done(function() {
                                empSel.select("<!--{$indicator.value|strip_tags|escape|trim}-->");
                            });
                        }
                    });
                    <!--{/if}-->
                }
                
                if(typeof nationalEmployeeSelector == 'undefined') {
                    $('head').append('<link type="text/css" rel="stylesheet" href="<!--{$orgchartPath}-->/css/employeeSelector.css" />');
                    $.ajax({
                        type: 'GET',
                        url: "<!--{$orgchartPath}-->/js/nationalEmployeeSelector.js",
                        dataType: 'script',
                        success: function() {
                            empSearchSuccess();
                        }
                    });
                }
                else {
                    empSearchSuccess();
                }
            });
            <!--{if $indicator.required == 1}-->
            formRequired["id<!--{$indicator.indicatorID}-->"] = {
                setRequired: function() {
                    return ($('#<!--{$indicator.indicatorID|strip_tags}-->').val().trim() == '');
                },
                setSubmitError: function() {
                    $([document.documentElement, document.body]).animate({
                        scrollTop: $('#<!--{$indicator.indicatorID|strip_tags}-->_required').offset().top
                    }, 700).clearQueue();
                },
                setRequiredError: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').addClass('input-required-error');
                },
                setRequiredOk: function() {
                    $('#<!--{$indicator.indicatorID|strip_tags}-->_required').removeClass('input-required-error');
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
