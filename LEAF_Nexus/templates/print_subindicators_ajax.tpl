<!--{**}-->
        <!--{if $indicator.format == 'textarea'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid}-->">
                <!--{$indicator.data|sanitize}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'radio'}-->
                <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
            <!--{foreach from=$indicator.options item=option}-->
                <!--{if is_array($option)}-->
                    <!--{assign var='option' value=$option[0]}-->
                    <!--{if $option == $indicator.data}-->
                        <!--{$option|strip_tags|escape}-->
                    <!--{/if}-->
                <!--{elseif $option == $indicator.data}-->
                    <!--{$option|strip_tags|escape}-->
                <!--{/if}-->
            <!--{/foreach}-->
                </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'multiselect'}-->
                <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
            <!--{foreach from=$indicator.options item=option}-->
                <!--{if is_array($option)}-->
                    <!--{assign var='option' value=$option[0]}-->
                    <!--{if $option == $indicator.data}-->
                        <!--{$option|strip_tags|escape}-->
                    <!--{/if}-->
                <!--{elseif $option == $indicator.data}-->
                    <!--{$option|strip_tags|escape}-->
                <!--{/if}-->
            <!--{/foreach}-->
                </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'dropdown'}-->
                <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
            <!--{foreach from=$indicator.options item=option}-->
                <!--{if is_array($option)}-->
                    <!--{assign var='option' value=$option[0]}-->
                    <!--{if $option == $indicator.data}-->
                        <!--{$option|strip_tags|escape}-->
                    <!--{/if}-->
                <!--{elseif $option == $indicator.data}-->
                    <!--{$option|strip_tags|escape}-->
                <!--{/if}-->
            <!--{/foreach}-->
                </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'text'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
                <!--{$indicator.data|sanitize}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'number'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
                <!--{$indicator.data|strip_tags|escape}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'numberspinner'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
                <!--{$indicator.data|strip_tags|escape}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'date'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
                <!--{$indicator.data|strip_tags|escape|date_format:"%A, %B %e, %Y"}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'time'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
                <!--{$indicator.data|strip_tags|escape|date_format:"%l:%M %p"}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'currency'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
                <!--{if $indicator.data != 'NaN'}-->
                    $<!--{$indicator.data|strip_tags|escape|number_format:2:".":","}-->
                <!--{else}-->

                <!--{/if}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'checkbox'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
                 <!--{$indicator.data|strip_tags|escape}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'checkboxes'}-->
                <span id="parentID_{$indicator.parentID|strip_tags|escape}">
            <!--{assign var='idx' value=0}-->
            <!--{foreach from=$indicator.options item=option}-->
                    <input type="hidden" name="<!--{$indicator.indicatorID|strip_tags|escape}-->[<!--{$idx}-->]" value="no" /> <!-- dumb workaround -->
                    <!--{if $option == $indicator.data[$idx]}-->
                        <br /><img class="print" src="images/checkbox-yes.png" alt="checked" />
                        <!--{$option|strip_tags|escape}-->
                    <!--{else}-->
                        <br /><img class="print" src="images/checkbox-no.png" alt="not checked" />
                        <!--{$option|strip_tags|escape}-->
                    <!--{/if}-->
                    <!--{assign var='idx' value=$idx+1}-->
            <!--{/foreach}-->
                </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'fileupload'}-->
            <span class="printResponse" style="text-align: right" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
            <!--{if $indicator.data[0] != ''}-->
            <!--{foreach from=$indicator.data item=file}-->
            <a href="file.php?categoryID=<!--{$categoryID|strip_tags|escape}-->&amp;UID=<!--{$uid|strip_tags|escape}-->&amp;indicatorID=<!--{$indicator.indicatorID|strip_tags|escape}-->&amp;file=<!--{$file|urlencode}-->" target="_blank" class="printResponse" onclick="event.stopPropagation();"><img src="dynicons/?img=mail-attachment.svg&amp;w=16" alt="" /><!--{$file|strip_tags|escape}--></a>
            <!--{/foreach}-->
            <!--{else}-->
            No files attached.
            <!--{/if}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'image'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
            <!--{if $indicator.data != ''}-->
            <img alt="request image upload" src="image.php?categoryID=<!--{$categoryID|strip_tags|escape}-->&amp;UID=<!--{$uid|strip_tags|escape}-->&amp;indicatorID=<!--{$indicator.indicatorID|strip_tags|escape}-->" class="printResponse" style="max-width: 200px" />
            <!--{else}-->
            No image available.
            <!--{/if}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'position'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
            <!--{if $indicator.data != ''}-->
            <div dojoType="dijit.layout.ContentPane" style="padding: 0px">
            <script type="dojo/method">
                dojo.xhrGet({
                    url: "./api/position/" + <!--{$indicator.data|strip_tags|escape}-->,
                    handleAs: 'json',
                    load: function(response, args) {
                        dojo.byId('data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->').innerHTML = response.title;
                        return response;
                    },
                    preventCache: true
                });
            </script>
            Loading...
            </div>
            <!--{else}-->
            Unassigned
            <!--{/if}-->
            </span>
        <!--{/if}-->

        <!--{include file="print_subindicators.tpl" form=$indicator.child depth=$depth+4 recordID=$recordID}-->
