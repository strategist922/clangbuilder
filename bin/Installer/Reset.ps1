<####################################################################################################################
# ClangSetup Environment Reset Feature
#
#
####################################################################################################################>
IF($PSVersionTable.PSVersion.Major -lt 3)
{
    Write-Error "Visual Studio Enviroment vNext Must Run on Windows PowerShell 3 or Later,`nYour PowerShell version Is :
    ${Host}"
    [System.Console]::ReadKey()
    return
}

Invoke-Expression "$PSScriptRoot\Update.ps1"
Invoke-Expression "$PSScriptRoot\Install.ps1 -Reset"
