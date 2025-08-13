// LeafAgentConfig parses and renders the UI for an agent's task
var LeafAgentConfig = function (containerID, siteURL) {
    let prefixID = 'LeafAgentConfig' + Math.floor(Math.random() * 1000) + '_';
    let config = {};
    let action = {}; // workflow actions
    let requestLabel = 'Request';
    let indicator = {}; // form fields
    let inst = { // Instruction definitions
        'holdForDuration': {
            'label': 'Hold Record',
            'explain': (payload) => {
                let secondsToHold = parseInt(payload.secondsToHold);

                let text = '';
                // generate human readable string
                if (secondsToHold < 60) {
                    text = secondsToHold + " seconds";
                } else if (secondsToHold < 3600) {
                    text = Math.floor(secondsToHold / 60) + " minutes";
                } else if (secondsToHold < 86400) {
                    text = Math.floor(secondsToHold / 3600) + " hours";
                } else if (secondsToHold < 604800) {
                    text = Math.floor(secondsToHold / 86400) + " days";
                } else if (secondsToHold < 31536000) {
                    text = Math.floor(secondsToHold / 604800) + " weeks";
                } else if (secondsToHold == 31536000) {
                    text = "1 year";
                } else {
                    text = Math.floor(secondsToHold / 31536000) + " years";
                }

                return `Hold record for ${text}`;
            }
        },
        'route': { // untested
            'label': 'Take Action',
            'explain': (payload) => {
                return `${action[payload.actionType]} ${requestLabel}`;
            }
        },
        'routeActionHistoryTally': {
            'label': 'routeActionHistoryTally',
            'explain': (payload) => {
                return JSON.stringify(payload);
            }
        },
        'routeConditionalData': {
            'label': 'Take Action (conditional)',
            'explain': (payload) => {
                let conditions = '<ul>';
                payload.query.terms.forEach(term => {
                    let gate = '';
                    if(term.gate != undefined && term.gate == 'OR') {
                        gate = `OR `;
                    }
                    if(indicator[term.indicatorID] != undefined) {
                        conditions += `<li>${gate}${indicator[term.indicatorID]} ${term.operator} ${term.match}</li>`;
                    } else {
                        let iid = '';
                        if(term.indicatorID != undefined) {
                            iid = term.indicatorID;
                        }
                        conditions += `<li>${gate}${term.id} ${iid} ${term.operator} ${term.match}</li>`;
                    }

                });
                conditions += '</ul>';
                return `${action[payload.actionType]} ${requestLabel} when ${conditions}`;
            }
        },
        'routeLLM': {
            'label': 'Select an option (workflow action)',
            'explain': (payload) => {
                let readIDs = [];
                payload.readIndicatorIDs.forEach(id => {
                    if(indicator[id] != undefined) {
                        readIDs.push(`(${indicator[id]} #${id})`);
                    } else {
                        readIDs.push(`Error: Unknown Field ${id}. Has the field been deleted or archived?`); 
                    }
                });
                let readText = readIDs.join(', ');

                let context = '';
                if(payload.context != '') {
                    context = `<p>
                        <details>
                            <summary>Additional Context</summary>
                            ${payload.context}
                        </details>
                        </p>`;
                }
                return `Select an option in <code>(${indicator[payload.writeIndicatorID]} #${payload.writeIndicatorID})</code> based on data in <code>${readText}</code>${context}`;
            }
        },
        'updateData4BLLM': {
            'label': 'Generate Text (LLM 4)',
            'explain': (payload) => {
                console.log(payload);
                let readIDs = [];
                payload.readIndicatorIDs.forEach(id => {
                    if(indicator[id] != undefined) {
                        readIDs.push(`(${indicator[id]} #${id})`);
                    } else {
                        readIDs.push(`Error: Unknown Field ${id}. Has the field been deleted or archived?`); 
                    }
                });
                let readText = readIDs.join(', ');

                return `<p>${payload.context}</p>
                    <p>Writing to field: <code>(${indicator[payload.writeIndicatorID]} #${payload.writeIndicatorID})</code></p>
                    <p>Reading from: <code>${readText}</code></p>`;
            }
        },
        'updateDataConditional': {
            'label': 'Update Data (conditional)',
            'explain': (payload) => {
                let conditions = '<ul>';
                payload.query.terms.forEach(term => {
                    let gate = '';
                    if(term.gate != undefined && term.gate == 'OR') {
                        gate = `OR `;
                    }
                    if(indicator[term.indicatorID] != undefined) {
                        conditions += `<li>${gate}${indicator[term.indicatorID]} ${term.operator} ${term.match}</li>`;
                    } else {
                        let iid = '';
                        if(term.indicatorID != undefined) {
                            iid = term.indicatorID;
                        }
                        conditions += `<li>${gate}${term.id} ${iid} ${term.operator} ${term.match}</li>`;
                    }

                });
                conditions += '</ul>';
                return `${action[payload.actionType]} ${requestLabel} when ${conditions}`;
            }
        },
        'updateDataLLMCategorization': {
            'label': 'Select an option (update data)',
            'explain': (payload) => {
                let readIDs = [];
                payload.readIndicatorIDs.forEach(id => {
                    if(indicator[id] != undefined) {
                        readIDs.push(`(${indicator[id]} #${id})`);
                    } else {
                        readIDs.push(`Error: Unknown Field ${id}. Has the field been deleted or archived?`); 
                    }
                });
                let readText = readIDs.join(', ');

                let context = '';
                if(payload.context != '') {
                    context = `<p>
                        <details>
                            <summary>Additional Context</summary>
                            ${payload.context}
                        </details>
                        </p>`;
                }
                return `Select an option in <code>(${indicator[payload.writeIndicatorID]} #${payload.writeIndicatorID})</code> based on data in <code>${readText}</code>${context}`;
            }
        },
        'updateDataLLMLabel': {
            'label': 'Generate Label (update data)',
            'explain': (payload) => {
                let readIDs = [];
                payload.readIndicatorIDs.forEach(id => {
                    if(indicator[id] != undefined) {
                        readIDs.push(`(${indicator[id]} #${id})`);
                    } else {
                        readIDs.push(`Error: Unknown Field ${id}. Has the field been deleted or archived?`); 
                    }
                });
                let readText = readIDs.join(', ');
                return `Generate label for <code>${readIDs.join(', ')}</code>. Write label in <code>(${indicator[payload.writeIndicatorID]} #${payload.writeIndicatorID})</code>`;
            }
        },
        'updateTitleLLMLabel': {
            'label': 'Generate Label (update title)',
            'explain': (payload) => {
                let readIDs = [];
                payload.readIndicatorIDs.forEach(id => {
                    if(indicator[id] != undefined) {
                        readIDs.push(`(${indicator[id]} #${id})`);
                    } else {
                        readIDs.push(`Error: Unknown Field ${id}. Has the field been deleted or archived?`); 
                    }
                });
                let readText = readIDs.join(', ');
                return `Generate label for <code>${readIDs.join(', ')}</code>. Write label in <code>(${indicator[payload.writeIndicatorID]} #${payload.writeIndicatorID})</code>`;
            }
        }
    };

    async function init() {
        // load workflow actions
        let res = await fetch(`${siteURL}api/workflow/actions?x-filterData=actionType,actionText`)
            .then(response => response.json());
        for(let i in res) {
            action[res[i].actionType] = res[i].actionText;
        }

        // load request label
        res = await fetch(`${siteURL}api/system/settings`)
            .then(response => response.json());
        requestLabel = res.requestLabel;

        // load form fields
        res = await fetch(`${siteURL}api/form/indicator/list?x-filterData=indicatorID,name,description`)
            .then(response => response.json());
        for(let i in res) {
            indicator[res[i].indicatorID] = res[i].name;
            if(res[i].description != '') {
                indicator[parseInt(res[i].indicatorID)] = res[i].description;
            }
            if(indicator[res[i].indicatorID].length > 50) {
                indicator[res[i].indicatorID] = indicator[res[i].indicatorID].substring(0, 50) + '...';
            }
        }
    }

    function importConfig(oldConfig) {
        config = oldConfig;
    }

    function render() {
        console.log(config);

        let output = '';
        config.forEach(instruction => {
            if(inst[instruction.type] != undefined) {
                output += `<tr><td>${inst[instruction.type].label}</td><td>${inst[instruction.type].explain(instruction.payload)}</td></tr>`;
            } else {
                output += `<tr><td>${instruction.type}</td><td>${JSON.stringify(instruction.payload)}</td></tr>`;
            }
        });

        document.querySelector('#'+containerID).innerHTML = `<table>
            <thead><tr>
                <th>Instruction</th>
                <th>Details</th>
            </tr></thead>
            ${output}</table>`;
    }

    return {
        init,
        importConfig,
        getConfig: () => config,
        render
    };
}
