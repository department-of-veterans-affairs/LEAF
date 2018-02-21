<!--{**}-->
        <!--{if $indicator.format == 'textarea'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tag|escape}-->_<!--{$uid}-->">
                <!--{$indicator.data}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'radio'}-->
                <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
            <!--{foreach from=$indicator.options item=option}-->
                <!--{if is_array($option)}-->
                    <!--{assign var='option' value=$option[0]}-->
                    <!--{if $option == $indicator.data}-->
                        <!--{$option}-->
                    <!--{/if}-->
                <!--{elseif $option == $indicator.data}-->
                    <!--{$option}-->
                <!--{/if}-->
            <!--{/foreach}-->
                </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'dropdown'}-->
                <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
            <!--{foreach from=$indicator.options item=option}-->
                <!--{if is_array($option)}-->
                    <!--{assign var='option' value=$option[0]}-->
                    <!--{if $option == $indicator.data}-->
                        <!--{$option}-->
                    <!--{/if}-->
                <!--{elseif $option == $indicator.data}-->
                    <!--{$option}-->
                <!--{/if}-->
            <!--{/foreach}-->
                </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'text'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid|strip_tags|escape}-->">
                <!--{$indicator.data|strip_tags}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'number'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
                <!--{$indicator.data|escape}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'numberspinner'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
                <!--{$indicator.data}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'date'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
                <!--{$indicator.data|date_format:"%A, %B %e, %Y"|strip|escape}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'time'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
                <!--{$indicator.data|date_format:"%l:%M %p"|strip|escape}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'currency'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
                <!--{if $indicator.data != 'NaN'}-->
                    $<!--{$indicator.data|number_format:2:".":","|strip|escape}-->
                <!--{else}-->

                <!--{/if}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'checkbox'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
                 <!--{$indicator.data}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'checkboxes'}-->
                <span id="parentID_{$indicator.parentID}">
            <!--{assign var='idx' value=0}-->
            <!--{foreach from=$indicator.options item=option}-->
                    <input type="hidden" name="<!--{$indicator.indicatorID}-->[<!--{$idx}-->]" value="no" /> <!-- dumb workaround -->
                    <!--{if $option == $indicator.data[$idx]}-->
                        <br /><img class="print" src="images/checkbox-yes.png" alt="checked" />
                        <!--{$option}-->
                    <!--{else}-->
                        <br /><img class="print" src="images/checkbox-no.png" alt="not checked" />
                        <!--{$option}-->
                    <!--{/if}-->
                    <!--{assign var='idx' value=$idx+1}-->
            <!--{/foreach}-->
                </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'fileupload'}-->
            <span class="printResponse" style="text-align: right" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
            <!--{if $indicator.data[0] != ''}-->
            <!--{foreach from=$indicator.data item=file}-->
            <a href="file.php?categoryID=<!--{$categoryID|strip_tags|escape}-->&amp;UID=<!--{$uid|escape}-->&amp;indicatorID=<!--{$indicator.indicatorID|strip_tags|escape}-->&amp;file=<!--{$file|urlencode|strip_tags|escape}-->" target="_blank" class="printResponse" onclick="event.stopPropagation();"><img src="../libs/dynicons/?img=mail-attachment.svg&amp;w=16" /><!--{$file}--></a>
            <!--{/foreach}-->
            <!--{else}-->
            No files attached.
            <!--{/if}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'image'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
            <!--{if $indicator.data != ''}-->
            <img src="image.php?categoryID=<!--{$categoryID}-->&amp;UID=<!--{$uid}-->&amp;indicatorID=<!--{$indicator.indicatorID}-->" class="printResponse" style="max-width: 200px" />
            <!--{else}-->
            No image available.
            <!--{/if}-->
            </span>
        <!--{/if}-->
        <!--{if $indicator.format == 'position'}-->
            <span class="printResponse" id="data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->">
            <!--{if $indicator.data != ''}-->
            <div dojoType="dijit.layout.ContentPane" style="padding: 0px">
            <script type="dojo/method">
                dojo.xhrGet({
                    url: "./api/?a=position/" + <!--{$indicator.data}-->,
                    handleAs: 'json',
                    load: function(response, args) {
                        dojo.byId('data_<!--{$indicator.indicatorID}-->_<!--{$categoryID}-->_<!--{$uid}-->').innerHTML = response.title;
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