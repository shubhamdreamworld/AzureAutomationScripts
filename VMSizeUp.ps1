$ResourceGroupName = ""
$VMName = ""

$connectionName = "AzureRunAsConnection"
try
{
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName
    "Logging in to Azure..."
   Connect-AzAccount `
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
$VMSize = (Get-AzVM -ResourceGroupName $ResourceGroupName).HardwareProfile
if ($VMSize -eq "Standard_E8ads_v5"){
write-host "VM is allready a Standard_E8ads_v5"}
else {
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -VMName $VMName
$vm.HardwareProfile.VmSize = "Standard_E8ads_v5"
Update-AzVM -VM $vm -ResourceGroupName $ResourceGroupName
write-host The Virtual Machine $vm has been resized to "Standard_E8ads_v5"
}
