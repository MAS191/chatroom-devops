# 🚀 Chatroom DevOps Project

This project demonstrates a complete, production-ready DevOps lifecycle for a microservices-based chat application. It integrates modern practices including **Infrastructure as Code (IaC)**, **Containerization**, **CI/CD**, **Configuration Management**, and **Observability**.

---

## 🛠️ Technologies Stack

| Category | Technology | Usage |
|----------|------------|-------|
| **Cloud** | Microsoft Azure | AKS, ACR, VNet, VM |
| **IaC** | Terraform | Provisioning Azure Resources |
| **Containerization** | Docker | Multi-stage builds for Python Flask |
| **Orchestration** | Kubernetes | Managing App, Mongo, Redis, Monitoring |
| **Config Mgmt** | Ansible | Automating K8s Manifest Application |
| **CI/CD** | GitHub Actions | Automated Build, Test, Security Scan, Deploy |
| **Monitoring** | Prometheus & Grafana | Metrics Collection & Visualization |
| **Database** | MongoDB & Redis | Persistence & Caching |

---

## 🏃‍♂️ How to Run

### Prerequisites
*   **Azure CLI**: `az login`
*   **Terraform**: `v1.5+`
*   **Docker Desktop**: Running
*   **Kubectl**: Configured

### 1️⃣ Local Development (Docker Compose)
To test the application logic locally without Kubernetes:
```bash
cd compose
docker-compose up --build
```
*   Access App: `http://localhost:5000`
*   Access Mongo: `localhost:27017`

### 2️⃣ Infrastructure Provisioning (Terraform)
Provision the Azure Kubernetes Service (AKS) and Network:
```bash
cd infra-azure
terraform init
terraform apply -auto-approve
```
*   *Note: This creates an AKS cluster, ACR, Public IP, and VNet.*

### 3️⃣ Deployment (Kubernetes)
You can deploy using the provided helper script which handles ACR login, building, pushing, and applying manifests:
```powershell
./deploy_aks.ps1
```
**Or manually:**
```bash
kubectl apply -f k8s/namespaces.yaml
kubectl apply -f k8s/
```

### 4️⃣ Configuration Management (Ansible)
To enforce configuration state using Ansible:
```bash
cd ansible
ansible-playbook -i hosts.ini playbook.yaml
```

---

## 📊 Monitoring & Observability
The stack includes a fully configured monitoring suite.

1.  **Deploy Monitoring Stack:**
    ```bash
    kubectl apply -f monitoring/
    ```
2.  **Access Grafana:**
    ```bash
    kubectl port-forward svc/grafana 3000:3000 -n monitoring
    ```
3.  **Login:**
    *   URL: `http://localhost:3000`
    *   User: `admin`
    *   Pass: `admin`
4.  **Dashboard:** Navigate to **Dashboards** > **ChatRoom DevOps Dashboard**.

---

## 🧹 Infrastructure Teardown
To avoid cloud costs, you can pause or destroy resources.

**Option A: Pause (Stop Billing for Compute)**
```powershell
./pause_resources.ps1
```

**Option B: Destroy (Remove All Resources)**
```bash
cd infra-azure
terraform destroy -auto-approve
```

