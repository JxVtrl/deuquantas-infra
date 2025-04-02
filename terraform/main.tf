provider "aws" {
  region  = "us-east-1"
}

# Criar um Security Group para permitir acesso
resource "aws_security_group" "deuquantas_sg" {
  name        = "deuquantas-sg"
  description = "Allow SSH, HTTP, and application traffic"

  # Permitir SSH apenas do seu IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["177.205.169.125/32"]  # Substitua pelo seu IP real
  }

  # Permitir HTTP para acesso à aplicação
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego para o backend (porta 3001)
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir saída para qualquer destino
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criar uma chave SSH para acessar a máquina
resource "aws_key_pair" "deuquantas_key" {
  key_name   = "deuquantas-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Certifique-se de ter essa chave gerada
}

# Criar uma Instância EC2 com Ubuntu
resource "aws_instance" "deuquantas_backend" {
  ami           = "ami-02396cdd13e9a1257"  # Ubuntu 22.04 LTS - Substitua por uma AMI válida
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deuquantas_key.key_name
  security_groups = [aws_security_group.deuquantas_sg.name]

  tags = {
    Name = "deuquantas-backend"
  }

  user_data = <<-EOF
            #!/bin/bash
            sudo apt update -y
            sudo apt install -y docker.io
            sudo systemctl enable docker
            sudo systemctl start docker
            sudo docker run -d -p 3001:3001 meu_usuario/deuquantas-backend:latest
            EOF
}

output "public_ip" {
  value = aws_instance.deuquantas_backend.public_ip
  description = "IP Público da Instância"
}
