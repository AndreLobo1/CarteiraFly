# ========================================
# ESTÁGIO 1: BUILDER - Ferramentas de Build
# ========================================
FROM node:20-bullseye-slim AS builder

# Instala dependências do sistema necessárias para build
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Define diretório de trabalho
WORKDIR /app

# Copia arquivos de dependências primeiro (otimiza cache de camadas)
COPY atualizador/package*.json ./atualizador/
COPY requirements.txt ./

# Instala dependências Node.js
RUN cd atualizador && npm ci --only=production

# Instala dependências Python
RUN pip3 install --no-cache-dir -r requirements.txt

# Copia o código da aplicação
COPY atualizador/ ./atualizador/
COPY run_export.py ./
COPY entrypoint.sh ./

# Dá permissão de execução para o entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# ========================================
# ESTÁGIO 2: FINAL - Imagem de Produção
# ========================================
FROM node:20-bullseye-slim AS final

# Instala Python e SQLite3
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Define diretório de trabalho
WORKDIR /app

# Copia apenas os artefatos necessários do estágio builder
COPY --from=builder /app/atualizador/node_modules ./atualizador/node_modules
COPY --from=builder /app/atualizador/ ./atualizador/
COPY --from=builder /app/run_export.py ./
COPY --from=builder /app/entrypoint.sh ./

# Instala dependências Python no estágio final
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

# Define entrypoint do container
ENTRYPOINT ["/app/entrypoint.sh"]
