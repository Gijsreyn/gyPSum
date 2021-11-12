BeforeDiscovery {
    # Script analyzer settings
    $AnalyzerRootPath = "$PSScriptRoot\.."
    $AnalyzerFile = "ScriptAnalyzerSettings.psd1"
    $AnalyzerFilePath = Join-Path -Path $AnalyzerRootPath -ChildPath $AnalyzerFile
    Write-Verbose "Analyzer file path: $AnalyzerFilePath"
    $Rules = (Import-PowerShellDataFile $AnalyzerFilePath).IncludeRules
}

Describe "<rule>" -Tag "Unit" -ForEach $Rules {
    BeforeAll {
        # Renaming the variable
        $Rule = $_

        # Retrieve the module manifest path this happens double at the moment don't know how to do it better
        $ModulePath = "$PSScriptRoot\..\bin\"
        $ModuleManifestPath = (Get-ChildItem $ModulePath -Recurse -Filter *.psm1).FullName
    }
    It "Should Pass Script Analyzer Rule: <rule>" {
        (Invoke-ScriptAnalyzer -Path $ModuleManifestPath -IncludeRule $Rule).Count | Should -Be 0
    }
}
