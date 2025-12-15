$resourceGroup = "rg-chatroom-devops"
$aksName = "aks-chatroom"
$vmName = "chatroom-devops-vm"

Write-Host "Starting AKS cluster: $aksName..."
az aks start --name $aksName --resource-group $resourceGroup

Write-Host "Starting VM: $vmName..."
az vm start --name $vmName --resource-group $resourceGroup

Write-Host "Resources resumed. You may need to check 'kubectl get service -n dev' for the external IP."
