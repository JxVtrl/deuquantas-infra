#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Iniciando limpeza do Docker...${NC}"

# Parar todos os containers
echo -e "${YELLOW}Parando todos os containers...${NC}"
docker stop $(docker ps -a -q) 2>/dev/null || echo -e "${GREEN}Nenhum container em execução${NC}"

# Remover todos os containers
echo -e "${YELLOW}Removendo todos os containers...${NC}"
docker rm $(docker ps -a -q) 2>/dev/null || echo -e "${GREEN}Nenhum container para remover${NC}"

# Remover todos os volumes
echo -e "${YELLOW}Removendo todos os volumes...${NC}"
docker volume rm $(docker volume ls -q) 2>/dev/null || echo -e "${GREEN}Nenhum volume para remover${NC}"

# Remover todas as imagens
echo -e "${YELLOW}Removendo todas as imagens...${NC}"
docker rmi $(docker images -q) 2>/dev/null || echo -e "${GREEN}Nenhuma imagem para remover${NC}"

# Remover redes não utilizadas
echo -e "${YELLOW}Removendo redes não utilizadas...${NC}"
docker network prune -f

# Limpar cache do builder
echo -e "${YELLOW}Limpando cache do builder...${NC}"
docker builder prune -f

echo -e "${GREEN}Limpeza concluída com sucesso!${NC}" 