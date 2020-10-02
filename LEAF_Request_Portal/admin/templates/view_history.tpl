<div>
<!-- main content -->

    <span id="historyName">
        <!--{if $titleOverride != null}-->
            <!--{$titleOverride}-->
        <!--{else}-->
            <!--{$dataType}--> Name: <!--{$dataName|sanitize}-->
        <!--{/if}-->
    </span>

    <!--{if !is_null($dataID) }-->
        History of <!--{$dataType}--> ID : <!--{$dataID|sanitize}-->
    <!--{/if}-->

    <div>
        <!--{if count($history) == 0}-->
            No history to show!
        <!--{else}-->

            <table class="usa-table usa-table--borderless leaf-width100pct" id="maintable" style="width: 760px">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <!--{foreach from=$history item=log}--><!--{strip}-->

                <tr>
                    <td class="leaf-textLeft leaf-width25pct">
                        <!--{$log.timestamp}-->
                    </td>
                    <td class="leaf-width75pct">
                        <span><b><!--{$log.action|sanitize}--></b> by <!--{$log.userName|sanitize}--> <!--{$log.history|sanitize}--></span>
                    </td>
                </tr>


            <!--{/strip}--><!--{/foreach}-->
            </table>

        <!--{/if}-->

    </div>


</div>
<!-- close main content -->
