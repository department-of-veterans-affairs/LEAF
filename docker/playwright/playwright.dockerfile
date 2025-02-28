FROM node:22-slim

WORKDIR /usr/app
RUN npm install -D @playwright/test@latest
RUN npm install -D mysql2

WORKDIR /usr/app/leaf
RUN npx playwright install --with-deps
CMD npx playwright install && node main.js
