FROM node:22-slim

WORKDIR /usr/app
RUN npm install -D @playwright/test@latest
RUN npx playwright install --with-deps

WORKDIR /usr/app/leaf
CMD node main.js
