<#############################################################################
#  RestoreClangReleased.ps1
#  Note: Clang Auto Build Environment
#  Date:2016.01.02
#  Author:Force <forcemz@outlook.com>
##############################################################################>
param(
    [Switch]$LLDB
)

. "$PSScriptRoot\RepositoryCheckout.ps1"
$ClangbuilderRoot=Split-Path -Parent $PSScriptRoot
$BuildFolder="$ClangbuilderRoot\out"
$ReleaseRevFolder="$BuildFolder\release"
if($LLDB){
    Write-Host "Include build lldb"
}
Write-Host "Release Folder: $ReleaseRevFolder"
$LLVMRepositoriesRoot="http://llvm.org/svn/llvm-project"
$ReleaseRevision="RELEASE_381/final"
$LLVMUrlParent=$LLVMRepositoriesRoot+"/llvm/tags/"+$ReleaseRevision
$Revision=380
$RequireRemove=$FALSE

IF(!(Test-Path $BuildFolder)){
    mkdir -Force $BuildFolder
}

IF(Test-Path "$BuildFolder\release"){
    $cacheUrl=svn info --show-item url "$BuildFolder\release"
    #URL: http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_X/X
    if($cacheUrl -ne $LLVMUrlParent){
      Write-Output "Checkouted URL: `n  $cacheUrl not equal `nNew URL: `n  $LLVMUrlParent`nRequire remove old llvm checkout file !"
      $RequireRemove=$TRUE   
    }
}


Push-Location $PWD
Set-Location $BuildFolder
IF((Test-Path "$BuildFolder\release") -and $RequireRemove){
    Remove-Item -Force -Recurse "$BuildFolder\release"
}
Restore-Repository -URL "$LLVMRepositoriesRoot/llvm/tags/$ReleaseRevision" -Folder "release"
if(!(Test-Path "$BuildFolder\release\tools")){
    Write-Output "Checkout LLVM Failed"
    Exit
}

Set-Location "$BuildFolder\release\tools"
Restore-Repository -URL "$LLVMRepositoriesRoot/cfe/tags/$ReleaseRevision" -Folder "clang"
Restore-Repository -URL "$LLVMRepositoriesRoot/lld/tags/$ReleaseRevision" -Folder "lld"

IF($LLDB){
    Restore-Repository -URL "$LLVMRepositoriesRoot/lldb/tags/$ReleaseRevision" -Folder "lldb"
}else{
    if(Test-Path "$BuildFolder\release\tools\lldb"){
        Remove-Item -Force -Recurse "$BuildFolder\release\tools\lldb"
    }
}

if(!(Test-Path "$BuildFolder/release/tools/clang/tools")){
    Write-Output "Checkout Clang Failed"
    Exit
}

Set-Location "$BuildFolder/release/tools/clang/tools"
Restore-Repository -URL "$LLVMRepositoriesRoot/clang-tools-extra/tags/$ReleaseRevision" -Folder "extra"
Set-Location "$BuildFolder/release/projects"
Restore-Repository -URL "$LLVMRepositoriesRoot/compiler-rt/tags/$ReleaseRevision" -Folder "compiler-rt"

Pop-Location
