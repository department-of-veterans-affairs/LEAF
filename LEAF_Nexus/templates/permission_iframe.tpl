<!--{foreach from=$privileges item=privilege}-->
    <!--{if $privilege.read == 0}-->
<div style="padding: 4px; color: red">
    <img src="dynicons/?img=emblem-readonly.svg&amp;w=32" alt="" style="vertical-align: middle" />
    No access to read this field.
    <!--{else}-->
<div style="padding: 4px; color: green" tabindex="0">
    <img src="dynicons/?img=edit-find.svg&amp;w=32" alt="" style="vertical-align: middle" />
    You have access to read this field.
    <!--{/if}-->
</div>
    <!--{if $privilege.write == 0}-->
<div style="padding: 4px; color: red" tabindex="0">
    <img src="dynicons/?img=emblem-readonly.svg&amp;w=32" alt="" style="vertical-align: middle" />
    No access to edit this field.
    <!--{else}-->
<div style="padding: 4px; color: green" tabindex="0">
    <img src="dynicons/?img=accessories-text-editor.svg&amp;w=32" alt="" style="vertical-align: middle" />
    You have access to edit this field.
    <!--{/if}-->
</div>
    <!--{if $privilege.grant == 0}-->
<div style="padding: 4px; color: red">
        <!--{if $privilege.read == 0}-->
        <img src="dynicons/?img=emblem-readonly.svg&amp;w=32" alt="" style="vertical-align: middle" />
        No access to edit permissions for this field.
        <!--{else}-->
        <div class="buttonNorm" onclick="window.open('index.php?a=view_permissions&amp;indicatorID=<!--{$indicatorID|strip_tags|escape}-->&amp;UID=<!--{$UID|strip_tags|escape}-->','Orgchart','width=840,resizable=yes,scrollbars=yes,menubar=yes').focus();">
        <img src="dynicons/?img=emblem-readonly.svg&amp;w=32" alt="" style="vertical-align: middle" />
        <u>View permissions for this field.</u></div>
        <!--{/if}-->
    <!--{else}-->
<div style="padding: 4px; color: green">
    <div onkeydown="triggerClick(event, this.id)" tabindex="0" id="editpermissions" class="buttonNorm" onclick="window.open('index.php?a=view_permissions&amp;indicatorID=<!--{$indicatorID|strip_tags|escape}-->&amp;UID=<!--{$UID|strip_tags|escape}-->','Orgchart','width=840,resizable=yes,scrollbars=yes,menubar=yes').focus();">
    <img src="dynicons/?img=emblem-system.svg&amp;w=32" alt="" style="vertical-align: middle" />
    You have access to <u>Edit Permissions</u> for this field.</div>
    <!--{/if}-->
</div>
<!--{/foreach}-->
<script>
    function triggerClick(e, id) {
        if(e.keyCode === 13) {
            document.getElementById(id).click();
        }
    }
</script>
