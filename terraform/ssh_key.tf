resource "aws_key_pair" "kind" {
  key_name   = var.ssh_key.name
  public_key = var.ssh_key.key
}
