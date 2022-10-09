export default {
    data() {
        return {
            name: this.cell?.name || 'No title',
            id: this.cell?.id || this.makeColumnID(),
            gridType: this.cell?.type || 'text',
            textareaDropOptions: this.cell?.options?.join('\n') || '',
        }
    },
    props: {
        cell: Object,
        column: Number
    },
    inject: [
        'gridJSON',
        'updateGridJSON'
    ],
    mounted() {
        console.log('mounted gridcell');
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
         * @param event
         */
        deleteColumn(event) {
            let column = event.currentTarget.closest('div.cell');
            let cellsParent = document.getElementById('gridcell_col_parent');
            let cells = Array.from(cellsParent.querySelectorAll('div.cell'));
            
            let colNumber = '';
            cells.forEach((c, i) => {
                if (c === column) { 
                    colNumber = i + 1;
                }
            })

            let numcells = cells.length;
            let focus;
            switch(numcells) {
                case 1:
                    alert('Cannot remove initial column.');
                    break;
                case 2:
                    column.remove();
                    numcells--;
                    focus = cells[0];
                    break;
                default: 
                    if(column.querySelector('[title="Move column right"]')===null){
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
         * @param event
         */
        moveRight(event) {
            let column = $(event.target).closest('div.cell');
            let nextColumn = column.next().find('[title="Move column right"]');
            
            column.insertAfter(column.next());
            if(nextColumn.length===0) {
                column.find('[title="Move column left"]').focus();
            } else {
                column.find('[title="Move column right"]').focus();
            }
            $('#tableStatus').attr('aria-label', 'Moved right to column ' + (parseInt($(column).index()) + 1) + ' of ' + column.parent().children().length);
            this.updateGridJSON();
        },
        /**
         * Purpose: Move Column Left
         * @param event
         */
        moveLeft(event) {
            let column = $(event.target).closest('div.cell');
            let nextColumn = column.prev().find('[title="Move column left"]');

            column.insertBefore(column.prev());
            setTimeout(()=> {  //need to clear stack
                if(nextColumn.length===0) {
                    column.find('[title="Move column right"]').focus();
                } else {
                    column.find('[title="Move column left"]').focus();
                }
            }, 0);
            $('#tableStatus').attr('aria-label', 'Moved left to column ' + (parseInt($(column).index()) + 1) + ' of ' + column.parent().children().length);
            this.updateGridJSON();
        },

    },
    template:`<div :id="id" class="cell">
        <img v-if="column!==1" role="button" tabindex="0"
            @click="moveLeft" @keypress.space.enter.prevent="moveLeft"
            src="../../libs/dynicons/?img=go-previous.svg&w=16" 
            title="Move column left" alt="Move column left" style="cursor: pointer" />
        <img v-if="column!==gridJSON.length" role="button" tabindex="0" 
            @click="moveRight"  @keypress.space.enter.prevent="moveRight" 
            src="../../libs/dynicons/?img=go-next.svg&w=16" 
            title="Move column right" alt="Move column right" style="cursor: pointer" /><br />
        <span class="columnNumber">
            <span>Column #{{column}}:</span>
            <img v-if="gridJSON.length !==1" role="button" tabindex="0"
            @click="deleteColumn" @keypress.space.enter.prevent="deleteColumn"
            src="../../libs/dynicons/?img=process-stop.svg&w=16" 
            title="Delete column" alt="Delete column" />
        </span>
        <label :for="'gridcell_title_' + id">Title:</label>
        <input type="text" v-model="name" :id="'gridcell_title_' + id" />
        <label :for="'gridcell_type_' + id">Type:</label>
        <select v-model="gridType" :id="'gridcell_type_' + id">
            <option value="text">Single line input</option>
            <option value="date">Date</option>
            <option value="dropdown">Drop Down</option>
            <option value="textarea">Multi-line text</option>
        </select>
        <span v-if="gridType==='dropdown'" class="dropdown">
            <label for="'gridcell_options_' + id">One option per line</label>
            <textarea :id="'gridcell_options_' + id" 
                v-model="textareaDropOptions"
                aria-label="Dropdown options, one option per line"
                style="width: 100%; height: 60px; resize:vertical">
            </textarea>
        </span>
    </div>`
}