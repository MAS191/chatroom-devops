$resourceGroup = "rg-chatroom-devops"
$aksName = "aks-chatroom"
$vmName = "chatroom-devops-vm"

Write-Host "Starting AKS cluster: $aksName..."
az aks start --name $aksName --resource-group $resourceGroup

Write-Host "Starting VM: $vmName..."
az vm start --name $vmName --resource-group $resourceGroup

Write-Host "Resources resumed."
Write-Host "--------------------------------------------------"
Write-Host "Checking Kubernetes Pods..."
kubectl get pods -n dev

Write-Host "--------------------------------------------------"
Write-Host "Checking Kubernetes Services (Look for EXTERNAL-IP)..."
kubectl get service -n dev
