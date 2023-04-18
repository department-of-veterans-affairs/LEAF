export default {
    name: 'mod-home-item',
    data() {
        return {
            test: 'test mod home menu'
        }
    },
    inject: [
        'menuButtonList',
    ],
    template: `<section>
        <h2>TEST HEADER</h2>
        <p>{{ test }}</p>
        <p>{{ menuButtonList }}</p>
        <ul>
            <li v-for="b in menuButtonList" :key="b.id"
                style="display: flex; align-items:center;" :style="{ backgroundColor: b.color, color: b.fontColor }">
                <img :src="b.icon"/> {{ b.description }}
            </li>
        </ul>
        </section>`
}