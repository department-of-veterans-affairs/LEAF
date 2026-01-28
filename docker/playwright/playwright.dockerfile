FROM node:22-slim
WORKDIR /usr/app/leaf

# Copy just package.json
COPY LEAF-Automated-Tests/end2end/package.json ./

# Use npm install (generates lock file inside container)
RUN npm install

# Install Playwright browsers
RUN npx playwright install --with-deps

# Command
CMD ["node", "main.js"]