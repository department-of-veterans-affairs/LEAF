<a id=menuLink href="../{$orgchartPath}" target="_blank">
    <span class="menuButtonSmall" style="background-color: #ffecb7">
        <img class="menuIconSmall" src="../../libs/dynicons/?img=applications-internet.svg&amp;w=76" style="position: relative" alt="Org Chart" title="Org Chart" />
        <span class="menuTextSmall">LEAF Nexus</span><br />
        <span class="menuDescSmall">Org. Charts and Employee Information for your facility</span>
    </span>
</a>

<script>
    $('#menuLink').focusin(function() {
        $('.menuButtonSmall').css('box-shadow', '0 4px 6px 2px #8e8e8e').css('margin', '12px').css('outline', 'black dotted');
    }).focusout(function() {
        $('.menuButtonSmall').css('box-shadow', '0 0 0 0').css('margin', '0px').css('outline', 'none');
    });
</script>