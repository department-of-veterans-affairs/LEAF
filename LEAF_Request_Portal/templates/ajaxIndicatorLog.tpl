<script type="text/javascript" src="js/jsdiff.js"></script>
Log of modifications made to this field:<br /><br />
<table class="agenda">
    <thead>
        <tr>
        <th>Date/Author</th>
        <th>Data</th>
        </tr>
    </thead>
    <tbody>
{foreach from=$log item=indicator}
    <tr>
        <td>{$indicator.timestamp|date_format:"%A, %B %e, %Y"}<br /><b>{$indicator.name|sanitize}</b></td>
        <td>{$indicator.data|sanitize}</td>
    </tr>
{/foreach}
    </tbody>
</table>
