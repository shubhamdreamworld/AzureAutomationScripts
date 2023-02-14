$SnapFrequency = "Daily"

$snapExportDate = (Get-Date).AddDays(14).ToString('yyyy-MM-dd')
$deletionDate = (Get-Date).AddDays(0).ToString('yyyy-MM-dd')
$today = (Get-Date -f yyyy-MM-dd)

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$connectionName = "AzureRunAsConnection"

try{
    $Conn = Get-AutomationConnection -Name $connectionName
    "Logging into Azure..."
    Connect-AzAccount `
        -ServicePrincipal -TenantID $Conn.TenantID `
        -ApplicationId $Conn.ApplicationID `
        -CertificateThumbprint $Conn.CertificateThumbprint `
}
catch{
    if(!$Conn){
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    }else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
if($err) {
    throw $err
}

$tagResList = Get-AzResource -TagName "Snapshot" -TagValue "Daily" -ResourceType "Microsoft.Compute/VirtualMachines" | foreach {$_.ResourceId}

foreach($tagRes in $tagResList) {
    $vmInfo = Get-AzVM -ResourceGroupName $tagRes.Split("/")[4] -Name $tagRes.Split("/")[8]

    $vmTags = (Get-AzVM -ResourceGroupName $tagRes.Split("/")[4] -Name $tagRes.Split("/")[8]).Tags

    $vmTags.set_Item("Snapshot", "False")

    "Setting Deletion Date for Snapshots to $deletionDate."
    $vmTags.Add('DeleteAfter', $deletionDate)

    "Setting Export Date for Snapshots to $exportDate."
    $vmTags.Add('ExportAfter', $snapExportDate)

    "Updating Managed By tag for Snapshots to Automation Runbook."
    if ($vmTags.ContainsKey("Managed By"))
    {
        $vmTags.set_Item("Managed By", "Automation Runbook")
        Write-Output "Managed By tag successfully updated to Automation Runbook."
    }
    else
    {
        $vmTags.Add("Managed By", "Automation Runbook")
        Write-Output "Managed By tag successfully added, and set to Automation Runbook."
    }

    $location = $vmInfo.Location
    $resourceGroupName = $vmInfo.ResourceGroupName
    $timestamp = (Get-Date -f yyyy-MM-dd-HH-mm-ss)

    $snapshotName = "Snapshot_VM_" + $vmInfo.Name + "_at_" + $timestamp

    $snapshot = New-AzSnapshotConfig -SourceUri $vmInfo.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy -Tag $vmTags
    
    New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName VM-Snapshots

    if($vmInfo.StorageProfile.DataDisks.Count -ge 1){
        
        for($i=0; $i -le $vmInfo.StorageProfile.DataDisks.Count - 1; $i++){
            
            $snapshotName = "Snapshot_VM_" + $vmInfo.StorageProfile.DataDisks[$i].Name + "_at_" + $timestamp

            
            $snapshot = New-AzSnapshotConfig -SourceUri $vmInfo.StorageProfile.DataDisks[$i].ManagedDisk.Id -Location $location -CreateOption copy -Tag $vmTags

            
            New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName VM-Snapshots
        }
    }
    else{
        $vmInfoName = $vmInfo.Name
        Write-Output "$vmInfoName doesn't have any additional data disk."
    }
}