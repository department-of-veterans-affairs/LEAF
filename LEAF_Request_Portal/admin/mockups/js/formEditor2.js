

var vm = new Vue({
	el: ".leaf-app",
	data: {
		state: FormEditorStore.state,
		form: FormEditorStore.state.form
	},
	methods: {
		checkMove: function(evt) {
			return (evt.draggedContext.element.name !== 'toggleable-section');
		},
		addSectionToStore: function (section) {
			FormEditorStore.addSection(section);
		},
		removeSectionFromStore: function(index) {
			FormEditorStore.removeSection(index);
		}
	}
});
