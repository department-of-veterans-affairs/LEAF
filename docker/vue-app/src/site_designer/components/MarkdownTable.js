import { marked } from 'marked';

export default {
    name: 'markdown-table',
    data() {
        return {
            host: window.location.host,
            entries: [
                { 
                    effect: "Italics.  Surround with * or _",
                    example: '*LEAF*, _LEAF_'
                },
                { 
                    effect: "Bold.  Surround with ** or __",
                    example: '**LEAF**, __LEAF__'
                },
                { 
                    effect: "Headings.  1-5 # (1 is largest).",
                    example: '### LEAF'
                },
                { 
                    effect: "Combined effects",
                    example: '### **_LEAF_**'
                },
                { 
                    effect: "Indented blockquote text",
                    example: '> LEAF'
                },
                { 
                    effect: "Indented lists",
                    example: `>>- item 1\n>>- item 2`
                },
                { 
                    effect: "Add a link. [link text] (link address)",
                    example: `[LEAF](https://${window.location.host})`
                },
                { 
                    effect: "Add an image. ![alt text] (image address 'optional title')",
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
        }
    },
    template:`<div id="markdown_tips">
        <p style="padding: 0.5em 0">
            Markdown can be used within the text editing area.  These are some common examples.
        </p>
        <table>
            <tr>
                <th>Effect</th><th>Example</th><th>Outcome</th>
            </tr>
            <tr v-for="item in entries" :key="item.effect">
                <td>{{ item.effect }}</td>
                <td>{{ item.example }}</td>
                <td v-html="markDown(item.example)"></td>
            </tr>
        </table>
    </div>`
}