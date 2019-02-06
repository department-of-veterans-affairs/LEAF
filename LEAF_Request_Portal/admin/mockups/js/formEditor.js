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
	text: "Question Text",
	inputType: "",
	defaultAnswer: "",
	required: false,
	sensitive: false,
	isNew: true
};

var question_test2 = {
	text: "Question Text2",
	inputType: "",
	defaultAnswer: "",
	required: false,
	sensitive: false,
	isNew: true
};

var vm = new Vue({
	el: ".leaf-app",
	data: {
		sections: [
			{
				title: "Nature of Action Request",
				type: "section-card",
				description: "Select the type of request:",
				questions: [question_test, question_test2, question_test]
			},
			section_defaults
		]
	}
	// list2: [[{
	// 	name: "Juan"
	// }, {
	// 	name: "Edgard"
	// }, {
	// 	name: "Johnson"
	// }], [{
	// 	name: "Jan"
	// }, {
	// 	name: "Kees"
	// }, {
	// 	name: "Piet"
	// }]] // embeded dragging elements
});
