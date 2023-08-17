export default {
    name: 'testpage',
    inject: [
        'appIsGettingData',
        'setCustom_page_select'
    ],
    created() {
        console.log('testpage created');
        this.setCustom_page_select('testpage');
    },
    template: `<div v-if="appIsGettingData" style="border: 2px solid black; text-align: center; 
        font-size: 24px; font-weight: bold; padding: 16px;">
        Loading... 
        <img src="../images/largespinner.gif" alt="loading..." />
    </div>
    <h3 v-else>Test View</h3>`
}