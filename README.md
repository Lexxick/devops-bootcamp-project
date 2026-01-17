# DevOps Bootcamp Final Project
**Project Name:** Trust Me, I’m a DevOps Engineer

---

## 🔗 Project Links

- **GitHub Repository:**  
  https://github.com/Lexxick/devops-bootcamp-project

- **Web Application:**  
  http://web.syedazam.my

- **Monitoring (Grafana via Cloudflare Tunnel):**  
  https://monitoring.syedazam.my

- **Documentation (GitHub Pages):**  
  https://lexxick.github.io/devops-bootcamp-project/

---

## 🏗 Infrastructure (Terraform)

All infrastructure is provisioned using **Terraform** in `ap-southeast-1`.

### Network
- VPC: `10.0.0.0/24`
- Public Subnet: `10.0.0.0/25`
- Private Subnet: `10.0.0.128/25`
- Internet Gateway + NAT Gateway

### EC2 Instances
| Role | Private IP | Access |
|----|----|----|
| Web Server | 10.0.0.5 | Public (EIP) |
| Ansible Controller | 10.0.0.135 | Private (SSM only) |
| Monitoring Server | 10.0.0.136 | Private (Cloudflare Tunnel) |

### Notes
- Terraform state stored in **S3**
- `user_data_controller.sh` installs Ansible and prepares inventory
- `user_data_node.sh` installs Docker and Node Exporter
- All servers are accessed via **AWS SSM**

---

## ⚙️ Configuration Management (Ansible)

All Ansible tasks are executed from the **Ansible Controller**.

### Web Server
- Docker installed
- Application container deployed
- Node Exporter running on port `9100`

### Monitoring Server
- Docker installed
- Prometheus + Grafana deployed using Docker Compose
- Prometheus scrapes Web Server metrics
- Grafana exposed securely via **Cloudflare Tunnel**

### Run Ansible
```bash
aws ssm start-session --target <ANSIBLE_CONTROLLER_INSTANCE_ID>
sudo -iu ubuntu
git clone https://github.com/Lexxick/devops-bootcamp-project.git
cd devops-bootcamp-project/ansible
ansible-playbook playbooks/site.yml

### Docker Image to ECR
- git clone https://github.com/Infratify/lab-final-project 
- aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin <ECR-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ECR-Container-Name> *Get in AWS Console view push commands*
- docker build -t devops-bootcamp-project-syedazam .
- docker tag <ECR-Container-Name>:latest <ECR-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ECR-Container-Name> *Get in AWS Console view push commands*
- docker push <ECR-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ECR-Container-Name> *Get in AWS Console view push commands*