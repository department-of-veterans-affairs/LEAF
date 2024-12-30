<div style="width: 450px">

<b>Tags are keywords used to help group requests together.<br /><br /></b>
<textarea id="taginput" name="taginput" dojoType="dijit.form.Textarea" maxlength="50">{foreach from=$tags item=tag}{$tag.tag|sanitize} {/foreach}</textarea>
<br /><br />
Notes:<br /><br />
- Tags are not required<br />
- Add a space between each tag<br />
- Tags may not contain spaces<br />
- Tags are not case sensitive<br />

</div>