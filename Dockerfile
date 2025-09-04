# Gunakan Node 18 Alpine sebagai base image
FROM node:18-alpine

# Set working directory di dalam container
WORKDIR /app

# Copy package.json & package-lock.json
COPY package*.json ./

# Install SEMUA dependencies (prod + dev) agar jest, jest-junit, dll ikut masuk
RUN npm ci --include=dev

# Copy seluruh source code
COPY . .

# Expose port aplikasi
EXPOSE 3000

# Default command saat container dijalankan tanpa argumen tambahan
CMD ["node", "src/index.js"]