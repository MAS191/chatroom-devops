$resourceGroup = "rg-chatroom-devops"
$aksName = "aks-chatroom"
$vmName = "chatroom-devops-vm"

Write-Host "Stopping AKS cluster: $aksName..."
az aks stop --name $aksName --resource-group $resourceGroup

Write-Host "Deallocating VM: $vmName..."
az vm deallocate --name $vmName --resource-group $resourceGroup

Write-Host "Resources paused. Compute charges have stopped (storage costs for disks/images still apply)."
