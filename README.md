# DevOps Bootcamp Final Project

## Links
- **GitHub Repo:** https://github.com/Lexxick/devops-bootcamp-project
- **Web App:** http://web.yourdomain.com
- **Monitoring (Grafana):** https://monitoring.syedazam.my


## Infrastructure
**Provisioned with Terraform:**
- Create S3 Bucket using AWS Console
- VPC: 10.0.0.0/24
- Web Server (public + EIP): 10.0.0.5
- Ansible Controller (private): 10.0.0.135
- Monitoring Server (private): 10.0.0.136
- user_data_controller.sh : Force apt to use IPv4,  intall all prerequisite and write SSH Key, Inventory.ini
- user_data_node.sh : Force apt to use IPv4,  install all prerequisite + node exporter
- terraform init -migrate-state --auto-approve = to use S3 bucket for terraform.tfstate
- terraform plan
- terraform apply --auto-approve


## Ansible
- Web server: Docker + app container + node-exporter
- Monitoring server: Docker + Prometheus + Grafana + Cloudflare Tunnel
- aws ssm start-session --target <i-1234567890abcdef0> *replace instance id*
- git clone https://github.com/Lexxick/devops-bootcamp-project.git *clone ansible file*
- sudo -iu Ubuntu *Terraform provision inventory.ini etc in ubuntu-user instead of ssm-user*
- ansible-playbook site.yml


## Docker Image to ECR
- git clone https://github.com/Infratify/lab-final-project 
- aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin <ECR-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ECR-Container-Name> *Get in AWS Console view push commands*
- docker build -t devops-bootcamp-project-syedazam .
- docker tag <ECR-Container-Name>:latest <ECR-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ECR-Container-Name> *Get in AWS Console view push commands*
- docker push <ECR-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ECR-Container-Name> *Get in AWS Console view push commands*