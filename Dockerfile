# enable BuildKit features
# ---- deps stage ----
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
# mount cache supaya node_modules tidak re-download tiap kali
RUN --mount=type=cache,target=/root/.npm \
    npm ci --include=dev --prefer-offline

# ---- runtime stage ----
FROM node:18-alpine AS runtime
RUN apk add --no-cache dumb-init curl
WORKDIR /app

# copy node_modules dari stage deps (sudah tercache)
COPY --from=deps /app/node_modules ./node_modules
COPY --chown=node:node . .

# buat folder test & own oleh user node
RUN mkdir -p /app/coverage /app/test-reports && \
    chown -R node:node /app

USER node
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "src/index.js"]