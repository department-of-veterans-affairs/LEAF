import { computed } from 'vue';

import LeafFormDialog from "@/common/components/LeafFormDialog.js";
import RestoreFieldOptionsDialog from "../components/dialog_content/RestoreFieldOptionsDialog.js";

export default {
    name: 'restore-fields-view',
    data() {
        return {
            disabledFields: null,
            headerSortTracking: {
                indicatorID: null,
                categoryName: null,
                name: null,
                format: null,
            },
            indicatorID_toRestore: null,
            disabledAncestors: [],
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

        'showFormDialog',
        'dialogFormContent'
    ],
    provide() {
        return {
            indicatorID_toRestore: computed(() => this.indicatorID_toRestore),
            disabledAncestors: computed(() => this.disabledAncestors),

            restoreField: this.restoreField,
            updateDisabledFields: this.updateDisabledFields,
        }
    },
    /**
     * get all disabled or archived indicators for indID > 0 and update app disabledFields (array)
     */
    created() {
        fetch(`${this.APIroot}form/indicator/list/disabled`)
        .then(res => res.json())
        .then(data => {
            this.disabledFields = data.filter(obj => +obj.indicatorID > 0);
        }).catch(err => console.log(err));
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.setDefaultAjaxResponseMessage();
        });
    },
    computed: {
        disabledFieldsParentIDLookup() {
            let lookup = {}
            let pID = null;

            this.disabledFields.forEach(f => {
                pID = f.parentIndicatorID;
                if (pID !== null) {
                    lookup[f.indicatorID] = pID;
                }
            });
            return lookup;
        },

        disabledFieldsLookup() {
            let lookup = {};
            this.disabledFields.forEach(f => lookup[f.indicatorID] = 1)
            return lookup;
        },
    },
    methods: {
        /**
         * Update indicatorID_toRestore and disabledAncestors component data
         * Restore if no disabled ancestors, otherwise use options modal
         * @param {number} indicatorID
         * @param {number} parentIndicatorID
         */
        restoreFieldGate(indicatorID, parentIndicatorID) {
            this.indicatorID_toRestore = indicatorID;
            this.disabledAncestors = this.getDisabledAncestors(parentIndicatorID);
            if(this.disabledAncestors.length === 0) {
                this.restoreField(indicatorID).then(() => this.updateDisabledFields(indicatorID));
            } else {
                this.openRestoreFieldOptionsDialog(indicatorID);
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
        updateDisabledFields(indicatorID = "") {
            let tableCell = document.getElementById(`restore_td_${indicatorID}`);
            if(tableCell !== null) {
                tableCell.innerHTML = `<b style="color:#064;">Field restored</b>`
            }
            setTimeout(() => {
                this.disabledFields = this.disabledFields.filter(f => f.indicatorID !== indicatorID);
            }, 750);
        },
        sortHeader(sortKey = "") {
            if(this.disabledFields.length > 1 && this.headerSortTracking?.[sortKey] !== undefined) {
                if(this.headerSortTracking[sortKey] === null) {
                    this.disabledFields = this.disabledFields.toSorted(
                        (a, b) => String(a[sortKey]).localeCompare(
                            String(b[sortKey]),
                            undefined,
                            {
                                numeric: sortKey === 'indicatorID',
                                sensitivity: 'base',
                            }
                        )
                    );
                    this.headerSortTracking[sortKey] = 0;
                } else {
                    const isAsc = this.headerSortTracking[sortKey] === 0;
                    this.headerSortTracking[sortKey] = isAsc ? 1 : 0;
                    this.disabledFields = this.disabledFields.toSorted(
                        (a, b) => (isAsc ? -1 : 1) * String(a[sortKey]).localeCompare(
                            String(b[sortKey]),
                            undefined,
                            {
                                numeric: sortKey === 'indicatorID',
                                sensitivity: 'base',
                            }
                        )
                    );
                }
                for (let k in this.headerSortTracking) {
                    if (k !== sortKey) {
                        this.headerSortTracking[k] = null;
                    }
                }
            }
        },
        //checks a field to be restored for disabled ancestors
        getDisabledAncestors(indicatorID = null) {
            let indIDs = [];
            if (this.disabledFieldsLookup[indicatorID] === 1) {
                indIDs.push(indicatorID);
            }
            let nextID = +this.disabledFieldsParentIDLookup[indicatorID];
            while(nextID > 0) {
                if (this.disabledFieldsLookup[nextID] === 1) {
                    indIDs.push(nextID);
                }
                nextID = this.disabledFieldsParentIDLookup[nextID];
            }
            return indIDs;
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

            <div v-if="disabledFields === null" class="page_loading">
                Loading...
                <img src="../images/largespinner.gif" alt="" />
            </div>
            <template v-else>
                <table v-if="disabledFields.length > 0">
                    <thead>
                        <tr>
                            <th>
                                <button type="button" @click="sortHeader('indicatorID')">
                                    indicatorID
                                    <span aria-hidden="true">
                                        {{ headerSortTracking.indicatorID === 0 ? "▲" :
                                           headerSortTracking.indicatorID === 1 ? "▼" : "" }}
                                    </span>
                                </button>
                            </th>
                            <th>
                                <button type="button" @click="sortHeader('categoryName')">
                                    Form
                                    <span aria-hidden="true">
                                        {{ headerSortTracking.categoryName === 0 ? "▲" :
                                           headerSortTracking.categoryName === 1 ? "▼" : "" }}
                                    </span>
                                </button>
                            </th>
                            <th>
                                <button type="button" @click="sortHeader('name')">
                                    Field Name
                                    <span aria-hidden="true">
                                        {{ headerSortTracking.name === 0 ? "▲" :
                                           headerSortTracking.name === 1 ? "▼" : "" }}
                                    </span>
                                </button>
                            </th>
                            <th>
                                <button type="button" @click="sortHeader('format')">
                                    Input Format
                                    <span aria-hidden="true">
                                        {{ headerSortTracking.format === 0 ? "▲" :
                                           headerSortTracking.format === 1 ? "▼" : "" }}
                                    </span>
                                </button>
                            </th>
                            <th>Status</th>
                            <th>Restore</th>
                        </tr>
                    </thead>
                    <tbody id="fields">
                        <tr v-for="f in disabledFields" :key="f.indicatorID">
                            <td>{{ f.indicatorID }}</td>
                            <td>{{ f.categoryName }}</td>
                            <td style="word-break:break-word;">{{ f.name }}</td>
                            <td>{{ f.format }}</td>
                            <td>{{ f.disabled }}</td>
                            <td :id="'restore_td_' + f.indicatorID"><button type="button" class="btn-general" style="margin:auto;"
                                @click="restoreFieldGate(+f.indicatorID, +f.parentIndicatorID)">
                                Restore this field</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <p v-else style="margin:1rem 0;">There are no disabled fields to restore.</p>
            </template>

            <!-- DIALOGS -->
            <leaf-form-dialog v-if="showFormDialog">
                <template #dialog-content-slot>
                    <component :is="dialogFormContent"></component>
                </template>
            </leaf-form-dialog>
        </section>`
}