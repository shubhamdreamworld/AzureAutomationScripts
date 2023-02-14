filter timestamp {"[$(Get-Date -Format G)]: $_"} 
  
Write-Output "Script started." | timestamp 
 
$newTier = "Basic"
$newSize = "B2"

$resourceGroupName = ""
$appServiceName = ""

#Authenticate with Azure Automation Run As account (service principal)   
$conn = Get-AutomationConnection -Name "AzureRunAsConnection" 
Connect-AzAccount -ServicePrincipal -Tenant $conn.TenantID -ApplicationId $conn.ApplicationID -CertificateThumbprint $conn.CertificateThumbprint | out-null
Write-Output "Authenticated with Automation Run As Account." 

$appService = Get-AzAppServicePlan -ResourceGroupName $resourceGroupName -Name $appServiceName 
Write-Output "App Service Plan name: $($appService.Name)" | timestamp 
Write-Output "Current App Service Plan status: $($appService.Status), tier: $($appService.Sku.Tier), name: $($appService.Sku.Name), size: $($appService.Sku.Size)" | timestamp 


$appService.Sku.Tier = $newTier
$appService.Sku.Size = $newSize
$appService.Sku.Name = $newSize

Set-AzAppServicePlan -AppServicePlan $appService
$appService = Get-AzAppServicePlan -ResourceGroupName $resourceGroupName -Name $appServiceName 
Write-Output "App Service Plan name: $($appService.Name)" | timestamp 
Write-Output "Current App Service Plan status: $($appService.Status), tier: $($appService.Sku.Tier), name: $($appService.Sku.Name), size: $($appService.Sku.Size)" | timestamp 
