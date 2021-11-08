[CmdletBinding()]
Param (
    [Parameter()]
    [version]$Version,
    [Parameter()]
    [string]$DocsPath = "$BuildRoot\Docs"
)


task Clean {
    Write-Build Yellow "Cleaning \bin directory"
    Remove-Item -Path ".\Bin" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Build Yellow "Cleaning \Docs directory"
    Remove-Item -Path ".\Docs" -Recurse -Force -ErrorAction SilentlyContinue
}

task Version {
    if (-not $Version) {
        Write-Build Yellow "Getting version number from changelog"
        ($Script:Version = switch -Regex -File 'CHANGELOG.md' {
                '##\s+[[](\d+\.\d+\.\d+)[]]' {
                    $Matches[1];
                    break
                }
            })

        assert $Script:Version
        Write-Build Yellow "Using build version from CHANGELOG.md: $Version"
    }
}

task TestCode {
    Write-Build Yellow "Executing Pester tests"
    $CodeCoverage = 'src\Public', 'src\Private'
    $Configuration = New-PesterConfiguration
    $Configuration.Run.Path = "Test\*.tests.ps1"
    $Configuration.Output.Verbosity = 'Detailed'
    $Configuration.Filter.Tag = 'Unit'
    $Configuration.Should.ErrorAction = 'Stop'
    $Configuration.TestResult.Enabled = $true
    $Configuration.TestResult.OutputFormat = 'NunitXml'
    $Configuration.CodeCoverage.Enabled = $true
    $Configuration.CodeCoverage.Path = $CodeCoverage
    $Configuration.CodeCoverage.OutputFormat = 'JaCoCo'
    $TestResult = Invoke-Pester -Configuration $Configuration
    if ($TestResult.FailedCount -gt 0) {
        Throw "One or more Pester tests failed."
    }
}

task BuildModule {
    $ModuleName = (Get-Item -Path $BuildRoot | Select-Object -ExpandProperty Name)
    Write-Build Yellow "Building module: $ModuleName"
    Write-Build Yellow "Version number: $Version"
    $BuildParams = @{}
    $BuildParams['Version'] = $Version
    Push-Location -Path "$BuildRoot\src" -StackName 'InvokeBuildTask'
    $Script:CompileResult = Build-Module @BuildParams -Passthru
    Get-ChildItem -Path "$BuildRoot\license*" | Copy-Item -Destination $Script:CompileResult.ModuleBase
    Pop-Location -StackName 'InvokeBuildTask'
}

task BuildPackage {
    if (-not (Get-Command -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Build Yellow "Installing Nuget in tools directory"
        $Source = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
        $Target = "$BuildRoot\tools\nuget.exe"
        # Extra for tls
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest $Source -OutFile (New-Item -Path $Target -Force)
        Set-Alias nuget $Target -Scope Global -Verbose
    }

    Write-Build Yellow "Creating manifest file"
    $Manifest = @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
    <metadata>
        <id>MyModule</id>
        <version>$Version</version>
        <authors>Gijs Reijn</authors>
        <description>MyModule module</description>
        <tags>Powershell</tags>
    </metadata>
</package>
"@
    Set-Content "$($Script:CompileResult.ModuleBase)\Package.nuspec" -Value $Manifest

    Write-Build Yellow "Pushing location to: $($Script:CompileResult.ModuleBase)"
    Push-Location -Path $Script:CompileResult.ModuleBase -StackName 'InvokePackageTask'

    # Package
    Write-Build Yellow "Building package in directory: $($Script:CompileResult.ModuleBase)\Package"
    exec {
        nuget pack Package.nuspec -NoDefaultExcludes -NoPackageAnalysis -OutputDirectory 'Package'
    }
    Pop-Location -StackName 'InvokePackageTask'
}

task MakeHelp {

    $ModuleInfo = Import-Module "$($Script:CompileResult.ModuleBase)/*.psd1" -Global -Force -PassThru

    try {
        if ($ModuleInfo.ExportedCommands.Count -eq 0) {
            Write-Warning 'No commands have been exported. Skipping markdown generation.'
            return
        }

        if (-not (Test-Path -LiteralPath $Script:DocsPath)) {
            New-Item -Path $Script:DocsPath -ItemType Directory | Out-Null
        }

        if (Get-ChildItem $DocsPath -Filter *.md -Recurse) {
            Get-ChildItem $DocsPath -Directory | ForEach-Object {
                Update-MarkdownHelp -Path $_.FullName > $null
            }
        }

        # ErrorAction set to SilentlyContinue so this command will not overwrite an existing MD file.
        $Locale = 'en-us'
        $NewMDParams = @{
            Module       = $ModuleInfo.Name
            Locale       = $Locale
            OutputFolder = [IO.Path]::Combine($DocsPath, $Locale)
            ErrorAction  = 'SilentlyContinue'
            Verbose      = $false
        }
        New-MarkdownHelp @newMDParams > $null

        # Copy it to the source directory
        Copy-Item -Path ([IO.Path]::Combine($DocsPath, $Locale)) -Destination $Script:CompileResult.ModuleBase -Recurse
    } finally {
        Remove-Module $ModuleInfo.Name
    }
}

task . Clean, Version, BuildModule, TestCode, MakeHelp, BuildPackage


