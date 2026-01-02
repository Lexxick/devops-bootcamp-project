resource "aws_vpc" "devops-vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

    tags = {
    Name = "devops-bootcamp-project-syedazam"
    }
}

resource "aws_subnet" "devops-public-subnet" {
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = "10.0.0.0/25"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
  
    tags = {
    Name = "devops-public-subnet"
    }
}

resource "aws_subnet" "devops-private-subnet" {
  vpc_id            = aws_vpc.devops-vpc.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = "ap-southeast-1a"

    tags = {
    Name = "devops-private-subnet"
    }
}

resource "aws_internet_gateway" "devops-igw" {
  vpc_id = aws_vpc.devops-vpc.id

    tags = {
    Name = "devops-igw"
    }
}

resource "aws_eip" "devops-ngw" {
  domain = "vpc"

   tags = {
   Name = "devops-ngw"
   }
}

resource "aws_nat_gateway" "devops-ngw" {
  allocation_id = aws_eip.devops-ngw.id
  subnet_id     = aws_subnet.devops-public-subnet.id
}

resource "aws_route_table" "devops-public-route" {
  vpc_id = aws_vpc.devops-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops-igw.id
  }

   tags = {
   Name = "devops-public-route"
   }
}

resource "aws_route_table" "devops-private-route" {
  vpc_id = aws_vpc.devops-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.devops-ngw.id
  }

   tags = {
   Name = "devops-private-route"
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
