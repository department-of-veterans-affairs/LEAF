<div class="loading-modal">
    <div class="loading-image">
        <div class="load-text"><!--{$title}--></div>
        <div class="load-cancel"><button id="load-cancel" type="button" class="usa-button usa-button--outline usa-button--inverse">Cancel</button></div>
    </div>
</div>

<script>
// loading spinner on each ajax request > 1 second
let loadTime;
$(document).ajaxStart(function() {
    loadTime = setTimeout(function() {$('#body').addClass("loading");}, 1000);
}).ajaxStop(function() {
    clearTimeout(loadTime);
    $('#body').removeClass("loading");
}).ready(function() {
    // loading cancel button
    $('#load-cancel').click(function () {
        $('#body').removeClass("loading");
    });
});
</script>