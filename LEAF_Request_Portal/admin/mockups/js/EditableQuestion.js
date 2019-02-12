var editableQuestion = Vue.component('editable-question', {
	props: {
		'question': {
			type: Object,
			default: function() { return {}; }
		}
	},
	template:
		'<div class="col-6">' +
			'<question-form v-if="editFormOpen":question="question"></question-form>' +
			'<question-pane v-else :question="question"></question-pane>' +
		'</div>',
	data: function() {
		return {
			editFormOpen: this.editFormOpen || false
		};
	},
	methods: {
		updateQuestion: function(text, type, answer, required, sensitive) {
			this.question.text = text;
			this.question.type = type;
			this.question.answer = answer;
			this.question.required = required;
			this.question.sensitive = sensitive;
			this.toggleQuestionView();
		},
		toggleQuestionView: function() {
			this.editFormOpen = !this.editFormOpen;
		}
	}
});