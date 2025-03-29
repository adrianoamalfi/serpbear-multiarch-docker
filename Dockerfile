# Stage 0: Base
# FROM node:lts-slim AS base
FROM --platform=${BUILDPLATFORM} node:lts-slim AS base

LABEL maintainer="adrianoamalfi"
LABEL org.opencontainers.image.authors "Adriano Amalfi"
LABEL org.opencontainers.image.description "Universal Docker images for Serpbear Open Source Search Engine Position Tracking App"
LABEL org.opencontainers.image.url "https://github.com/adrianoamalfi/serpbear-multiarch-docker"
LABEL org.opencontainers.image.documentation "https://raw.githubusercontent.com/adrianoamalfi/serpbear-multiarch-docker/main/README.md"
LABEL org.opencontainers.image.source "https://raw.githubusercontent.com/adrianoamalfi/serpbear-multiarch-docker/main/Dockerfile"
LABEL org.opencontainers.image.version "v2.0.7"
LABEL org.opencontainers.image.base.name "node:lts-slim"
LABEL org.opencontainers.image.licenses "MIT"

LABEL maintainer="Adriano Amalfi <adrianoamalfi@gmail.com>" \
      version="2.0.7" \
      description="Universal Docker images for Serpbear Open Source Search Engine Position Tracking App"


ENV NPM_VERSION=10.3.0
ENV PYTHON=/usr/bin/python3

# Aggiorna npm e installa le dipendenze di build necessarie
RUN npm install -g npm@"${NPM_VERSION}" && \
    apt-get update && apt-get install -y --no-install-recommends \
        python3 python3-pip make g++ build-essential curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Stage 1: Dependencies
FROM base AS deps
ARG SERPBEAR_VERSION=2.0.7
WORKDIR /src
# Scarica e decomprimi l'archivio
RUN curl -fsSL -o serpbear.tar.gz "https://github.com/towfiqi/serpbear/archive/refs/tags/v${SERPBEAR_VERSION}.tar.gz" && \
    tar -zxf serpbear.tar.gz && \
    mv serpbear-${SERPBEAR_VERSION} serpbear && \
    rm serpbear.tar.gz
WORKDIR /src/serpbear
# Installa le dipendenze ignorando quelle di sviluppo
RUN npm install --omit=dev

# Stage 2: Build
FROM base AS builder
WORKDIR /app
COPY --from=deps /src/serpbear ./
# Rimuove cartelle non necessarie per ridurre il peso e costruisce l'applicazione
RUN rm -rf data __tests__ __mocks__ && \
    npm run build

# Stage 3: Runtime (Runner)
FROM node:lts-slim AS runner
WORKDIR /app
ENV NODE_ENV=production

LABEL stage="production"

# Aggiungi un healthcheck per monitorare lo stato dell'applicazione
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

# Creazione di un utente non root per motivi di sicurezza
RUN groupadd -r nodejs --gid 1001 && \
    useradd -r -u 1001 -g nodejs nextjs && \
    mkdir -p /app/data && \
    chown nextjs:nodejs /app/data

# Copia degli artefatti necessari dalla fase di build
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/cron.js ./cron.js
COPY --from=builder --chown=nextjs:nodejs /app/email ./email
COPY --from=builder --chown=nextjs:nodejs /app/database ./database
COPY --from=builder --chown=nextjs:nodejs /app/.sequelizerc ./.sequelizerc
COPY --from=builder --chown=nextjs:nodejs /app/entrypoint.sh ./entrypoint.sh

# Imposta i permessi eseguibili per lo script entrypoint
RUN chmod +x /app/entrypoint.sh

# Se non hai un package.json di produzione predefinito, rigeneralo e installa le dipendenze runtime
RUN rm -f package.json && \
    npm init -y && \
    npm install cryptr@6.0.3 dotenv@16.0.3 croner@9.0.0 @googleapis/searchconsole@1.0.5 sequelize-cli@6.6.2 @isaacs/ttlcache@1.4.1 && \
    npm install -g concurrently

USER nextjs
EXPOSE 3000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["concurrently", "node server.js", "node cron.js"]