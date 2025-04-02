# Usa uma imagem leve do Node.js
FROM node:20-alpine

# Instala o OpenSSL para suporte ao crypto
RUN apk add --no-cache openssl

# Define o diretório de trabalho
WORKDIR /app

# Instala o cliente do PostgreSQL
RUN apk add --no-cache postgresql-client

# Copia apenas os arquivos de dependências primeiro
COPY ../../backend/package.json ../../backend/package-lock.json ./

# Instala as dependências
RUN npm install

# Copia o restante do código do backend
COPY ../../backend .

# Compila o código NestJS
RUN npm run build

# Expõe a porta do backend
EXPOSE 3001

# Define o ambiente com a importação do crypto antes de iniciar
CMD ["node", "-r", "crypto", "dist/main.js"]
