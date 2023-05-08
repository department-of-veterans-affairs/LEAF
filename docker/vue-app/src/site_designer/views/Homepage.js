import CustomHomeMenu from "../components/CustomHomeMenu";
import CustomSearch from "../components/CustomSearch";

export default {
    name: 'homepage',
    data() {
        return {
            templateName: 'homepage',
        }
    },
    inject: [
        'publishedStatus',
        'isPostingUpdate',
        'postEnableTemplate'
    ],
    components: {
        CustomHomeMenu,
        CustomSearch
    },
    template: `<div id="site_designer_hompage" style="display: flex; flex-wrap: wrap;">
        <div id="custom_menu_wrapper">
            <custom-home-menu></custom-home-menu>
            <hr style="margin: 2rem 0; border-bottom: 1px solid black;" />
            <h3 style="margin: 0.5rem 0;">{{templateName}} is {{ publishedStatus.homepage === true ? '' : 'not'}} enabled</h3>
            <button type="button" class="btn-confirm" @click="postEnableTemplate(templateName)" :disabled="isPostingUpdate">
                {{ publishedStatus.homepage === true ? 'Click to disable' : 'Click to enable'}}
            </button>
        </div>
        <custom-search></custom-search>
    </div>`
}