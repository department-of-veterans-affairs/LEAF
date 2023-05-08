import { createRouter, createWebHashHistory } from "vue-router";

//these likely won't be big enough to need lazy load
import Homepage from "../views/Homepage.js";

const routes = [
    {
        path: '/',
        redirect: { name: 'homepage' }
    },
    {
        path: '/homepage',
        name: 'homepage',
        component: Homepage
    }
];


const router = createRouter({
    history: createWebHashHistory(),
    routes,
});

export default router;