<style>
    .is-true: {
        color: #008817;
    }

    .is-false {
        color: #b50909;
    }
</style>

<div>
    <!-- main content -->

    <span id="historyName">
        <!--{if $titleOverride != null}-->
            <!--{$titleOverride}-->
        <!--{else}-->
            <!--{$dataType}--> Name:
            <!--{$dataName|sanitize}-->
        <!--{/if}-->
    </span>

    <!--{if !is_null($dataID) }-->
        History of
        <!--{$dataType}--> ID :
        <!--{$dataID|sanitize}-->
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

                <!--{foreach from=$history item=log}-->
                    <!--{strip}-->
                        <tr>
                            <td class="leaf-textLeft leaf-width30pct">
                                <!--{$log.timestamp|sanitize}-->
                            </td>
                            <td class="leaf-width70pct">
                                <span>
                                    <a style="color: #005ea2"
                                        href="<!--{$orgchartPath}-->/?a=view_employee&empUID=<!--{$log.userID}-->"
                                        target="_blank">
                                        <!--{$log.userName|sanitize}-->
                                    </a>
                                    &nbsp;
                                    <!--{if isset($log.targetEmpUID) && $log.targetEmpUID > 0}-->
                                        <!--{$log.history|sanitize|replace:$log.displayName:('<a style="color: #005ea2;" href="'|cat:$orgchartPath|cat:'/?a=view_employee&empUID='|cat:$log.targetEmpUID|cat:'" target="_blank">'|cat:$log.displayName|cat:'</a>')}-->
                                    <!--{else}-->
                                        <!--{$log.history|sanitize}-->
                                    <!--{/if}-->
                                </span>
                            </td>
                        </tr>
                    <!--{/strip}-->
                <!--{/foreach}-->
            </table>

        <!--{/if}-->

    </div>


</div>
<!-- close main content -->