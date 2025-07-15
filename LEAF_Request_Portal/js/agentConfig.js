var LeafAgentConfig = function (containerID) {
    let prefixID = "LeafAgentConfig" + Math.floor(Math.random() * 1000) + "_";
    let config = {};

    function importConfig(oldConfig) {
        config = oldConfig;
    }

    function render() {
        console.log(config);
    }

    return {
        importConfig,
        render
    };
}
