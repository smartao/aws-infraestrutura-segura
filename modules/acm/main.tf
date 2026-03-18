
# =============================================================================
# Self-Signed TLS Certificate
# =============================================================================

# Generate a private key (RSA 2048-bit)
resource "tls_private_key" "self_signed" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate a self-signed certificate using the private key
resource "tls_self_signed_cert" "self_signed" {
  private_key_pem = tls_private_key.self_signed.private_key_pem

  subject {
    common_name  = var.common_name
    organization = var.organization
  }

  validity_period_hours = var.validity_period_hours

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# =============================================================================
# AWS ACM – Import the self-signed certificate
# =============================================================================

resource "aws_acm_certificate" "self_signed" {
  private_key      = tls_private_key.self_signed.private_key_pem
  certificate_body = tls_self_signed_cert.self_signed.cert_pem

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-self-signed-cert"
      Environment = var.environment
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
