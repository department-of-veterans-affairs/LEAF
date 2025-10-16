import { createRouter, createWebHashHistory } from "vue-router";
const FormBrowserView = () => import(/* webpackChunkName:"form-browser-view" */"../views/FormBrowserView");
const FormEditorView = () => import(/* webpackChunkName:"form-editor-view" */"../views/FormEditorView");
const WorkflowEditorView = () => import(/* webpackChunkName:"workflow-editor-view" */"../views/WorkflowEditorView");
const RestoreFieldsView = () => import(/* webpackChunkName:"restore-fields-view" */"../views/RestoreFieldsView");

const routes = [
    {
        path: '/',
        name: 'browser',
        component: FormBrowserView,
        meta: { title: 'Form Browser' }
    },
    {
        path: '/forms',
        name: 'category',
        component: FormEditorView,
        meta: { title: 'Form Editor' }
    },
    {
        path: '/workflows',
        name: 'workflows',
        component: WorkflowEditorView,
        meta: { title: 'Workflow Editor' }
    },
    {
        path: '/restore',
        name: 'restore',
        component: RestoreFieldsView,
        meta: { title: 'Restore Fields' }
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
    const defaultTitle = document?.title || '';
    document.title = to?.meta?.title || defaultTitle;
});

export default router;