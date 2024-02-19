
########################################################################
# EC2 INSTANCE
########################################################################
resource "aws_instance" "zizikesh" {
  ami               = "ami-06aa3f7caf3a30282"
  instance_type     = "t2.micro"
  key_name          = "TF_key"
  security_groups   = [aws_security_group.TF_SG.name]
  availability_zone = "us-east-1a"
  metadata_options {
    http_tokens = "required"
  }


  # root disk
  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  depends_on = [
    aws_key_pair.TF_key
  ]

  tags = {
    Name = "zizikesh"
  }
}

########################################################################
# KEY_PAIR CREATION CONFIGURATION
########################################################################
resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}


########################################################################
# ELASTIC_IP CREATION AND ATTACHMENT
########################################################################
resource "aws_eip" "zizikesh_eip" {
  instance = aws_instance.zizikesh.id
  domain   = "vpc"

  tags = {
    Name = "zizikesh_EIP"
  }
}

########################################################################
# OUTPUT_OF_PUBLIC_EIP
########################################################################
output "EIP" {
  value = aws_eip.zizikesh_eip.public_ip
}

########################################################################
# SECURITY GROUP
########################################################################
resource "aws_security_group" "TF_SG" {
  name        = "security group for zizikesh terraform"
  description = "security group for zizikesh terraform"
  vpc_id      = "vpc-0a4182622620cbf56"


  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.cidr_blocks]
    ipv6_cidr_blocks = [var.ipv6_cidr_blocks]
  }

  egress {
    description      = "http"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.cidr_blocks]
    ipv6_cidr_blocks = [var.ipv6_cidr_blocks]
  }

  tags = {
    Name = "TF_SG"
  }
}
