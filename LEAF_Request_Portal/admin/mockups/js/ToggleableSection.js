const NEW_SECTION_DEFAULTS = {
	isOpen: false,
	section: {
		title: '',
		description: ''
	}
};

var NEW_SECTION_DEFAULTS_CLONE = JSON.parse(JSON.stringify(NEW_SECTION_DEFAULTS));

var toggleableSection = Vue.component('toggleable-section', {
	props: {
		sections: Array
	},
	template:
		`<div class="row">\
			<section-form\
				v-if="isOpen"\ 
				:create="true"\ 
				v-model="section">\				
			</section-form>\
			<div v-else\
				class="col-4">\
				<div class="card section new-section"\
					@click="handleFormOpen">\
						<h3>+ Add Section</h3>\
				</div>\
			</div>\
		</div>`
	,
	data() {
		return NEW_SECTION_DEFAULTS_CLONE;
	},

	methods: {
		handleFormOpen: function () {
			this.isOpen = !this.isOpen;
		},
		toggleSectionView: function () {
			this.isOpen = !this.isOpen;
		}
	}
});