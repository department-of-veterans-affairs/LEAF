{literal}
    <style type="text/css">
        .card{
            display:inline-block;
            width: 85px;
            height: 85px;
            padding: 10px;
            vertical-align: middle;
        }
        
        .card-title{
            font-family: verdana;
            text-align: center;
            padding:5px 0px 5px 0 px;
            font-size: 10px;
        }
        
        .card-image{
            display:block;
            height: 50px;
            width:50px;
            margin:auto;
            -webkit-filter: grayscale(100%); /* Safari 6.0 - 9.0 */
            filter: grayscale(100%);    
        }
        
        a{
            text-decoration:none;
        }
    </style>
{/literal}


<div id="card-container">
    {foreach $carddata as $item}
        <div class="card">
            <a href="{$item.faqUrl}">
                <img src="{$item.imgUrl}" class="card-image"/>
                <div class="card-title">
                    {$item.title}
                </div>
            </a>
        </div>
    {/foreach}
</div>
