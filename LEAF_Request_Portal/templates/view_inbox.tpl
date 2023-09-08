The following is a list of requests that are pending your action:
<!--{if count($inbox) == 0}-->
<br /><br />
<div style="width: 50%; margin: 0px auto; border: 1px solid black; padding: 16px; background-color: white">
<img src="dynicons/?img=folder-open.svg&amp;w=96" alt="empty" style="float: left; padding-right: 16px"/><div style="font-size: 200%"> Your inbox is empty.<br /><br />Have a good day!</div>
</div>
<!--{/if}-->

<!--{if count($errors) > 0 && $errors[0].code == 1}-->
<br /><br />
<div style="width: 50%; margin: 0px auto; border: 1px solid black; padding: 16px; background-color: white">
<img src="dynicons/?img=folder-open.svg&amp;w=96" alt="empty" style="float: left; padding-right: 16px"/><div style="font-size: 200%">Warning: Inbox limit is in place to ensure consistent performance</div>
</div>
<!--{/if}-->

<div id="inbox">
<!--{if count($errors) == 0}-->
<!--{foreach from=$inbox item=dep}-->
<br /><br />
<table onKeypress="toggleDepVisibilityKeypress(event, '<!--{$dep.dependencyID|strip_tags}-->', '<!--{$CSRFToken}-->')" tabindex="0" id="depTitle_<!--{$dep.dependencyID}-->" class="agenda" style="width: 100%; margin: 0px auto">
    <div aria-live="assertive" id="depTitle_<!--{$dep.dependencyID}-->_announce"></div>
    <tr style="background-color: <!--{$dep.dependencyBgColor|strip_tags}-->; cursor: pointer"  onclick="toggleDepVisibility('<!--{$dep.dependencyID|strip_tags}-->', '<!--{$CSRFToken}-->')">
      <th colspan="3">
      <span style="float: left; font-size: 120%; font-weight: bold">
          <!--{if $dep.dependencyID > 0}-->
              <!--{$dep.dependencyDesc|sanitize}-->
          <!--{else}-->
              <!--{$dep.approverName|sanitize}-->
          <!--{/if}-->
      </span>
      <span style="float: right; text-decoration: underline; font-weight: bold"><span aria-label="Collapsed menu" id="depTitleAction_<!--{$dep.dependencyID|strip_tags}-->">View</span> <!--{$dep.count}--> requests</span>
    </th>
    </tr>
</table>
<div style="background-color: <!--{$dep.dependencyBgColor|strip_tags}-->">
        <div id="depContainerIndicator_<!--{$dep.dependencyID|strip_tags}-->" style="display: none; border: 1px solid black; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px">Loading...</div>
        <div id="depContainer_<!--{$dep.dependencyID|strip_tags}-->">
    </div>
</div>
<!--{/foreach}-->
<!--{/if}-->
</div>

<!-- DIALOG BOXES -->
<!--{include file="site_elements/generic_dialog.tpl"}-->
<!--{include file="site_elements/generic_OkDialog.tpl"}-->

<script type="text/javascript" src="js/functions/toggleZoom.js"></script>
<script type="text/javascript" src="<!--{$app_js_path}-->/LEAF/sensitiveIndicator.js"></script>
<script type="text/javascript" src="<!--{$app_js_path}-->/LEAF/inbox/view_inbox.js"></script>
<script>
    var CSRFToken = '<!--{$CSRFToken}-->';

    $(function() {
        dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
        dialog_ok = new dialogController('ok_xhrDialog', 'ok_xhr', 'ok_loadIndicator', 'confirm_button_ok', 'confirm_button_cancelchange');
        <!--{foreach from=$inbox item=dep}-->
        toggleDepVisibility('<!--{$dep.dependencyID|strip_tags}-->', 1, CSRFToken);
        <!--{/foreach}-->
    });
</script>
