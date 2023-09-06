export default {
    name: 'response-message',
    props: {
        message: {
            type: String
        }
    },
    template: `<div style="padding: 1rem; background-color: white;">{{ message }}</div>`
}