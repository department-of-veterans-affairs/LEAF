import { marked } from 'marked';

export default {
    name: 'markdown-table',
    data() {
        return {
            entries: [
                { 
                    effect: "Italics. <br/>Surround with * or _",
                    example: '*LEAF*, _LEAF_'
                },
                { 
                    effect: "Bold. <br/>Surround with ** or __",
                    example: '**LEAF**, __LEAF__'
                },
                { 
                    effect: "Headings. <br/>1-5 # (1 is largest)",
                    example: '### LEAF'
                },
                // not sure if this should be included.  this space should be limited
                // { 
                //     effect: "Indented blockquote text. <br/>> for each indent",
                //     example: '> LEAF\n>> LEAF',
                //     html: `> LEAF<br />>> LEAF`
                // },
                { 
                    effect: "ordered and unordered lists",
                    example: `1. item A\n2. item B\n* item A\n* item B`,
                    html: `1. item A<br/>2. item B<br/><br/>* item A<br/>* item B`
                },
                { 
                    effect: "Add a link. <br/>[link text] (link address)",
                    example: `[LEAF](https://${window.location.host}/` + `${window.location.host === 'localhost' ?
                        'LEAF_Request_Portal' : 'launchpad'})`
                },
                { 
                    effect: "Add an image. <br/>![alt text] (image address 'optional title')",
                    example: `![LEAF logo](https://${window.location.host}/libs/dynicons/svg/LEAF-thumbprint.svg 'Welcome to LEAF')`
                },
            ]
        }
    },
    computed: {
        tableHeight() {
            return 10;
        }
    },
    methods: {
        markDown(input = '') {
            return marked(input);
        },
        rowColor(i) {
            return i%2 === 0 ? '#ffffff' : '#fbfbfd'
        }
    },
    template:`<div id="markdown_tips">
        <p style="padding-bottom: 0.5em">
            Markdown can be used within the text editing area.  Below are some common examples.
        </p>
        <table>
            <tr>
                <th>Effect</th><th>Example</th><th>Outcome</th>
            </tr>
            <tr v-for="ele, i in entries" :key="ele.effect" :style="{backgroundColor: rowColor(i)}">
                <td v-html="ele.effect"></td>

                <td v-if="ele.html !== undefined" v-html="ele.html"></td>
                <td v-else>{{ ele.example }}</td>

                <td v-html="markDown(ele.example)"></td>
            </tr>
        </table>
    </div>`
}