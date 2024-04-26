resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name}-bastion-keys-${random_id.bucket_id.hex}"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "aws_s3_bucket_object" "private_key" {
  bucket  = aws_s3_bucket.bucket.id
  key     = "${var.name}-bastion-key.pem"
  content = tls_private_key.private_key.private_key_pem
  acl     = "private"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "bastion-key"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "aws_instance" "bastion_host" {
  ami                         = "ami-04e5276ebb8451442"
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.generated_key.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true


  root_block_device {
    volume_type = "gp3"
    volume_size = 20
  }

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "${var.name}-bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}