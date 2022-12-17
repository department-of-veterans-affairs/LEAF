
FROM node:16.16-alpine

WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH

COPY package.json /app/package.json
RUN npm install

RUN npm install -g nodemon

COPY . .


CMD ["nodemon", "--ext", "js,css,vue", "--watch src", "--exec", "npm", "run", "dev-vue" ]