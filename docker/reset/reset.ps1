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

# Subindo os containers novamente
Write-Host "Iniciando os containers..." -ForegroundColor $YELLOW
docker-compose -f ../docker-compose.yml up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "Containers iniciados com sucesso!" -ForegroundColor $GREEN
    
    # Função para verificar se o container está pronto
    function Wait-ContainerReady {
        param (
            [string]$ContainerName,
            [int]$MaxAttempts = 30,
            [int]$DelaySeconds = 5
        )
        
        $attempt = 0
        while ($attempt -lt $MaxAttempts) {
            $containerStatus = docker inspect -f '{{.State.Status}}' $ContainerName 2>$null
            if ($containerStatus -eq "running") {
                Write-Host "Container $ContainerName está pronto!" -ForegroundColor $GREEN
                return $true
            }
            Write-Host "Aguardando container $ContainerName estar pronto... (tentativa $($attempt + 1) de $MaxAttempts)" -ForegroundColor $YELLOW
            Start-Sleep -Seconds $DelaySeconds
            $attempt++
        }
        Write-Host "Timeout aguardando container $ContainerName" -ForegroundColor $RED
        return $false
    }

    # Aguardar o container do backend estar pronto
    if (Wait-ContainerReady -ContainerName "deuquantas-backend") {
        # Aguardar mais um pouco para garantir que o banco está pronto
        Write-Host "Aguardando banco de dados estar pronto..." -ForegroundColor $YELLOW
        Start-Sleep -Seconds 12

       # Executa o script SQL para criar os dados de teste
        Write-Host "Criando dados de teste..."
        Get-Content "$PSScriptRoot\scripts\create-users.sql" | docker exec -i deuquantas-db psql -U postgres -d deuquantas

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Dados de teste criados com sucesso!" -ForegroundColor $GREEN
        } else {
            Write-Host "Erro ao criar dados de teste" -ForegroundColor $RED
        }
    } else {
        Write-Host "Não foi possível executar o script de criação de dados" -ForegroundColor $RED
    }
} else {
    Write-Host "Erro ao iniciar os containers" -ForegroundColor $RED
} 