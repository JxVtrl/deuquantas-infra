#!/bin/bash

# Configurações
PROJECT_ID="deuquantas-456304" # Substitua pelo seu Project ID do Google Cloud
REGION="southamerica-east1" # Região mais próxima do Brasil
SERVICE_NAME="deuquantas-api"
REPOSITORY="deuquantas"
IMAGE_NAME="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$SERVICE_NAME"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Iniciando processo de deploy...${NC}"

# Verificar se o gcloud está instalado
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Google Cloud SDK não encontrado. Por favor, instale-o primeiro.${NC}"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Verificar se está autenticado
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo -e "${YELLOW}Autenticando no Google Cloud...${NC}"
    gcloud auth login
fi

# Configurar projeto
echo -e "${YELLOW}Configurando projeto...${NC}"
gcloud config set project $PROJECT_ID

# Configurar autenticação Docker
echo -e "${YELLOW}Configurando autenticação Docker...${NC}"
gcloud auth configure-docker $REGION-docker.pkg.dev

# Criar repositório no Artifact Registry (se não existir)
echo -e "${YELLOW}Verificando repositório...${NC}"
if ! gcloud artifacts repositories describe $REPOSITORY --location=$REGION &> /dev/null; then
    echo -e "${YELLOW}Criando repositório no Artifact Registry...${NC}"
    gcloud artifacts repositories create $REPOSITORY \
        --repository-format=docker \
        --location=$REGION \
        --description="Repositório de imagens Docker para Deu Quantas"
fi

# Build da imagem
echo -e "${YELLOW}Construindo imagem Docker...${NC}"
docker build -t $IMAGE_NAME -f Dockerfile.prod .

# Push da imagem para o Artifact Registry
echo -e "${YELLOW}Enviando imagem para o Artifact Registry...${NC}"
docker push $IMAGE_NAME

# Deploy no Cloud Run
echo -e "${YELLOW}Deployando no Cloud Run...${NC}"
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_NAME \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --min-instances 0 \
    --max-instances 1 \
    --cpu 1 \
    --memory 512Mi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Deploy concluído com sucesso!${NC}"
    echo -e "${YELLOW}URL da API:${NC}"
    gcloud run services describe $SERVICE_NAME --region $REGION --format="value(status.url)"
else
    echo -e "${RED}Erro durante o deploy${NC}"
    exit 1
fi 