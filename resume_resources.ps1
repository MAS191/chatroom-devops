$resourceGroup = "rg-chatroom-devops"
$aksName = "aks-chatroom"
$vmName = "chatroom-devops-vm"

# 1. Check Azure Login
Write-Host "Checking Azure connection..."
try {
    az account show | Out-Null
} catch {
    Write-Warning "You are not logged in to Azure. Please sign in now."
    az login
}

# 2. Start Resources
Write-Host "Starting AKS cluster: $aksName..."
az aks start --name $aksName --resource-group $resourceGroup

Write-Host "Starting VM: $vmName..."
az vm start --name $vmName --resource-group $resourceGroup

Write-Host "Resources resumed."
Write-Host "--------------------------------------------------"
Write-Host "Checking Kubernetes Pods (App)..."
kubectl get pods -n dev

Write-Host "Checking Kubernetes Pods (Monitoring)..."
kubectl get pods -n monitoring

Write-Host "--------------------------------------------------"
Write-Host "Checking Kubernetes Services (Look for EXTERNAL-IP)..."
kubectl get service -n dev

Write-Host "--------------------------------------------------"
Write-Host "MONITORING ACCESS INSTRUCTIONS:"
Write-Host "To access Grafana, run this in a NEW terminal:"
Write-Host "  kubectl port-forward svc/grafana 3000:3000 -n monitoring"
Write-Host "  Then open: http://localhost:3000 (admin/admin)"
Write-Host ""
Write-Host "To access Prometheus, run this in a NEW terminal:"
Write-Host "  kubectl port-forward svc/prometheus 9090:9090 -n monitoring"
Write-Host "  Then open: http://localhost:9090"
Write-Host "--------------------------------------------------"
