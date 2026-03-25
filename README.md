![license](https://img.shields.io/badge/License-MIT-orange?style=flat-square)

# 🛡️ AWS Secure Infrastructure

Terraform project to deploy an internal application with secure infrastructure on AWS.

## 📋 Table of Contents

- 🌐 [Network Topology](#-network-topology)
- 📐 [Architecture and Security Decisions](#-architecture-and-security-decisions)
- ✅ [Prerequisites](#-prerequisites)
- 📖 [How to Use (Deploy and Destroy)](#-how-to-use-deploy-and-destroy)
- 📝 [Terraform Documentation](#-terraform-documentation)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

## 🌐 Network Topology

![Network Topology](imagens/topologia-rede-projeto.png)

## 📐 Architecture and Security Decisions

The architecture was designed simulating a real corporate environment focusing on high security, compliance, and scalability:

- **Private by Default**: No application instances (EC2) have a public IP (`associate_public_ip_address = false`). The application is not directly accessible from the internet.
- **Dynamic Internal Load Balancer (ALB)**: The ALB is associated with private subnets and configured as internal (`internal = true`). It automatically configures its listener port (80 or 443) based on the specified protocol (`HTTP` or `HTTPS`). To ensure encryption in transit, `HTTPS` is the default and uses a self-signed certificate managed by the **ACM** module. The Security Group (`SG-ALB`) only accepts traffic from the internal network (VPC CIDR).
- **Web Application Firewall (WAF)**: An optional but highly recommended WAF layer is managed via the remote module `smartao/wafv2-web-acl/aws` to protect the ALB against common web exploits. In `prod` environments, the WAF is strictly **mandatory**.
- **Bastion Host (VPN Client Simulation)**: This host is utilized strictly to simulate an external corporate connection, acting similarly to an AWS Client VPN endpoint. It is designed to evaluate internal application accessibility via HTTP/HTTPS only, without being used for traditional administrative SSH access to the application instances. Located in a public subnet, its Security Group (`SG-BASTION`) restricts access to configured trusted IPs, applying the principle of least privilege.
- **Production Guardrails (Infrastructure Validation)**: The codebase employs strict `terraform_data` lifecycle preconditions enforcement to validate the security posture before deployment, especially when `environment = "prod"`:
  - 🛑 Blocks the wildcard `0.0.0.0/0` in Bastion ingress.
  - 🛡️ Demands that `enable_waf = true`.
  - 🔒 Requires `alb_listener_protocol = "HTTPS"`.
  - 🚫 Disables the output of sensitive developer access information.
- **Controlled External Access**: Private instances use a NAT Gateway (located in the public subnets) for controlled outbound communication (egress) and package updates, isolated from the Internet Gateway (IGW).
- **Micro-segmentation via Security Groups**:
  - `SG-APP` restricts application traffic to accept connections **ONLY** from `SG-ALB`.

## ✅ Prerequisites

Before you begin, ensure you have the following:

- **AWS Account**: An active AWS account with appropriate permissions to create VPCs, EC2 instances, ALBs, and S3 buckets.
- **Terraform**: Version 1.3.0 or higher installed locally.
- **OpenSSH**: To generate and use SSH keys for access.

## 📖 How to Use (Deploy and Destroy)

The provisioned infrastructure can be initialized and deployed from the desired environment directory (e.g., `environments/dev`):

1. **Access the environment directory:**

   ```bash
   cd environments/dev
   ```

2. **Create the SSH key expected by this environment (if it doesn't exist in the `keys` folder yet):**

   ```bash
   ssh-keygen -t rsa -b 4096 -f keys/dev_key -N ""
   ```

3. **Initialize Terraform** (downloading modules and configuring the backend):

   ```bash
   terraform init
   ```

4. **(Optional) Format and validate the code:**

   ```bash
   terraform fmt --recursive
   terraform validate
   ```

5. **Validate changes and generate the execution plan:**

   ```bash
   terraform plan -out plan.out
   ```

6. **Apply the modifications to provision the infrastructure:**

   ```bash
   terraform apply plan.out
   ```

   > [!TIP]
   > If you set `dev_access_information = true` in your `.tfvars`, Terraform will output helper commands to access the Bastion Host and test the internal application URL. Depending on your local SSH setup, you may need to explicitly provide the private key with `-i keys/dev_key`.

7. **Deprovisioning (Destroy)**: To delete all created resources after testing:

   ```bash
   terraform destroy
   ```

---

## 📝 Terraform Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | [smartao/acm-self-signed/aws](https://registry.terraform.io/modules/smartao/acm-self-signed/aws/latest) | 1.1.0 |
| <a name="module_alb"></a> [alb](#module_alb) | [smartao/alb/aws](https://registry.terraform.io/modules/smartao/alb/aws/latest) | 2.1.1 |
| <a name="module_app"></a> [app](#module_app) | [smartao/ec2-autoscaling-app/aws](https://registry.terraform.io/modules/smartao/ec2-autoscaling-app/aws/latest) | 1.0.0 |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | [smartao/bastion/aws](https://registry.terraform.io/modules/smartao/bastion/aws/latest) | 3.0.0 |
| <a name="module_network"></a> [network](#module\_network) | [smartao/secure-vpc/aws](https://registry.terraform.io/modules/smartao/secure-vpc/aws/latest) | 1.2.0 |
| <a name="module_waf"></a> [waf](#module_waf) | [smartao/wafv2-web-acl/aws](https://registry.terraform.io/modules/smartao/wafv2-web-acl/aws/latest) | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [terraform_data.validate_alb_protocol](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.validate_bastion_ingress](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.validate_dev_access](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.validate_waf](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_common_name"></a> [acm\_common\_name](#input\_acm\_common\_name) | Common Name (CN) for the self-signed certificate used by the ALB | `string` | `"internal.app.local"` | no |
| <a name="input_alb_allowed_egress_cidr_blocks"></a> [alb\_allowed\_egress\_cidr\_blocks](#input\_alb\_allowed\_egress\_cidr\_blocks) | CIDR blocks the internal ALB can reach on the target group port | `list(string)` | `[]` | no |
| <a name="input_alb_listener_protocol"></a> [alb\_listener\_protocol](#input\_alb\_listener\_protocol) | The protocol used by the internal ALB listener | `string` | `"HTTPS"` | no |
| <a name="input_app_html_page"></a> [app\_html\_page](#input\_app\_html\_page) | The HTML template deployed by the application user data | `string` | `"index.html.tpl"` | no |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | The port on which the application listens | `number` | n/a | yes |
| <a name="input_app_protocol"></a> [app\_protocol](#input\_app\_protocol) | The protocol used by the application (e.g., HTTP, HTTPS) | `string` | n/a | yes |
| <a name="input_app_script"></a> [app\_script](#input\_app\_script) | The application script to initialize the EC2 instances | `string` | n/a | yes |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | Desired number of instances in the ASG | `number` | n/a | yes |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | Maximum number of instances in the ASG | `number` | n/a | yes |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | Minimum number of instances in the ASG | `number` | n/a | yes |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones to use | `list(string)` | n/a | yes |
| <a name="input_bastion_script"></a> [bastion\_script](#input\_bastion\_script) | The user data script to initialize the bastion host | `string` | `"bastion.sh"` | no |
| <a name="input_bastion_ssh_ingress_cidrs"></a> [bastion\_ssh\_ingress\_cidrs](#input\_bastion\_ssh\_ingress\_cidrs) | List of CIDR blocks allowed to SSH into the bastion host. (Cannot contain '0.0.0.0/0' if environment is 'prod') | `list(string)` | n/a | yes |
| <a name="input_dev_access_information"></a> [dev\_access\_information](#input\_dev\_access\_information) | Output access information for dev environment | `bool` | `false` | no |
| <a name="input_enable_waf"></a> [enable\_waf](#input\_enable\_waf) | Activates the WAF security feature to protect the ALB. (Mandatory if environment is 'prod') | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g., dev, stg, prod) | `string` | `"dev"` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Approximate amount of time, in seconds, between health checks | `number` | `30` | no |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | The HTTP codes to use when checking for a successful health check response | `string` | `"200"` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The destination for the ALB target group health check request | `string` | `"/"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Amount of time, in seconds, during which no response means a failed health check | `number` | `5` | no |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | Number of consecutive successful health checks required before considering a target healthy | `number` | `2` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type for the EC2 instances | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Resource owner | `string` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | A list of CIDR blocks for the private subnets | `list(string)` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | A list of CIDR blocks for the public subnets | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Filename of the SSH public key stored in the keys directory | `string` | n/a | yes |
| <a name="input_unhealthy_threshold"></a> [unhealthy\_threshold](#input\_unhealthy\_threshold) | Number of consecutive failed health checks required before considering a target unhealthy | `number` | `2` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_information"></a> [access\_information](#output\_access\_information) | Useful commands and URLs |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the internal Application Load Balancer |
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | The public IP address of the Bastion Host. Use this to SSH into the bastion. |
<!-- END_TF_DOCS -->