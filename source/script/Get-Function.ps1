Function Get-Function {
    <#
    .SYNOPSIS
        Get function

    .DESCRIPTION
        The function Get-Function gets a function

    .PARAMETER String
        Provide a string value

    .EXAMPLE
        PS C:\> Get-Function

        Gets a function

    .NOTES
        Author: <%=$PLASTER_PARAM_ModuleName%>
    #>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [string]$String = 'Function'
    )

    Process {
        Write-Output "This is a get $String"
    }
}
