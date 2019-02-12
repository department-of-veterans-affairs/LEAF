var sectionDefaults = {
	id: 0,
	title: "+ Add Section",
	description: "",
	questions: [],
	rawQuestions: []
};

var questionDefaults = {
	text: "+ Add Question",
	type: "",
	template: '',
	answer: "",
	required: false,
	sensitive: false
};

var questionTest = {
	text: "Question Text1",
	type: "text",
	template: '',
	answer: "",
	required: false,
	sensitive: false
};

var questionTest2 = {
	text: "Request Format",
	type: "radio",
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
	sensitive: false
};

var questionTest3 = {
	text: "Question Text3",
	type: "text",
	template: '<input type="text"/>',
	answer: "",
	required: false,
	sensitive: false
};

var mockData = [
	{
		id: 1,
		title: "Nature of Action Request",
		description: "Select the type of request:",
		questions: [],
		rawQuestions: [questionTest, questionTest2, questionTest3, questionDefaults]
	},
	sectionDefaults
];

var vm = new Vue({
	el: ".leaf-app",
	data: function () {
		return {
			sections: mockData
		};
	}
});
