$dotnetVersion = Read-Host "Please enter .NET version"
$coreVersion = Read-Host "Please enter Core version"

if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
    Write-Output "Installing chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } catch {
        Write-Output "Error: $_.Exception.Message"
    }
} else {
    Write-Output "Chocolatey is already installed."
}

$features = 'IIS-WebServerRole', 'IIS-WebServer', 'IIS-CommonHttpFeatures', 'IIS-HttpErrors', 'IIS-HttpRedirect', 'IIS-ApplicationDevelopment', 'IIS-Security', 'IIS-RequestFiltering', 'IIS-NetFxExtensibility', 'IIS-NetFxExtensibility45', 'IIS-HealthAndDiagnostics', 'IIS-HttpLogging', 'IIS-LoggingLibraries', 'IIS-HttpTracing', 'IIS-Performance', 'IIS-WebServerManagementTools', 'IIS-ManagementScriptingTools', 'IIS-IIS6ManagementCompatibility', 'IIS-Metabase', 'IIS-StaticContent', 'IIS-DirectoryBrowsing', 'IIS-WebSockets', 'IIS-ApplicationInit', 'IIS-ISAPIExtensions', 'IIS-ISAPIFilter', 'IIS-CustomLogging', 'IIS-HttpCompressionStatic', 'IIS-ManagementConsole', 'IIS-ManagementService', 'IIS-WMICompatibility', 'IIS-LegacyScripts', 'IIS-ASPNET', 'IIS-ASP', 'IIS-ASPNET45'

foreach ($feature in $features) {
    Enable-WindowsOptionalFeature -Online -FeatureName $feature -All
}

choco install dotnet-$dotnetVersion-sdk -y
choco install dotnet-$dotnetVersion-windowshosting -y
choco install dotnet-$dotnetVersion-aspnetruntime -y
choco install dotnetcore --version=$coreVersion -y
choco install dotnetcore-windowshosting --version=$coreVersion -y
choco install dotnetcore-sdk -y
