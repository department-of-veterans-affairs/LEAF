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
        path: '/bodyarea', //fixes an issue caused by the hashed navskip in main.tpl
        redirect: { name: 'homepage' }
    },
    {
        path: '/homepage',
        name: 'homepage',
        component: Homepage
    },
    {
        path: '/testpage',
        name: 'testpage',
        component: TestView
    }
];


const router = createRouter({
    history: createWebHashHistory(),
    routes,
});

export default router;