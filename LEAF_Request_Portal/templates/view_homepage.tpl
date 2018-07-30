<div class="menu2" style="width: 315px; float: left">

<button onclick="location.href='?a=newform';"  href="" tabindex="-1" style="background: none; border: none; text-align: left;">
    <span class="menuButtonSmall" style="background-color: #2372b0; color: white" tabindex="0">
        <img class="menuIconSmall" src="../libs/dynicons/?img=document-new.svg&amp;w=76" style="position: relative"/>
        <span aria-disable="true" class="menuTextSmall" style="color: white">New Request</span><br />
        <span class="menuDescSmall" style="color: white">Start a new request</span>
    </span>
</button>

<!--{if $inbox_status == 0}-->
<button onclick="location.href='?a=inbox';" tabindex="-1" style="background: none; border: none; text-align: left;">
    <span class="menuButtonSmall" style="background-color: #c9c9c9" tabindex="0">
        <img class="menuIconSmall" src="../libs/dynicons/?img=folder-open.svg&amp;w=76" style="position: relative"/>
        <span aria-disable="true" class="menuTextSmall">Inbox</span><br />
        <span class="menuDescSmall">Your inbox is currently empty</span>
    </span>
</button>
<!--{else}-->
<button onclick="location.href='?a=inbox';" tabindex="-1" style="background: none; border: none; text-align: left;">
    <span class="menuButtonSmall" style="background-color: #b6ef6d" tabindex="0">
        <img class="menuIconSmall" src="../libs/dynicons/?img=document-open.svg&amp;w=76" style="position: relative"/>
        <span aria-disable="true" class="menuTextSmall">Inbox</span><br />
        <span class="menuDescSmall">Review and apply actions to active requests</span>
    </span>
</button>
<!--{/if}-->

<button onclick="location.href='?a=bookmarks';" tabindex="-1" style="background: none; border: none; text-align: left;">
    <span class="menuButtonSmall" style="background-color: #7eb2b3" tabindex="0">
        <img class="menuIconSmall" src="../libs/dynicons/?img=bookmark.svg&amp;w=76" style="position: relative"/>
        <span aria-disable="true" class="menuTextSmall">Bookmarks</span><br />
        <span class="menuDescSmall">View saved links to requests</span>
    </span>
</button>

<button onclick="location.href='?a=reports&v=3';" tabindex="-1" style="background: none; border: none; text-align: left;">
    <span class="menuButtonSmall" style="background-color: black" tabindex="0">
        <img class="menuIconSmall" src="../libs/dynicons/?img=x-office-spreadsheet.svg&amp;w=76" style="position: relative"/>
        <span aria-disable="true" class="menuTextSmall" style="color: white">Report Builder</span><br />
        <span class="menuDescSmall" style="color: white">Create custom reports</span>
    </span>
</button>

</div>

<!--{include file=$tpl_search is_service_chief=$is_service_chief is_admin=$is_admin empUID=$empUID userID=$userID}-->
