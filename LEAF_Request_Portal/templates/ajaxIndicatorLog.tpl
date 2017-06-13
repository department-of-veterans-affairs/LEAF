<script type="text/javascript" src="js/jsdiff.js"></script>
Log of modifications made to this field:<br /><br />
<table class="agenda">
    <thead>
        <tr>
        <td>Date/Author</td>
        <td>Data</td>
        </tr>
    </thead>
    <tbody>
{foreach from=$log item=indicator}
    <tr>
        <td>{$indicator.timestamp|date_format:"%A, %B %e, %Y"}<br /><b>{$indicator.name}</b></td>
        <td>{$indicator.data}</td>
    </tr>
{/foreach}
    </tbody>
</table>