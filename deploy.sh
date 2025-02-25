#!/bin/bash

set -e  # Para o script se qualquer comando falhar

echo "🚀 Iniciando o deploy do backend..."

# 1️⃣ Construir a imagem Docker
echo "🔨 Construindo a imagem do backend..."
docker build -t majorssolutions/deuquantas-backend:latest -f infra/docker/backend/Dockerfile backend/

# 2️⃣ Fazer login no Docker Hub (caso necessário)
echo "🔑 Fazendo login no Docker Hub..."
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

# 3️⃣ Fazer push da imagem para o Docker Hub
echo "📤 Enviando a imagem para o Docker Hub..."
docker push majorssolutions/deuquantas-backend:latest

# 4️⃣ Rodar o Ansible para atualizar o servidor
echo "🔄 Atualizando o backend no servidor com Ansible..."
ansible-playbook -i inventories/dev/hosts playbooks/setup-backend.yml

echo "✅ Deploy finalizado com sucesso!"
