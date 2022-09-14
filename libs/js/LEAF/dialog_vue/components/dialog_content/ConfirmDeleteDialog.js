export default {
    data() {
        return {
            formID: this.currSubformID || this.currCategoryID,
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'currCategoryID',
        'currSubformID',
        'currentCategorySelection',
        'ajaxSelectedCategoryStapled',
        'selectNewCategory',
        'closeFormDialog'
    ],
    computed: {
        formName() {  //NOTE: global LEAF class
            return XSSHelpers.stripAllTags(this.currentCategorySelection.categoryName);
        },
        formDescription() {
            return XSSHelpers.stripAllTags(this.currentCategorySelection.categoryDescription);
        }
    },
    methods:{
        onSave() {
            if(this.ajaxSelectedCategoryStapled.length === 0) {
                
                $.ajax({
                    type: 'DELETE',
                    url: `${this.APIroot}formStack/_${this.formID}?` + $.param({CSRFToken:this.CSRFToken}),
                    success: (res) => {
                        if(res !== true) {
                            alert(res);
                        } else {
                            this.closeFormDialog();
                            this.selectNewCategory(null);
                        }
                    }
                });

            } else {
                alert('Please remove all stapled forms before deleting.')
            }
        }
    },
    template:`<div>
        <div>Are you sure you want to delete this form?</div>
        <div style="margin: 1em 0;"><b>{{formName}}</b></div>
        <div style="width:300px; height: 50px">{{formDescription}}</div>
        <div v-if="ajaxSelectedCategoryStapled.length > 0">⚠️ This form has stapled forms attached</div>
    </div>`
}