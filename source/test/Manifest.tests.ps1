BeforeAll {
    $ModulePath = "$PSScriptRoot\..\src\"
    # Remove trailing slash or backslash
    $ModulePath = $ModulePath -replace '[\\/]*$'
    $ModuleName = (Get-Item "$ModulePath\..").Name
    $ModuleManifestName = $ModuleName + '.psd1'
    $ModuleManifestPath = Join-Path -Path $ModulePath -ChildPath $ModuleManifestName
    $ManifestData = Test-ModuleManifest -Path $ModuleManifestPath -Verbose:$false -ErrorAction Stop -WarningAction SilentlyContinue
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
            {[guid]::Parse($manifestData.Guid)} | Should -Not -Throw
        }

        It 'Has a valid copyright' {
            $manifestData.CopyRight | Should -Not -BeNullOrEmpty
        }
    }
}
AfterAll {
    Get-Module -Name $ModuleName | Remove-Module -Force
}