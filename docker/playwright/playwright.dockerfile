FROM node:22-slim

WORKDIR /usr/app
RUN npm install -D @playwright/test@latest
RUN npx playwright install --with-deps
RUN npm install -D mysql2

WORKDIR /usr/app/leaf
CMD node main.js
