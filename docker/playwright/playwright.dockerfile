FROM quay.vapo.va.gov/2195_leaf/node:22-slim

WORKDIR /usr/app
RUN npm install -D @playwright/test@latest
RUN npm install -D mysql2

WORKDIR /usr/app/leaf
RUN npx playwright install --with-deps
# Second "playwright install" needed to workaround issue on first run: "Playwright was just installed or updated"
CMD npx playwright install && node main.js
