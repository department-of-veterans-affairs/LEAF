<div id="toolbar" class="toolbar_right toolbar noprint">
    <div id="tools" class="tools">Tools:<br />
    </div>
<!--
    <div id="category_list">Quick Links:<br />
    <!--{if $is_service_chief == true}-->
        <div><a href="?a=service_chief" style="text-decoration: none"><img src="dynicons/?img=accessories-text-editor.svg&amp;w=32" style="float: left; padding: 2px" alt="" title="Service Prioritization" /> Service Prioritization for Equipment/FTE</a></div>
    <!--{/if}-->
    <!--{if $ingroup_quadrad == true}-->
    <div><a href="?a=quadrad_equipment_review" style="text-decoration: none"><img src="dynicons/?img=utilities-system-monitor.svg&amp;w=32" style="float: left; padding: 2px" alt="" title="Quadrad Prioritization" /> Quadrad Equipment Prioritization</a></div>
    <div><a href="?a=quadrad_fte_review" style="text-decoration: none"><img src="dynicons/?img=system-users.svg&amp;w=32" style="float: left; padding: 2px" alt="" title="Quadrad Prioritization" /> Quadrad FTE Prioritization</a></div>
    <!--{/if}-->
    </div>
-->
</div>

<!--{foreach from=$bookmarks item=record}-->
<div id="bookmark_<!--{$record.recordID|strip_tags}-->" style="float: left; border: 1px solid black; margin: 8px; padding: 0px; background-color: <!--{$record.stepBgColor|strip_tags}-->; color: <!--{$record.stepFontColor|strip_tags}-->; width: 370px">
    <div style="float: left; cursor: pointer; background-color: black; font-size: 150%; font-weight: bold; color: white; padding: 8px; text-align: center" onclick="window.location='?a=printview&amp;recordID=<!--{$record.recordID|strip_tags}-->'">
        <!--{$record.recordID}--><br />
        <!--{if $record.actionIcon != ''}-->
        <img src="dynicons/?img=<!--{$record.actionIcon|strip_tags}-->&amp;w=32" alt="" title="<!--{$record.stepTitle|strip_tags}--> <!--{$record.actionTextPasttense|strip_tags}-->" />
        <!--{else}-->
        <img src="dynicons/?img=emblem-notice.svg&amp;w=32" alt="" title="<!--{$record.stepTitle|strip_tags}--> <!--{$record.actionTextPasttense|strip_tags}-->" />
        <!--{/if}-->
    </div>
    <div>
        <div style="background-color: #e0e0e0; font-weight: bold; border-bottom: 1px solid black; padding: 2px">
                        <span style="float: right; cursor: pointer"><img src="dynicons/?img=process-stop.svg&amp;w=16" alt="" title="Delete Bookmark" onclick="removeBookmark(<!--{$record.recordID|strip_tags}-->)"/></span>
                <span style="padding: 4px; font-size: 140%"><a href="?a=printview&amp;recordID=<!--{$record.recordID|strip_tags}-->" style="text-decoration: none"><!--{$record.title|truncate:25:"...":true|sanitize}--></a></span>
        </div>
        <div style="padding: 4px">
            <!--{if $record.submitted == 0}-->
                <!--{if $record.stepTitle != ''}-->
                    <span style="padding: 4px; font-weight: bold">Status:</span>
                    <!--{$record.lastStatus|sanitize}--><br /><br />
                <!--{/if}-->
                <span style="padding: 4px; font-weight: bold">This form is available for editing.
                </span>
            <!--{else if $record.stepTitle != ''}-->
                <span style="padding: 4px; font-weight: bold">Status:</span>
                <!--{$record.lastStatus|sanitize}-->
            <!--{else}-->
                <span style="padding: 4px">Request submitted, pending initial review</span>
                <!--{$record.lastStatus|sanitize}-->
            <!--{/if}-->
        </div>
    </div>
</div>
<!--{/foreach}-->

<!--{if count($bookmarks) == 0}-->
<br style="clear: both" />
<div style="width: 50%; margin: 0px auto; border: 1px solid black; padding: 16px; background-color: #fffcc9">
<img src="dynicons/?img=help-browser.svg&amp;w=96" alt="" style="float: left"/><span style="font-size: 200%"> You do not have any requests bookmarked!<br /><br />To bookmark a request, open a request and select "Add Bookmark".</span>
</div>
<!--{/if}-->

<script type="text/javascript">
/* <![CDATA[ */

function removeBookmark(recordID) {
	/*dojo.style('bookmark_' + recordID, 'opacity', '0.2');
    dojo.xhrPost({
        url: "ajaxIndex.php?a=removebookmark&recordID=" + recordID,
        content: {CSRFToken: '<!--{$CSRFToken}-->'},
        load: function(response, ioArgs) {
        },
        preventCache: true
    });*/
    $.ajax({
            type: "POST",
            url: "ajaxIndex.php?a=removebookmark&recordID=" + recordID,
            data: {CSRFToken: '<!--{$CSRFToken}-->'},
            success: function(response, ioArgs) {
             $(document).ajaxStop(function() { location.reload(true); });
        },
        cache: false
       });
}

//attempt to force a consistent width for the sidebar if there is enough desktop resolution
var lastScreenSize = null;
/*function sideBar() {
    console.log(dojo.body().clientWidth);
    if(lastScreenSize != dojo.body().clientWidth) {
        lastScreenSize = dojo.body().clientWidth;

        if(lastScreenSize < 700) {
            mainWidth = lastScreenSize * 0.97;
            dojo.removeClass("toolbar", "toolbar_right");
            dojo.addClass("toolbar", "toolbar_inline");
            dojo.style("toolbar", "width", "98%");
        }
        else {
            mainWidth = (lastScreenSize * 0.8) - 2;
            dojo.removeClass("toolbar", "toolbar_inline");
            dojo.addClass("toolbar", "toolbar_right");
            // effective width of toolbar becomes around 200px
            mywidth = Math.floor((1 - 200/lastScreenSize) * 100);
            dojo.style("toolbar", "width", 98-mywidth + "%");
        }
    }
}

dojo.addOnLoad(function() {
    sideBar();
    setInterval("sideBar()", 500);
});*/

/* ]]> */
</script>
