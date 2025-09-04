FROM node:18-alpine

# Install PostgreSQL client utilities (termasuk pg_isready)
RUN apk add --no-cache postgresql-client

WORKDIR /app
COPY package*.json ./
RUN npm ci --include=dev
COPY . .
EXPOSE 3000
CMD ["node", "src/index.js"]