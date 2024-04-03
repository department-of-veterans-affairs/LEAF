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
        }
    },
    inject: [
        'dialogTitle', 
        'closeFormDialog',
        'formSaveFunction',
        'dialogButtonText',
        'lastModalTab'
    ],
    mounted() {
        this.elBody = document.querySelector('body');
        this.elModal = document.getElementById(this.modalElementID);
        this.elBackground = document.getElementById(this.modalBackgroundID);
        this.elClose = document.getElementById('leaf-vue-dialog-close');
        //helps adjust the modal background coverage
        const min = this.elModal.clientWidth > this.elBody.clientWidth ? this.elModal.clientWidth : this.elBody.clientWidth;
        this.elBackground.style.minHeight = 200 + this.elBody.clientHeight + 'px';
        this.elBackground.style.minWidth = min + 'px';

        this.makeDraggable(this.elModal);
        window.addEventListener('resize', this.checkSizes);
        const activeEl = document.activeElement;
        const closestLeafDialog = activeEl !== null ? activeEl.closest('.leaf-vue-dialog-content') : null;
        if(closestLeafDialog === null) {
            this.elClose.focus();
        }
    },
    beforeUnmount() {
        window.removeEventListener('resize', this.checkSizes);
    },
    methods: {
        checkSizes() {
            const min = this.elModal.clientWidth > this.elBody.clientWidth ? this.elModal.clientWidth : this.elBody.clientWidth;
            this.elBackground.style.minWidth = min + 'px';
            this.elBackground.style.minHeight = this.elModal.offsetTop + this.elBody.clientHeight + 'px';
        },
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
        <div id="leaf-vue-dialog-background">
            <div :id="modalElementID" class="leaf-vue-dialog" role="dialog" :style="{top: scrollY + initialTop + 'px'}">
                <div v-html="dialogTitle" :id="modalElementID + '_drag_handle'" class="leaf-vue-dialog-title"></div>
                <div tabindex=0 @click="closeFormDialog" @keypress.enter="closeFormDialog" @keydown.tab="firstTab" id="leaf-vue-dialog-close">&#10005;</div>
                <div id="record">
                    <div role="document" style="position: relative;">
                        <main id="xhr" class="leaf-vue-dialog-content" role="main">
                            <slot name="dialog-content-slot"></slot>
                        </main>
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
        </div>
    </Teleport>`
}