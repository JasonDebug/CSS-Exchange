#https://github.com/dpaulson45/PublicPowerShellScripts/blob/master/Functions/ComputerInformation/Get-ServerType/Get-ServerType.ps1
#v21.01.08.2133
Function Get-ServerType {
    [CmdletBinding()]
    [OutputType("System.String")]
    param(
        [Parameter(Mandatory = $true)][string]$ServerType
    )
    #Function Version #v21.01.08.2133

    Write-VerboseWriter("Calling: Get-ServerType")
    $returnServerType = [string]::Empty
    if ($ServerType -like "VMware*") { $returnServerType = "VMware" }
    elseif ($ServerType -like "*Microsoft Corporation*") { $returnServerType = "HyperV" }
    elseif ($ServerType.Length -gt 0) { $returnServerType = "Physical" }
    else { $returnServerType = "Unknown" }

    Write-VerboseWriter("Returning: {0}" -f $returnServerType)
    return $returnServerType
}
