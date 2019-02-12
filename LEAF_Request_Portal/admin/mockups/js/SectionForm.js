var section = Vue.component('section-form', {
	props: {
		'create': {
			type: Boolean,
			default: false
		},
		'section': {
			type: Object,
			default: function() { return {}; }
		}
	},
	template:
		`<div class="col-4">
			<div class="card section">\
				<label for="input-text-section-title">Section Title</label>\
				<input id="input-text-section-title"\
					name="input-text-section-title"
					type="text"
					v-model.trim="title">\
				<label for="input-text-section-description">Section Description\
					<a href="#" style="float:right;">Advanced Formatting</a>
				</label>\
				<textarea\
					id="textarea-section-description"\
					name="textarea-section-description"\
					type="textarea" style="max-width:100%"\
					v-model="description"\
					placeholder="Enter text to describe this form section"></textarea>\
				<div class="container row no-gutters">\
					<button class="col" @click="cancelEdit">Cancel</button>\
					<button class="col" @click="onSubmit">Save</button>\
				</div>\
			</div>\
		</div>`,
	data() {
		return {
			title: this.section.title || '',
			description: this.section.description || ''
		}
	},

	methods: {
		onSubmit: function () {
			if (this.create) {
				var section = this.createSectionData();
				FormEditorStore.addSection(section);
				this.resetSectionForm();
				this.$parent.isOpen = false;
			} else {
				this.$parent.updateSection(this.title, this.description);
			}
		},
		cancelEdit: function () {
			this.$parent.toggleSectionView();
		},
		createSectionData:function() {
			var ret = {};
			ret.id = this._uid;
			ret.title = this.title;
			ret.description = this.description;
			ret.questions = [];
			ret.rawQuestions = [];

			return ret;
		},
		resetSectionForm: function() {
			this.title = null;
			this.description = null;
		}
	}
});