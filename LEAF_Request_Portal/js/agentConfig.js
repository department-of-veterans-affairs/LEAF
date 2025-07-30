// LeafAgentConfig parses and renders the UI for an agent's task
var LeafAgentConfig = function (containerID) {
    let prefixID = "LeafAgentConfig" + Math.floor(Math.random() * 1000) + "_";
    let config = {};

    function importConfig(oldConfig) {
        config = oldConfig;
    }

    function render() {
        console.log(config);

        let output = '';
        config.forEach(instruction => {
            output += `<tr><td>${instruction.type}</td><td>${JSON.stringify(instruction.payload)}</td></tr>`;
        });

        document.querySelector('#'+containerID).innerHTML = `<table>
            <thead><tr>
                <th>Instruction</th>
                <th>Configuration</th>
            </tr></thead>
            ${output}</table>`;
    }

    return {
        importConfig,
        getConfig: () => config,
        render
    };
}
