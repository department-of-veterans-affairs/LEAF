
FROM node:16.16-alpine

WORKDIR /app
#ENV PATH /app/node_modules/.bin:$PATH

COPY package*.json ./
RUN npm install

#RUN npm i -g webpack webpack-cli
RUN npm install -g nodemon

COPY . .

CMD ["nodemon", "--ext", "js,css,vue", "--watch src", "--exec", "npm", "run", "dev-vue" ]
#CMD ["npm", "run", "dev-vue" ]