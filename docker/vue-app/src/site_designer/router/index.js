import { createRouter, createWebHashHistory } from "vue-router";

//these likely won't be big enough to need lazy load
import Homepage from "../views/Homepage.js";
import TestView from "../views/TestView.js";

const routes = [
    {
        path: '/',
        redirect: { name: 'homepage' }
    },
    {
        path: '/homepage',
        name: 'homepage',
        component: Homepage
    },
    {
        path: '/testview',
        name: 'testview',
        component: TestView
    }
];


const router = createRouter({
    history: createWebHashHistory(),
    routes,
});

export default router;