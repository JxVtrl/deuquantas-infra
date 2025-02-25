# Usa uma imagem leve do Node.js
FROM node:18-alpine

# Define o diretório de trabalho
WORKDIR /app

# Copia apenas os arquivos de dependências primeiro
COPY ../../backend/package.json ../../backend/package-lock.json ./

# Instala as dependências
RUN npm install

# Copia o restante do código do backend
COPY ../../backend .

# Compila o código NestJS
RUN npm run build

# Expõe a porta do backend
EXPOSE 3000

# Comando de inicialização
CMD ["npm", "run", "start:prod"]
