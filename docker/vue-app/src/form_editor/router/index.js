import { createRouter, createWebHashHistory } from "vue-router";
const FormBrowserView = () => import(/* webpackChunkName:"form-browser-view" */"../views/FormBrowserView");
const FormEditorView = () => import(/* webpackChunkName:"form-editor-view" */"../views/FormEditorView");
const RestoreFieldsView = () => import(/* webpackChunkName:"restore-fields-view" */"../views/RestoreFieldsView");

const routes = [
    {
        path: '/',
        name: 'browser',
        component: FormBrowserView
    },
    {
        path: '/forms',
        name: 'category',
        component: FormEditorView
    },
    {
        path: '/restore',
        name: 'restore',
        component: RestoreFieldsView
    },
];

const router = createRouter({
    history: createWebHashHistory(),
    routes,
});

/* prevents the app from trying to route to the navskip hash link */
router.beforeEach(to => {
    if (to.path === '/bodyarea') {
        return false;
    }
});

export default router;