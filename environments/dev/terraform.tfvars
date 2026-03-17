# =============================================================================
# Global
# =============================================================================
region                 = "us-east-1"
azs                    = ["us-east-1a", "us-east-1b"]
owner                  = "Sergei"
project                = "infra-segura"
dev_access_information = true

# =============================================================================
# Module: Network
# =============================================================================
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]


# =============================================================================
# Module: Bastion
# =============================================================================
bastion_ssh_ingress_cidrs = ["0.0.0.0/0"] # WARNING: In a real scenario, restrict this to trusted IPs
ssh_key_name              = "dev_key.pub"


# =============================================================================
# Module: ALB
# =============================================================================
alb_listener_port     = 80
alb_listener_protocol = "HTTP"


# =============================================================================
# Module: App
# =============================================================================
instance_type = "t3.micro"
app_port      = 80
app_protocol  = "HTTP"
app_script    = "app.sh.tpl"
app_html_page = "index.html.tpl"

# Auto Scaling
asg_desired_capacity = 2
asg_min_size         = 2
asg_max_size         = 3
