//scrolling warning banner
export default {
    data(){
        return {
            leafSecure: this.$props.propSecure
        }
    },
    props: {
        propSecure: {
            type: String,
            required: true,
        },
        bgColor: {
            type: String,
            required: false,
            default: 'rgb(250,75,50)'
        },
        textColor: {
            type: String,
            required: false,
            default: 'rgb(255,255,255)'
        }
    },
    template:
        `<p v-if="leafSecure==='0'" id="scrolling-leaf-warning" :style="{backgroundColor: bgColor, color: textColor}"><slot></slot></p>`
}