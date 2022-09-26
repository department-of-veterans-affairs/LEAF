const path = require('path');
const webpack = require('webpack');

module.exports = {
    entry: './libs/js/LEAF/form_editor_vue_src/LEAF_FormEditor_main.js',
    output: {
        filename: 'LEAF_FormEditor_main_build.js',
        path: path.resolve(__dirname, './libs/js/vue-dest')
    },
    resolve: {
        alias: {
            vue: 'vue/dist/vue.esm-bundler.js'
        }
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                use: {
                    loader: 'babel-loader'
                }
            },
            {
                test: /\.scss$/,
                use: [
                    'style-loader',
                    'css-loader',
                    'sass-loader'
                ]
            }
        ]
    },
    plugins: [
        new webpack.DefinePlugin({
            "__VUE_OPTIONS_API__": true,
            "__VUE_PROD_DEVTOOLS__": false,
            options: {
                runtimeCompiler: true,
            }
        })
    ],
}