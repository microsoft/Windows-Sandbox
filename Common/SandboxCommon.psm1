#Fill in the directories included as part of the common module here
[String[]]$ModuleDirs = @('Sandbox_Setup')

$ChildModules  = $ModuleDirs | ForEach-Object {@( Get-ChildItem -Path $PSScriptRoot\..\Common\$_\*.ps1 )}

ForEach($Module in $ChildModules){
    Try {
        . $Module.fullname
    } Catch {
        Write-Error -Message "Failed to import function $($Module.fullname): $_"
    }
}

function VerifySetup {
    <#
    .SYNOPSIS
        Executes the VerifySandbox & VerifyBios modules
    .DESCRIPTION
        Runs all necessary checks for Sandbox to run
    .EXAMPLE
        C:\> VerifySetup;
    #>      

    Write-Output 'Verifying host system...';
    $bios = VerifyBios;
    if (-not $bios -or $bios -eq $false) {
        throw 'ERROR: Please Enable Virtualization capabilities in your BIOS settings...';
    }

    $sandbox = VerifySandbox;
    if (-not $sandbox -or $sandbox -eq $false) {
        throw 'Please reboot to finish installing Windows Sandbox, then re-run this script...';
    }

    Write-Output "Windows Sandbox and Virtualization are both enabled on this system."
}
Export-ModuleMember -Function VerifySetup