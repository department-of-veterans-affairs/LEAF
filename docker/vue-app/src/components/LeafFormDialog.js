export default {
    data() {
        return {
            scrollY: window.scrollY,
            initialTop: 15,
            modalElementID: 'leaf_dialog_content',
            modalBackgroundID: 'leaf-vue-dialog-background'
        }
    },
    props: {
        hasDevConsoleAccess: {
            type: Number,
            default: 0
        }
    },
    inject: [
        'dialogTitle', 
        'showFormDialog',
        'closeFormDialog',
        'formSaveFunction',
        'dialogButtonText'
    ],
    provide() {
        return {
            hasDevConsoleAccess: this.hasDevConsoleAccess
        }
    },
    mounted() {
        const elModal = document.getElementById(this.modalElementID);
        //this helps fix the modal background coverage (being a teleport element seems to affect this)
        const elBody = document.querySelector('body');
        const currBodyHeight = elBody.clientHeight;
        document.getElementById(this.modalBackgroundID).style.minHeight = currBodyHeight + 'px';
        this.makeDraggable(elModal);
    },
    methods: {
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
                let scrollbarWidth = 20;
                if (el.offsetTop < window.scrollY) {
                    el.style.top = window.scrollY + 'px';
                }
                if (el.offsetLeft < 0) {
                    el.style.left = 0 + 'px';
                }
                if (el.offsetLeft + el.clientWidth + scrollbarWidth > window.innerWidth) {  //extra space for scrollbar
                    el.style.left = (window.innerWidth - el.clientWidth - scrollbarWidth) + 'px';
                }
            }
            if (document.getElementById(this.modalElementID + "_drag_handle")) {
                document.getElementById(this.modalElementID + "_drag_handle").onmousedown = dragMouseDown;
            }
        }
    },
    template: `<Teleport to="body">
        <div v-if="showFormDialog" :id="showFormDialog ? 'leaf-vue-dialog-background' : ''">
            <div :id="modalElementID" class="leaf-vue-dialog" role="dialog" :style="{top: scrollY + initialTop + 'px'}">
                <div v-html="dialogTitle" :id="modalElementID + '_drag_handle'" class="leaf-vue-dialog-title"></div>
                <div tabindex=0 @click="closeFormDialog" @keypress.enter="closeFormDialog" id="leaf-vue-dialog-close">&#10005;</div>
                <div id="record">
                    <div role="document" style="position: relative;">
                        <main id="xhr" class="leaf-vue-dialog-content" role="main">
                            <slot name="dialog-content-slot"></slot>
                        </main>
                    </div>
                    <div id="leaf-vue-dialog-cancel-save">
                        <button style="width: 90px;"
                            id="button_save" class="btn-confirm" :title="dialogButtonText.confirm"
                            @click="formSaveFunction">
                            {{dialogButtonText.confirm}}
                        </button>
                        <button style="width: 90px;"
                            id="button_cancelchange" class="btn-general" :title="dialogButtonText.cancel"
                            @click="closeFormDialog">
                            {{dialogButtonText.cancel}}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </Teleport>`
}