$ResourceGroupName = "res_Marg_CI"
$ServerName = "margbooksdbserver"
$DatabaseName = "newmargDB361549325125" 
$Edition = "GeneralPurpose"
$PricingTier = "GP_Gen5_4"


$StartDate=(GET-DATE)
Write-Verbose -Message 'Connecting to Azure'


$ConnectionName = 'AzureRunAsConnection'
try
{
    $ServicePrincipalConnection = Get-AutomationConnection -Name $ConnectionName      
   
    'Log in to Azure...'
    $null = Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $ServicePrincipalConnection.TenantId `
        -ApplicationId $ServicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint 
}
catch 
{
    if (!$ServicePrincipalConnection)
    {
        $ErrorMessage = "Connection $ConnectionName not found."
        throw $ErrorMessage
    }
    else
    {
        Write-Error -Message $_.Exception.Message
        throw $_.Exception
    }
}

$MyAzureSqlDatabase = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ServerName -DatabaseName $DatabaseName
if (!$MyAzureSqlDatabase)
{
    Write-Error "$($ServerName)\$($DatabaseName) not found in $($ResourceGroupName)"
    return
}
else
{
    Write-Output "Current pricing tier of $($ServerName)\$($DatabaseName): $($MyAzureSqlDatabase.Edition) - $($MyAzureSqlDatabase.CurrentServiceObjectiveName)"
}

if ($MyAzureSqlDatabase.Edition -eq $Edition -And $MyAzureSqlDatabase.CurrentServiceObjectiveName -eq $PricingTier)
{
    Write-Error "Cannot change pricing tier of $($ServerName)\$($DatabaseName) because the new pricing tier is equal to current pricing tier"
    return
}
else
{
    Write-Output "Changing pricing tier to $($Edition) - $($PricingTier)"
    $null = Set-AzSqlDatabase -DatabaseName $DatabaseName -ServerName $ServerName -ResourceGroupName $ResourceGroupName -Edition $Edition -RequestedServiceObjectiveName $PricingTier
}

$Duration = NEW-TIMESPAN –Start $StartDate –End (GET-DATE)
Write-Output "Done in $([int]$Duration.TotalMinutes) minute(s) and $([int]$Duration.Seconds) second(s)"