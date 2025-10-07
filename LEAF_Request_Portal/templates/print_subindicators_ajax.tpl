<!--{**}-->
        <!--{if $indicator.is_sensitive == 1}-->
            <div class="sensitiveIndicatorMaskToggle">
                <input type="checkbox" id="sensitiveIndicatorMaskCheckbox_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->" onClick="toggleStayVisible_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->(); toggleSensitiveIndicator(<!--{$indicator.indicatorID|strip_tags}-->, <!--{$indicator.series|strip_tags}-->, this.checked);">
                <label for="sensitiveIndicatorMaskCheckbox_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->" title="Show Sensitive Data" tabindex="0" onkeydown="if (event.keyCode==13){ this.click();}"></label>
            </div>
            <span class="sensitiveIndicator-masked" id="<!--{$indicator.indicatorID|strip_tags}-->_masked">
                **********
            </span>
            <script>
                var stayVisible_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}--> = false;
                $("#<!--{$indicator.indicatorID|strip_tags}-->_masked").on({
                    mouseenter: function () {
                        if (stayVisible_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}--> === false) {
                            $("#sensitiveIndicatorMaskCheckbox_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->").prop('checked', true);
                            toggleSensitiveIndicator(<!--{$indicator.indicatorID|strip_tags}-->, <!--{$indicator.series|strip_tags}-->, $("#sensitiveIndicatorMaskCheckbox_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->").prop('checked'));
                        }
                    }
                });
                $("#data_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->").on({
                    mouseleave: function () {
                        if (stayVisible_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}--> === false) {
                            $("#sensitiveIndicatorMaskCheckbox_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->").prop('checked', false);
                            toggleSensitiveIndicator(<!--{$indicator.indicatorID|strip_tags}-->, <!--{$indicator.series|strip_tags}-->, $("#sensitiveIndicatorMaskCheckbox_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->").prop('checked'));
                        }
                    }
                });

                function toggleStayVisible_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->() {
                    stayVisible_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}--> = !stayVisible_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->;
                }

            </script>
        <!--{/if}-->
        <!--{if $indicator.format == ''}-->
            <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'textarea'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{$indicator.value|replace:'  ':'&nbsp;&nbsp;'|sanitize}-->
            </span>
            <!--{$indicator.htmlPrint}-->
            <script>
                if(typeof enableUserContentLinks === 'function') {
                    const element = document.getElementById("data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->");
                    enableUserContentLinks(element);
                }
            </script>
        <!--{/if}-->
        <!--{if $indicator.format == 'radio'}-->
                <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{$indicator.value|sanitize}-->
                </span>
                <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'multiselect'}-->
                <span class="printResponse">
            <!--{assign var='idx' value=0}-->
            <ul>
            <!--{foreach from=$indicator.value item=option}-->
                    <input type="hidden" name="<!--{$indicator.indicatorID}-->[<!--{$idx}-->]" value="no" />
                    <!--{if $indicator.value[$idx] != 'no'}-->
                        <li><!--{$option|sanitize}--></li>
                    <!--{/if}-->
                    <!--{assign var='idx' value=$idx+1}-->
            <!--{/foreach}-->
            </ul>
                </span>
                <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'dropdown'}-->
                <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{$indicator.value|sanitize}-->
                </span>
                <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'text'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{$indicator.value|sanitize}-->
            </span>
            <!--{$indicator.htmlPrint}-->
            <script>
                if(typeof enableUserContentLinks === 'function') {
                    const element = document.getElementById("data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->");
                    enableUserContentLinks(element);
                }
            </script>
        <!--{/if}-->
        <!--{if $indicator.format == 'number'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{$indicator.value|sanitize}-->
            </span>
            <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'numberspinner'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{$indicator.value|sanitize}-->
            </span>
            <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'date'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{if $indicator.value != '' && $indicator.value != '[protected data]'}-->
                <!--{$indicator.value|date_format:"%A, %B %e, %Y"}-->
                <!--{/if}-->
            </span>
            <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'time'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{if $indicator.value != '' && $indicator.value != '[protected data]'}-->
                <!--{$indicator.value|date_format:"%l:%M %p"}-->
                <!--{/if}-->
            </span>
            <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'currency'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{if is_numeric($indicator.value)}-->
                    <!--{if $indicator.value < 0}-->-<!--{/if}-->$<!--{$indicator.value|abs|number_format:2:".":","}-->
                <!--{/if}-->
            </span>
            <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'checkbox'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                 <!--{$indicator.value|sanitize}-->
            </span>
            <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'checkboxes'}-->
                <span class="printResponse">
            <!--{assign var='idx' value=0}-->
            <ul style="list-style: none">
            <!--{foreach from=$indicator.value item=option}-->
                    <input type="hidden" name="<!--{$indicator.indicatorID}-->[<!--{$idx}-->]" value="no" />
                    <!--{if $indicator.value[$idx] != 'no' && $indicator.value[$idx] !== ''}-->
                        <li><img class="print" src="dynicons/?img=dialog-apply.svg&w=16" style="vertical-align: middle" alt="" />
                        <!--{$option|sanitize}--></li>
                    <!--{/if}-->
                    <!--{assign var='idx' value=$idx+1}-->
            <!--{/foreach}-->
            </ul>
                </span>
                <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'fileupload'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
            <!--{if $indicator.value[0] != ''}-->
            <!--{assign var='idx' value=0}-->
            <!--{foreach from=$indicator.value item=file}-->
            <a href="<!--{$portal_url}-->file.php?form=<!--{$recordID}-->&amp;id=<!--{$indicator.indicatorID}-->&amp;series=<!--{$indicator.series}-->&amp;file=<!--{$idx}-->" target="_blank" class="printResponse">
                <img src="dynicons/?img=mail-attachment.svg&amp;w=24" alt="" /><!--{$file}--></a><br />
            <!--{assign var='idx' value=$idx+1}-->
            <!--{/foreach}-->
            <!--{else}-->
            No files attached.
            <!--{/if}-->
            <br /><br />
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'image'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
            <!--{if $indicator.value[0] != ''}-->
            <!--{assign var='idx' value=0}-->
            <!--{foreach from=$indicator.value item=file}-->
                <!--{if $indicator.value != '[protected data]'}-->
                <img alt="image upload: <!--{$file}-->"
                    src="<!--{$portal_url}-->image.php?form=<!--{$recordID}-->&amp;id=<!--{$indicator.indicatorID}-->&amp;series=<!--{$indicator.series}-->&amp;file=<!--{$idx}-->"
                    style="max-width: 200px"
                    onclick="window.open('<!--{$portal_url}-->image.php?form=<!--{$recordID}-->&amp;id=<!--{$indicator.indicatorID}-->&amp;series=<!--{$indicator.series}-->&amp;file=<!--{$idx}-->', 'newName', 'width=550', 'height=550'); return false;" />
                <!--{assign var='idx' value=$idx+1}-->
                <!--{else}-->
                [protected data]
                <!--{/if}-->
            <!--{/foreach}-->
            <!--{else}-->
            No image available.
            <!--{/if}-->
            <br /><br />
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'orgchart_group'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
            <!--{if $indicator.value != ''}-->
                <!--{if $indicator.displayedValue != ''}-->
                    <!--{$indicator.displayedValue|sanitize}-->
                <!--{else}-->
                    Group #:<!--{$indicator.value|escape }--> not found<br>
                    Recorded on <!--{$indicator.timestamp|date_format}--> by <!--{$indicator.userID|escape}-->
                <!--{/if}-->
            <!--{else}-->
            Unassigned
            <!--{/if}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'orgchart_position'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
            <!--{if trim($indicator.value) != ''}-->
            <div style="padding: 0px">
            <script>
            $(function() {
                $.ajax({
                    type: 'GET',
                    url: '<!--{$orgchartPath}-->/api/position/<!--{$indicator.value|escape}-->',
                    dataType: 'json',
                    success: function(data) {
                        if(data.title != false) {
                            $('#data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->').append('<div style="border: 1px solid black" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->_pos">\
                                    <img src="dynicons/?img=preferences-system-windows.svg&w=32" alt="" style="float: left; padding: 4px" /><b>' + data.title + '</b><br />' + data[2].data + '-' + data[13].data + '-' + data[14].data + '</div>');
                            $('#data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->_pos').on('click', function() {
                                window.open('<!--{$orgchartPath}-->/?a=view_position&positionID=<!--{$indicator.value|escape}-->','Resource_Request','width=870,resizable=yes,scrollbars=yes,menubar=yes');
                            });
                            $('#data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->_pos').addClass('buttonNorm noprint');
                            $('#data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->_pos').css('margin-top', '8px');

                            if(data[3].data != '') {
                                for(i in data[3].data) {
                                    $('#data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->').append('<br />Position Description: <a class="printResponse" target="_blank" href="<!--{$orgchartPath}-->/file.php?categoryID=2&UID=<!--{$indicator.value}-->&indicatorID=3&file=' + encodeURIComponent(data[3].data[i]) +'">'+ data[3].data[i] +'</a>');
                                }
                            }
                        }
                        else {
                            $('#data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->').html(
                                `Position #:<!--{$indicator.value|escape}--> not found<br>
                                Recorded on <!--{$indicator.timestamp|date_format}--> by <!--{$indicator.userID|escape}-->`
                            );
                        }
                    }
                });
            });
            </script>
                <!--{if $indicator.displayedValue != ''}-->
                    <!--{$indicator.displayedValue|sanitize}-->
                <!--{else}-->
                Loading...
                <!--{/if}-->
            </div>
            <!--{else}-->
            Unassigned
            <!--{/if}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'orgchart_employee'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
            <!--{if trim($indicator.value) != ''}-->
            <div style="padding: 0px">
                <!--{if $indicator.displayedValue != ''}-->
                    <a href="<!--{$orgchartPath}-->/?a=view_employee&empUID=<!--{$indicator.value|escape}-->"><!--{$indicator.displayedValue|sanitize}--></a>
                <!--{else}-->
                    empUID #:<!--{$indicator.value|escape }--> (disabled account)<br>
                    Recorded on <!--{$indicator.timestamp|date_format}--> by <!--{$indicator.userID|escape}-->
                <!--{/if}-->
            </div>
            <!--{else}-->
            Unassigned
            <!--{/if}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'raw_data'}-->
            <textarea class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->" style="display: none"><!--{$indicator.value|sanitize}--></textarea>
            <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.is_sensitive == 1}-->
            <div style="clear:both;"></div>
        <!--{/if}-->
        <!--{if $indicator.format == 'grid' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
        <div class="printResponse" style="overflow-x: scroll; -ms-overflow-x: scroll;" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
            <table class="table" id="grid_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->_<!--{$recordID}-->_output" style="word-wrap:break-word; text-align: center;">
                <thead>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
        <script>
            // fix for IE scroll bar
            $('#xhrIndicator_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->').css('max-width', parseInt($('.printmainlabel').css('width')) * .85 + 'px');
            var gridInput_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}--> = new gridInput(<!--{$indicator.options[0]}-->, <!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->, <!--{$recordID}-->);
            $(function() {
                gridInput_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->.output(<!--{$indicator.value|json_encode}-->);
            })
        </script>
        <!--{/if}-->
        <!--{include file=$printSubindicatorsTemplate form=$indicator.child depth=$depth+4 recordID=$recordID}-->
