FROM --platform=${BUILDPLATFORM} node:lts-alpine AS deps

LABEL maintainer="adrianoamalfi"
LABEL org.opencontainers.image.authors "Adriano Amalfi"
LABEL org.opencontainers.image.description "Universal Docker images for Serpbear Open Source Search Engine Position Tracking App"
LABEL org.opencontainers.image.url "https://github.com/adrianoamalfi/serpbear-multiarch-docker"
LABEL org.opencontainers.image.documentation "https://raw.githubusercontent.com/adrianoamalfi/serpbear-multiarch-docker/main/README.md"
LABEL org.opencontainers.image.source "https://raw.githubusercontent.com/adrianoamalfi/serpbear-multiarch-docker/main/Dockerfile"
LABEL org.opencontainers.image.version "v0.2.4"
LABEL org.opencontainers.image.base.name "node:lts-alpine"
LABEL org.opencontainers.image.licenses "MIT"

ARG SERPBEAR_VERSION=0.2.2

WORKDIR /src

ADD https://github.com/towfiqi/serpbear/archive/refs/tags/v${SERPBEAR_VERSION}.tar.gz ./
RUN tar -zvxf v${SERPBEAR_VERSION}.tar.gz && mv serpbear-${SERPBEAR_VERSION} serpbear

RUN apk add --update python3 py3-pip 

RUN cd serpbear/ && npm install

FROM node:lts-alpine AS builder
WORKDIR /app
COPY --from=deps /src/serpbear ./
RUN npm run build


FROM node:lts-alpine AS runner
WORKDIR /app
ENV NODE_ENV production
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
RUN set -xe && mkdir -p /app/data && chown nextjs:nodejs /app/data
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
# COPY --from=builder --chown=nextjs:nodejs /app/data ./data
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# setup the cron
COPY --from=builder --chown=nextjs:nodejs /app/cron.js ./
COPY --from=builder --chown=nextjs:nodejs /app/email ./email
RUN rm package.json
RUN npm init -y 
RUN npm i cryptr dotenv croner @googleapis/searchconsole
RUN npm i -g concurrently

USER nextjs

EXPOSE 3000

CMD ["concurrently","node server.js", "node cron.js"]