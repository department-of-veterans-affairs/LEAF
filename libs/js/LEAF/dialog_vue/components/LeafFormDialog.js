export default {
	data() {
		return {
			scrollY: window.scrollY,
			initialTop: 15,
			elementID: 'leaf_xhrDialog2'
		}
	},
	inject: [
		'dialogTitle', 
		'dialogFormContent',
		'closeFormDialog',
		'formSaveFunction'
	],
	mounted() {
		this.makeDraggable(document.getElementById(this.elementID));
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
				if (this.scrollY !== null) this.scrollY = null;
                e = e || window.event;
                e.preventDefault();
                mouseX = e.clientX;
                mouseY = e.clientY;
                document.onmouseup = closeDragElement;
                document.onmousemove = elementDrag;
            }
			const checkBounds = ()=> {
				let pX = parseInt(el.style.left);
				let pY = parseInt(el.style.top);
				let scrollbarWidth = 20;

				if (pY < window.scrollY) {
					el.style.top = window.scrollY + 'px';
				}
				if (pX < 0) {
					el.style.left = 0 + 'px';
				}
				if (pX + currWidth + scrollbarWidth> window.innerWidth) {  //extra space for scrollbar
					el.style.left = (window.innerWidth - currWidth - scrollbarWidth) + 'px';
				}
			}
			if (document.getElementById(this.elementID + "_drag_handle")) {
                document.getElementById(this.elementID + "_drag_handle").onmousedown = dragMouseDown;
            }
        }
	},
    template: `<div :id="elementID" class="leaf-vue-dialog" role="dialog" 
			:style="{marginTop: scrollY !== null ? scrollY + initialTop + 'px' : ''}">
			<div v-html="dialogTitle" :id="elementID + '_drag_handle'" class="leaf-vue-dialog-title"></div>
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
		</div>`
};