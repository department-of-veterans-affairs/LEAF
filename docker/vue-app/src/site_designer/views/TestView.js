export default {
    name: 'testpage',
    inject: [
        'appIsGettingData',
        'setCustom_page_select'
    ],
    created() {
        this.setCustom_page_select('testpage');
    },
    template: `<div v-if="appIsGettingData" style="border: 2px solid black; text-align: center; 
        font-size: 24px; font-weight: bold; padding: 16px;">
        Loading... 
        <img src="../images/largespinner.gif" alt="loading..." />
    </div>
    <div v-else></div>`
}