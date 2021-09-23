[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [version]$Version
)

task Clean {
    Write-Build Yellow "Cleaning \bin directory"
    Remove-Item -Path ".\Bin" -Recurse -Force -ErrorAction SilentlyContinue
}

task TestCode {
    Write-Build Yellow "Testing Pester test(s)"
    $PesterConfiguration = New-PesterConfiguration -Hashtable @{
        Run = @{
            Path = "$BuildRoot\test\*tests.ps1"
        }
        Output = @{
            Verbosity = 'Detailed'
        }
        Filter = @{
            Tag = 'Unit'
        }
        Should = @{
            ErrorAction = 'Stop'
        }
        TestResult = @{
            Enabled = $true
            OutputFormat = 'NUnitXml'
        }
    }

    Invoke-Pester -Configuration $PesterConfiguration
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

task . Clean, BuildModule, TestCode

