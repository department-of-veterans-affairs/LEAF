FROM node:22

WORKDIR /usr/app
RUN npm install -D @playwright/test@latest
RUN npx playwright install --with-deps

