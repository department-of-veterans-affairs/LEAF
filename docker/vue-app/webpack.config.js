const path = require('path');
const webpack = require('webpack');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const commonConfig = {
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
                test: /\.js$/i,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader'
                }
            },
            {
                test: /\.(s[ac]|c)ss$/i,
                exclude: /node_modules/,
                use: [
                    MiniCssExtractPlugin.loader,
                    'css-loader',
                    'sass-loader'
                ]
            },
            {
                test: /\.(png|gif|woff|woff2|ttf)$/i,
                type: "asset/resource",
            },
        ]
    },
    plugins: [
        new webpack.DefinePlugin({
            "__VUE_OPTIONS_API__": true,
            "__VUE_PROD_DEVTOOLS__": false,
            options: {
                runtimeCompiler: true,
            }
        }),
        new MiniCssExtractPlugin()
    ],
}

const formEditorConfig = {
    ...commonConfig,
    entry: {
        'LEAF_FormEditor': path.resolve(__dirname, './src/form_editor/LEAF_FormEditor_main.js'),
    },
    output: {
        filename: '[name].js',
        chunkFilename: '[name].chunk.js',
        path: path.resolve(__dirname, '/app/vue-dest/form_editor'),
        clean: true
    }
}

const siteDesignerConfig = {
    ...commonConfig,
    entry: {
        'LEAF_Designer': path.resolve(__dirname, './src/site_designer/LEAF_Designer_main.js'),
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '/app/vue-dest/site_designer'),
        clean: true
    }
}
/* NOTE: keeping commented until implemented in future update
const adminSassConfig = {
    ...commonConfig,
    entry: {
        'leaf': path.resolve(__dirname, './src/sass/main.js'),
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '/app/css'),
        publicPath: '',
        assetModuleFilename: `assets/[name].[hash][ext][query]`,
        clean: true
    }
}*/

module.exports = [
    formEditorConfig,
    siteDesignerConfig,
    //adminSassConfig
];