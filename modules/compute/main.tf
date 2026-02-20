resource "aws_key_pair" "generated_key" {
  key_name   = "bastion-key"
  public_key = chomp(file("/home/sergei/.ssh/id_rsa.pub")) # Replace with your actual public key path
}