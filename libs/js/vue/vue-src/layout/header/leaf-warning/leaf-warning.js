//warning section with triangle
module.exports = {
    data(){
        return {
            leafSecure: this.$props.propSecure
        }
    },
    props: {
        propSecure: {
            type: String,
            required: true
        }
    },
    template:
        `<div v-if="leafSecure==='0'" id="leaf-warning">
            <div>
                <h3>Do not enter PHI/PII: this site is not yet secure</h3>
                <p><a href="../report.php?a=LEAF_start_leaf_secure_certification">Start certification process</a></p>
            </div>
            <div><i class="fas fa-exclamation-triangle fa-2x"></i></div>
        </div>`
}