import { createRouter, createWebHashHistory } from "vue-router";
import FormEditorView from "@/views/FormEditorView";
import RestoreFieldsView from "@/views/RestoreFieldsView";

/* if chunking.  would require ref updates
const FormBrowser = () => import('../views/FormBrowser');
const FormEditorView = () => import('../components/form_view/FormEditorView');
const RestoreFieldsView = () => import('../components/RestoreFieldsView');
*/

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