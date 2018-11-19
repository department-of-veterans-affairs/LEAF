<!--{**}-->
        <!--{if $indicator.format == 'textarea'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{$indicator.value|replace:'  ':'&nbsp;&nbsp;'|sanitize}-->
            </span>
            <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'radio'}-->
                <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
                <!--{$indicator.value|sanitize}-->
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
                    $<!--{$indicator.value|number_format:2:".":","}-->
                <!--{else}-->

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
            <!--{foreach from=$indicator.value item=option}-->
                    <input type="hidden" name="<!--{$indicator.indicatorID}-->[<!--{$idx}-->]" value="no" /> <!-- dumb workaround -->
                    <!--{if $indicator.value[$idx] != 'no'}-->
                        <br /><img class="print" src="../libs/dynicons/?img=dialog-apply.svg&w=16" style="vertical-align: middle" alt="checked" />
                        <!--{$option|sanitize}-->
                    <!--{/if}-->
                    <!--{assign var='idx' value=$idx+1}-->
            <!--{/foreach}-->
                </span>
                <!--{$indicator.htmlPrint}-->
        <!--{/if}-->
        <!--{if $indicator.format == 'fileupload'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
            <!--{if $indicator.value[0] != ''}-->
            <!--{assign var='idx' value=0}-->
            <!--{foreach from=$indicator.value item=file}-->
            <a href="file.php?form=<!--{$recordID}-->&amp;id=<!--{$indicator.indicatorID}-->&amp;series=<!--{$indicator.series}-->&amp;file=<!--{$idx}-->" target="_blank" class="printResponse"><img src="../libs/dynicons/?img=mail-attachment.svg&amp;w=24" alt="file" /><!--{$file}--></a><br />
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
            <img src="image.php?form=<!--{$recordID}-->&amp;id=<!--{$indicator.indicatorID}-->&amp;series=<!--{$indicator.series}-->&amp;file=<!--{$idx}-->" style="max-width: 200px" />
            <!--{assign var='idx' value=$idx+1}-->
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
                    url: '<!--{$orgchartPath}-->/api/?a=position/<!--{$indicator.value|escape}-->',
                    dataType: 'json',
                    success: function(data) {
                        if(data.title != false) {
                            $('#data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->').append('<div style="border: 1px solid black" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->_pos">\
                                    <img src="../libs/dynicons/?img=preferences-system-windows.svg&w=32" alt="View Position Details" style="float: left; padding: 4px" /><b>' + data.title + '</b><br />' + data[2].data + '-' + data[13].data + '-' + data[14].data + '</div>');
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
                            $('#data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->').html('Position not found.');
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
                Loading...
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
        <!--{if $indicator.format == 'grid' && ($indicator.isMasked == 0 || $indicator.value == '')}-->
        <script type="text/javascript" src="js/gridInput.js"></script>
        <div class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
            <table class="table" id="grid_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->_output" style="word-wrap:break-word; text-align: center;">
                <thead>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
        <script>
            $(function() {
                printTableOutput(<!--{$indicator.options[0]}-->, <!--{$indicator.value|json_encode}-->, <!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->);
            })
        </script>
        <!--{/if}-->
        <!--{include file="print_subindicators.tpl" form=$indicator.child depth=$depth+4 recordID=$recordID}-->