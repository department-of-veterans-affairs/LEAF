var section_defaults = {
	title: "+ Add Section",
	isNew: true,
	description: "",
	questions: []
};

var question_defaults = {
	text: "+ Add Question",
	inputType: "",
	defaultAnswer: "",
	required: false,
	sensitive: false,
	isNew: true
};

var question_test = {
	text: "Question Text1",
	inputType: "text",
	defaultAnswer: "",
	required: false,
	sensitive: false,
	isNew: false
};

var question_test2 = {
	text: "Question Text2",
	inputType: "textarea",
	defaultAnswer: "",
	required: false,
	sensitive: false,
	isNew: false
};

var question_test3 = {
	text: "Question Text3",
	inputType: "radio",
	defaultAnswer: "",
	required: false,
	sensitive: false,
	isNew: false
};

var vm = new Vue({
	el: ".leaf-app",
	data: {
		sections: [
			{
				id: "someHash",
				title: "Nature of Action Request",
				type: "section-card",
				isNew: false,
				description: "Select the type of request:",
				questions: [question_test, question_test2, question_test3],
				rawQuestions: [question_test, question_test2, question_defaults]
			},
			section_defaults
		]
	}
});
