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

            <table class="agenda usa-table" id="maintable">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Action Taken</th>
                    </tr>
                </thead>

                <!--{foreach from=$history item=log}--><!--{strip}-->

                <tr>
                    <td>
                        <!--{$log.timestamp}-->
                    </td>
                    <td>
                        <span><b><!--{$log.action|sanitize}--></b> by <!--{$log.userName|sanitize}-->
                        <br /><!--{$log.history|sanitize}--></span>
                    </td>
                </tr>


            <!--{/strip}--><!--{/foreach}-->
            </table>

        <!--{/if}-->

    </div>


</div>
<!-- close main content -->
