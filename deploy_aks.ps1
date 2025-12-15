$ErrorActionPreference = "Stop"

Write-Host "Starting deployment to AKS..."

# Navigate to infra directory
Set-Location "infra-azure"

# Initialize Terraform
Write-Host "Initializing Terraform..."
terraform init

# Apply Terraform
Write-Host "Applying Terraform configuration..."
terraform apply -auto-approve

# Get Outputs
$acrLoginServer = $(terraform output -raw acr_login_server)
$acrName = $(terraform output -raw acr_name)
$aksClusterName = $(terraform output -raw aks_cluster_name)
$aksResourceGroup = $(terraform output -raw aks_resource_group)

Write-Host "ACR Login Server: $acrLoginServer"
Write-Host "ACR Name: $acrName"
Write-Host "AKS Cluster: $aksClusterName"
Write-Host "Resource Group: $aksResourceGroup"

# Login to ACR
Write-Host "Logging in to ACR..."
az acr login --name $acrName

# Build Docker Image
Write-Host "Building Docker image..."
Set-Location ".."
docker build -t "$acrLoginServer/chat-api:latest" "./services/chat-api"

# Push Docker Image
Write-Host "Pushing Docker image to ACR..."
docker push "$acrLoginServer/chat-api:latest"

# Get AKS Credentials
Write-Host "Getting AKS credentials..."
az aks get-credentials --resource-group $aksResourceGroup --name $aksClusterName --overwrite-existing

# Deploy to Kubernetes
Write-Host "Deploying to Kubernetes..."
kubectl apply -f k8s/namespaces.yaml
kubectl apply -f k8s/

# Update Image in Deployment
Write-Host "Updating deployment image..."
kubectl set image deployment/chat-api chat-api="$acrLoginServer/chat-api:latest" -n dev

Write-Host "Deployment complete!"
Write-Host "Get the external IP with: kubectl get service chat-api -n dev"
