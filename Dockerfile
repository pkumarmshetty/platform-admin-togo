# ---------------------
# Build stage
# ---------------------
FROM oven/bun:1.3.3-alpine AS build

WORKDIR /app

# Copy dependency manifests
COPY package.json bun.lock ./

# Install dependencies
RUN bun install

# Copy source
COPY . .

# Next.js inlines NEXT_PUBLIC_* at build time - must arrive as build args, not just runtime env
ARG NEXT_PUBLIC_BASE_API_PATH
ARG NEXT_PUBLIC_PAYMENT_GATEWAY_ENDPOINT
ARG NEXT_PUBLIC_CRYPTO_PRIVATE_KEY
ARG NEXT_PUBLIC_LOGO
ARG NEXT_PUBLIC_PLATFORM_NAME
ARG NEXT_PUBLIC_APPLICATION_ENDPOINT
ARG NEXT_PUBLIC_CREDEBL_UI_PATH
ARG NEXT_PUBLIC_CLIENT_URL
ARG NEXT_PUBLIC_CLIENT_NAME
ARG NEXT_PUBLIC_PLATFORM_CLIENT_ID
ARG NEXT_PUBLIC_PLATFORM_CLIENT_SECRET
ARG NEXT_PUBLIC_QR_ENCRYPTION_DECREPTION_KEY
ENV NEXT_PUBLIC_BASE_API_PATH=$NEXT_PUBLIC_BASE_API_PATH \
    NEXT_PUBLIC_PAYMENT_GATEWAY_ENDPOINT=$NEXT_PUBLIC_PAYMENT_GATEWAY_ENDPOINT \
    NEXT_PUBLIC_CRYPTO_PRIVATE_KEY=$NEXT_PUBLIC_CRYPTO_PRIVATE_KEY \
    NEXT_PUBLIC_LOGO=$NEXT_PUBLIC_LOGO \
    NEXT_PUBLIC_PLATFORM_NAME=$NEXT_PUBLIC_PLATFORM_NAME \
    NEXT_PUBLIC_APPLICATION_ENDPOINT=$NEXT_PUBLIC_APPLICATION_ENDPOINT \
    NEXT_PUBLIC_CREDEBL_UI_PATH=$NEXT_PUBLIC_CREDEBL_UI_PATH \
    NEXT_PUBLIC_CLIENT_URL=$NEXT_PUBLIC_CLIENT_URL \
    NEXT_PUBLIC_CLIENT_NAME=$NEXT_PUBLIC_CLIENT_NAME \
    NEXT_PUBLIC_PLATFORM_CLIENT_ID=$NEXT_PUBLIC_PLATFORM_CLIENT_ID \
    NEXT_PUBLIC_PLATFORM_CLIENT_SECRET=$NEXT_PUBLIC_PLATFORM_CLIENT_SECRET \
    NEXT_PUBLIC_QR_ENCRYPTION_DECREPTION_KEY=$NEXT_PUBLIC_QR_ENCRYPTION_DECREPTION_KEY

# Build Next.js app
RUN bun --bun run build


# ---------------------
# Production stage
# ---------------------
FROM oven/bun:1.3.3-alpine AS production

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy required runtime files
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/src/app ./src/app
COPY --from=build /app/next.config.mjs ./next.config.mjs

# Fix ownership
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3001

# Start Next.js
CMD ["bun", "run", "start"]
