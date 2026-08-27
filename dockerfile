# Stage 1: Base image and pnpm setup
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI="true"
RUN corepack enable

# Stage 2: Install dependencies
FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
# Tell pnpm to turn off strict build failures inside the container
RUN pnpm config set strict-dep-builds false
# Install without triggering arbitrary postinstall scripts when possible
RUN pnpm install --frozen-lockfile

# Stage 3: Build the Next.js application
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Build the standalone server
#VIEWS_IP_SALT dummy value only for build process, make sure you actually have a real secret generated and set for VIEWS_IP_SALT in your .env file
RUN VIEWS_IP_SALT="dummy_build_salt_123456" pnpm build 

# Stage 4: Production runner
FROM base AS runner
WORKDIR /app
ENV NODE_ENV="production"
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Create a non-root system user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy static assets
COPY --from=builder /app/public ./public

# Copy the full node_modules from deps to bypass Next.js tracing missing sharp's .so dependencies on pnpm
COPY --from=deps --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000

# The standalone output generates its own minimal server.js
CMD ["node", "server.js"]