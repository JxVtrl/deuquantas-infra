# Configuração do Provider AWS
provider "aws" {
  region  = "us-east-2"
  profile = "conta-pessoal"
}

# Variáveis para tornar reutilizável
variable "instance_type" {
  default = "t2.micro"
}

variable "db_password" {
  default = "senha_super_segura"
}

# Criando Security Group para EC2
resource "aws_security_group" "deuquantas_sg" {
  name        = "deuquantas-sg"
  description = "Permite trafego para o backend"

  # Permitir acesso SSH apenas do seu IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["177.205.169.125/32"]  # Substitua pelo seu IP real
  }

  # Permitir tráfego HTTP (caso use Nginx)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego para backend na porta 3000
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego PostgreSQL apenas na VPC
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Permitir todo tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Criando Instância EC2 para o Backend
resource "aws_instance" "deuquantas_backend" {
  ami           = "ami-03dc37e5d50384ad1"  # AMI do Ubuntu
  instance_type = var.instance_type
  security_groups = [aws_security_group.deuquantas_sg.name]

  tags = {
    Name = "deuquantas-dev-backend"
  }

  # Script de inicialização para instalar Docker e rodar o backend
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo docker run -d -p 3000:3000 meu_usuario/deuquantas-backend:latest
              EOF
}

# Criando Banco de Dados RDS (PostgreSQL)
resource "aws_db_instance" "deuquantas_db" {
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_name           = "deuquantas"
  username         = "postgres"
  password         = var.db_password
  publicly_accessible = false
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.deuquantas_sg.id]
}

# Criando um Load Balancer (Futuro Escalonamento)
resource "aws_lb" "deuquantas_lb" {
  name               = "deuquantas-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.deuquantas_sg.id]
  subnets            = ["subnet-0ca718d7c149c9c73"]  # Substitua pelo ID da subnet pública
}


resource "aws_lb_target_group" "deuquantas_tg" {
  name     = "deuquantas-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "vpc-004e0bab6fb94a9e4"  # Substitua pelo ID correto
}

resource "aws_lb_listener" "deuquantas_listener" {
  load_balancer_arn = aws_lb.deuquantas_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.deuquantas_tg.arn
  }
}
