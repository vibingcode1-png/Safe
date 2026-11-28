# syntax=docker/dockerfile:1
FROM node:20-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-pip git \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci || npm install

COPY requirements.txt .
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir --break-system-packages -r requirements.txt; fi

COPY . .

RUN apt-get purge -y --auto-remove git && rm -rf /var/lib/apt/lists/*

STOPSIGNAL SIGINT

CMD ["sh", "-c", "npx tsx src/server.ts --host 0.0.0.0 --port ${PORT:-10000}"]