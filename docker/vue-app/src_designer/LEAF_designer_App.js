import { computed } from 'vue';

import ModHomeMenu from "./components/ModHomeMenu.js";

export default {
    data() {
        return {
            CSRFToken: CSRFToken,
            test: 'some test data'
        }
    },
    provide() {
        return {
            CSRFToken: computed(() => this.CSRFToken),
        }
    },
    components: {
        ModHomeMenu,
    }
}