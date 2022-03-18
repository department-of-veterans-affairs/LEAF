<div id="LEAF_conditions_editor"></div>  <!-- vue mount -->

<script src="https://unpkg.com/vue@3"></script>
<script src="../js/vue_conditions_editor/LEAF_conditions_editor.js"></script>
<link rel="stylesheet" href="../js/vue_conditions_editor/LEAF_conditions_editor.css" />

<script>
    var CSRFToken = '<!--{$CSRFToken}-->';
    document.addEventListener('DOMContentLoaded', function () {
        ConditionsEditor.mount('#LEAF_conditions_editor');
    }, false);
</script>