// couldn't figuire out how to use the ec2_keypair module because of terragrunt's `//` path requirement, so just copying it here
locals {
  public_key  = element(tls_private_key.this.*.public_key_openssh, 0)
  private_key = element(tls_private_key.this.*.private_key_pem, 0)
}

resource "tls_private_key" "this" {  
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = var.keypair_name
  public_key = local.public_key

  tags = var.tags
}