export default {
    inject: ['retracted', 'toggleHeader'],
    computed: {
        buttonTitle(){
            return this.retracted.refBool ? 'Display full header' : 'Minimize header';
        },
        faClass(){
            return this.retracted.refBool ? 'fas fa-angle-double-down': 'fas fa-angle-double-up';
        }
    },
    template: `<li id="header-toggle-button">
                <a role="button" :title="buttonTitle" href="#" @click.prevent="toggleHeader"><i :class="[faClass]"></i></a>
               </li>`
}