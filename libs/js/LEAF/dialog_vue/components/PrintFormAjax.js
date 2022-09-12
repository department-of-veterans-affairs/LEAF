import PrintSubindicators from './PrintSubindicators.js';
import FormEntryDisplay from './FormEntryDisplay.js';
import FormIndexListing from './FormIndexListing.js';

export default {
    data()  {
        return {
            formID: this.currentCategorySelection.categoryID,
            listItems: [],  //objects w indID, parID, newParID, sort, index
            formFlat: {},   //used to determine the number of indicators on the form (better way?)
            totalIndicators: null,
            sortValuesToUpdate: []   //used to update legacy sort values
        }
    },
    components: {
        PrintSubindicators,
        FormEntryDisplay,
        FormIndexListing
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'ajaxFormByCategoryID',
        'currSubformID',
        'selectNewCategory',
        'newQuestion',
        'currentCategorySelection',
    ],
    provide() {
        return {
            listItems: Vue.computed(() => this.listItems),
            addToListItemsArray: this.addToListItemsArray,
        }
    },
    computed: {
        formName() {
            return this.currentCategorySelection.categoryName || 'Untitled';
        },
        allListItemsAreAdded() {
            console.log( this.totalIndicators, this.listItems.length);
            return this.totalIndicators !== null && this.totalIndicators === this.listItems.length;
        },
    },
    beforeMount() {
        this.getFormIndicatorList().then(res => {
            this.formFlat = res;  //save this to get the parentID for the indicators
            this.totalIndicators = Object.keys(res).length;  //total to track updates
        });
    },
    methods: {
        addToListItemsArray(formNode, parentID, listIndex) {
            const { indicatorID, sort } = formNode;
            const item = { indicatorID, sort, parentID, listIndex }
            this.listItems = [...this.listItems, item];
            this.handleItemSortShouldUpdate(item);
        },
        //checks if the sort value is not the index, adds it to sortValuesToUpdate to update (true for old forms).
        handleItemSortShouldUpdate(listItem) {
            if(listItem.sort !== listItem.listIndex) {
                console.log('update the sort val to the index val for', listItem.indicatorID);
                console.log('from', listItem.sort, 'to', listItem.listIndex);
                this.sortValuesToUpdate = [...this.sortValuesToUpdate, listItem];
            }
        },
        getFormIndicatorList(){
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: `${this.APIroot}form/_${this.formID}/flat`,
                    success: (res) => resolve(res),
                    error: (err) => reject(err)
                });
            });
        }
    },
    watch: {
        allListItemsAreAdded(newVal, oldVal){
            console.log('watching');
            if(newVal===true) {
                if (this.sortValuesToUpdate.length > 0) {
                    //update legacy sort to from prev sort val to new index based value
                    let updateSort = [];
                    this.sortValuesToUpdate.forEach(item => {
                        updateSort.push(
                            $.ajax({
                                type: 'POST',
                                url: `${this.APIroot}formEditor/${item.indicatorID}/sort`,
                                data: {
                                    sort: item.listIndex,
                                    CSRFToken: this.CSRFToken
                                },
                                success: () => {},
                                error: err => console.log('ind sort post err', err)
                            })
                        );
                    });
                    Promise.all(updateSort).then((res)=> {
                        console.log('promise all:', updateSort, res);
                        if (res.length > 0) {
                            this.selectNewCategory(this.formID, this.currSubformID !== null);
                        }
                    });
                }
            }
        }
    }, //{{currentCategorySelection.categoryID}} {{currSubformID || 'n/a'}}
    template:`
    <div style="display:flex;">
        <!-- FORM INDEX DISPLAY -->
        <div id="form_index_display">
            <h3 style="margin: 0; margin-bottom: 0.5em; color: black;">{{ formName }}</h3>
            <ul v-if="ajaxFormByCategoryID.length > 0">
                <form-index-listing v-for="(formSection, i) in ajaxFormByCategoryID"
                    :depth=0
                    :formNode="formSection"
                    :index=i
                    :parentID=null
                    :key="'index_list_item_' + formSection.indicatorID">
                </form-index-listing>
            </ul>
        </div>

        <!-- FORM ENTRY DISPLAY -->
        <div style="display:flex; flex-direction: column; width: 100%; background-color: white; border: 1px solid black; min-width: 400px;">
            <template v-if="ajaxFormByCategoryID.length > 0">
                <template v-for="(formSection, i) in ajaxFormByCategoryID">
                    <div class="printformblock">
                        <print-subindicators 
                            :depth="0"
                            :formNode="formSection"
                            :index="i"
                            :key="formSection.indicatorID">
                        </print-subindicators>
                    </div>
                </template>
            </template>
            <div class="buttonNorm" role="button" tabindex="0" 
                @click="newQuestion(null)" @keypress.enter="newQuestion(null)"
                style="margin: 0 -1px -1px -1px">
                <img src="../../libs/dynicons/?img=list-add.svg&amp;w=16" alt="" title="Add Section Heading"/> Add Section Heading
            </div>
        </div>
    </div>`
}