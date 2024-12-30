<script>
// This should only be used as part of the normal LEAF Secure Certification process

$(function() {
	$.ajax({
    	type: 'POST',
        url: './api/form/new',
        data: {
            title: 'LEAF Secure Certification',
            service: '',
            priority: 0,
            numleaf_secure: 1,
            CSRFToken: '<!--{$CSRFToken}-->'
        }
    })
    .then(function(res) {
    	let recordID = parseFloat(res);
        if(!isNaN(recordID) && isFinite(recordID) && recordID != 0) {
            window.location = `index.php?a=view&recordID=${recordID}&masquerade=nonAdmin`;
        }
    });
});
    
</script>