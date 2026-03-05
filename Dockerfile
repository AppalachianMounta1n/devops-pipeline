#Stage 1: Build the application
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json #copy package.json and package-lock.json
RUN npm ci #Install dependencies
COPY .. #copy source code
RUN npm run build #build the application

#Stage 2: Production image
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist #Copy built assets and production dependencies
COPY --from=builder /app/package*.json ./
RUN npm ci --production #Install only production dependencies
CMD ["node", "dist/server.js"] #Run the built application