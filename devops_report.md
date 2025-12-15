# DevOps Final Project Report

## 1. Technologies Used
*   **Source Control**: Git & GitHub
*   **Containerization**: Docker (Multi-stage optimized images)
*   **Infrastructure as Code**: Terraform (Azure Provider)
*   **Orchestration**: Azure Kubernetes Service (AKS)
*   **Configuration Management**: Ansible
*   **CI/CD**: GitHub Actions
*   **Monitoring**: Prometheus & Grafana
*   **Application**: Python Flask, MongoDB, Redis

## 2. Pipeline & Infrastructure Diagram

### Infrastructure (Azure)
*   **Resource Group**: `rg-chatroom-devops`
*   **Networking**: VNet (`10.10.0.0/16`), Subnet (`10.10.1.0/24`), NSG (Allow SSH, NodePorts)
*   **Compute**:
    *   **AKS Cluster**: `aks-chatroom` (Standard_B2s_v2 nodes)
    *   **VM**: `chatroom-devops-vm` (Jumpbox/Ansible Controller)
*   **Storage**: Azure Container Registry (`acrchatroom...`)

### CI/CD Pipeline (GitHub Actions)
1.  **Trigger**: Push to `main` branch.
2.  **Build**: Docker build (multi-stage).
3.  **Push**: Push image to Azure Container Registry (ACR).
4.  **Deploy**: Update Kubernetes deployment in AKS using `kubectl set image`.

## 3. Secret Management Strategy
*   **Kubernetes Secrets**: Sensitive data (DB connection strings, Flask keys) are stored in Kubernetes `Secret` objects (`k8s/secret.yaml`).
*   **Environment Variables**: The application reads configuration from environment variables injected by Kubernetes.
*   **Terraform State**: State file is kept local (for this project), but in production, it would be stored in a remote backend (Azure Storage Account) with encryption.
*   **GitHub Secrets**: Azure credentials (`AZURE_CREDENTIALS`) are stored in GitHub Repository Secrets for the CI/CD pipeline.

## 4. Monitoring Strategy
*   **Prometheus**: Scrapes metrics from the application (`/metrics` endpoint) and Kubernetes nodes.
*   **Grafana**: Visualizes the data collected by Prometheus.
*   **Key Metrics**:
    *   HTTP Request Latency
    *   Request Count (Success/Failure)
    *   Memory/CPU Usage of Pods

## 5. Lessons Learned
*   **Multi-stage Builds**: Significantly reduced the Docker image size by separating the build environment from the runtime environment.
*   **Infrastructure as Code**: Terraform made it easy to tear down and recreate the entire Azure environment consistently, avoiding manual configuration drift.
*   **Kubernetes Networking**: Understanding Services (LoadBalancer vs ClusterIP) was crucial for exposing the application to the internet while keeping the database internal.
*   **State Management**: Managing Terraform state and Kubernetes persistent volumes requires careful planning to avoid data loss.
