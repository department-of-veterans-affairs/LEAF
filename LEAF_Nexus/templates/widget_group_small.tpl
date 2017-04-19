<div class="groupSmall" onclick="switchGroup(<!--{$groupData['groupID']}-->, '<!--{$groupData['groupTitle']}-->')">
    <div class="groupSmall_title" title="<!--{$groupData['groupID']}-->"><b><!--{$groupData['groupTitle']}--></b></div>
    <div class="groupSmall_data">
        <!--{if $groupData['numSubgroups'] > 0}-->
            <b>##</b> Current FTE<br />
            <b>##</b> Total Authorized FTE<br />
            Includes <b><!--{$groupData['numSubgroups']}--></b> subgroups
        <!--{/if}-->
    </div>
</div>