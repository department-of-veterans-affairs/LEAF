<div id="deleteConfirmation" style="width: 100%">
<div style="background-color: #9d0000; color: white; padding: 4px; font-weight: bold">Are you sure you want to delete this attachment?</div>
<div class="button" onclick="hideConfirmation()" style="float: left; padding: 8px; text-align: center; width: 200px"><img src="dynicons/?img=process-stop.svg&amp;w=32" style="vertical-align: middle" alt="" title="No" /> No</div>
<div class="button" onclick="confirmDelete()" style="float: left; padding: 8px; text-align: center; width: 200px"><img src="dynicons/?img=edit-delete.svg&amp;w=32" style="vertical-align: middle" alt="" title="Yes" /> Yes</div>
</div>
<script type="text/javascript">
/* <![CDATA[ */

function hideConfirmation() {
	$('#deleteConfirmation').css('visibility', 'hidden');
	$('#deleteConfirmation').css('display', 'none');
}

function confirmDelete() {
    $.ajax({
    	type: 'POST',
        url: "ajaxIndex.php?a=deleteattachment&categoryID=<!--{$categoryID|strip_tags|escape}-->",
        data: {categoryID: <!--{$categoryID|strip_tags|escape}-->,
        	      UID: <!--{$UID|strip_tags|escape}-->,
        	      indicatorID: <!--{$indicatorID|strip_tags|escape}-->,
        	      file: '<!--{$file}-->',
        	      CSRFToken: '<!--{$CSRFToken}-->'},
        success: function(response) {
            $('#deleteConfirmation').html('Attachment Deleted!');
        },
        cache: false
    });
}

$(function() {

});

/* ]]> */
</script>
