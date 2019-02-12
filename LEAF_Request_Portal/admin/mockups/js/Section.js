var section = Vue.component('section-pane', {
	props: {
		'section': {
			type: Object,
			default: function() { return {}; }
		}
	},
	template:
		`<div class="col-4">\
			<div class="card section">\
				<h4>{{title}} <a href="#" @click="editSection"><i class="fas fa-edit"></i></a></h4>\
				<div class="card-icons"><a href="#" @click="removeSection"><i class="fas fa-times"></i></a></div>\
				<div class="card-body">{{description}}</div>\
				<draggable 
					id="questions-container" 
					class="flex-row no-gutters dragArea" 
					:options='{group: "questions"}'>
					
					<div class="col" v-for="(question,index) in section.questions" >
					<question-pane :key="question.id" :question="question">

					</question-pane></div>
				</draggable>\
			</div>
		</div>`,
	data() {
		return {
			id: this.section.id,
			title: this.section.title,
			description: this.section.description,
			questions: this.section.questions
		}
	},

	methods: {
		editSection: function() {
			this.$parent.toggleSectionView();
		},
		removeSection: function() {
			FormEditorStore.removeSectionById(this._uid)
		}
	}
});