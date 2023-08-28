import { createRouter, createWebHashHistory } from "vue-router";
const FormEditorView = () => import(/* webpackPrefetch: true, webpackChunkName:"form-editor-view" */"../views/FormEditorView");
const RestoreFieldsView = () => import(/* webpackChunkName:"restore-fields-view" */"../views/RestoreFieldsView");

const routes = [
    {
        path: '/',
        redirect: { name: 'category' }
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

export default router;