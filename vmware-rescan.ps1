# List of ESXi Hosts
#$ESXiHosts = @("10.20.4.11", "10.20.4.13", "10.20.4.14", "10.20.4.15", "10.20.4.16", "10.20.4.17", "10.20.4.18")

$ESXiHosts = @("10.30.3.11", "10.30.3.12", "10.30.3.13", "10.30.3.14", "10.30.3.15", "10.30.3.16", "10.30.3.17")
$Username = "root" # ESXi username

# Prompt for password securely
$SecurePassword = Read-Host -Prompt "Enter Password for $Username" -AsSecureString
$Credential = New-Object -TypeName PSCredential -ArgumentList $Username, $SecurePassword

foreach ($ESXiHost in $ESXiHosts) {
    Write-Host "Connecting to ESXi Host: $ESXiHost" -ForegroundColor Green
    try {
        # Connect to the ESXi host
        $esxConnection = Connect-VIServer -Server $ESXiHost -Credential $Credential -ErrorAction Stop
        Write-Host "Connected successfully to ESXi Host: $ESXiHost" -ForegroundColor Cyan

        # Retrieve the EsxCli object
        $EsxCli = Get-EsxCli -Server $esxConnection -V2 -ErrorAction Stop

        # Perform the storage adapter rescan
        Write-Host "Running rescan: esxcli storage core adapter rescan --all" -ForegroundColor Yellow
        $EsxCli.storage.core.adapter.rescan.Invoke(@{ all = $true })

        Write-Host "Rescan completed on ESXi Host: $ESXiHost" -ForegroundColor Cyan

        # Disconnect from the ESXi host
        Disconnect-VIServer -Server $esxConnection -Confirm:$false
    } catch {
        Write-Host "Failed to connect or rescan on ESXi Host: $ESXiHost. Error: $_" -ForegroundColor Red
    }
}
