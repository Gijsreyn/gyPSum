[CmdletBinding()]
Param(
    # Bootstrap dependencies
    [switch]$Bootstrap
)

$ErrorActionPreference = 'Stop'

# Bootstrap dependencies
if ($Bootstrap.IsPresent) {
    Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    if (-not (Get-Module -Name PSDepend -ListAvailable)) {
        Install-module -Name PSDepend -Repository PSGallery
    }
    Import-Module -Name PSDepend -Verbose:$false
    Invoke-PSDepend -Path './requirements.psd1' -Install -Import -Force -WarningAction SilentlyContinue
}