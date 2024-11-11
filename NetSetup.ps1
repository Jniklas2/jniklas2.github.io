$Interface = Get-NetAdapter -InterfaceDescription "*Red Hat*" | Where-Object { $_.Status -eq "Up" }
$AddrConf = Get-NetIPAddress -InterfaceAlias $Interface.Name -AddressFamily IPv4
$DnsConf = Get-DnsClientServerAddress -InterfaceAlias $Interface.Name -AddressFamily IPv4

If ($AddrConf.IPAddress -eq "") {
    $IP = Read-Host -Prompt "Enter IP Adress"
    $Subnet = 24
    $Gateway = $IP.TrimEnd($IP.Split(".")[-1]) + "1"
    New-NetIPAddress -InterfaceAlias $Interface.Name -IPAddress $IP -PrefixLength $Subnet -DefaultGateway $Gateway
    $DoneSth = $true
}
If ($DnsConf.ServerAddresses -eq "") {
    Set-DnsClientServerAddress -InterfaceAlias $Interface.Name -ServerAddresses ("8.8.8.8", "1.1.1.1")
    $DoneSth = $true
}
If ($DoneSth) {
    Write-Host "Configuration done"
} else {
    Write-Host "Something doesn't work"
    Write-Host "Doing Connectivity Test"
    $ConTestHTTP = (Test-NetConnection -ComputerName zap-hosting.com -CommonTCPPort HTTP)
    if ($ConTestHTTP.TcpTestSucceeded) {
        Write-Host "HTTP Test Succeeded"
    } else {
        Write-Host "HTTP Test Failed"
    }
    $ConTestPing = (Test-NetConnection -ComputerName 1.1.1.1)
    if ($ConTestPing.PingSucceeded) {
        Write-Host "Ping Test Succeeded"
    } else {
        Write-Host "Ping Test Failed"
    }
    if ($ConTestHTTP.TcpTestSucceeded -and $ConTestPing.PingSucceeded) {
        Write-Host "Connectivity Test Succeeded"
    } else {
        Write-Host "Something is fucked up"
        Write-Host "Current Config:"
        Write-Host "IP: " $AddrConf.Address
        Write-Host "Prefix Length: " $AddrConf.PrefixLength
        Write-Host "Gateway: " $Interface.
    }
}

if (Resolve-DnsName -Name google.com -NoHostsFile -DnsOnly) {
    Write-Host "It works now :)"
}