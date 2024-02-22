export default {
    name: 'history-dialog',
    data() {
        return {
            requiredDataProperties: ['historyType','historyID'],
            divSaveCancelID: 'leaf-vue-dialog-cancel-save',
            page: 1,
            historyType: this.dialogData.historyType,
            historyID: this.dialogData.historyID,
            ajaxRes: null
        }
    },
    inject: [
        'dialogData',
        'checkRequiredData',
        'lastModalTab'
    ],
    created() {
        this.checkRequiredData(this.requiredDataProperties);
    },
    mounted() {
        document.getElementById(this.divSaveCancelID).style.display = 'none';
        this.getPage();
    },
    computed: {
        showNext() {
            return this.ajaxRes === null ? false : this.ajaxRes.indexOf('No history to show') === -1;
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
        getPage() {
            try {
                const url = `ajaxIndex.php?a=gethistory&type=${this.historyType}&gethistoryslice=1&page=${this.page}&id=${this.historyID}`;
                fetch(url).then(res => {
                    res.text().then(txt => this.ajaxRes = txt);
                });
            }
            catch (error) {
                console.log('error getting history', error);
            }
        }
    },
    template:`<div>
        <div v-if="ajaxRes === null" class="page_loading">
            Loading...
            <img src="../images/largespinner.gif" alt="loading..." />
        </div>
        <div v-else id="history-slice" v-html="ajaxRes" style="min-height: 100px; min-width: 300px;"></div>
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
                @click="getNext" @keydown.tab="lastModalTab" title="get next page">
                Next page
            </button>
        </div>
    </div>`
}