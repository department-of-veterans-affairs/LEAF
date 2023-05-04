const path = require('path');
const webpack = require('webpack');

module.exports = {
    entry: {
        'form_editor/LEAF_FormEditor': path.resolve(__dirname, './src/form_editor/LEAF_FormEditor_main.js'),
        'site_designer/LEAF_Designer': path.resolve(__dirname, './src/site_designer/LEAF_Designer_main.js'),
    },
    output: {
        filename: '[name].js',
        chunkFilename: '[name].chunk.js',
        path: path.resolve(__dirname, '/app/vue-dest'),
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