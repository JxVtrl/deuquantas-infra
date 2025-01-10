
# Deu Quantas - Infraestrutura

Este repositório contém a infraestrutura como código (IaC) para o projeto **Deu Quantas**, responsável por configurar, provisionar e gerenciar os recursos necessários para o backend, frontend e serviços auxiliares. Ele utiliza ferramentas como **Terraform**, **Ansible** e **Docker** para automação e escalabilidade.

## 📂 Estrutura do Repositório

```plaintext
deuquantas-infra/
├── terraform/         # Configurações do Terraform para provisionamento de infraestrutura
│   ├── dev/           # Ambiente de desenvolvimento
│   ├── staging/       # Ambiente de homologação
│   └── prod/          # Ambiente de produção
├── ansible/           # Configuração do Ansible para gerenciar servidores e deploy
│   ├── playbooks/     # Playbooks do Ansible
│   └── roles/         # Papéis de configuração
├── docker/            # Configurações do Docker
│   ├── Dockerfile     # Configuração do backend
│   └── docker-compose.yml # Orquestração local para serviços
├── .github/             # Pipelines para GitHub Actions
└── README.md          # Este arquivo
```

---

## 🚀 Funcionalidades

### **Terraform**
O Terraform é usado para provisionar e gerenciar a infraestrutura na AWS:
- Criação de instâncias EC2 para o backend.
- Configuração de redes (VPC, subnets e security groups).
- Banco de dados gerenciado (RDS - PostgreSQL).
- Armazenamento de objetos (S3).
- Balanceador de carga (ALB/ELB).

### **Ansible**
O Ansible automatiza a configuração dos servidores:
- Instalação de dependências (Python, PostgreSQL, etc.).
- Configuração do backend em instâncias EC2.
- Automação de tarefas de gerenciamento e deploy.

### **Docker**
O Docker facilita a execução dos serviços localmente:
- Imagens Docker para o backend.
- Orquestração dos serviços com Docker Compose.
- Deploy simplificado em ambientes configurados com Docker.

### **CI/CD**
Automação dos pipelines para build, teste e deploy:
- **GitHub Actions** para automação de pipelines.
- **GitLab CI** para integração opcional com GitLab.
- **Jenkins** para deploy e execução customizada.

---

## 🛠 Configurações e Pré-requisitos

### **Ferramentas Necessárias**
Certifique-se de que as seguintes ferramentas estão instaladas no seu ambiente de desenvolvimento:
- [Terraform](https://www.terraform.io/) (v1.5+)
- [Ansible](https://www.ansible.com/) (v2.12+)
- [Docker](https://www.docker.com/) e [Docker Compose](https://docs.docker.com/compose/) (v2.5+)
- [AWS CLI](https://aws.amazon.com/cli/)

### **Configuração Inicial**
1. **Configurar Credenciais AWS**:
   ```bash
   aws configure
   ```
   Insira o `AWS Access Key`, `AWS Secret Key` e `region`.

2. **Inicializar o Terraform**:
   Navegue até o diretório desejado e execute:
   ```bash
   terraform init
   terraform apply
   ```

3. **Executar o Ansible**:
   Execute os playbooks para configurar o ambiente:
   ```bash
   ansible-playbook ansible/playbooks/setup-backend.yml
   ```

4. **Rodar o Docker Compose**:
   Suba os serviços localmente:
   ```bash
   docker-compose up --build
   ```

---

## 🧩 Configuração do CI/CD

### **GitHub Actions**
Os pipelines do GitHub Actions estão configurados no diretório `ci-cd/github/`. Certifique-se de configurar os segredos no repositório:
- **AWS_ACCESS_KEY_ID** e **AWS_SECRET_ACCESS_KEY** para o Terraform.
- **DOCKER_USERNAME** e **DOCKER_PASSWORD** para push de imagens.
- **SSH_KEY**, **HOST**, **USER** para deploy remoto.

### **GitLab CI**
Para usar o GitLab CI, configure o arquivo `.gitlab-ci.yml` com base nos exemplos em `ci-cd/gitlab/`.

### **Jenkins**
Se utilizar Jenkins, os pipelines podem ser configurados a partir dos exemplos em `ci-cd/jenkins/`.

---

## 🌐 Deploy

### **Ambiente de Desenvolvimento**
1. Suba os serviços localmente usando Docker Compose.
2. Acesse o backend em: [http://localhost:8000](http://localhost:8000).

### **Ambiente de Produção**
1. Provisione a infraestrutura com Terraform no diretório `terraform/prod`.
2. Configure os servidores com Ansible.
3. Faça o deploy final do backend usando Docker Compose ou Ansible.

---

## 🔒 Segurança

1. **Segredos**: Armazene chaves sensíveis (AWS, SSH, etc.) nos sistemas de segredo das ferramentas CI/CD ou localmente no arquivo `~/.ssh/`.
2. **Princípio do Menor Privilégio**: Configure políticas IAM para dar apenas as permissões necessárias.
3. **State do Terraform**: Evite versionar os arquivos `terraform.tfstate` no repositório.

---

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

Se precisar de mais informações ou encontrar problemas, abra uma **issue** ou entre em contato com a equipe de infraestrutura. 🚀
