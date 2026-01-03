Terraform :
 1. Main.tf = Required Providers, region&profile, backend s3
 2. terraform init -migrate-state --auto-approve = to use S3 bucket for terraform.tfstate
 3. vpc.tf = resource "..." "..." 
	 1) aws_vpc.devop-vpc, cidrblock 10.0.0.0/24
	 2) aws_subnet.devop-public-subnet, cidrblock 10.0.0.0/25
	 3) aws_subnet.devops-private-subnet, cidrblock 10.0.0.128/25
         4) aws_internet_gateway.devops-igw
         5) aws_eip.devops-ngw
         6) aws_nat_gateway.devops-ngw,
	    allocation_id = aws_eip.devops-ngw.id
	    subnet_id     = aws_subnet.devops-public-subnet.id
         7) aws_route_table.devop-public-route, cidrblock 0.0.0.0/0, gateway_id = aws_internet_gateway.devops-igw
         8) aws_route_table.devop-private-route, cidrblock 0.0.0.0/0, nat_gateway_id = aws_nat_gateway.devops-ngw
         9) "aws_route_table_association" "devops-public-route"
	    subnet_id      = aws_subnet.devops-public-subnet.id
	    route_table_id = aws_route_table.devops-public-route.id
	10) "aws_route_table_association" "devops-private-route"
	    subnet_id      = aws_subnet.devops-private-subnet.id
	    route_table_id = aws_route_table.devops-private-route.id
 4. securitygroup.tf =
	 1) devops-public-sg
	    ingress = port 80 cidrblock 0.0.0.0/0, port 22 cidrblock [aws_vps.devops-vps.cidr_block]
	    egress  = port 0 cidrblock 0.0.0.0/0
	 2) devops-private-sg
	    ingress = port 22 cidrblock [aws_vps.devops-vps.cidr_block]
	    egress  = port 0 cidrblock 0.0.0.0/0
 5. iam.tf = ec2-ssm-role
 6. ec2.tf = resouce "..." "..."
	 1) WebServer, private ip 10.0.0.5, public-subnet, public-sg, iam_instance_profile
	 2) AnsibleController, private ip 10.0.0.135, private-subnet, private-sg, iam_instance_profile
	 3) MonitoringServer, private ip 10.0.0.136, private-subnet, private-sg, iam_instance_profile
 7. ecr.tf = resource "aws_ecr_repository" "devops-bootcamp-project-syedazam"
 terraform plan
 terraform apply --auto-approve
....

Docker Image to ECR :

git clone https://github.com/Infratify/lab-final-project 

aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 516267217090.dkr.ecr.ap-southeast-1.amazonaws.com

docker build -t devops-bootcamp-project-syedazam .

docker tag devops-bootcamp-project-syedazam:latest 516267217090.dkr.ecr.ap-southeast-1.amazonaws.com/devops-bootcamp-project-syedazam:latest

docker push 516267217090.dkr.ecr.ap-southeast-1.amazonaws.com/devops-bootcamp-project-syedazam:latest

....

Ansible :
 1. ansible/
├── ansible.cfg
├── inventory.ini        # Terraform generates this
├── deploy.yaml          # One combined playbook
├── templates/
│   ├── docker-compose-web.yml.j2
│   └── docker-compose-monitoring.yml.j2
└── README.md

 2. aws ssm start-session --target <i-1234567890abcdef0> #replace instance id
    git clone https://github.com/Lexxick/devops-bootcamp-project.git #clone ansible file
    cd ansible
    ansible-playbook main.yaml


STUCK AT INVENTORY.INI CREATED DLM LOCAL BKN EC2