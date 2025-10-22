<script>
    if(navigator.userAgent.indexOf("Trident") != -1) {
        $('#body').html('<h1>Please use Microsoft Edge or Google Chrome to access this site.</h1>');
    }
</script>
<style type="text/css" media="screen">
    @import "<!--{$app_js_path}-->/../css/dark_mode.css";
</style>
<div class="menu2" style="width: 315px; float: left">

<a href="?a=newform" role="button">
    <span class="menuButtonSmall NRBlue">
        <img class="menuIconSmall" src="dynicons/?img=document-new.svg&amp;w=76" style="position: relative" alt=""/>
        <span class="menuTextSmall" style="color: white">New Request</span><br />
        <span class="menuDescSmall" style="color: white">Start a new request</span>
    </span>
</a>

<!--{if $inbox_status == 0}-->
<a href="report.php?a=LEAF_Inbox" role="button">
    <span class="menuButtonSmall inboxGreen">
        <img class="menuIconSmall" src="dynicons/?img=folder-open.svg&amp;w=76" style="position: relative" alt=""/>
        <span class="menuTextSmall">Inbox</span><br />
        <span class="menuDescSmall">Your inbox is currently empty</span>
    </span>
</a>
<!--{else}-->
<a href="report.php?a=LEAF_Inbox" role="button">
    <span class="menuButtonSmall inboxGreen">
        <img class="menuIconSmall" src="dynicons/?img=document-open.svg&amp;w=76" style="position: relative" alt=""/>
        <span class="menuTextSmall">Inbox</span><br />
        <span class="menuDescSmall">Review and apply actions to active requests</span>
    </span>
</a>
<!--{/if}-->

<a href="?a=bookmarks" role="button">
    <span class="menuButtonSmall BMGreen">
        <img class="menuIconSmall" src="dynicons/?img=bookmark.svg&amp;w=76" style="position: relative" alt=""/>
        <span class="menuTextSmall">Bookmarks</span><br />
        <span class="menuDescSmall">View saved links to requests</span>
    </span>
</a>

<a href="?a=reports&v=3" role="button">
    <span class="menuButtonSmall RBBlack">
        <img class="menuIconSmall" src="dynicons/?img=x-office-spreadsheet.svg&amp;w=76" style="position: relative" alt=""/>
        <span class="menuTextSmall" style="color: white">Report Builder</span><br />
        <span class="menuDescSmall" style="color: white">Create custom reports</span>
    </span>
</a>

</div>

<!--{include file=$tpl_search is_service_chief=$is_service_chief is_admin=$is_admin empUID=$empUID userID=$userID}-->