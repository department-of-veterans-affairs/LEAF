A list of tags. Larger fontsize represents more requests.<br /><br />
<div style="text-align: center">
<!--{foreach from=$tags item=tag}-->
    <!--{if $tag.count/$total > 0.2}-->
        <!--{assign var='style' value='font-size: 42px; font-weight: bold'}-->
    <!--{elseif $tag.count/$total > 0.15}-->
        <!--{assign var='style' value='font-size: 36px'}-->
    <!--{elseif $tag.count/$total > 0.1}-->
        <!--{assign var='style' value='font-size: 32px'}-->
    <!--{elseif $tag.count/$total > 0.05}-->
        <!--{assign var='style' value='font-size: 24px'}-->
    <!--{else}-->
        <!--{assign var='style' value='font-size: 12px'}-->
    <!--{/if}-->

<span style="<!--{$style}-->"><a href="?a=gettagmembers&amp;tag=<!--{$tag.tag|escape:'hex'}-->"><!--{$tag.tag|escape:'html'}--></a></span>&nbsp;
<!--{/foreach}-->
</div>