$resourceGroupName = ""
$serverName = ""
$databaseName = ""
$scaleEdition = "Standard"
$scaleTier = "S4"

$connectionName = "AzureRunAsConnection"

try
{
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

filter timestamp {"[$(Get-Date -Format G)]: $_"}
 
Write-Output "Script started." | timestamp

$sqlDB = Get-AzureRmSqlDatabase `
-ResourceGroupName $resourceGroupName `
-ServerName $serverName `
-DatabaseName $databaseName

Write-Output "DB name: $($sqlDB.DatabaseName)" | timestamp
Write-Output "Current DB status: $($sqlDB.Status), edition: $($sqlDB.Edition), tier: $($sqlDB.CurrentServiceObjectiveName)" | timestamp

if ($sqlDB.Edition -eq $scaleEdition -And $sqlDB.CurrentServiceObjectiveName -eq $scaleTier)
{
    Write-Output "Already Database Server $($ServerName)\$($DatabaseName) is in required tier : $($scaleEdition):$($scaleTier)" | timestamp
}
else
{
    Write-Output "Updating Database Server $($ServerName)\$($DatabaseName) to Edition : $($scaleEdition), tier: $($scaleTier)" | timestamp
    Write-Output  "Updating Database , please wait..."  | timestamp
    $sqlDB | Set-AzureRmSqlDatabase -Edition $scaleEdition -RequestedServiceObjectiveName $scaleTier | out-null
}

$sqlDB = Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $databaseName
Write-Output "Final DB status: $($sqlDB.Status), edition: $($sqlDB.Edition), tier: $($sqlDB.CurrentServiceObjectiveName)" | timestamp

Write-Output "Database updated successfully"  | timestamp
