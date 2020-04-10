#Requires -RunAsAdministrator
function Start
{
<#
    .SYNOPSIS
        Entry point for the process
    .DESCRIPTION
        This function is used to create and start a Sandbox instance running
        Fold@Home.
    .PARAMETER username
        Optional username for the Fold@Home user.
    .EXAMPLE
        C:\> Create -username 'wsandbox_anon' -team '251561';
#>    
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$false)][string]$username='wsandbox_anon',
        [Parameter(Mandatory=$false)][string]$team='251561'
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
        
        Write-Output 'Setup configuration...';
        GetFAH;
        CreateFAHConf -username $username -team $team;
        CreateLogonScript;
        $config = "$env:USERPROFILE\fah_conf\fah_sandbox.wsb";
        Write-Verbose "Start-Process 'C:\WINDOWS\system32\WindowsSandbox.exe' -ArgumentList '$config';";
        $proc = Start-Process 'C:\WINDOWS\system32\WindowsSandbox.exe' -ArgumentList $config;
        do 
        {
            start-sleep -Milliseconds 500;
        }
        until ($proc.HasExited);
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message;
        Write-Error $ErrorMessage;
    }
}