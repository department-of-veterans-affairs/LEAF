export default {
    name: 'grid-cell',
    data() {
        return {
            name: this.cell?.name || 'No title',
            id: this.cell?.id || this.makeColumnID(),
            gridType: this.cell?.type || 'text',
            textareaDropOptions: this.cell?.options ? this.cell.options.join('\n') : [],
            file: this.cell?.file || "",
            hasHeader: this.cell?.hasHeader || false
        }
    },
    props: {
        cell: Object,
        column: Number
    },
    inject: [
        'libsPath',
        'gridJSON',
        'updateGridJSON',
        'fileManagerTextFiles'
    ],
    mounted() {
        /**
         * adds the first column to a new grid format indicator
         */
        if(this.gridJSON.length === 0) {
            this.updateGridJSON();
        }
    },
    computed: {
        gridJSONlength() {
            return this.gridJSON.length;
        }
    },
    methods: {
        /**
         * Purpose: Generates Unique ID to track columns to update user input with grid format
         * @returns {string}
         */
        makeColumnID() {
            return "col_" + (((1 + Math.random())*0x10000)|0).toString(16).substring(1);
        },
        /**
         * Purpose: Delete a column from Grid
         * @param {Object} event DOM event
         */
        deleteColumn(event = {}) {
            let column = event.currentTarget.closest('div.cell');
            const cellsParent = document.getElementById('gridcell_col_parent');
            const cells = Array.from(cellsParent.querySelectorAll('div.cell'));
            
            const colNumber = cells.indexOf(column) + 1;
            let numcells = cells.length;
            let focus;
            switch(numcells) {
                case 2:
                    column.remove();
                    numcells--;
                    focus = cells[0];
                    break;
                default: 
                    if(column.querySelector('[title="Move column right"]') === null){
                        focus = column.previousElementSibling.querySelector('[title="Delete column"]');
                    } else {
                        focus = column.nextElementSibling.querySelector('[title="Delete column"]');
                    }
                    column.remove();
                    numcells--;
                    break;
            } 
            document.getElementById('tableStatus').setAttribute('aria-label', `column ${colNumber} removed, ${numcells} total.`);
            focus.focus();
            this.updateGridJSON(); 
        },
        /**
         * Purpose: Move Column Right
         * @param {Object} event DOM event
         */
        moveRight(event = {}) {
            let column = event.currentTarget.closest('div.cell');
            const nextColumnRight = column.nextElementSibling;
            const nextColumnRightImg = column.nextElementSibling.querySelector('[title="Move column right"]');
            
            nextColumnRight.after(column);
            setTimeout(()=> {  //clear stack
                column.querySelector(`[title="Move column ${nextColumnRightImg === null ? 'left' : 'right'}"]`)?.focus();
            }, 0);
            document.getElementById('tableStatus').setAttribute('aria-label', `Moved right to column ${this.column + 1} of ${this.gridJSONlength}`);
            this.updateGridJSON();
        },
        /**
         * Purpose: Move Column Left
         * @param {Object} event DOM event
         */
        moveLeft(event = {}) {
            let column = event.currentTarget.closest('div.cell');
            const nextColumnLeft = column.previousElementSibling;
            const nextColumnLeftImg = column.previousElementSibling.querySelector('[title="Move column left"]');

            nextColumnLeft.before(column);
            setTimeout(()=> {  //clear stack
                column.querySelector(`[title="Move column ${nextColumnLeftImg === null ? 'right' : 'left'}"]`)?.focus();
            }, 0);
            document.getElementById('tableStatus').setAttribute('aria-label', `Moved left to column ${this.column - 1} of ${this.gridJSONlength}`);
            this.updateGridJSON();
        },

    },
    watch: {
        /**
         * updates aria when a grid column is added when editing grid format indicators
         * @param {number} newVal 
         * @param {number} oldVal 
         */
        gridJSONlength(newVal, oldVal) {
            if (newVal > oldVal) {
                document.getElementById('tableStatus').setAttribute('aria-label', `Added a new column, ${this.gridJSONlength} total.`);
            }
        }
    },
    template:`<div :id="id" class="cell">
        <img v-if="column !== 1" role="button" tabindex="0"
            @click="moveLeft" @keypress.space.enter.prevent="moveLeft"
            :src="libsPath + 'dynicons/svg/go-previous.svg'" style="width: 16px; cursor: pointer"
            title="Move column left" alt="Move column left"  />
        <img v-if="column !== gridJSON.length" role="button" tabindex="0" 
            @click="moveRight"  @keypress.space.enter.prevent="moveRight" 
            :src="libsPath + 'dynicons/svg/go-next.svg'" style="width: 16px; cursor: pointer"
            title="Move column right" alt="Move column right" /><br />
        <span class="columnNumber">
            <span>Column #{{column}}:</span>
            <img v-if="gridJSON.length !== 1" role="button" tabindex="0"
            @click="deleteColumn" @keypress.space.enter.prevent="deleteColumn"
            :src="libsPath + 'dynicons/svg/process-stop.svg'" style="width: 16px; cursor: pointer"
            title="Delete column" alt="Delete column" />
        </span>
        <label :for="'gridcell_title_' + id">Title:</label>
        <input type="text" v-model="name" :id="'gridcell_title_' + id" />
        <label :for="'gridcell_type_' + id">Type:</label>
        <select v-model="gridType" :id="'gridcell_type_' + id">
            <option value="text">Single line input</option>
            <option value="date">Date</option>
            <option value="dropdown">Drop Down</option>
            <option value="dropdown_file">Dropdown From File</option>
            <option value="textarea">Multi-line text</option>
        </select>
        <div v-show="gridType === 'dropdown'">
            <label for="'gridcell_options_' + id">One option per line</label>
            <textarea :id="'gridcell_options_' + id" 
                v-model="textareaDropOptions"
                aria-label="Dropdown options, one option per line"
                style="width: 100%; height: 60px; resize:vertical">
            </textarea>
        </div>
        <div v-show="gridType === 'dropdown_file'">
            <label :for="'dropdown_file_select_' + id">File (csv or txt format)</label>
            <select :id="'dropdown_file_select_' + id" v-model="file">
                <option value="">Select a File</option>
                <option v-for="f in fileManagerTextFiles" :key="'file_' + f" :value="f">{{f}}</option>
            </select>
            <label :for="'dropdown_file_header_select_' + id">Does file contain headers</label>
            <select :id="'dropdown_file_header_select_' + id" v-model="hasHeader">
                <option :value="false">No</option>
                <option :value="true">Yes</option>
            </select>
        </div>
    </div>`
}