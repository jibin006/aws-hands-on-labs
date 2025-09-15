# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-vpc"
  }

  lifecycle {
    ignore_changes = [tags_all]
  }
}

# Subnets

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr 
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  lifecycle {
  ignore_changes = [tags_all]
}
}



resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr 
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  lifecycle {
  ignore_changes = [tags_all]
}
}
# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  lifecycle {
  ignore_changes = [tags_all]
}
}

# NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name        = "nat-eip"
    Environment = "Dev"
    Project     = "Lab"
    Owner       = "Jibin"
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }
  lifecycle {
  ignore_changes = [tags_all]
}
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]
  lifecycle {
  ignore_changes = [tags_all]
}
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
  ignore_changes = [tags_all]
}
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
  
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  lifecycle {
  ignore_changes = [tags_all]
}
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id

}

# Security Groups
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
  ignore_changes = [tags_all]
}
}


resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id
  name   = "db-sg"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
  ignore_changes = [tags_all]
}
}

# EC2 Instances
resource "aws_instance" "web" {
  ami           = "ami-0b09ffb6d8b58ca91"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server"
  }

  lifecycle {
    ignore_changes = [tags_all]
  }
}

resource "aws_instance" "db" {
  ami           = "ami-0b09ffb6d8b58ca91"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "db-server"
  }

  lifecycle {
    ignore_changes = [tags_all]
  }
}
