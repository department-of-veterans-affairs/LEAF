module.exports = {
    props: {
        isRetracted: {
            type: Boolean,
            required: true
        }
    },
    computed: {
        buttonTitle(){
            return this.$props.isRetracted ? 'Display full header' : 'Minimize header';
        }
    },
    template: `<li role="button" id="header-toggle-button" :title="buttonTitle">
                <a href="#" @click.prevent="$emit('toggle-top-header')"><i :class="[isRetracted ? 'fas fa-angle-double-down': 'fas fa-angle-double-up']"></i></a>
               </li>`
}