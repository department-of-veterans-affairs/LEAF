
FROM node:16.16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

#CMD ["npm", "run", "dev-vue" ]
ENTRYPOINT ["tail", "-f", "/dev/null"]