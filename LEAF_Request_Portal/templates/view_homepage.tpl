<div class="menu2" style="width: 315px; float: left">

<a href="?a=newform" role="button">
    <span class="menuButtonSmall" style="background-color: #2372b0; color: white">
        <img class="menuIconSmall" src="../libs/dynicons/?img=document-new.svg&amp;w=76" style="position: relative" />
        <span class="menuTextSmall" style="color: white">New Request</span><br />
        <span class="menuDescSmall" style="color: white">Start a new request</span>
    </span>
</a>

<!--{if $inbox_status == 0}-->
<a href="?a=inbox" role="button">
    <span class="menuButtonSmall" style="background-color: #c9c9c9">
        <img class="menuIconSmall" src="../libs/dynicons/?img=folder-open.svg&amp;w=76" style="position: relative" />
        <span class="menuTextSmall">Inbox</span><br />
        <span class="menuDescSmall">Your inbox is currently empty</span>
    </span>
</a>
<!--{else}-->
<a href="?a=inbox" role="button">
    <span class="menuButtonSmall" style="background-color: #b6ef6d">
        <img class="menuIconSmall" src="../libs/dynicons/?img=document-open.svg&amp;w=76" style="position: relative" />
        <span class="menuTextSmall">Inbox</span><br />
        <span class="menuDescSmall">Review and apply actions to active requests</span>
    </span>
</a>
<!--{/if}-->

<a href="?a=bookmarks" role="button">
    <span class="menuButtonSmall" style="background-color: #7eb2b3">
        <img class="menuIconSmall" src="../libs/dynicons/?img=bookmark.svg&amp;w=76" style="position: relative" />
        <span class="menuTextSmall">Bookmarks</span><br />
        <span class="menuDescSmall">View saved links to requests</span>
    </span>
</a>

<a href="?a=reports&v=3" role="button">
    <span class="menuButtonSmall" style="background-color: black">
        <img class="menuIconSmall" src="../libs/dynicons/?img=x-office-spreadsheet.svg&amp;w=76" style="position: relative" />
        <span class="menuTextSmall" style="color: white">Report Builder</span><br />
        <span class="menuDescSmall" style="color: white">Create custom reports</span>
    </span>
</a>

</div>

<!--{include file=$tpl_search is_service_chief=$is_service_chief is_admin=$is_admin empUID=$empUID userID=$userID}-->
