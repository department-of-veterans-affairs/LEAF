export default {
    name: 'testview',
    inject: [
        'setCustom_page_select'
    ],
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.setCustom_page_select('testview')
        });
    },
    template: `<h3>Test View</h3>`
}