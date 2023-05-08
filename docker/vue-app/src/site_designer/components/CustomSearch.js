export default {
    name: 'custom-search',
    data() {
        return {
            gridSearch: {}
        }
    },
    mounted() {
        console.log('mounted search');
    },
    template: `<section style="display: flex; flex-direction: column; width: fit-content;">
        <div id="searchContainer"></div>
        <button id="searchContainer_getMoreResults" class="buttonNorm" style="display: none; margin-left:auto;">Show more records</button>
    </section>`
}