import PrintSubindicators from './PrintSubindicators.js';

export default {
    components: {
        PrintSubindicators
    },
    inject: [
        'ajaxFormByCategoryID',
        'newQuestion'
    ],
    template:`
    <div class="printmainform">
        <template v-if="ajaxFormByCategoryID.length > 0">
            <template v-for="(formSection, i) in ajaxFormByCategoryID">
                <div class="printformblock">
                    <print-subindicators 
                        :depth="0"
                        :formNode="formSection"
                        :sectionNumber=i+1
                        :key="formSection.indicatorID">
                    </print-subindicators>
                </div>
            </template>
        </template>
        <div class="buttonNorm" role="button" tabindex="0" 
            @click="newQuestion(null)" @keypress.enter="newQuestion(null)"
            style="margin: 0 -1px -1px -1px">
            <img src="../../libs/dynicons/?img=list-add.svg&amp;w=16" alt="" title="Add Section Heading"/> Add Section Heading
        </div>
    </div>`
}