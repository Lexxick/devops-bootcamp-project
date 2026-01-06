resource "aws_vpc" "devops-vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "devops-vpc"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_subnet" "devops-public-subnet" {
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = "10.0.0.0/25"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name      = "devops-public-subnet"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_subnet" "devops-private-subnet" {
  vpc_id            = aws_vpc.devops-vpc.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name      = "devops-private-subnet"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_internet_gateway" "devops-igw" {
  vpc_id = aws_vpc.devops-vpc.id

  tags = {
    Name      = "devops-igw"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_eip" "devops_ngw_eip" {
  domain = "vpc"
  tags = {
    Name      = "devops-ngw-eip"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_nat_gateway" "devops_ngw" {
  allocation_id = aws_eip.devops_ngw_eip.id
  subnet_id     = aws_subnet.devops-public-subnet.id
  depends_on    = [aws_internet_gateway.devops-igw]

  tags = {
    Name      = "devops-ngw"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_route_table" "devops-public-route" {
  vpc_id = aws_vpc.devops-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops-igw.id
  }

  tags = {
    Name      = "devops-public-route"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_route_table" "devops-private-route" {
  vpc_id = aws_vpc.devops-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.devops_ngw.id
  }

  tags = {
    Name      = "devops-private-route"
    Project   = "devops-bootcamp-final"
    ManagedBy = "terraform"
    Env       = "dev"
  }
}

resource "aws_route_table_association" "devops-public-route" {
  subnet_id      = aws_subnet.devops-public-subnet.id
  route_table_id = aws_route_table.devops-public-route.id
}

resource "aws_route_table_association" "devops-private-route" {
  subnet_id      = aws_subnet.devops-private-subnet.id
  route_table_id = aws_route_table.devops-private-route.id
}
