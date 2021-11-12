Param (
    [Parameter(Mandatory)]
    [string]$ModuleName
)

BeforeAll {
    $ModulePath = "$PSScriptRoot\..\src\"
    # Remove trailing slash or backslash
    $ModulePath = $ModulePath -replace '[\\/]*$'
    $ModuleManifestName = $ModuleName + '.psd1'
    $ModuleManifestPath = Join-Path -Path $ModulePath -ChildPath $ModuleManifestName
    $ManifestData = Test-ModuleManifest -Path $ModuleManifestPath -Verbose:$false -ErrorAction Stop -WarningAction SilentlyContinue

    # Get module commands
    # Remove all versions of the module from the session. Pester can't handle multiple versions.
    Get-Module $ModuleName | Remove-Module -Force -ErrorAction Ignore
    Import-Module -Name $ModuleManifestPath -Verbose:$false -ErrorAction Stop
}

AfterAll {
    Get-Module -Name $ModuleName | Remove-Module -Force
}

Describe 'Module manifest' -Tag 'Unit' {
    Context 'Validation' {
        It 'Has a valid manifest' {
            $manifestData | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid version in the manifest' {
            $manifestData.Version -as [Version] | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid description' {
            $manifestData.Description | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid author' {
            $manifestData.Author | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid guid' {
            { [guid]::Parse($manifestData.Guid) } | Should -Not -Throw
        }

        It 'Has a valid copyright' {
            $manifestData.CopyRight | Should -Not -BeNullOrEmpty
        }
    }
}
