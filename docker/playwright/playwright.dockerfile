FROM quay.vapo.va.gov/mirrors/redhat/ubi9/nodejs-22:latest

WORKDIR /usr/app
RUN npm install -D @playwright/test@latest
RUN npm install -D mysql2

WORKDIR /usr/app/leaf
RUN npx playwright install --with-deps
# Second "playwright install" needed to workaround issue on first run: "Playwright was just installed or updated"
CMD npx playwright install && node main.js
