#Requires -RunAsAdministrator
function Start
{
<#
    .SYNOPSIS
        Entry point for the process
    .DESCRIPTION
        This function is used to create and start a Minecraft server instance.
#>    
    [cmdletbinding()]
    param(
    )
    try
    {
        Write-Verbose 'Start process';
        $ProgressPreference = 'SilentlyContinue'; #Progress bar makes things way slower
        Write-Output 'Verify host system...';
        $bios = VerifyBios;
        if (-not $bios -or $bios -eq $false)
        {
            throw 'ERROR: Please Enable Virtualization capabilities in your BIOS settings...';
        }
    
        $sandbox = VerifySandbox;
        if (-not $sandbox -or $sandbox -eq $false)
        {
            throw 'Please reboot to finish installing Windows Sandbox, then re-run this script...';
        }
        
        Write-Output 'Download minecraft server...';
        $installer_fullname = GetMineCraft;
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message;
        Write-Error $ErrorMessage;
    }
}