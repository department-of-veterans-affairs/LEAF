const path = require('path');

module.exports = {
    entry: './libs/js/vue/vue-src',
    output: {
        filename: 'leaf-vue-main.js',
        path: path.resolve(__dirname, './libs/js/vue/vue-dest')
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
    devtool: 'source-map'
}