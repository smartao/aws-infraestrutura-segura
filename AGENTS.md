Você é um especialista em AWS, redes e Terraform.

Seu objetivo é PROJETAR e DESCREVER uma infraestrutura segura para aplicações internas na AWS, totalmente provisionada via Terraform, seguindo rigorosamente os requisitos abaixo.

========================

🔴 CENÁRIO 7 – INFRAESTRUTURA SEGURA PARA APLICAÇÕES INTERNAS

🎯 OBJETIVO
Projetar uma arquitetura AWS que simule um ambiente corporativo real, onde:

- Nenhuma instância de aplicação possui IP público
- A aplicação NÃO é acessível diretamente pela internet
- O acesso administrativo ocorre apenas via Bastion Host
- Segurança é aplicada em múltiplas camadas (rede + compute)
- A infraestrutura é descrita como código (Terraform)

========================

🧱 ARQUITETURA GERAL

- 1 VPC dedicada
- Subnets públicas e privadas
- Application Load Balancer interno
- EC2 privadas para aplicação
- Bastion Host em subnet pública
- NAT Gateway para saída controlada
- Security Groups bem segmentados

========================

🌐 REDE (NETWORKING)

Requisitos obrigatórios:

- VPC com CIDR configurável via variável
- Uso de pelo menos 2 Availability Zones
- Subnets:
  - Subnet pública:
    - Internet Gateway
    - NAT Gateway
    - Bastion Host
  - Subnets privadas:
    - EC2 de aplicação
    - Application Load Balancer interno
- Route Tables separadas:
  - Subnet pública com rota para Internet Gateway
  - Subnets privadas com rota default apontando para NAT Gateway

⚠️ Restrições:

- EC2 de aplicação NÃO podem ter IP público
- EC2 privadas NÃO podem ter rota direta para Internet Gateway
- Todo acesso externo deve ser bloqueado

========================

⚖️ LOAD BALANCER

- Application Load Balancer (ALB)
- Tipo: interno (internal = true)
- Associado às subnets privadas
- Listener HTTP ou HTTPS
- Target Group com instâncias EC2 privadas

Regras:

- O ALB NÃO deve ser acessível pela internet
- Security Group do ALB deve permitir tráfego apenas da rede interna

========================

🖥️ COMPUTE (EC2)

- Instâncias EC2 privadas
- Distribuídas em múltiplas AZs
- AMI obtida dinamicamente
- User Data para simular aplicação (ex: Nginx)

Restrições:

- associate_public_ip_address = false
- Comunicação permitida apenas via ALB
- Auto Scaling Group é opcional, mas desejável

========================

🔐 SEGURANÇA

Security Groups separados por função:

- SG-BASTION
- SG-ALB
- SG-APP

Regras mínimas:

- SG-BASTION:
  - SSH permitido apenas de IPs confiáveis
- SG-APP:
  - Aceita tráfego SOMENTE do SG-ALB
  - SSH permitido SOMENTE a partir do Bastion
- SG-ALB:
  - Aceita tráfego apenas da rede interna

Aplicar o princípio do menor privilégio.
Evitar CIDRs amplos como 0.0.0.0/0.

========================

🗂️ TERRAFORM (REQUISITOS TÉCNICOS)

- Backend remoto no S3
- Uso de:
  - variables.tf
  - outputs.tf
  - locals.tf
- Estrutura modular mínima:
  - module/network
  - module/compute
  - module/security

========================

🧪 CRITÉRIOS DE VALIDAÇÃO

- EC2 privadas NÃO acessíveis pela internet
- ALB não responde externamente
- Acesso administrativo apenas via Bastion Host
- terraform plan sem mudanças após apply

========================

📄 DOCUMENTAÇÃO ESPERADA

- Diagrama lógico da arquitetura
- Explicação das decisões de segurança
- Passos para deploy e destroy
- Lista de variáveis configuráveis

========================

🏁 ESCOPO IDEAL

- 1 região AWS
- 2 Availability Zones
- 1 Bastion Host público
- 2 EC2 privadas de aplicação
- 1 ALB interno
- 2 NAT Gateway

========================

INSTRUÇÃO FINAL

Com base nos requisitos acima:

- Explique a arquitetura
- Justifique as decisões técnicas
- Sugira como implementar isso em Terraform
- Mantenha foco em boas práticas corporativas e segurança
