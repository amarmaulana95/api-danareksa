FROM node:18-alpine

# Install postgresql-client + curl
RUN apk add --no-cache postgresql-client curl

WORKDIR /app
COPY package*.json ./
RUN npm ci --include=dev
COPY . .
EXPOSE 3000
CMD ["node", "src/index.js"]