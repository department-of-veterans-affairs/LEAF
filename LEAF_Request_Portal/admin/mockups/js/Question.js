var question = Vue.component('question-pane', {
	props: {
		'question': {
			type: Object,
			default: function() { return {}; }
		}
	},
	template:
		'<div class="card question">' +
			'<h4>{{text}} <a href="#" @click="editQuestion"><i class="fas fa-edit"></i></a></h4>' +
			'<div class="card-icons"><a href="#"><i class="fas fa-times"></i></a></div>' +
			'<div class="card-body">' +
				'<fieldset v-if="type === \'radio\'">' +
				'<input v-for="option in multiInputOptions" :type="type" :value="option.value">' +
				'</fieldset>' +
				'<span style="float:right;color:#981b1e">' +
				'<div v-show="required">Required</div>' +
				'<div v-show="sensitive">Sensitive</div>' +
				'</span>' +
				'<p>{{answer}}</p>' +
				'<p v-if="multiInputOptions && multiInputOptions.length > 0">{{multiInputOptions}}</p>' +
			'</div>' +
		'</div>',
	data: function () {
		return {
			text: this.question.text,
			type: this.question.type,
			answer: this.question.answer,
			required: this.question.required,
			sensitive: this.question.sensitive,
			multiInputOptions: this.question.multiInputOptions
		};
	},

	methods: {
		editQuestion: function() {
			this.$parent.toggleQuestionView();
		}
	}
});