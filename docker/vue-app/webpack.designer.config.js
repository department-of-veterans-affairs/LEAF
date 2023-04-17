const path = require('path');
const webpack = require('webpack');

module.exports = {
    entry: './src_designer/LEAF_designer_main.js',
    output: {
        filename: 'LEAF_designer_main_build.js',
        path: path.resolve(__dirname, '/app/vue-dest/site_designer'),
        clean: true
    },
    watchOptions: {
        poll: true
    },
    resolve: {
        alias: {
            vue: 'vue/dist/vue.esm-bundler.js',
            "@": path.resolve(__dirname, "src_designer")
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