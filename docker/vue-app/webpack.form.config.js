const path = require('path');
const webpack = require('webpack');

module.exports = {
    entry: './src/LEAF_FormEditor_main.js',
    output: {
        filename: 'LEAF_FormEditor_main_build.js',
        path: path.resolve(__dirname, '/app/vue-dest/form_editor'),
        clean: true
    },
    watchOptions: {
        poll: true
    },
    resolve: {
        alias: {
            vue: 'vue/dist/vue.esm-bundler.js',
            "@": path.resolve(__dirname, "src")
        }
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader'
                }
            },
            {
                test: /\.scss$/,
                exclude: /node_modules/,
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