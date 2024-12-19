<div class="groupSmall" onclick="switchGroup(<!--{$groupData['groupID']|strip_tags|escape}-->, '<!--{$groupData['groupTitle']|strip_tags|escape}-->')">
    <div class="groupSmall_title" title="<!--{$groupData['groupID']|strip_tags|escape}-->"><b><!--{$groupData['groupTitle']|strip_tags|escape}--></b></div>
    <div class="groupSmall_data">
        <!--{if $groupData['numSubgroups'] > 0}-->
            <b>##</b> Current FTE<br />
            <b>##</b> Total Authorized FTE<br />
            Includes <b><!--{$groupData['numSubgroups']}--></b> subgroups
        <!--{/if}-->
    </div>
</div>
