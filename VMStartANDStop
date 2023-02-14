    $VmName = ""
    $ResourceGroupName = ""
    $VmAction = "Start"

    # Being able to run it through Azure Automation.
    $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection"
        $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint > $null
    } catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }

    # Start 
    if ($VmAction -eq "Start") {
        # If input is wildcard, then start all virtual machines within resource group
        if($VmName -eq "*") {
            $vms = Get-AzureRmVM -ResourceGroupName $ResourceGroupName | Select Name
            Foreach ( $vm in $vms )
            {
                Write-Output ("🔌 Starting $($vm.Name) on resource group $($ResourceGroupName)...")
                Start-AzureRmVM -Name $vm.Name -ResourceGroupName $ResourceGroupName > $null
                $state = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -Status > $null

                if($state.Statuses[1].Code -eq "PowerState/running")
                {
                    Write-Output ("✔️ Successfully started $($vm.Name), it is now running.")
                } else {
                    Write-Output ("❌ Unable to start $($vm.Name), current status: $($state.Statuses[1].Code).")
                } 
            }
        } else {
        # If not, just start the specific one
            Write-Output ("🔌 Starting $($VmName) on resource group $($ResourceGroupName)...")
            Start-AzureRmVM -Name $VmName -ResourceGroupName $ResourceGroupName
            $state = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status > $null

            if($state.Statuses[1].Code -eq "PowerState/running")
            {
                Write-Output ("✔️ Successfully started $($VmName), it is now running.")
            } else {
                Write-Output ("❌ Unable to start $($VmName), current status: $($state.Statuses[1].Code).")
            }
        }
    }
 
    # Stop
    if ($VmAction -eq "Stop") {
        # If input is wildcard, then stop all virtual machines within resource group
        if($VmName -eq "*") {
            $vms = Get-AzureRmVM -ResourceGroupName $ResourceGroupName | Select Name
            Foreach ( $vm in $vms )
            {
                Write-Output ("🔌 Stopping $($vm.Name) on resource group $($ResourceGroupName)...")
                Stop-AzureRmVM -Name $vm.Name -ResourceGroupName $ResourceGroupName -Force
                $state = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -Status > $null

                if($state.Statuses[1].Code -eq "PowerState/deallocated")
                {
                    Write-Output ("✔️ Successfully stopped $($vm.Name), it is now deallocated.")
                } else {
                    Write-Output ("❌ Unable to stop $($vm.Name), current status: $($state.Statuses[1].Code).")
                } 
            }
        } else {
        # If not, just stop the specific one
            Write-Output ("🔌 Stopping $($VmName) on resource group $($ResourceGroupName)...")
            Stop-AzureRmVM -Name $VmName -ResourceGroupName $ResourceGroupName -Force
            $state = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status > $null

            if($state.Statuses[1].Code -eq "PowerState/deallocated")
            {
                Write-Output ("✔️ Successfully stopped $($VmName), it is now deallocated.")
            } else {
                Write-Output ("❌ Unable to stop $($VmName), current status: $($state.Statuses[1].Code).")
            }
        }
    }
