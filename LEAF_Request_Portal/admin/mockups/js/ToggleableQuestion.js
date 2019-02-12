var NEW_QUESTION_DEFAULTS = {
	isOpen: false,
	question: {
		title: '',
		description: ''
	}
};

var NEW_QUESTION_DEFAULTS_CLONE = JSON.parse(JSON.stringify(NEW_QUESTION_DEFAULTS));

var toggleableQuestion = Vue.component('toggleable-question', {
	props: {
		'sectionId': {
			type: Number,
			default: 0
		}
	},
	template:
		'<div class="col-6">' +
			'<question-form v-if="isOpen" :create="true" :sectionId="sectionId" v-model="question"></question-form>' +
			'<div v-else class="card question new-question" @click="handleFormOpen">' +
				'<h3>+ Add Question</h3>' +
			'</div>' +
		'</div>'
	,
	data: function() {
		return NEW_QUESTION_DEFAULTS_CLONE;
	},

	methods: {
		handleFormOpen: function () {
			this.isOpen = !this.isOpen;
		},
		toggleQuestionView: function () {
			this.isOpen = !this.isOpen;
		}
	}
});