provider "aws" {
  region = "sa-east-1"
  profile = "conta-pessoal"
}

resource "aws_instance" "app" {
  ami           = "ami-00400ab4ebe313814"
  instance_type = "t2.micro"
  tags = {
    Name = "deuquantas-dev-app"
  }
}
