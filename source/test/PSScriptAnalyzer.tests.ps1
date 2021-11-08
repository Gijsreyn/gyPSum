BeforeAll {
    $ModulePath = "$PSCommandPath\..\src\"
    # Remove trailing slash or backslash
    $ModulePath = $ModulePath -replace '[\\/]*$'
    $ModuleName = (Get-Item "$ModulePath\..").Name
    $ModuleManifestName = $ModuleName + '.psd1'
    $ModuleManifestPath = Join-Path -Path $ModulePath -ChildPath $ModuleManifestName

    # Script analyzer settings
    $AnalyzerRootPath = "$PSScriptRoot\.."
    $AnalyzerFile = "ScriptAnalyzerSettings.psd1"
    $AnalyzerFilePath = Join-Path -Path $AnalyzerRootPath -ChildPath $AnalyzerFile
    $Rules = Import-PowerShellDataFile $AnalyzerFilePath
}

Describe "Test2" -Tag "Unit" -ForEach $Rules {

}

Describe "Test" -Tag "Unit" {
    Context "Testing against Script Analyzer Rules" -Tag "Unit" {
        foreach ($Rule in $Rules.IncludeRules) {
            Write-Verbose "Rule name: $Rule"

            It "Should Pass Script Analyzer Rule: $Rule" {
                (Invoke-ScriptAnalyzer -Path $ModuleManifestPath -IncludeRule $Rules.IncludeRules).Count | Should -Be 0
            }
        }
    }
}

# Describe "Powershell Script Analyzer Test" -Tag "Unit" {
#     BeforeAll {
#         $ModulePath = "$PSCommandPath\..\src\"
#         # Remove trailing slash or backslash
#         $ModulePath = $ModulePath -replace '[\\/]*$'
#         $ModuleName = (Get-Item "$ModulePath\..").Name
#         $ModuleManifestName = $ModuleName + '.psd1'
#         $ModuleManifestPath = Join-Path -Path $ModulePath -ChildPath $ModuleManifestName

#         # Script analyzer settings
#         $AnalyzerRootPath = "$PSCommandPath\.."
#         $AnalyzerFile = "ScriptAnalyzerSettings.psd1"
#         $AnalyzerFilePath = Join-Path -Path $AnalyzerRootPath -ChildPath $AnalyzerFile
#         $Rules = Get-ScriptAnalyzerRule -CustomRulePath $AnalyzerFilePath
#     }

#     Context "Testing against Script Analyzer Rules" -Tag "Unit" {
#         # Script analyzer settings
#         $AnalyzerRootPath = "$PSCommandPath\.."
#         $AnalyzerFile = "ScriptAnalyzerSettings.psd1"
#         $AnalyzerFilePath = Join-Path -Path $AnalyzerRootPath -ChildPath $AnalyzerFile
#         $Rules = Get-ScriptAnalyzerRule -CustomRulePath $AnalyzerFilePath
#         foreach ($Rule in $Rules) {
#             Write-Verbose "Rule name: $Rule"

#             It "Should Pass Script Analyzer Rule: $Rule" {
#                 (Invoke-ScriptAnalyzer -Path $ModuleManifestPath -IncludeRule $Rule.RuleName) | Should -BeNullOrEmpty
#             }
#         }
#     }
# }

# Describe "PSScriptAnalyzer analysis" -Tag "Unit" {
#     BeforeAll {
#         $ModulePath = "$PSScriptRoot\..\src\"
#         # Remove trailing slash or backslash
#         $ModulePath = $ModulePath -replace '[\\/]*$'
#         $ModuleName = (Get-Item "$ModulePath\..").Name
#         $ModuleManifestName = $ModuleName + '.psd1'
#         $ModuleManifestPath = Join-Path -Path $ModulePath -ChildPath $ModuleManifestName

#         # Get module commands
#         # Remove all versions of the module from the session. Pester can't handle multiple versions.
#         Get-Module $ModuleName | Remove-Module -Force -ErrorAction Ignore
#         Import-Module -Name $ModuleManifestPath -Verbose:$false -ErrorAction Stop
#     }
#     Context "PSScriptAnalyzer unit test" -Tag "Unit" {
#         It "Should not violate any rule" {
#             $ScriptAnalyzerRules = Get-ScriptAnalyzerRule

#             foreach ($Rule in $ScriptAnalyzerRules) {
#                 Invoke-ScriptAnalyzer -Path $ModuleManifestPath -IncludeRule $Rule.RuleName | Should -BeNullOrEmpty
#             }
#         }
#     }
# }

# BeforeDiscovery {
#     $files = Get-ChildItem "../src/*.ps1" -Recurse
# }

# Describe "<file>" -ForEach $files {
#     BeforeAll {
#         # Renaming the automatic $_ variable to $file
#         # to make it easier to work with
#         $file = $_
#     }
#     It "<file> - has help" {
#         $content = Get-Content $file
#         # ...
#     }
# }
