# Usa a imagem oficial do Node.js
FROM node:18-alpine

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia os arquivos do projeto para dentro do container
COPY package*.json ./

# Instala as dependências
RUN npm install

# Copia o restante do código para dentro do container
COPY . .

# Expõe a porta do backend
EXPOSE 3000

# Inicia o backend
CMD ["npm", "run", "start:prod"]
