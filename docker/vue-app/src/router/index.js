import { createRouter, createWebHashHistory } from "vue-router";
import FormBrowser from "../views/FormBrowser";
import FormViewController from "../components/form_view/FormViewController";
import RestoreFields from "../components/RestoreFields";

/* if chunking.  would require ref updates
const FormBrowser = () => import('../views/FormBrowser');
const FormViewController = () => import('../components/form_view/FormViewController');
const RestoreFields = () => import('../components/RestoreFields');
*/

const routes = [
    {
        path: '/',
        name: 'browser',
        component: FormBrowser
    },
    {
        path: '/forms/:formID',
        name: 'category',
        component: FormViewController
    },
    {
        path: '/restore',
        name: 'restore',
        component: RestoreFields
    },
];

const router = createRouter({
    history: createWebHashHistory(),
    routes,
});

export default router;