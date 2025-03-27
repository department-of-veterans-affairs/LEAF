import { computed } from 'vue';

import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import RestoreFieldOptionsDialog from "../components/dialog_content/RestoreFieldOptionsDialog.js";

export default {
    name: 'restore-fields-view',
    data() {
        return {
            loading: true,
            formGrid: null,
            disabledFields: [],
            enabledFields: {},
            indicatorID_toRestore: null,
            disabledAncestors: [],
            firstOrphanID: null,
            searchPending: true
        }
    },
    components: {
        LeafFormDialog,
        RestoreFieldOptionsDialog,
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'setDefaultAjaxResponseMessage',
        'openRestoreFieldOptionsDialog',
        'decodeAndStripHTML',

        'showFormDialog',
        'dialogFormContent'
    ],
    provide() {
        return {
            indicatorID_toRestore: computed(() => this.indicatorID_toRestore),
            disabledAncestors: computed(() => this.disabledAncestors),
            firstOrphanID: computed(() => this.firstOrphanID),
            searchPending: computed(() => this.searchPending),

            restoreField: this.restoreField,
            updateAppData: this.updateAppData,
        }
    },
    /**
     * get all disabled or archived indicators for indID > 0 and update app disabledFields (array)
     */
    created() {
        //get information used for table for all non-builtin disabled fields.
        const disabledPromise = fetch(
            `${this.APIroot}form/indicator/list/disabled`)
            .then(res => res.json());

        //get other indicators to identify enabled fields (used to complete indicator: parent ID chain)
        const unabridgedPromise = fetch(
            `${this.APIroot}form/indicator/list/unabridged?x-filterData=indicatorID,parentIndicatorID,isDisabled`)
            .then(res => res.json());

        Promise.all([disabledPromise, unabridgedPromise]).then(data => {
            const resDisabled = data[0];
            const resUnabridged = data[1];
            let dFields = [];
            //set component data disabled fields array and enabled fields object
            resDisabled.map(obj => {
                if(+obj.indicatorID > 0) {
                    obj.name = this.decodeAndStripHTML(obj.name);
                    dFields.push(obj);
                }
            });
            this.disabledFields = dFields;

            const enabledFields = resUnabridged.filter(obj => +obj.indicatorID > 0 && +obj.isDisabled === 0);
            enabledFields.forEach(
                f => this.enabledFields[f.indicatorID] = { 
                    indicatorID: f.indicatorID,
                    parentIndicatorID: f.parentIndicatorID
                }
            );
            this.loading = false;
            this.initializeAppGrid();

        }).catch(err => console.log(err));
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.setDefaultAjaxResponseMessage();
        });
    },
    computed: {
        /* Lookup table of parentID information keyed by indicatorID */
        fieldParentIDLookup() {
            let lookup = {}
            let pID = null;

            this.disabledFields.forEach(f => {
                pID = f.parentIndicatorID;
                if (pID !== null) {
                    lookup[f.indicatorID] = pID;
                }
            });

            for(let indID in this.enabledFields) {
                pID = this.enabledFields[indID].parentIndicatorID;
                if (pID !== null) {
                    lookup[indID] = pID;
                }
            }
            return lookup;
        },
        /* Lookup table of disabled fields information keyed by indicator ID.  RecordID is added for grid use*/
        disabledFieldsLookup() {
            let lookup = {};
            this.disabledFields.forEach(f => lookup[f.indicatorID] = { ...f, recordID: f.indicatorID });
            return lookup;
        },
    },
    methods: {
        /**
         * Update indicatorID_toRestore and disabledAncestors component data
         * Restore if no disabled ancestors, otherwise use options modal
         * @param {number} indicatorID
         * @param {number|null} parentIndicatorID
         */
        restoreFieldGate(indicatorID, parentIndicatorID) {
            this.indicatorID_toRestore = indicatorID;
            this.searchAncestorStates(parentIndicatorID);

            if(this.searchPending === false && this.disabledAncestors.length === 0 && this.firstOrphanID === null) {
                this.restoreField(this.indicatorID_toRestore)
                    .then(() => this.updateAppData(indicatorID, 1250))
                    .catch(err => console.log(err));
            } else {
                this.openRestoreFieldOptionsDialog(this.indicatorID_toRestore);
            }
        },
        /**
         * 
         * @param {number} indicatorID
         * returns promise
         */
        restoreField(indicatorID) {
            let formData = new FormData();
            formData.append('CSRFToken', this.CSRFToken);
            formData.append('disabled', 0);

            return fetch(`${this.APIroot}formEditor/${indicatorID}/disabled`, {
                method: 'POST',
                body: formData
            });
        },
        /**
         * Used for edge-case of retrieving indicator information for prior orphaned questions
         * @param {number} indicatorID
         * @returns Promise
         */
        getIndicator(indicatorID) {
            return fetch(`${this.APIroot}formEditor/indicator/${indicatorID}?x-filterData=indicatorID,parentID`)
        },
        updateTableIfNoResults() {
            //force full file read first - default message would otherwise be added after this method runs.
            setTimeout(() => {
                let tBody = document.getElementById(this.formGrid.getPrefixID() + "tbody");
                if (this.disabledFields.length === 0 && tBody !== null) {
                    tBody.innerHTML = `<tr><td colspan="6" style="text-align: center">No Fields To Restore</td></tr>`;
                }
            });
        },
        /**
         *
         * @param {number} indicatorID for fields to be updated
         * @param {number} timeout time (ms) 'Restore' message is displayed in table
         */
        updateAppData(indicatorID = 0, timeout = 0) {
            if(indicatorID > 0) {
                this.disabledFields = this.disabledFields.filter(f => f.indicatorID !== indicatorID);
                this.enabledFields[indicatorID] = {
                    indicatorID,
                    parentIndicatorID: this.fieldParentIDLookup[indicatorID],
                };
                this.formGrid.setDataBlob(this.disabledFieldsLookup)

                const tableBodyID = this.formGrid.getPrefixID() + "tbody";
                const tableRowID = this.formGrid.getPrefixID() + "tbody_tr" + indicatorID;
                let tableBody = document.getElementById(tableBodyID);
                let tableRow = document.getElementById(tableRowID);
                if(tableBody !== null && tableRow !== null) {
                    tableRow.innerHTML = `<td colspan="6" style="text-align:center;">
                        <b style="color:#064;">Field restored</b>
                    </td>`;
                    setTimeout(() => {
                        tableBody.removeChild(tableRow);
                        this.updateTableIfNoResults();
                    }, timeout);
                }
            }
        },
        /**
         * Searches up the ancestor chain of the field to be restored. Adds inactive fields to app disabledAncestors array.
         * Updates app firstOrphanID if an orphan is found - attempts once to get information for it.
         * If successful, updates app enabledFields and reattempts ancestor search - otherwise ends search.
         * @param {number} directParentID
         */
        searchAncestorStates(directParentID = null) {
            this.disabledAncestors = [];
            this.firstOrphanID = null;
            
            let baseParent = null;
            if(directParentID !== null) {
                baseParent = directParentID;
                while(directParentID > 0) {
                    //if ancestor is confirmed inactive, add it and update variable
                    if (this.disabledFieldsLookup[directParentID]?.indicatorID > 0) {
                        this.disabledAncestors.push(this.disabledFieldsLookup[directParentID]);
                        directParentID = +this.fieldParentIDLookup[directParentID];

                    } else {
                        //if it's accounted for, just update the loop variable
                        if (this.enabledFields[directParentID]?.indicatorID > 0) {
                            directParentID = +this.fieldParentIDLookup[directParentID];
                        //otherwise, try to get the data (likely rare - occurs if an enabled q is a child of a deleted one)
                        } else {
                            this.firstOrphanID = directParentID;
                            directParentID = 0;
                        } 
                    }
                }

                if(this.firstOrphanID !== null) {
                    this.getIndicator(this.firstOrphanID)
                        .then(res => res.json()
                        .then(data => {
                            const indicator = data?.[this.firstOrphanID];
                            if(indicator?.indicatorID > 0) {
                                const { parentID:parentIndicatorID, indicatorID } = indicator;
                                this.enabledFields[indicatorID] = { indicatorID, parentIndicatorID };
                                //try again if indicator info could be found
                                this.searchAncestorStates(baseParent);

                            //set searching to false if: not found, on error, no orphan detection, first parent is page level.
                            } else {
                                this.searchPending = false;
                            }
                        }).catch(err => {
                            this.searchPending = false;
                            console.log(err)
                        })
                    );
                } else {
                    this.searchPending = false;
                }
            } else {
                this.searchPending = false;
            }
        },
        initializeAppGrid() {
            this.formGrid = new LeafFormGrid("restore_fields_grid", {});
            this.formGrid.setRootURL('../');
            this.formGrid.hideIndex();
            this.formGrid.enableToolbar();
            this.formGrid.setHeaders([
                {
                    name: 'IndicatorID&nbsp;',
                    indicatorID: 'indicatorID',
                    editable: false,
                    callback: (data, blob) => {
                        let elContainer = document.getElementById(data.cellContainerID);
                        if(elContainer !== null) {
                            elContainer.textContent = blob[data.recordID].indicatorID;
                        }
                    }
                },
                {
                    name: 'Form&nbsp;',
                    indicatorID:'categoryName',
                    editable: false,
                    callback: (data, blob) => {
                        let elContainer = document.getElementById(data.cellContainerID);
                        if(elContainer !== null) {
                            elContainer.textContent = blob[data.recordID].categoryName;
                        }
                    }
                },
                {
                    name: 'Field Name&nbsp;',
                    indicatorID:'name',
                    editable: false,
                    callback: (data, blob) => {
                        let elContainer = document.getElementById(data.cellContainerID);
                        if(elContainer !== null) {
                            elContainer.textContent = blob[data.recordID].name;
                        }
                    }
                },
                {
                    name: 'Input Format',
                    indicatorID:'fomrat',
                    editable: false,
                    callback: (data, blob) => {
                        let elContainer = document.getElementById(data.cellContainerID);
                        if(elContainer !== null) {
                            elContainer.textContent = blob[data.recordID].format;
                        }
                    }
                },
                {
                    name: 'Status ',
                    indicatorID:'disabled',
                    editable: false,
                    sortable: false,
                    callback: (data, blob) => {
                        let elContainer = document.getElementById(data.cellContainerID);
                        if(elContainer !== null) {
                            elContainer.textContent = blob[data.recordID].disabled;
                        }
                    }
                },
                {
                    name: 'Restore ',
                    indicatorID:'restore',
                    editable: false,
                    sortable: false,
                    callback: (data, blob) => {
                        let elContainer = document.getElementById(data.cellContainerID);
                        if(elContainer !== null) {
                            const ID = blob[data.recordID].indicatorID;
                            const pID = blob[data.recordID].parentIndicatorID;
                            elContainer.innerHTML = `
                                <button type="button" id="restore_indicator_${ID}"
                                    class="btn-general" style="margin: auto;">
                                    Restore this field
                                </button>`;
                            let elBtn = document.getElementById(`restore_indicator_${ID}`);
                            if(elBtn !== null) {
                                elBtn.addEventListener("click", () => this.restoreFieldGate(ID, pID));
                            }
                        }
                    }
                },
            ]);
            let arrHeaders = Array.from(document.querySelectorAll('table > thead > tr > th'));
            arrHeaders.forEach(h => {
                h.style.padding = "4px 8px";
                h.style.fontSize = "1rem";
                h.style.fontWeight = "bold";
            });

            this.formGrid.setDataBlob(this.disabledFieldsLookup);
            this.formGrid.renderBody();
            this.updateTableIfNoResults();
            this.formGrid.setPostSortRequestFunc(this.updateTableIfNoResults);
        }
    },
    template: `<section id="restore_fields_view">
            <h2 id="page_breadcrumbs">
                <a href="../admin" class="leaf-crumb-link" title="to Admin Home">Admin</a>
                <i class="fas fa-caret-right leaf-crumb-caret"></i>
                <router-link :to="{ name: 'browser' }" class="leaf-crumb-link" title="to Form Browser">Form Browser</router-link>
                <i class="fas fa-caret-right leaf-crumb-caret"></i>Restore Fields
            </h2>
            <h3>List of disabled fields available for recovery</h3>
            <div>Deleted fields and associated data will not display in the Report Builder.</div>
            <div v-if="loading === true" class="page_loading">
                Loading...
                <img src="../images/largespinner.gif" alt="" />
            </div>
            <div id="restore_fields_grid"></div> <!-- this won't work inside of else -->

            <!-- DIALOGS -->
            <leaf-form-dialog v-if="showFormDialog">
                <template #dialog-content-slot>
                    <component :is="dialogFormContent"></component>
                </template>
            </leaf-form-dialog>
        </section>`
}