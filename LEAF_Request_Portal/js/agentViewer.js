// LeafAgentViewer parses and renders the UI for an agent's task
var LeafAgentViewer = function (containerID, siteURL) {
    let prefixID = 'LeafAgentViewer' + Math.floor(Math.random() * 1000) + '_';
    let config = [];
    let action = {}; // workflow actions
    let requestLabel = 'Request';
    let indicator = {}; // form fields
    let inst = { // Instruction definitions
        'annotation': {
            'label': 'Annotation',
            'explain': (payload) => {
                return `(${payload.data})`;
            }
        },
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

                return `Hold ${requestLabel} for ${text}`;
            }
        },
        'route': { // untested
            'label': 'Take Action',
            'explain': (payload) => {
                return `Take Action: ${action[payload.actionType]}`;
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
                return `Take Action: ${action[payload.actionType]} only if: ${conditions}`;
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
                    context = `<br />${payload.context}`;
                }
                return `Select an option in <code>(${indicator[payload.writeIndicatorID]} #${payload.writeIndicatorID})</code> based on data in <code>${readText}</code>${context}`;
            }
        },
        'updateData4BLLM': {
            'label': 'Generate Text (LLM 4)',
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

                return `${payload.context}
                    <br />Writing to field: <code>(${indicator[payload.writeIndicatorID]} #${payload.writeIndicatorID})</code>
                    <br />Reading from: <code>${readText}</code>`;
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
                return `Take Action: ${action[payload.actionType]} only if: ${conditions}`;
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
                    context = `<br />${payload.context}`;
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
        let pActions = fetch(`${siteURL}api/workflow/actions?x-filterData=actionType,actionText`)
            .then(response => response.json());

        // load request label
        let pSettings = fetch(`${siteURL}api/system/settings`)
            .then(response => response.json());

        // load form fields
        let pIndicators = fetch(`${siteURL}api/form/indicator/list?x-filterData=indicatorID,name,description`)
            .then(response => response.json());

        let res = await Promise.all([pActions, pSettings, pIndicators]);
        let resActions = res[0];
        requestLabel = res[1].requestLabel;
        let resIndicators = res[2];

        for(let i in resActions) {
            action[resActions[i].actionType] = resActions[i].actionText;
        }

        for(let i in resIndicators) {
            indicator[resIndicators[i].indicatorID] = resIndicators[i].name;
            if(resIndicators[i].description != '') {
                indicator[parseInt(resIndicators[i].indicatorID)] = resIndicators[i].description;
            }
            if(indicator[resIndicators[i].indicatorID].length > 50) {
                indicator[resIndicators[i].indicatorID] = indicator[resIndicators[i].indicatorID].substring(0, 50) + '...';
            }
        }
    }

    function importConfig(oldConfig) {
        if(!Array.isArray(oldConfig)) {
            alert('Invalid configuration');
            return;
        }
        config = oldConfig;
    }

    function render() {
        let output = '<ol class="agentConfig">';
        let usesLLM = '';
        config.forEach(instruction => {
            let showLLM = instruction.type.indexOf('LLM') != -1 ? '🤖 ' : '';
            if(showLLM != '') {
                usesLLM = `<p>A robot icon (🤖) indicates use of Large Language Model (LLM) technology, which can make mistakes.
                            <br />Ensure that your workflow includes steps that verify and correct information when necessary.</p>`;
            }

            if(inst[instruction.type] != undefined) {
                output += `<li>${showLLM}${inst[instruction.type].explain(instruction.payload)}</li>`;
            } else {
                output += `<li>${showLLM}${instruction.type} - ${JSON.stringify(instruction.payload)}</li>`;
            }
        });
        output += '</ol>';

        if(config.length == 0) {
            output = 'No instructions have been given to the Agent.';
        }

        let styles = `<style>
            ol.agentConfig {
                list-style: none;
                counter-reset: agentConfigCounter;
                font-size: 1rem;
                padding-left: 0;
            }
            ol.agentConfig > li {
                counter-increment: agentConfigCounter;
                padding-left: 3rem;
                margin-bottom: 1rem;
                text-indent: -3rem;
                background-color: #f1f1f1ff;
            }
            ol.agentConfig > li::before {
                content: counter(agentConfigCounter);
                background-color: black;
                color: white;
                font-size: 1.2rem;
                font-weight: bold;
                display: inline-block;
                width: 2rem;
                height: 2rem;
                line-height: 2rem;
                margin-right: 1rem;
                text-indent: 0rem;
                text-align: center;
            }
            ol.agentConfig > li > details {
                text-indent: 1rem;
            }
            ol.agentConfig > li > ul {
                text-indent: 0rem;
            }
        </style>`;
        document.querySelector('#'+containerID).innerHTML = styles + usesLLM + output;
    }

    return {
        init,
        importConfig,
        getConfig: () => config,
        render
    };
}
