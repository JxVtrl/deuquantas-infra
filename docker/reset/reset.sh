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

# Subindo os containers novamente
echo -e "${YELLOW}Iniciando os containers...${NC}"
docker-compose -f ../docker-compose.yml up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Containers iniciados com sucesso!${NC}"
    
    # Função para verificar se o container está pronto
    wait_container_ready() {
        local container_name=$1
        local max_attempts=30
        local delay_seconds=5
        local attempt=0
        
        while [ $attempt -lt $max_attempts ]; do
            local container_status=$(docker inspect -f '{{.State.Status}}' $container_name 2>/dev/null)
            if [ "$container_status" = "running" ]; then
                echo -e "${GREEN}Container $container_name está pronto!${NC}"
                return 0
            fi
            echo -e "${YELLOW}Aguardando container $container_name estar pronto... (tentativa $((attempt + 1)) de $max_attempts)${NC}"
            sleep $delay_seconds
            attempt=$((attempt + 1))
        done
        echo -e "${RED}Timeout aguardando container $container_name${NC}"
        return 1
    }

    # Aguardar o container do backend estar pronto
    if wait_container_ready "deuquantas-backend"; then
        # Aguardar mais um pouco para garantir que o banco está pronto
        echo -e "${YELLOW}Aguardando banco de dados estar pronto...${NC}"
        sleep 12

        # Executa o script SQL para criar os dados de teste
        echo -e "${YELLOW}Criando dados de teste...${NC}"
        docker exec -i deuquantas-db psql -U postgres -d deuquantas < "$(dirname "$0")/scripts/create-users.sql"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Dados de teste criados com sucesso!${NC}"
        else
            echo -e "${RED}Erro ao criar dados de teste${NC}"
        fi
    else
        echo -e "${RED}Não foi possível executar o script de criação de dados${NC}"
    fi
else
    echo -e "${RED}Erro ao iniciar os containers${NC}"
fi 