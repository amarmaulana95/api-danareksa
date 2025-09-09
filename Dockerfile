# ---- deps stage ----
    FROM node:18-alpine AS deps
    WORKDIR /app
    COPY package*.json ./
    RUN npm ci --include=dev && npm cache clean --force
    
    # ---- runtime stage ----
    FROM node:18-alpine AS runtime
    RUN apk add --no-cache dumb-init curl
    WORKDIR /app
    
    # copy node_modules saja
    COPY --from=deps /app/node_modules ./node_modules
    COPY --chown=node:node . .
    
    # buat folder test & own oleh user node
    RUN mkdir -p /app/coverage /app/test-reports && \
        chown -R node:node /app
    
    USER node
    EXPOSE 3000
    ENTRYPOINT ["dumb-init", "--"]
    CMD ["node", "src/index.js"]