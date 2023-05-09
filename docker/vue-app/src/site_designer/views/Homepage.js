import CustomHomeMenu from "../components/CustomHomeMenu";
import CustomSearch from "../components/CustomSearch";

export default {
    name: 'homepage',
    inject: [
        'isEditingMode'
    ],
    components: {
        CustomHomeMenu,
        CustomSearch
    },
    template: `<div id="site_designer_hompage"
        style="display: flex; flex-wrap: wrap;" :style="{backgroundColor: isEditingMode ? 'transparent' : 'white'}">
        <div id="custom_menu_wrapper" style="margin-bottom: 1rem;">
            <custom-home-menu></custom-home-menu>
        </div>
        <custom-search></custom-search>
    </div>`
}