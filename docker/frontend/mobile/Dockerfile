# Etapa 1: Build
FROM node:18-alpine AS builder

# Definir o diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar dependências
RUN npm install --legacy-peer-deps

# Copiar o restante do código do projeto
COPY . .

# Construir a aplicação Expo
RUN npx expo export

# Etapa 2: Produção
FROM nginx:alpine AS production

# Copiar arquivos de exportação para o NGINX
COPY --from=builder /app/dist /usr/share/nginx/html

# Expor a porta do NGINX
EXPOSE 80

# Iniciar o NGINX
CMD ["nginx", "-g", "daemon off;"]
