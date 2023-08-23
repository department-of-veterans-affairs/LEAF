export default {
    name: 'history-dialog', //NOTE: this might potentially mv to common after FE modal refactor
    data() {
        return {
            divSaveCancelID: 'leaf-vue-dialog-cancel-save',
            page: 1,
            ajaxRes: ''
        }
    },
    props: {
        historyType: {
            type: String,
            required: true            
        },
        historyID: {
            type: [String, Number],
            required: true
        }
    },
    mounted() {
        document.getElementById(this.divSaveCancelID).style.display = 'none';
        this.getPage();
    },
    computed: {
        showNext() {
            return this.ajaxRes.indexOf('No history to show') === -1;
        },
        showPrev() {
            return this.page > 1;
        }
    },
    methods: {
        getNext() {
            this.page++;
            this.getPage();
        },
        getPrev() {
            this.page--;
            this.getPage();
        },
        async getPage() {
            try {
                const url = `ajaxIndex.php?a=gethistory&type=${this.historyType}&gethistoryslice=1&page=${this.page}&id=${this.historyID}`;
                const response = await fetch(url);
                this.ajaxRes = await response.text();
            }
            catch (error) {
                console.log('error getting history', error);
            }
        }
    },
    template:`<div>
        <div id="history-slice" v-html="ajaxRes" style="min-height: 100px; min-width: 300px;"></div>
        <div id="history-page-buttons" style="display: flex; justify-content: space-between;">
            <button v-if="showPrev" id="prev" type="button"
                class="btn-general"
                style="width: 125px;"
                @click="getPrev" title="get previous page">
                Previous page
            </button>
            <button v-if="showNext" id="next" type="button"
                class="btn-general"
                style="width: 125px; margin-left: auto;"
                @click="getNext" title="get next page">
                Next page
            </button>
        </div>
    </div>`
}