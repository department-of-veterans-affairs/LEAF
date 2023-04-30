<style>
    /* NOTE: temp template - can replace with vue app later */
    #bodyarea {
        margin: 1rem;
        font-size: 14px;
        font-family: Verdana, sans-serif;
    }
    ul#menu {
        list-style-type: none;
        margin: 0 1rem 1rem 0;
        padding: 0;
    }
    .custom_menu_card {
        /* TODO: some of these can be customizable */
        margin: 0.75rem 0;
        display: flex;
        align-items: center;
        width: 300px;
        padding: 0.4rem 0.5rem;
        text-decoration: none;
        box-shadow: 0 0 4px rgba(0,0,25,0.4);
        border: 2px solid transparent;
    }
    .custom_menu_card:first-child {
        margin-top: 0.25rem;
    }
    .custom_menu_card:hover, .custom_menu_card:focus,.custom_menu_card:active {
        border: 2px solid white;
    }
    .card_text {
        font-family: Verdana, sans-serif;
        display: flex;
        gap: 2px;
        flex-direction: column;
        justify-content: center;
        align-self: stretch;
        width: 100%;
        min-height: 55px;
    }
    div.LEAF_custom * {
        margin: 0;
        padding: 0;
        font-family: inherit;
        color: inherit; /* prevents override of color choices and interference w other styles*/
    }
    .icon_choice {
        cursor: auto;
        margin-right: 0.5rem;
        width: 50px;
        height: 50px;
    }

</style>

<main>
    <div style="display: flex; flex-wrap: wrap;">
        <div id="custom_menu_wrapper"></div>

        <!--{include file=$tpl_search is_service_chief=$is_service_chief is_admin=$is_admin empUID=$empUID userID=$userID}-->
    </div>
</main>

<script>
    const dyniconsPath = "../libs/dynicons/svg/";

    let menuItems = JSON.parse(<!--{$menuItems}--> || "[]");
    menuItems = menuItems.filter(item => +item.enabled === 1)
    menuItems = menuItems.sort((a,b) => a.order - b.order);
    //testing TODO: rework JSON to include and store menu direction
    const direction = '';//'horizontal';
    const directionAttr = direction === 'horizontal' ? 'style="display:flex; flex-wrap:wrap;" ' : '';
    //
    let buffer = `<ul ${directionAttr} id="menu">`;
    menuItems.forEach(item => {
        const title = XSSHelpers.stripTags(item.title, ['<script>']);
        const subtitle = XSSHelpers.stripTags(item.subtitle, ['<script>']);
        buffer += `<li><a href="${item.link}" target="_blank" style="background-color:${item.bgColor};" class="custom_menu_card">`
        if (item.icon !== '') {
            buffer += `<img v-if="menuItem.icon" src="${dyniconsPath}${item.icon}" alt="" class="icon_choice "/>`
        }
        buffer += `<div class="card_text">
            <div style="color:${item.titleColor}" class="LEAF_custom">${title}</div>
            <div style="color:${item.subtitleColor}" class="LEAF_custom">${subtitle}</div>
        </div></a></li>`
    });
    buffer += `</ul>`
    $('#custom_menu_wrapper').html(buffer);
        
</script>