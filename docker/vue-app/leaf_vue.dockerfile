
FROM node:22-bullseye-slim

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

ENTRYPOINT ["tail", "-f", "/dev/null"]