var editableSection = Vue.component('editable-section', {
	props: {
		'section': {
			type: Object,
			default: function() { return {}; }
		}
	},
	template:
		`<div class="row">
			<section-form
				v-if="editFormOpen"
				:section="section">
			</section-form>
			<section-pane
				v-else
				:section="section">
			</section-pane>
			<div class="col">
				<draggable\
					v-model="section.rawQuestions"\
					:options='{group: "questions"}'\
					class="row"\
					style="min-height: 150px">\
					<editable-question\
						v-for="(question, index) in section.rawQuestions"\
						:question="question"\
						:sectionId="section.id"
						:key="question.id">\
					</editable-question>\
					<toggleable-question\
						:rawQuestions="section.rawQuestions"\
						:sectionId="section.id">\
					</toggleable-question>\
				</draggable>\
			</div>
		</div>`,
	data() {
		return {
			editFormOpen: this.editFormOpen || false,
			rawQuestions: this.section.rawQuestions || []
		}
	},
	methods: {
		updateSection: function(title, description) {
			this.section.title = title;
			this.section.description = description;
			this.toggleSectionView();
		},
		toggleSectionView: function() {
			this.editFormOpen = !this.editFormOpen;
		}
	}
});