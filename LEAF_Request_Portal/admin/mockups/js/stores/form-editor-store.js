var question_test = {
	text: "Question Text1",
	inputType: "text",
	template: '',
	answer: "",
	required: false,
	sensitive: false,
	multiInputOptions: []
};

var question_test2 = {
	text: "Request Format",
	inputType: "radio",
	template: '<fieldset>' +
		'<input type="radio" id="option-1" name="request_format" value="photography" checked>' +
		'<label for="option-1">Photography</label>' +
		'<input type="radio" id="option-2" name="request_format" value="sharepoint site request">' +
		'<label for="option-2">Sharepoint Site Request</label>' +
		'<input type="radio" id="option-3" name="request_format" value="intranet site">' +
		'<label for="option-3">Intranet Site</label>' +
		'</fieldset>'
	,
	answer: "",
	required: false,
	sensitive: false,
	multiInputOptions: []
};

var question_test3 = {
	text: "Question Text3",
	inputType: "text",
	template: '<input type="text"/>'
	,
	defaultAnswer: "",
	required: false,
	sensitive: false,
	isNew: false
};

var test = {
	id: 1,
	title: "test title",
	description: "test description",
	editFormOpen: true,
	questions: [question_test2,question_test3],
	rawQuestions: []
};

var test2 = {
	id: 1,
	title: "test title",
	description: "test description",
	editFormOpen: true,
	questions: [],
	rawQuestions: []
};

var test2 = {
	id: 1,
	title: "test title",
	description: "test description",
	editFormOpen: true,
	questions: [],
	rawQuestions: []
};

var mockForm = {
	name: 'Public Affairs Action Request',
	description: 'To request photos, Sharepoint, intranet, PAO action.'
};

var FormEditorStore = {
	state: {
		form: mockForm,
		sections: []
	},
	addSection: function(newSection) {
		this.state.sections.push(newSection);
	},
	removeSectionById: function(id) {
		var i = this.state.sections.map(function(item) {
			return item.id === id;
		});
		this.state.sections.splice(i, 1);
	},
	removeSection: function(index) {
		this.state.sections.splice(index, 1);
	},
	getSectionById: function(id) {
		var i = this.state.sections.filter(function(section) {
			if(section.id === id) {
				return section;
			}
		});
		return i[0] || {}
	}
};