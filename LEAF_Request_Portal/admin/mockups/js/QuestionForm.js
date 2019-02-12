var question = Vue.component('question-form', {
	props: {
		'create': {
			type: Boolean,
			default: false
		},
		'question': {
			type: Object,
			default: function() { return {}; }
		},
		'sectionId': {
			type: Number,
			default: 0
		}
	},
	template:
		'<div class="card question">' +
			'<div style="float:right;">' +
				'<input type="checkbox" id="options-required" name="options-required" v-model="required" >' +
				'<label for="options-required" style="margin:0" >Required?</label>' +
				'<input type="checkbox" id="options-sensitive" name="options-sensitive" v-model="sensitive" >' +
				'<label for="options-sensitive" style="margin:0" >Sensitive</label>' +
			'</div>' +
			'<label for="input-text-question-text">Question Text ' +
				'<a href="#" style="padding-left:1rem">Advanced Formatting</a>' +
			'</label>' +
			'<input id="input-text-question-text" name="input-text-question-text" type="text" v-model.trim="text">' +
			'<label for="select-question-type">Question Type</label>' +
			'<select id="question-type" v-model="type" name="select-question-type">' +
				'<option value="">None</option>' +
				'<option value="text">Single line text</option>' +
				'<option value="textarea">Multi-line text</option>' +
				'<option value="grid">Grid (Table with rows and columns)</option>' +
				'<option value="number">Numeric</option>' +
				'<option value="currency">Currency</option>' +
				'<option value="date">Date</option>' +
				'<option value="radio">Radio (single select, multiple options)</option>' +
				'<option value="checkbox">Checkbox (A single checkbox)</option>' +
				'<option value="checkboxes">Checkboxes (Multiple Checkboxes)</option>' +
				'<option value="dropdown">Dropdown Menu (single select, multiple options)</option>' +
				'<option value="fileupload">File Attachment</option>' +
				'<option value="image">Image Attachment</option>' +
				'<option value="orgchart_group">Orgchart Group</option>' +
				'<option value="orgchart_position">Orgchart Position</option>' +
				'<option value="orgchart_employee">Orgchart Employee</option>' +
				'<option value="raw_data">Raw Data (for programmers)</option>' +
			'</select>' +
			'<div v-show="type === \'radio\' || type === \'checkbox\' || type === \'checkboxes\' || ' +
				'type === \'dropdown\'">' +
				'<label>One option per line:</label>' +
				'<textarea id="textarea-multi-input" v-model="multiInputOptions"></textarea>' +
			'</div>' +
			'<label for="textarea-question-default-answer">Default Answer</label>' +
			'<textarea v-model="answer" name="textarea-question-default-answer" ></textarea>' +
			'<div class="container row no-gutters">' +
				'<button class="col" @click="cancelEdit">Cancel</button>' +
				'<button class="col" @click="saveQuestion">Save</button>' +
			'</div>' +
		'</div>',
	data: function() {
		return {
			text: this.question.text || '',
			type: this.question.type || '',
			answer: this.question.answer || '',
			multiInputOptions: this.question.multiInputOptions || '',
			required: this.question.required || false,
			sensitive: this.question.sensitive || false
		};
	},
	methods: {
		saveQuestion: function() {
			if(this.create) {
				var question = this.createQuestionData();
				var section = FormEditorStore.getSectionById(this.sectionId);
				section.rawQuestions.push(question);
				this.resetQuestionForm();
				this.$parent.isOpen = false;
			} else {
				this.$parent.updateQuestion(this.text, this.type, this.answer, this.required, this.sensitive);
			}
		},
		cancelEdit: function() {
			this.$parent.toggleQuestionView();
		},
		createQuestionData: function() {
			var ret = {};
			ret.text = this.text;
			ret.type = this.type;
			ret.multiInputOptions = this.parseMultiInputOptions();
			ret.answer = this.answer;
			ret.required = this.required;
			ret.sensitive = this.sensitive;

			return ret;
		},
		parseMultiInputOptions: function() {
			// TODO Split text into array,
		},
		resetQuestionForm: function() {
			this.text = null;
			this.type = null;
			this.multiInputOptions = null;
			this.answer = null;
			this.required = null;
			this.sensitive = null;
		}

	}
});