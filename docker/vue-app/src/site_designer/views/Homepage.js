import CustomHomeMenu from "../components/CustomHomeMenu";
import CustomSearch from "../components/CustomSearch";

export default {
    name: 'homepage',
    components: {
        CustomHomeMenu,
        CustomSearch
    },
    template: `<div id="site_designer_hompage" style="display: flex; flex-wrap: wrap;">
        <custom-home-menu></custom-home-menu>
        <custom-search></custom-search>
    </div>`
}