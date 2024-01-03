<span style="font-size: 150%; font-style: italic; font-weight: bold" id="version"></span>
<br /><br />
<span style="line-height: 140%">
This software was developed at the Washington D.C.<br />
VA Medical Center in an effort to improve resource<br />
requesting processes.
<br /><br />
<img src="dynicons/?img=internet-mail.svg&amp;w=16" alt="email icon" /> Developer Contact: <a href="mailto:Michael.Gao@va.gov&amp;subject=ERM:">Michael.Gao@va.gov</a>
</span>
<br /><br />

<table class="agenda">
    <tr>
        <td>Database version</td>
        <td><!--{$dbversion}--></td>
    </tr>
    <tr>
        <td>Server Timezone</td>
        <td><!--{date('T - e')}--></td>
    </tr>
    <tr>
        <td>Server Date</td>
        <td><!--{$smarty.now|date_format:"%A, %B %e, %Y"}--></td>
    </tr>
    <tr>
        <td>Server Time</td>
        <td><!--{$smarty.now|date_format:"%l:%M %p"}--></td>
    </tr>
</table>

<img style="position: absolute; bottom: 0px; right: 0px; width: 57%; z-index: -999" src="images/aboutlogo.png" alt="VA logo and Seal, U.S. Department of Veterans Affairs" />
<script type="text/javascript">
/* <![CDATA[ */

$(function() {
    $('#version').html($('#versionID').html());
});
/* ]]> */
</script>
