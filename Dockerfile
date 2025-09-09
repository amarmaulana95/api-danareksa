FROM node:18-alpine
RUN apk add --no-cache postgresql-client curl
WORKDIR /app

RUN mkdir -p /app/coverage /app/test-reports \
 && chown -R node:node /app
USER node

COPY --chown=node:node package*.json ./

RUN npm ci --include=dev

COPY --chown=node:node . .
EXPOSE 3000

CMD ["node","src/index.js"]