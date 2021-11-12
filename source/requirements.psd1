@{
    PSDependOptions  = @{
        Target = 'CurrentUser'
    }

    ModuleBuilder    = '2.0.0'
    Pester           = @{
        MinimumVersion = '5.3.0'
        Parameters     = @{
            SkipPublisherCheck = $true
        }
    }
    PSScriptAnalyzer = '1.19.0'
    InvokeBuild      = '5.6.0'
    platyPS          = '0.14.1'
}
