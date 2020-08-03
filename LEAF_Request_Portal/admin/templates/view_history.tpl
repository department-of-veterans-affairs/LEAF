
<div>
    <!-- main content -->
    <p><!--{$dataType}--> Name: <!--{$dataName|sanitize}--></p>

<div style="padding: 2px">
    <!--{if count($history) == 0}-->
        No history to show!
    <!--{else}-->
        <table class="agenda" id="maintable">
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
                <tbody>
                    <!--{foreach from=$history item=log}--><!--{strip}-->
                    <tr>
                        <td class="leaf-font0-8rem">
                            <!--{$log.timestamp|date_format:"%B %e, %Y. %l:%M %p"}-->
                        </td>
                        <td>
                            <span><b><!--{$log.action|sanitize}--></b> by <!--{$log.userName|sanitize}-->
                            <br /><!--{$log.history|sanitize}--></span>
                        </td>
                    </tr>
                    <!--{/strip}--><!--{/foreach}-->
                </tbody>
            </table>
        <!--{/if}-->

    </div>

</div><!-- close main content -->
