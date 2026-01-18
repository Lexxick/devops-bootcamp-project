# 🚀 DevOps Bootcamp Final Project
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

## 💻 Local Setup

### 🛠 Git
- .gitignore
- .github/workflows
	> pages.yml
	> ecr-build-push.yml

### 🏗 Terraform Structure
- providers.tf
- iam.tf
- backend.tf
- ec2.tf
- ecr.tf
- vpc.tf
- security.tf
- variables.tf
- bootstrap.tf
- user_data_controller.sh *Install all prerequisites and write SSH Key*
- user_data_node.sh *Install all prerequisites and write SSH Key*
- outputs.tf

### 🤖 Ansible Structure
- playbooks
	> site.yml
	> web.yml
	> monitoring.yml
- group_vars
	> all.yml
	> cloudflare_token.yml *manually added into ec2 to avoid git hub*
- templates
	> docker-compose.yml.j2
	>prometheus.yml.j2

### 📦 Docker Image to ECR
```bash
git clone https://github.com/Infratify/lab-final-project 
```
```bash
mv lab-final-project docker
```
```bash
cd docker
```
```bash
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin <ECR-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ECR-Container-Name> #Get in AWS Console view push commands
```
```bash
docker build -t devops-bootcamp-project-syedazam .
```
```bash
docker tag <ECR-Container-Name>:latest <ECR-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ECR-Container-Name> #Get in AWS Console view push commands
```
```bash
- docker push <ECR-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ECR-Container-Name> #Get in AWS Console view push commands
```

---

## 🏗 Infrastructure (Terraform)

All infrastructure is provisioned using **Terraform** in `ap-southeast-1`.

### 🌐 Network
- VPC: `10.0.0.0/24`
- Public Subnet: `10.0.0.0/25`
- Private Subnet: `10.0.0.128/25`
- Internet Gateway + NAT Gateway

### 🖥 EC2 Instances
| Role | Private IP | Access |
|----|----|----|
| Web Server | 10.0.0.5 | Public (EIP) |
| Ansible Controller | 10.0.0.135 | Private (SSM only) |
| Monitoring Server | 10.0.0.136 | Private (Cloudflare Tunnel) |

### 📝 Notes
- Terraform state stored in **S3**
- `user_data_controller.sh` installs Ansible and prepares inventory
- `user_data_node.sh` installs Docker and Node Exporter
- All servers are accessed via **AWS SSM**

---

## ⚙️ Configuration Management (Ansible)

All Ansible tasks are executed from the **Ansible Controller**.

### 🚀 Web Server
- Docker installed
- Application container deployed
- Node Exporter running on port `9100`

### 📈 Monitoring Server
- Docker installed
- Prometheus + Grafana deployed using Docker Compose
- Prometheus scrapes Web Server metrics
- Grafana exposed securely via **Cloudflare Tunnel**

### ⌨️ Run Ansible
```bash
aws ssm start-session --target <ANSIBLE_CONTROLLER_INSTANCE_ID>
```
```bash
sudo -iu ubuntu
```
```bash
git clone https://github.com/Lexxick/devops-bootcamp-project.git
```
```bash
cd devops-bootcamp-project/ansible
```
#### Ubuntu/devop-bootcamp-project/ansible/group_vars/cloudflare_token.yml
```bash
cd group_vars
```
```bash
nano cloudflare_token.yml 
```
#### Paste Inside cloudflare_token.yml
```bash
cloudflared_tunnel_token: "TOKEN_FROM_LOCAL_CLOUDFLARE_TOKEN.YML"
```
#### Run Playbook
```bash
cd ../playbooks
```
```bash
ansible-playbook /site.yml
```

---

## ☁️ Cloudflare + Cloudflare Tunnel (ZeroTrust)

### 🛰 Dns Record
- Type A : Web : (Web ec2 Elastic IP) *if destory infra need to change new*
- Type Cname : Monitoring : (from tunnel)

### 🔒 SSL/TLS
- Set to Flexible (per project task)

### 🛡 Zero Trust (Tunnel)
- monitoring-tunnel

---

## 📊 	Prometheus Dashboard

### Boring Easy Approach
- Import
- Prometheus Source = 

---

## 🤖 	Git Hub Action Docker Build

### 🔐 AWS Console
- Create Iam User
- Attach Permission
	> AmazonEC2ContainerRegistryFullAccess
	> AmazonSSMFullAccess
- Create Acces Key

### 💻 Local
- In .github/workflows
	> ecr-build-push.yml

### 🔑 Add GitHub Secrets (so Actions can login to AWS)
- AWS_ACCESS_KEY_ID = (secret)
- AWS_SECRET_ACCESS_KEY = (secret)
- AWS_REGION = ap-southeast-1
- AWS_ACCOUNT_ID = (secret)
- ANSIBLE_CONTROLLER_INSTANCE_ID = (i-ooooyourownec2idoooo)

---

## 👤 Change DevOps Engineer > Syed Azam

### 💻 Local
- docker-compose.yml > USER_NAME=${USER_NAME:-DevOps Engineer} > USER_NAME=${USER_NAME:-Syed Azam}
```bash
- git add .
```
```bash
- git commit -m "blabla"
```
```bash
- git push 
```

---

## 📖 Documentation (local to git hub pages)

### Docs/README.md
- index.html
- .nojeklly