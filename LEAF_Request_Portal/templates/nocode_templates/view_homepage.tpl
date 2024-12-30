<style>
    #no_code_home {
        margin: 1rem;
    }
    #custom_menu_wrapper {
        font-size: 14px;
        font-family: Verdana, sans-serif;
    }
    ul#menu {
        list-style-type: none;
        margin: 0 1rem 1rem 0;
        padding: 0;
    }
    ul#menu * { 
        box-sizing: border-box;
    }
    ul#menu > li {
        margin: 0.5rem 0;
        display: flex;
    }
    a.custom_menu_card {
        display: flex;
        align-items: center;
        width: 300px;
        min-height: 55px;
        padding: 6px 8px;
        text-decoration: none;
        border: 2px solid transparent;
        box-shadow: 0 0 6px rgba(0,0,25,0.3);
        transition: all 0.35s ease;
    }
    a.disableClick {
        pointer-events: none;
    }
    a.custom_menu_card:hover, a.custom_menu_card:focus, a.custom_menu_card:active {
        border: 2px solid white;
        box-shadow: 0 0 8px rgba(0,0,25,0.6);
        z-index: 10;
    }
    a.custom_menu_card h2 {
        margin: 0;
    }
    .card_text {
        font-family: Verdana, sans-serif;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-self: stretch;
        width: 100%;
        min-height: 55px;
    }
    .icon_choice {
        cursor: auto;
        margin-right: 0.5rem;
        width: 50px;
        height: 50px;
    }
</style>

<div>
    <div id="no_code_home" style="display: flex; flex-wrap: wrap;">
        <div id="custom_menu_wrapper"></div>
        <!--{include file=$tpl_search is_service_chief=$is_service_chief is_admin=$is_admin empUID=$empUID userID=$userID}-->
    </div>
</div>

<script>
    const dyniconsPath = "../libs/dynicons/svg/";
    const data = JSON.parse('<!--{$homeDesignJSON}-->');
    let menuItems = data?.menuCards || [];
    menuItems = menuItems.filter(item => +item?.enabled === 1);
    menuItems = menuItems.sort((a, b) => a.order - b.order);

    const direction = data?.direction || 'v';
    const directionAttr = direction === 'h' ?
        'style="display:flex; flex-wrap:wrap;" ' : 'style="display:flex; flex-direction: column;"';

    let buffer = `<ul ${directionAttr} id="menu">`;
    menuItems.forEach(item => {
        const title = XSSHelpers.stripAllTags(XSSHelpers.decodeHTMLEntities(item.title));
        const subtitle = XSSHelpers.stripAllTags(XSSHelpers.decodeHTMLEntities(item.subtitle));
        const link = XSSHelpers.stripAllTags(item.link).trim();
        const linkClasses = link === '' ? 'disableClick custom_menu_card' : 'custom_menu_card'
        buffer += `<li><a href="${link}" target="_blank" style="background-color:${item.bgColor};" class="${linkClasses}">`
        if (item.icon !== '') {
            buffer += `<img v-if="menuItem.icon" src="${dyniconsPath}${item.icon}" alt="" class="icon_choice "/>`
        }
        buffer += `<div class="card_text">
            <h2 style="color:${item.titleColor};">${title}</h2>
            <div style="color:${item.subtitleColor};">${subtitle}</div>
        </div></a></li>`
    });
    buffer += `</ul>`
    $('#custom_menu_wrapper').html(buffer);
</script>