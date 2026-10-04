# Build the React application
FROM node:22-alpine

WORKDIR /app

# Install dependencies using the lock file
COPY package.json package-lock.json ./
RUN npm ci

# Copy application source
COPY . .

# Create production build
RUN npm run build

# Serve the static React application
RUN npm install -g serve

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]