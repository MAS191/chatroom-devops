$resourceGroup = "rg-chatroom-devops"
$aksName = "aks-chatroom"
$vmName = "chatroom-devops-vm"

Write-Host "Checking Azure Resources Status..."
Write-Host "--------------------------------------------------"

# Check AKS Status
try {
    $aksState = az aks show --resource-group $resourceGroup --name $aksName --query "powerState.code" -o tsv 2>$null
    if ($LASTEXITCODE -ne 0) { $aksState = "Not Found" }
} catch {
    $aksState = "Error/Not Found"
}

# Check VM Status
try {
    $vmState = az vm show --resource-group $resourceGroup --name $vmName --show-details --query "powerState" -o tsv 2>$null
    if ($LASTEXITCODE -ne 0) { $vmState = "Not Found" }
} catch {
    $vmState = "Error/Not Found"
}

Write-Host "AKS Cluster ($aksName): $aksState"
Write-Host "Virtual Machine ($vmName): $vmState"

Write-Host "--------------------------------------------------"
if ($aksState -eq "Running" -or $vmState -like "*running*") {
    Write-Host "⚠️  WARNING: RESOURCES ARE RUNNING AND CONSUMING CREDITS!" -ForegroundColor Red
} elseif ($aksState -eq "Stopped" -and $vmState -like "*deallocated*") {
    Write-Host "✅  Resources are paused. Compute charges are stopped." -ForegroundColor Green
} else {
    Write-Host "⚠️  Status is mixed or unknown. Please check Azure Portal." -ForegroundColor Yellow
}
