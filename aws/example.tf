provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_instance" "example" {
  ami           = var.amis[var.region]
  instance_type = var.types[var.region]
  count         = 3
}

resource "aws_eip" "ip" {
  count    = 3
  vpc      = true
  instance = aws_instance.example[count.index].id
}