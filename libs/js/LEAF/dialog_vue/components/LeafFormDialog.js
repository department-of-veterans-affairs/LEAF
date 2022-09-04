export default {
	data() {
		return {
			scrollY: window.scrollY,
			initialTop: 15,
			modalElementID: 'leaf_xhrDialog2',  //NOTE: update
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
		'dialogFormContent',
		'showFormDialog',
		'closeFormDialog',
		'formSaveFunction'
	],
	provide() {
		return {
			hasDevConsoleAccess: this.hasDevConsoleAccess
		}
	},
	mounted() {
		const elModal = document.getElementById(this.modalElementID);
		const currModalHeight = elModal.clientHeight;
		document.getElementById(this.modalBackgroundID).style.minHeight = currModalHeight + window.innerHeight + 'px';
		this.makeDraggable(elModal);
	},
	methods: {
		makeDraggable(el) {
			const currWidth = el.clientWidth;
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
				if (el.offsetLeft + currWidth + scrollbarWidth > window.innerWidth) {  //extra space for scrollbar
					el.style.left = (window.innerWidth - currWidth - scrollbarWidth) + 'px';
				}
			}
			if (document.getElementById(this.modalElementID + "_drag_handle")) {
                document.getElementById(this.modalElementID + "_drag_handle").onmousedown = dragMouseDown;
            }
        }
	},
    template: `<Teleport to="body">
    <div v-if="showFormDialog || showGeneralDialog" :id="showFormDialog ? 'leaf-vue-dialog-background' : ''">
		<div :id="modalElementID" class="leaf-vue-dialog" role="dialog" 
			:style="{top: scrollY + initialTop + 'px'}">
			<div v-html="dialogTitle" :id="modalElementID + '_drag_handle'" class="leaf-vue-dialog-title"></div>
			<div tabindex=0 @click="closeFormDialog" @keypress.enter="closeFormDialog" id="leaf-vue-dialog-close">&#10005;</div>
			<div>
				<form id="record" action="javascript:void(0);">
					<div role="document" style="position: relative;">
						<div id="loadIndicator2" class="leaf-dialog-loader"></div>
						<main id="xhr2" class="leaf-vue-dialog-content" role="main">
							<slot name="dialog-content-slot"></slot>
						</main>
					</div>
					<div style="display:flex; justify-content: space-between; margin-top: 1em;">
						<button id="button_save" class="usa-button leaf-btn-med;"
							@click="formSaveFunction" @keypress.enter="formSaveFunction">
							Save
						</button>
						<button id="button_cancelchange" class="usa-button usa-button--outline leaf-btn-med" 
							@click="closeFormDialog" @keypress.enter="closeFormDialog">
							Cancel
						</button>
					</div>
				</form>
			</div>
		</div>
	</div>
</Teleport>`
};