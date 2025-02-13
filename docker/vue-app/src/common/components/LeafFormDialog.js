export default {
    data() {
        return {
            scrollY: window.scrollY,
            initialTop: 15,
            modalElementID: 'leaf_dialog_content',
            modalBackgroundID: 'leaf-vue-dialog-background',

            elBody: null,
            elModal: null,
            elBackground: null,
            elClose: null,
            lastFocus: null,
        }
    },
    inject: [
        'dialogTitle', 
        'closeFormDialog',
        'formSaveFunction',
        'dialogButtonText',
        'lastModalTab'
    ],
    created(){
        this.lastFocus = document.activeElement || null;
    },
    mounted() {
        this.elBody = document.querySelector('body');
        this.elModal = document.getElementById(this.modalElementID);
        this.elModal.style.left = window.scrollX + window.innerWidth/2 - this.elModal.clientWidth/2 + 'px';
        this.elBackground = document.getElementById(this.modalBackgroundID);
        this.elClose = document.getElementById('leaf-vue-dialog-close');

        this.makeDraggable(this.elModal);
        //if there is not already an active el in the modal, focus the close button
        const activeEl = document.activeElement;
        const closestLeafDialog = activeEl !== null ? activeEl.closest('.leaf-vue-dialog-content') : null;
        if(closestLeafDialog === null) {
            this.elClose.focus();
        }
    },
    beforeUnmount() {
        //refocus last item.  some events can cause a remount so try to select the el from its id first
        const lastID = this.lastFocus?.id || null;
        if(lastID !== null) {
            const lastEl = document.getElementById(lastID)
            if(lastEl !== null) {
                lastEl.focus();
            }
        } else if(this.lastFocus !== null) {
            this.lastFocus.focus();
        }
    },
    methods: {
        firstTab(event) {
            if (event?.shiftKey === true) {
                const modCancel = document.querySelector('#ifthen_deletion_dialog button.btn-general');
                const next = document.getElementById('next');
                const cancel = document.getElementById('button_cancelchange');
                const last = modCancel || next || cancel;
                if(last !== null && typeof last.focus === 'function') {
                    last.focus();
                    event.preventDefault();
                }
            }
        },
        /**
         * makes the modal draggable
         * @param {Object} el DOM element
         */
        makeDraggable(el = {}) {
            let pos1 = 0; let pos2 = 0; let mouseX = 0; let mouseY = 0;

            const elementDrag = (e) => {
                e = e || window.event;
                e.preventDefault();
                pos1 = mouseX - e.clientX;
                pos2 = mouseY - e.clientY;
                mouseX = e.clientX;
                mouseY = e.clientY;
                el.style.top = (el.offsetTop - pos2) + "px";
                el.style.left = (el.offsetLeft - pos1)  + "px";
                checkBounds();
            }
            const closeDragElement = () => {
                document.onmouseup = null;
                document.onmousemove = null;
            }
            const dragMouseDown = (e) => {
                e = e || window.event;
                e.preventDefault();
                mouseX = e.clientX;
                mouseY = e.clientY;
                document.onmouseup = closeDragElement;
                document.onmousemove = elementDrag;
            }
            const checkBounds = ()=> {
                let scrollbarWidth = 18;
                if (el.offsetTop < window.scrollY) {
                    el.style.top = window.scrollY + 'px';
                }
                if (el.offsetLeft < window.scrollX) {
                    el.style.left = window.scrollX + 'px';
                }
                if (el.offsetLeft + el.clientWidth + scrollbarWidth > window.innerWidth + window.scrollX) {
                    el.style.left = (window.innerWidth + window.scrollX - el.clientWidth - scrollbarWidth) + 'px';
                }
                this.elBackground.style.minWidth = this.elBody.clientWidth + 'px';
                this.elBackground.style.minHeight = this.elModal.offsetTop + this.elBody.clientHeight + 'px';
            }
            if (document.getElementById(this.modalElementID + "_drag_handle")) {
                document.getElementById(this.modalElementID + "_drag_handle").onmousedown = dragMouseDown;
            }
        }
    },
    template: `<Teleport to="body">
        <div id="leaf-vue-dialog-background" aria-disabled="true" aria-hidden="true"></div>
        <div :id="modalElementID" class="leaf-vue-dialog"
            role="dialog" aria-modal="true" :aria-labelledby="modalElementID + '_drag_handle'" aria-describedby="record"
            :style="{top: scrollY + initialTop + 'px'}">
            <div v-html="dialogTitle" :id="modalElementID + '_drag_handle'" class="leaf-vue-dialog-title"></div>
            <button type="button" @click="closeFormDialog" @keydown.tab="firstTab" id="leaf-vue-dialog-close" aria-label="Close">&#10005;</button>
            <div id="record" style="max-height:100vh;overflow-y:auto">
                <div id="xhr" class="leaf-vue-dialog-content">
                    <slot name="dialog-content-slot"></slot>
                </div>
                <div id="leaf-vue-dialog-cancel-save">
                    <button type="button" style="width: 90px;"
                        id="button_save" class="btn-confirm" :title="dialogButtonText.confirm"
                        @click="formSaveFunction">
                        {{dialogButtonText.confirm}}
                    </button>
                    <button type="button" style="width: 90px;"
                        id="button_cancelchange" class="btn-general" :title="dialogButtonText.cancel"
                        @click="closeFormDialog" @keydown.tab="lastModalTab">
                        {{dialogButtonText.cancel}}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>`
}