export default {
    data() {
        return {
            divSaveCancelID: 'leaf-vue-dialog-cancel-save',
            page: 1,
            formID: this.currSubformID || this.currCategoryID,
            ajaxRes: ''
            
        }
    },
    inject: [
        'currSubformID',
        'currCategoryID'
    ],
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
        getPage(){
            $.ajax({
                type: 'GET',
                url: `ajaxIndex.php?a=gethistory&type=form&gethistoryslice=1&page=${this.page}&id=${this.formID}`,
                dataType: 'text',
                success: (res) => {
                    this.ajaxRes = res;
                },
                error: err => console.log(err),
                cache: false
            })
        }
    },
    template:`<div id="history-slice" v-html="ajaxRes" style="min-height: 100px; min-width: 300px;"></div>
        <div id="history-page-buttons" style="display: flex; justify-content: space-between;">
            <button v-if="showPrev" id="prev" 
                class="btn-general"
                style="width: 125px;"
                @click="getPrev" title="get previous page">
                Previous page
            </button>
            <button v-if="showNext" id="next" 
                class="btn-general"
                style="width: 125px; margin-left: auto;"
                @click="getNext" title="get next page">
                Next page
            </button>
        </div>`
}
