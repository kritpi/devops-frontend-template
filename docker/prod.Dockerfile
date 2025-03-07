# ───────────────────────────────────────────────────────────
# 🏗️ Stage 1: Build the Next.js Application
# ───────────────────────────────────────────────────────────

FROM node:22-alpine AS builder
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm
COPY package.json pnpm-log.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .


# ───────────────────────────────────────────────────────────
# 🚀 Stage 2: Create the Final Runtime Image
# ───────────────────────────────────────────────────────────

RUN pnpm run build

# Production Stage
FROM node:22-alpine AS runner
WORKDIR /app

# Install pnpm globally in the runner stage
RUN npm install -g pnpm
COPY --from=builder /app/package.json .
COPY --from=builder /app/pnpm-lock.yaml .

# Install production dependencies only
RUN pnpm install --prod

# Copy necessary project files
COPY --from=builder /app/next.config.ts ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

ENV NODE_ENV=production

EXPOSE 3000
CMD ["pnpm", "start"]