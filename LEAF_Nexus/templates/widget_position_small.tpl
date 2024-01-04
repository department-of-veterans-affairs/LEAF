<div class="positionSmall" onclick="selectPosition(<!--{$positionData['positionID']}-->)">
    <img class="positionPhoto" id="pPhoto_<!--{$positionData['positionID']|strip_tags|escape}-->" src="dynicons/?img=gnome-stock-person.svg&amp;w=64" alt="" title="photo" />
    <div class="positionSmall_title" title="<!--{$positionData['positionID']|strip_tags|escape}-->">
        <b><!--{$positionData['positionTitle']}--></b>
        <!--{if $positionData['empUID'] > 0}-->
            <br /><i><!--{$positionData['firstName']}--> <!--{$positionData['lastName']}--></i>
        <!--{else}-->
            <br /><i>VACANT POSITION</i>
        <!--{/if}-->
    </div>
    <div class="positionSmall_data" id="pData_<!--{$positionData['positionID']|strip_tags|escape}-->">
        <!--{$positionData['numberFTE']|strip_tags|escape}--> FTE
    </div>
</div>
