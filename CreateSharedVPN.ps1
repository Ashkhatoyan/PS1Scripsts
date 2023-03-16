# Define the path to the XML file containing the VPN profile configuration
$profilePath = 'your profileconfig path'

# Load the XML file and extract the VPN profile settings
$vpnProfile = [xml] (Get-Content $profilePath)
$vpnName = $vpnProfile.VPNProfile.VPNName
$vpnServer = $vpnProfile.VPNProfile.ServerAddress
$vpnUser = Read-Host UserName
$vpnPass = Read-Host Password -AsSecureString

# Define the path where the VPN profile will be saved
$profileSavePath = "C:\ProgramData\Microsoft\Network\Connections\Pbk\rasphone.pbk"

# Create a new VPN connection object
$vpn = New-Object -ComObject "RASDIALLib.RASDialer"
$vpn.EntryName = $vpnName
$vpn.PhoneNumber = $vpnServer
$vpn.AllowUseStoredCredentials = $true
$vpn.PhonebookPath = $profileSavePath

# Save the VPN profile to the system's VPN profile directory
$vpnCredentials = New-Object -ComObject "RASDIALLib.RASDialCredentials"
$vpnCredentials.UserName = $vpnUser
$vpnCredentials.Password = $vpnPass
$vpn.UpdateCredentials($vpnCredentials)
$vpn.EntryType = 1
$vpn.EntryId = "{0:B}" -f [guid]::NewGuid()
$vpn.Save()

# Grant access to the VPN connection to all users of the machine
$secDescriptor = $vpn.GetSecurityDescriptor()
$users = [System.Security.Principal.NTAccount]::new("Users")
$ace = [System.Security.AccessControl.CommonAce]::new([System.Security.AccessControl.AceFlags]::None, [System.Security.AccessControl.AceQualifier]::AccessDenied, [System.Security.AccessControl.FileSystemRights]::FullControl, $users, $false, $null)
$secDescriptor.DiscretionaryAcl.AddAccess($ace)
$vpn.SetSecurityDescriptor($secDescriptor)

# Set the VPN connection to be available to all users of the machine
$vpnConnection = Get-WmiObject -Namespace "root\cimv2\ms_409" -Class "Win32_NetworkAdapterConfiguration" | Where-Object { $_.ServiceName -eq "RasMan" }
$vpnConnection.EnableStatic($vpnServer, "255.255.255.255")
$vpnConnection.SetGateways(@($vpnServer), 1)
$vpnConnection.SetDNSServerSearchOrder(@($vpnServer))
$vpnConnection.SetIPConnectionMetric(1)
$vpnConnection.SetTcpipNetbios(2)
