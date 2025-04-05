# Cores para output
$RED = [System.ConsoleColor]::Red
$GREEN = [System.ConsoleColor]::Green
$YELLOW = [System.ConsoleColor]::Yellow

Write-Host "Iniciando limpeza do Docker..." -ForegroundColor $YELLOW

# Parar todos os containers
Write-Host "Parando todos os containers..." -ForegroundColor $YELLOW
docker stop $(docker ps -a -q) 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Nenhum container em execução" -ForegroundColor $GREEN
}

# Remover todos os containers
Write-Host "Removendo todos os containers..." -ForegroundColor $YELLOW
docker rm $(docker ps -a -q) 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Nenhum container para remover" -ForegroundColor $GREEN
}

# Remover todos os volumes
Write-Host "Removendo todos os volumes..." -ForegroundColor $YELLOW
docker volume rm $(docker volume ls -q) 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Nenhum volume para remover" -ForegroundColor $GREEN
}

# Remover todas as imagens
Write-Host "Removendo todas as imagens..." -ForegroundColor $YELLOW
docker rmi $(docker images -q) 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Nenhuma imagem para remover" -ForegroundColor $GREEN
}

# Remover redes não utilizadas
Write-Host "Removendo redes não utilizadas..." -ForegroundColor $YELLOW
docker network prune -f

# Limpar cache do builder
Write-Host "Limpando cache do builder..." -ForegroundColor $YELLOW
docker builder prune -f

Write-Host "Limpeza concluída com sucesso!" -ForegroundColor $GREEN 