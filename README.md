# Chatroom DevOps Project

This project demonstrates a complete DevOps lifecycle for a microservices-based chat application, including containerization, infrastructure as code, configuration management, CI/CD, and monitoring.

## 🚀 Project Overview

*   **Application**: Flask-based Chat API with MongoDB (persistence) and Redis (caching).
*   **Infrastructure**: Azure Kubernetes Service (AKS) provisioned via Terraform.
*   **Configuration**: Ansible playbooks for Kubernetes resource management.
*   **CI/CD**: GitHub Actions pipeline for automated build and deployment.
*   **Monitoring**: Prometheus and Grafana stack.

## 🛠️ Technologies Used

*   **Cloud**: Microsoft Azure (AKS, ACR, VM, VNet)
*   **IaC**: Terraform
*   **Containerization**: Docker (Multi-stage builds)
*   **Orchestration**: Kubernetes
*   **Config Management**: Ansible
*   **CI/CD**: GitHub Actions
*   **Monitoring**: Prometheus, Grafana
*   **Backend**: Python (Flask), Gunicorn
*   **Database**: MongoDB, Redis

## 🏃‍♂️ How to Run

### Prerequisites
*   Azure CLI (`az login`)
*   Terraform
*   Docker
*   Kubectl

### 1. Provision Infrastructure
```bash
cd infra-azure
terraform init
terraform apply -auto-approve
```

### 2. Deploy Application (Manual / Script)
You can use the provided PowerShell script to build, push, and deploy:
```powershell
./deploy_aks.ps1
```

### 3. Deploy via Ansible (Optional)
If you have Ansible installed:
```bash
cd ansible
ansible-playbook -i hosts.ini playbook.yaml
```

### 4. Access the Application
Get the external IP:
```bash
kubectl get service chat-api -n dev
```
Visit `http://<EXTERNAL-IP>` in your browser.

## 📊 Monitoring
Prometheus and Grafana are deployed to the `monitoring` namespace.
```bash
kubectl get svc -n monitoring
```
Port-forward to access Grafana:
```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```
Access at `http://localhost:3000` (Default login: admin/admin).

## 🧹 Cleanup
To stop billing, run:
```powershell
./pause_resources.ps1
```
To destroy everything:
```bash
cd infra-azure
terraform destroy -auto-approve
```
